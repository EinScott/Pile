using System;
using System.Collections;
using System.Diagnostics;
using stbtt;

using internal Pile;

namespace Pile
{
	class FontSize
	{
	    /// A single Font Character
	    public struct Character
	    {
	        public readonly char32 Unicode;
	        public readonly int32 Glyph;
	        public readonly uint32 Width;
	        public readonly uint32 Height;
	        public readonly float Advance;
	        public readonly float OffsetX;
	        public readonly float OffsetY;
	        public readonly bool HasGlyph;

			public this(char32 unicode, int32 glyph, uint32 width, uint32 height, float advance, float offsetX, float offsetY, bool hasGlyph)
			{
				Unicode = unicode;
				Glyph = glyph;
				Width = width;
				Height = height;
				Advance = advance;
				OffsetX = offsetX;
				OffsetY = offsetY;
				HasGlyph = hasGlyph;
			}
	    }

	    public readonly Font Font;
	    public readonly uint32 Size;

	    public readonly float Ascent; // This is the Font.Ascent * our Scale
	    public readonly float Descent; // This is the Font.Descent * our Scale
	    public readonly float LineGap; // This is the Font.LineGap * our Scale
	    public readonly float Height; // This is the Font.Height * our Scale
	    public readonly float LineHeight; // This is the Font.LineHeight * our Scale
	    public readonly float Scale;

	    public readonly Dictionary<char32, Character> Charset ~ delete _;

	    public this(Font font, uint32 size, Span<char32> charset)
	    {
	        Font = font;
	        Size = size;
	        Scale = font.GetScale(size);
	        Ascent = font.Ascent * Scale;
	        Descent = font.Descent * Scale;
	        LineGap = font.LineGap * Scale;
	        Height = Ascent - Descent;
	        LineHeight = Height + LineGap;

			Charset = new Dictionary<char32, Character>((.)charset.Length);
	        for (int i = 0; i < charset.Length; i++)
	        {
	            // Get font info
	            var unicode = charset[i];
	            int32 glyph = font.GetGlyph(unicode);

	            if (glyph > 0)
	            {
	                int32 advance = 0, offsetX = 0, x0 = 0, y0 = 0, x1 = 0, y1 = 0;

					stbtt.stbtt_GetGlyphHMetrics(&font.fontInfo, glyph, &advance, &offsetX);
					stbtt.stbtt_GetGlyphBitmapBox(&font.fontInfo, glyph, Scale, Scale, &x0, &y0, &x1, &y1);
					
					Debug.Assert((x1 - x0) >= 0 && (y1 - y0) >= 0);
					uint32 w = (uint32)(x1 - x0);
					uint32 h = (uint32)(y1 - y0);

					// Define character
					let ch = Character(unicode, glyph, w, h, advance * Scale, offsetX * Scale, y0,
						(w > 0 && h > 0 && !stbtt.stbtt_IsGlyphEmpty(&font.fontInfo, glyph)));

					Charset.Add(unicode, ch);
	            }
	        }
	    }

	    /// Gets the Kerning Value between two Unicode characters at the Font Size, or 0 if there is no Kerning
	    public float GetKerning(char32 unicode0, char32 unicode1)
	    {
	        if (Charset.TryGetValue(unicode0, let char0) && Charset.TryGetValue(unicode1, let char1))
	        	return stbtt.stbtt_GetGlyphKernAdvance(&Font.fontInfo, char0.Glyph, char1.Glyph) * Scale;

	        return 0f;
	    }

	    /// Renders the Unicode character to a buffer at the Font Size, and returns true on success. The bitmap will be cleared before rendering to it
	    public bool Render(char32 unicode, Bitmap bitmap, bool resizeBitmapBuffered = false)
	    {
	        if (Charset.TryGetValue(unicode, let ch) && ch.HasGlyph)
	        {
				// Prepare bitmap
				if (resizeBitmapBuffered) bitmap.ResizeAndClear(ch.Width, ch.Height, true);
				else bitmap.ResizeAndClear(ch.Width, ch.Height);

                // we actually use the bitmap buffer as our temporary buffer, and fill the pixels out backwards after [FOSTERCOMMENT]
                // kinda weird but it works & saves creating more memory

                var input = (uint8*)bitmap.Pixels.Ptr;
                stbtt.stbtt_MakeGlyphBitmap(&Font.fontInfo, input, (.)ch.Width, (.)ch.Height, (.)ch.Width, Scale, Scale, ch.Glyph);

                for (int i = (.)(ch.Width * ch.Height - 1); i >= 0; i--)
                    bitmap.Pixels[i] = Color(input[i], input[i], input[i], input[i]);

	            return true;
	        }

	        return false;
	    }
	}
}
