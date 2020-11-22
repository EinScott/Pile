using System;
using System.Collections;

namespace Pile
{
	public class SpriteFont
	{
		public class Character
		{
			public readonly Subtexture Image ~ delete _;
			public readonly Vector2 Offset;
			public readonly float Advance;

			public readonly Dictionary<char16, float> Kerning = new Dictionary<char16, float>() ~ delete _;

			public this(Subtexture image, Vector2 offset, float advance)
			{
				Image = image;
				Offset = offset;
				Advance = advance;
			}
		}

		public readonly Dictionary<char16, Character> Charset = new Dictionary<char16, Character>() ~ DeleteDictionaryAndItems!(_);

		public String FamilyName = new .() ~ delete _;
		public String StyleName = new .() ~ delete _;

		public readonly uint32 Size;
		public readonly float Ascent;
		public readonly float Descent;
		public readonly float LineGap; // Vertical gap between lines
		public readonly float Height; // Ascent - Descent (font height)
		public readonly float LineHeight; // Ascent + Descent (height of a line, includes line gap)
		

		Texture[] tex ~ DeleteContainerAndItems!(_); // temp

		public this(Font font, uint32 size, Span<char16> charset, TextureFilter filter = .Linear)
			: this(scope FontSize(font, size, charset), filter) {}

		public this(FontSize fontSize, TextureFilter filter = .Linear)
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
			var buffer = scope Bitmap(Size * 2, Size * 2);
			let name = scope String(2);

			// Process all chars
			for (let ch in fontSize.Charset.Values)
			{
				name.Append(ch.Unicode);

				// Pack bitmap
				if (fontSize.Render(ch.Unicode, buffer, true))
					packer.AddBitmap(name, buffer);

				// Create character
				let sprChar = new Character(new Subtexture(), Vector2(ch.OffsetX, ch.OffsetY), ch.Advance);
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

			let res = packer.Pack();
			Runtime.Assert(res case .Ok, scope $"Failed to pack character bitmaps");

			// Link textures
			let output = res.Get();

			tex = new Texture[output.Pages.Count];// TEMP

			for (int i = 0; i < output.Pages.Count; i++)
			{
				// todo: integrate with assets

			    var texture = new Texture(output.Pages[i]);
			    texture.Filter = filter;
				tex[i] = texture;

			    for (let entry in output.Entries.Values)
			    {
			        if (entry.Page != i)
			            continue;

			        if (Charset.TryGetValue(entry.Name[0], let character))
			            character.Image.Reset(texture, entry.Source, entry.Frame);
			    }

			}

			delete output;
			delete packer;
		}

		public float WidthOf(Span<char16> text)
		{
		    var width = 0f;
		    var line = 0f;

		    for (int i = 0; i < text.Length; i++)
		    {
		        if (text[i] == '\n')
		        {
		            if (line > width)
		                width = line;
		            line = 0;
		            continue;
		        }

		        if (!Charset.TryGetValue(text[i], let ch))
		            continue;

		        line += ch.Advance;
		    }

		    return Math.Max(width, line);
		}

		public float WidthOf(Span<char8> text)
		{
		    var width = 0f;
		    var line = 0f;

		    for (int i = 0; i < text.Length; i++)
		    {
		        if (text[i] == '\n')
		        {
		            if (line > width)
		                width = line;
		            line = 0;
		            continue;
		        }

		        if (!Charset.TryGetValue((char16)text[i], let ch))
		            continue;

		        line += ch.Advance;
		    }

		    return Math.Max(width, line);
		}

		public float HeightOf(Span<char16> text)
		{
		    if (text.Length <= 0)
		        return 0;

		    var height = Height;

		    for (int i = 0; i < text.Length; i++)
		    {
		        if (text[i] == '\n')
		            height += LineHeight;
		    }

		    return height;
		}

		public float HeightOf(Span<char8> text)
		{
		    if (text.Length <= 0)
		        return 0;

		    var height = Height;

		    for (int i = 0; i < text.Length; i++)
		    {
		        if (text[i] == '\n')
		            height += LineHeight;
		    }

		    return height;
		}

		public Vector2 SizeOf(Span<char16> text)
		{
		    return Vector2(WidthOf(text), HeightOf(text));
		}

		public Vector2 SizeOf(Span<char8> text)
		{
		    return Vector2(WidthOf(text), HeightOf(text));
		}
	}
}
