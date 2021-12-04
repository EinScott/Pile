using System;
using System.Collections;
using System.Text;

namespace Pile
{
	class SpriteFont
	{
		public struct Character : IDisposable
		{
			public readonly Subtexture Image;
			public readonly Vector2 Offset;
			public readonly float Advance;

			public readonly Dictionary<char32, float> Kerning = new Dictionary<char32, float>();

			public this(Subtexture image, Vector2 offset, float advance)
			{
				Image = image;
				Offset = offset;
				Advance = advance;
			}

			public void Dispose()
			{
				delete Image;
				delete Kerning;
			}
		}

		public readonly Dictionary<char32, Character> Charset ~
			{
				for (let pair in _)
					pair.value.Dispose();

				delete _;
			};

		public String FamilyName = new .() ~ delete _;
		public String StyleName = new .() ~ delete _;

		public readonly uint32 Size;
		public readonly float Ascent;
		public readonly float Descent;
		public readonly float LineGap; // Vertical gap between lines
		public readonly float Height; // Ascent - Descent (font height)
		public readonly float LineHeight; // Ascent + Descent (height of a line, includes line gap)
		
		Texture[] tex ~ DeleteContainerAndItems!(_);

		public this(Font font, uint32 size, Span<char32> charset, TextureFilter filter = Core.Defaults.SpriteFontFilter, bool genMipmaps = Core.Defaults.SpriteFontsGenMipmaps)
			: this(scope FontSize(font, size, charset), filter, genMipmaps) {}

		public this(FontSize fontSize, TextureFilter filter = Core.Defaults.SpriteFontFilter, bool genMipmaps = Core.Defaults.SpriteFontsGenMipmaps)
		{
			FamilyName.Set(fontSize.Font.FamilyName);
			StyleName.Set(fontSize.Font.StyleName);
			Size = fontSize.Size;
			Ascent = fontSize.Ascent;
			Descent = fontSize.Descent;
			LineGap = fontSize.LineGap;
			Height = fontSize.Height;
			LineHeight = fontSize.LineHeight;

			let packer = new Packer();
			var buffer = new Bitmap(Size * 2, Size * 2);
			let name = scope String(2);

			// Process all chars
			Charset = new Dictionary<char32, Character>((.)fontSize.Charset.Count);
			for (let ch in fontSize.Charset.Values)
			{
				name.Append(ch.Unicode);

				// Pack bitmap
				bool hasImage;
				if ((hasImage = fontSize.Render(ch.Unicode, buffer, true)))
					packer.AddBitmap(name, buffer);

				// Create character
				let sprChar = Character(hasImage ? new Subtexture() : null, Vector2(ch.OffsetX, ch.OffsetY), ch.Advance);
				Charset.Add(ch.Unicode, sprChar);

				// Get kerning
				for (let ch2 in fontSize.Charset.Values)
				{
					let kerning = fontSize.GetKerning(ch.Unicode, ch2.Unicode);
					if (Math.Abs(kerning) > 0.000001f)
					    sprChar.Kerning[ch2.Unicode] = kerning;
				}

				name.Clear();
			}
			delete buffer;

			let res = packer.Pack();
			Runtime.Assert(res case .Ok, "Failed to pack character bitmaps");

			// Link textures
			let output = res.Get();

			tex = new Texture[output.Pages.Count];

			for (int i = 0; i < output.Pages.Count; i++)
			{
			    var texture = new Texture(output.Pages[i].page, filter, genMipmaps);
				tex[i] = texture;

			    for (let entry in output.Entries.Values)
			    {
			        if (entry.Page != i)
			            continue;

					// Get char
					char32 char = ?;

					// Encoded unicode char
					if (UTF8.GetDecodedLength(entry.Name[0]) > 1)
					{
						let ress = UTF8.Decode(entry.Name.Ptr, entry.Name.Length);

						if (ress.c == (char32)-1)
							continue; // Invalid

						char = ress.c;
					}
					else char = entry.Name[0];

					// Update character Subtexture
			        if (Charset.TryGetValue(char, let character))
			            character.Image.Reset(texture, entry.Source, entry.Frame);
			    }
			}

			delete output;
			delete packer;
		}

		public float WidthOf(StringView text)
		{
		    var width = 0f;
		    var line = 0f;

		    for (int i = 0; i < text.Length; i++)
		    {
				// Get char
				let res = text.GetChar32(i);
				if (res.1 == 0) // .1 is length
					continue;
				
				i += (res.1) - 1;
				let char = res.0;

		        if (char == '\n')
		        {
		            if (line > width)
		                width = line;
		            line = 0;
		            continue;
		        }

		        if (!Charset.TryGetValue(char, let ch))
		            continue;

		        line += ch.Advance;
		    }

		    return Math.Max(width, line);
		}

		public float HeightOf(StringView text)
		{
		    if (text.Length <= 0)
		        return 0;

		    var height = Height;

		    for (int i = 0; i < text.Length; i++)
		    {
				let len = UTF8.GetDecodedLength(text[i]);
				if (len > 1)
				{
					i += len - 1;
				}
		        else if (text[i] == '\n')
		            height += LineHeight;
		    }

		    return height;
		}

		public Vector2 SizeOf(StringView text)
		{
		    return Vector2(WidthOf(text), HeightOf(text));
		}

		/// Will return a StringView that is either the full line (end or before first line break) or a sub-string of it that fits the given width
		public StringView SubstringLineByWidth(StringView text, float width, bool trimAtSpace = true)
		{
		    var countWidth = 0f;

		    for (int i = 0; i < text.Length; i++)
		    {
				// Get char
				let res = text.GetChar32(i);
				if (res.1 == 0) // .1 is length
					continue;
				
				i += (res.1) - 1;
				let char = res.0;

		        if (char == '\n')
		        {
					// End of line reached, return it
		            return StringView(text.Ptr, i); // Do not include \n
		        }

		        if (!Charset.TryGetValue(char, let ch))
		            continue;

				if (countWidth + ch.Advance > width)
				{
					// Trim it
					if (trimAtSpace)
					{
						for (int j = i; j >= 0; j--)
							if (text[j].IsWhiteSpace)
								return StringView(text.Ptr, i); // Do not include space
					}

					// As a fallback for when there is no way to trim, or just when we don't trim, simply cut here
					return StringView(text.Ptr, i); // Do not include this character that goes beyond width
				}
		        else countWidth += ch.Advance;
		    }

			// Full text fits (and is one line)
			return text;
		}

		/// Will return a StringView that is either the full line (start or after last line break) or a sub-string of it that fits the given width
		public StringView SubstringLineByWidthFromEnd(StringView text, float width)
		{
		    var countWidth = 0f;

		    for (int i = text.Length - 1; i >= 0; i--)
		    {
				// Get char
				let res = text.GetChar32(i);
				if (res.1 == 0) // in this case, the char is probably part of a larger code point in later / "earlier" chars
					continue;
				
				let char = res.0;

		        if (char == '\n')
		        {
					if (i == text.Length)
						return StringView(&text[i], 0); // String ends with \n...

					// End of prev line reached, return
		            return StringView(&text[i + 1], text.Length - i - 1); // Do not include \n
		        }

		        if (!Charset.TryGetValue(char, let ch))
		            continue;

				if (countWidth + ch.Advance > width)
				{
					if (i == text.Length)
						return StringView(&text[i], 0); // String is instantly too wide

					return StringView(&text[i + 1], text.Length - i - 1); // Do not include this character that goes beyond width
				}
		        else countWidth += ch.Advance;
		    }

			// Full text fits (and is one line)
			return text;
		}

		/// Returns the height of the text when rendered, text will be modified
		public float WrapText(String text, float wrapWidth, String splitStr = "\n")
		{
		    if (text.Length <= 0)
		        return 0;

			float width = 0;
		    var height = Height;

			var lastSplitChar = -1;
			var lastSplitCharLen = 0;
		    for (int i = 0; i < text.Length; i++)
		    {
				// Get char
				let res = text.GetChar32(i);
				if (res.length == 0)
					continue;
				let iStart = i;
				i += res.length - 1;
				let char = res.c;

				if (char == '\n')
				{
					width = 0;
		            height += LineHeight;
				}
				else if (char.IsWhiteSpace)
				{
					lastSplitChar = iStart;
					lastSplitCharLen = i - iStart + 1;
				}

				if (!Charset.TryGetValue(char, let ch))
					continue;

				if (width + ch.Advance > wrapWidth)
				{
					if (splitStr.Length > 0)
					{
						if (lastSplitChar >= 0)
						{
							if (text[lastSplitChar] != '\t')
							{
								// Replace space with split string
								if (lastSplitCharLen > splitStr.Length)
									text.Remove(lastSplitChar + splitStr.Length, lastSplitCharLen - splitStr.Length);
								else if (lastSplitCharLen < splitStr.Length)
									text.Insert((.)lastSplitChar, '?', splitStr.Length - lastSplitCharLen);
								
								for (let j < splitStr.Length)
									text[lastSplitChar + j] = splitStr[j];
								i += splitStr.Length;
							}
							else
							{
								text.Insert(lastSplitChar, splitStr); // Keep tabs
								i += splitStr.Length;
							}
							lastSplitChar = -1;
						}
						else
						{
							text.Insert(i, splitStr); // Hard wrap
							i += splitStr.Length;
						}
					}

					width = 0;
					height += LineHeight;
				}
				else  width += ch.Advance;
		    }

		    return height;
		}
	}
}
