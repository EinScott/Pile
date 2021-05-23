using System;
using System.Collections;
using System.Text;

namespace Pile
{
	class SpriteFont
	{
		public class Character
		{
			public readonly Subtexture Image ~ delete _;
			public readonly Vector2 Offset;
			public readonly float Advance;

			public readonly Dictionary<char32, float> Kerning = new Dictionary<char32, float>() ~ delete _;

			public this(Subtexture image, Vector2 offset, float advance)
			{
				Image = image;
				Offset = offset;
				Advance = advance;
			}
		}

		public readonly Dictionary<char32, Character> Charset = new Dictionary<char32, Character>() ~ DeleteDictionaryAndValues!(_);

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
			for (let ch in fontSize.Charset.Values)
			{
				name.Append(ch.Unicode);

				// Pack bitmap
				bool hasImage;
				if ((hasImage = fontSize.Render(ch.Unicode, buffer, true)))
					packer.AddBitmap(name, buffer);

				// Create character
				let sprChar = new Character(hasImage ? new Subtexture() : null, Vector2(ch.OffsetX, ch.OffsetY), ch.Advance);
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
			    var texture = new Texture(output.Pages[i], filter, genMipmaps);
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
				char32 char = ?;
				if (!UTF8.DecodeAt(text, ref i, ref char))
					continue;

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
	}
}
