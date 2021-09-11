using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Diagnostics;
using stbtt;

namespace Pile
{
	class Font
	{
		internal readonly stbtt_fontinfo fontInfo ~ delete _;

		readonly uint8[] fontBuffer ~ delete _;
		readonly Dictionary<char32, int32> glyphs = new Dictionary<char32, int32>() ~ delete _;

		public readonly String FamilyName = new .() ~ delete _;
		public readonly String StyleName = new .() ~ delete _;
		public readonly int32 Ascent;
		public readonly int32 Descent;
		public readonly int32 LineGap;
		public readonly int32 Height; // The Height of the Font (Ascent - Descent)
		public readonly int32 LineHeight; // The Line Height of the Font (Height + LineGap). This is the total height of a single line, including the line gap

		public static bool IsValid(Span<uint8> buffer) => stbtt.stbtt__isfont(buffer.Ptr) == 1;

		public static bool IsValid(Stream stream)
		{
			if (stream.Peek<uint8[4]>() case .Ok(var val))
				return stbtt.stbtt__isfont(&val[0]) == 1;
			return false;
		}

		public this(Span<uint8> buffer)
		{
			Runtime.Assert(buffer.Length > 0 && stbtt.stbtt__isfont(buffer.Ptr) == 1, "Invalid font buffer");

		    fontBuffer = new uint8[buffer.Length];
			buffer.CopyTo(fontBuffer);
		    fontInfo = new stbtt_fontinfo();

		    let res = stbtt.stbtt_InitFont(fontInfo, fontBuffer.Ptr, 0);
			Runtime.Assert(res == 1, "Failed to load font from buffer");

		    GetName(fontInfo, 1, FamilyName);
		    GetName(fontInfo, 2, StyleName);

		    // properties
		    int32 ascent = ?, descent = ?, linegap = ?;
		    stbtt.stbtt_GetFontVMetrics(fontInfo, &ascent, &descent, &linegap);
		    Ascent = ascent;
		    Descent = descent;
		    LineGap = linegap;
		    Height = Ascent - Descent;
		    LineHeight = Height + LineGap;

		    void GetName(stbtt_fontinfo fontInfo, int32 nameID, String buffer)
		    {
		        int32 length = 0;

		        int8* ptr = stbtt.stbtt_GetFontNameString(fontInfo, &length,
		            stbtt.STBTT_PLATFORM_ID_MICROSOFT,
		            stbtt.STBTT_MS_EID_UNICODE_BMP,
		            stbtt.STBTT_MS_LANG_ENGLISH,
		            nameID);

		        if (length > 0)
				{
					let span = Span<uint8>((uint8*)ptr, length);

					// Swap (big endian)
					for (int i = 0; i < span.Length + 1; i += 2)
					{
						if (i + 1 >= span.Length)
							break;

						let swap = span[i + 1];
						span[i + 1] = span[i];
						span[i] = swap;
					}

					// Decode normal little endian
					Encoding.UTF16.DecodeToUTF8(span, buffer);
				}
				else buffer.Append("Unknown");
		    }
		}

		/// Gets the Scale of the Font for a given Height. This value can then be used to scale proprties of a Font for the given Height
		public float GetScale(uint32 height)
		{
		    return stbtt.stbtt_ScaleForPixelHeight(fontInfo, height);
		}

		/// Gets the Glyph code for a given Unicode value, if it exists, or 0 otherwise
		public int32 GetGlyph(char32 unicode)
		{
		    if (!glyphs.TryGetValue(unicode, var glyph))
		    {
		        glyph = stbtt.stbtt_FindGlyphIndex(fontInfo, (int32)unicode);
		        glyphs.Add(unicode, glyph);
		    }

		    return glyph;
		}
	}
}
