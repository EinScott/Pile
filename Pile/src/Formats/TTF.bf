using System;

/*
* Port of stb_truetype at e140649 by EinBurgbauer
* The original stb_truetype (https://github.com/nothings/stb/blob/master/stb_truetype.h) by Sean Barret is
* released as part of the public domain (www.unlicense.org).
*/

namespace stbtt
{
	[Optimize]
	static class stbtt
	{
		public static uint32 stbtt__find_table(uint8* data, uint32 fontstart, String tag)
		{
			int32 num_tables = ttUSHORT(data + fontstart + 4);
			var tabledir = fontstart + 12;
			int32 i;
			for (i = 0; i < num_tables; ++i)
			{
				var loc = (uint32)(tabledir + 16 * (.)i);
				if ((data + loc + 0)[0] == tag[0] && (data + loc + 0)[1] == tag[1] &&
					(data + loc + 0)[2] == tag[2] && (data + loc + 0)[3] == tag[3])
					return ttULONG(data + loc + 8);
			}

			return 0;
		}

		public static bool stbtt_BakeFontBitmap(uint8[] ttf, int32 offset, float pixel_height, uint8[] pixels, int32 pw,
			int32 ph,
			int32 first_char, int32 num_chars, stbtt_bakedchar[] chardata)
		{
			var result = stbtt_BakeFontBitmap(&ttf[0], offset, pixel_height, &pixels[0], pw, ph, first_char,
				num_chars,
				&chardata[0]);

			return result != 0;
		}
		public const int32 STBTT_vmove = 1;
		public const int32 STBTT_vline = 2;
		public const int32 STBTT_vcurve = 3;
		public const int32 STBTT_vcubic = 4;

		public const int32 STBTT_PLATFORM_ID_UNICODE = 0;
		public const int32 STBTT_PLATFORM_ID_MAC = 1;
		public const int32 STBTT_PLATFORM_ID_ISO = 2;
		public const int32 STBTT_PLATFORM_ID_MICROSOFT = 3;

		public const int32 STBTT_UNICODE_EID_UNICODE_1_0 = 0;
		public const int32 STBTT_UNICODE_EID_UNICODE_1_1 = 1;
		public const int32 STBTT_UNICODE_EID_ISO_10646 = 2;
		public const int32 STBTT_UNICODE_EID_UNICODE_2_0_BMP = 3;
		public const int32 STBTT_UNICODE_EID_UNICODE_2_0_FULL = 4;

		public const int32 STBTT_MS_EID_SYMBOL = 0;
		public const int32 STBTT_MS_EID_UNICODE_BMP = 1;
		public const int32 STBTT_MS_EID_SHIFTJIS = 2;
		public const int32 STBTT_MS_EID_UNICODE_FULL = 10;

		public const int32 STBTT_MAC_EID_ROMAN = 0;
		public const int32 STBTT_MAC_EID_ARABIC = 4;
		public const int32 STBTT_MAC_EID_JAPANESE = 1;
		public const int32 STBTT_MAC_EID_HEBREW = 5;
		public const int32 STBTT_MAC_EID_CHINESE_TRAD = 2;
		public const int32 STBTT_MAC_EID_GREEK = 6;
		public const int32 STBTT_MAC_EID_KOREAN = 3;
		public const int32 STBTT_MAC_EID_RUSSIAN = 7;

		public const int32 STBTT_MS_LANG_ENGLISH = 0x0409;
		public const int32 STBTT_MS_LANG_ITALIAN = 0x0410;
		public const int32 STBTT_MS_LANG_CHINESE = 0x0804;
		public const int32 STBTT_MS_LANG_JAPANESE = 0x0411;
		public const int32 STBTT_MS_LANG_DUTCH = 0x0413;
		public const int32 STBTT_MS_LANG_KOREAN = 0x0412;
		public const int32 STBTT_MS_LANG_FRENCH = 0x040c;
		public const int32 STBTT_MS_LANG_RUSSIAN = 0x0419;
		public const int32 STBTT_MS_LANG_GERMAN = 0x0407;
		public const int32 STBTT_MS_LANG_SPANISH = 0x0409;
		public const int32 STBTT_MS_LANG_HEBREW = 0x040d;
		public const int32 STBTT_MS_LANG_SWEDISH = 0x041D;

		public const int32 STBTT_MAC_LANG_ENGLISH = 0;
		public const int32 STBTT_MAC_LANG_JAPANESE = 11;
		public const int32 STBTT_MAC_LANG_ARABIC = 12;
		public const int32 STBTT_MAC_LANG_KOREAN = 23;
		public const int32 STBTT_MAC_LANG_DUTCH = 4;
		public const int32 STBTT_MAC_LANG_RUSSIAN = 32;
		public const int32 STBTT_MAC_LANG_FRENCH = 1;
		public const int32 STBTT_MAC_LANG_SPANISH = 6;
		public const int32 STBTT_MAC_LANG_GERMAN = 2;
		public const int32 STBTT_MAC_LANG_SWEDISH = 5;
		public const int32 STBTT_MAC_LANG_HEBREW = 10;
		public const int32 STBTT_MAC_LANG_CHINESE_SIMPLIFIED = 33;
		public const int32 STBTT_MAC_LANG_ITALIAN = 3;
		public const int32 STBTT_MAC_LANG_CHINESE_TRAD = 19;

		public static uint8 stbtt__buf_get8(stbtt__buf* b)
		{
			if ((b.cursor) >= (b.size))
				return (uint8)(0);
			return (uint8)(b.data[b.cursor++]);
		}

		public static uint8 stbtt__buf_peek8(stbtt__buf* b)
		{
			if ((b.cursor) >= (b.size))
				return (uint8)(0);
			return (uint8)(b.data[b.cursor]);
		}

		public static void stbtt__buf_seek(stbtt__buf* b, int32 o)
		{
			b.cursor = (int32)((((o) > (b.size)) || ((o) < (0))) ? b.size : o);
		}

		public static void stbtt__buf_skip(stbtt__buf* b, int32 o)
		{
			stbtt__buf_seek(b, (int32)(b.cursor + o));
		}

		public static uint32 stbtt__buf_get(stbtt__buf* b, int32 n)
		{
			uint32 v = (uint32)(0);
			int32 i = 0;
			for (i = (int32)(0); (i) < (n); i++)
			{
				v = (uint32)((v << 8) | stbtt__buf_get8(b));
			}

			return (uint32)(v);
		}

		public static stbtt__buf stbtt__new_buf(void* p, uint64 size)
		{
			stbtt__buf r = stbtt__buf();
			r.data = (uint8*)(p);
			r.size = ((int32)(size));
			r.cursor = (int32)(0);
			return (stbtt__buf)(r);
		}

		public static stbtt__buf stbtt__buf_range(stbtt__buf* b, int32 o, int32 s)
		{
			stbtt__buf r = (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
			if (((((o) < (0)) || ((s) < (0))) || ((o) > (b.size))) || ((s) > (b.size - o)))
				return (stbtt__buf)(r);
			r.data = b.data + o;
			r.size = (int32)(s);
			return (stbtt__buf)(r);
		}

		public static stbtt__buf stbtt__cff_get_index(stbtt__buf* b)
		{
			int32 count = 0;
			int32 start = 0;
			int32 offsize = 0;
			start = (int32)(b.cursor);
			count = (int32)(stbtt__buf_get((b), (int32)(2)));
			if ((count) != 0)
			{
				offsize = (int32)(stbtt__buf_get8(b));
				stbtt__buf_skip(b, (int32)(offsize * count));
				stbtt__buf_skip(b, (int32)(stbtt__buf_get(b, (int32)(offsize)) - 1));
			}

			return (stbtt__buf)(stbtt__buf_range(b, (int32)(start), (int32)(b.cursor - start)));
		}

		public static uint32 stbtt__cff_int32(stbtt__buf* b)
		{
			int32 b0 = (int32)(stbtt__buf_get8(b));
			if (((b0) >= (32)) && (b0 <= 246))
				return (uint32)(b0 - 139);
			else if (((b0) >= (247)) && (b0 <= 250))
				return (uint32)((b0 - 247) * 256 + stbtt__buf_get8(b) + 108);
			else if (((b0) >= (251)) && (b0 <= 254))
				return (uint32)(-(b0 - 251) * 256 - stbtt__buf_get8(b) - 108);
			else if ((b0) == (28))
				return (uint32)(stbtt__buf_get((b), (int32)(2)));
			else if ((b0) == (29))
				return (uint32)(stbtt__buf_get((b), (int32)(4)));
			return (uint32)(0);
		}

		public static void stbtt__cff_skip_operand(stbtt__buf* b)
		{
			int32 v = 0;
			int32 b0 = (int32)(stbtt__buf_peek8(b));
			if ((b0) == (30))
			{
				stbtt__buf_skip(b, (int32)(1));
				while ((b.cursor) < (b.size))
				{
					v = (int32)(stbtt__buf_get8(b));
					if (((v & 0xF) == (0xF)) || ((v >> 4) == (0xF)))
						break;
				}
			}
			else
			{
				stbtt__cff_int32(b);
			}
		}

		public static stbtt__buf stbtt__dict_get(stbtt__buf* b, int32 key)
		{
			stbtt__buf_seek(b, (int32)(0));
			while ((b.cursor) < (b.size))
			{
				int32 start = (int32)(b.cursor);
				int32 end = 0;
				int32 op = 0;
				while ((stbtt__buf_peek8(b)) >= (28))
				{
					stbtt__cff_skip_operand(b);
				}

				end = (int32)(b.cursor);
				op = (int32)(stbtt__buf_get8(b));
				if ((op) == (12))
					op = (int32)(stbtt__buf_get8(b) | 0x100);
				if ((op) == (key))
					return (stbtt__buf)(stbtt__buf_range(b, (int32)(start), (int32)(end - start)));
			}

			return (stbtt__buf)(stbtt__buf_range(b, (int32)(0), (int32)(0)));
		}

		public static void stbtt__dict_get_int32s(stbtt__buf* b, int32 key, int32 outcount, uint32* _out_)
		{
			int32 i = 0;
			stbtt__buf operands = (stbtt__buf)(stbtt__dict_get(b, (int32)(key)));
			for (i = (int32)(0); ((i) < (outcount)) && ((operands.cursor) < (operands.size)); i++)
			{
				_out_[i] = (uint32)(stbtt__cff_int32(&operands));
			}
		}

		public static int32 stbtt__cff_index_count(stbtt__buf* b)
		{
			stbtt__buf_seek(b, (int32)(0));
			return (int32)(stbtt__buf_get((b), (int32)(2)));
		}

		public static stbtt__buf stbtt__cff_index_get(stbtt__buf b, int32 i)
		{
			var b;

			int32 count = 0;
			int32 offsize = 0;
			int32 start = 0;
			int32 end = 0;
			stbtt__buf_seek(&b, (int32)(0));
			count = (int32)(stbtt__buf_get((&b), (int32)(2)));
			offsize = (int32)(stbtt__buf_get8(&b));
			stbtt__buf_skip(&b, (int32)(i * offsize));
			start = (int32)(stbtt__buf_get(&b, (int32)(offsize)));
			end = (int32)(stbtt__buf_get(&b, (int32)(offsize)));
			return (stbtt__buf)(stbtt__buf_range(&b, (int32)(2 + (count + 1) * offsize + start), (int32)(end - start)));
		}

		public static uint16 ttUSHORT(uint8* p)
		{
			return (uint16)((uint16)p[0] * 256 + p[1]);
		}

		public static int16 ttSHORT(uint8* p)
		{
			return (int16)((int16)p[0] * 256 + p[1]);
		}

		public static uint32 ttULONG(uint8* p)
		{
			return (uint32)(((uint32)p[0] << 24) + ((uint32)p[1] << 16) + ((uint32)p[2] << 8) + p[3]);
		}

		public static int32 ttLONG(uint8* p)
		{
			return (int32)(((int32)p[0] << 24) + ((int32)p[1] << 16) + ((int32)p[2] << 8) + p[3]);
		}

		public static int32 stbtt__isfont(uint8* font)
		{
			if (((((((font)[0]) == ('1')) && (((font)[1]) == (0))) && (((font)[2]) == (0))) && (((font)[3]) == (0))))
				return (int32)(1);
			if (((((((font)[0]) == ("typ1"[0])) && (((font)[1]) == ("typ1"[1]))) && (((font)[2]) == ("typ1"[2]))) &&
				(((font)[3]) == ("typ1"[3]))))
				return (int32)(1);
			if (((((((font)[0]) == ("OTTO"[0])) && (((font)[1]) == ("OTTO"[1]))) && (((font)[2]) == ("OTTO"[2]))) &&
				(((font)[3]) == ("OTTO"[3]))))
				return (int32)(1);
			if (((((((font)[0]) == (0)) && (((font)[1]) == (1))) && (((font)[2]) == (0))) && (((font)[3]) == (0))))
				return (int32)(1);
			if (((((((font)[0]) == ("true"[0])) && (((font)[1]) == ("true"[1]))) && (((font)[2]) == ("true"[2]))) &&
				(((font)[3]) == ("true"[3]))))
				return (int32)(1);
			return (int32)(0);
		}

		public static int32 stbtt_GetFontOffsetForIndex_internal(uint8* font_collection, int32 index)
		{
			if ((stbtt__isfont(font_collection)) != 0)
				return (int32)((index)== (0) ? 0 : -1);
			if (((((((font_collection)[0]) == ("ttcf"[0])) && (((font_collection)[1]) == ("ttcf"[1]))) &&
				(((font_collection)[2]) == ("ttcf"[2]))) && (((font_collection)[3]) == ("ttcf"[3]))))
			{
				if (((ttULONG(font_collection + 4)) == (0x00010000)) ||
					((ttULONG(font_collection + 4)) == (0x00020000)))
				{
					int32 n = (int32)(ttLONG(font_collection + 8));
					if ((index) >= (n))
						return (int32)(-1);
					return (int32)(ttULONG(font_collection + 12 + index * 4));
				}
			}

			return (int32)(-1);
		}

		public static int32 stbtt_GetNumberOfFonts_internal(uint8* font_collection)
		{
			if ((stbtt__isfont(font_collection)) != 0)
				return (int32)(1);
			if (((((((font_collection)[0]) == ("ttcf"[0])) && (((font_collection)[1]) == ("ttcf"[1]))) &&
				(((font_collection)[2]) == ("ttcf"[2]))) && (((font_collection)[3]) == ("ttcf"[3]))))
			{
				if (((ttULONG(font_collection + 4)) == (0x00010000)) ||
					((ttULONG(font_collection + 4)) == (0x00020000)))
				{
					return (int32)(ttLONG(font_collection + 8));
				}
			}

			return (int32)(0);
		}

		public static stbtt__buf stbtt__get_subrs(stbtt__buf cff, stbtt__buf fontdict)
		{
			var cff, fontdict;

			uint32 subrsoff = (uint32)(0);
			let pl = scope uint32[2];
			uint32* private_loc = &pl[0];
			private_loc[0] = (uint32)(0);
			private_loc[1] = (uint32)(0);

			stbtt__buf pdict = stbtt__buf();
			stbtt__dict_get_int32s(&fontdict, (int32)(18), (int32)(2), private_loc);
			if ((private_loc[1] == 0) || (private_loc[0] == 0))
				return (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
			pdict = (stbtt__buf)(stbtt__buf_range(&cff, (int32)(private_loc[1]), (int32)(private_loc[0])));
			stbtt__dict_get_int32s(&pdict, (int32)(19), (int32)(1), &subrsoff);
			if (subrsoff == 0)
				return (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
			stbtt__buf_seek(&cff, (int32)(private_loc[1] + subrsoff));
			return (stbtt__buf)(stbtt__cff_get_index(&cff));
		}

		public static int32 stbtt_InitFont_internal(stbtt_fontinfo info, uint8* data, int32 fontstart)
		{
			uint32 cmap = 0;
			uint32 t = 0;
			int32 i = 0;
			int32 numTables = 0;
			info.data = data;
			info.fontstart = (int32)(fontstart);
			info.cff = (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
			cmap = (uint32)(stbtt__find_table(data, (uint32)(fontstart), "cmap"));
			info.loca = (int32)(stbtt__find_table(data, (uint32)(fontstart), "loca"));
			info.head = (int32)(stbtt__find_table(data, (uint32)(fontstart), "head"));
			info.glyf = (int32)(stbtt__find_table(data, (uint32)(fontstart), "glyf"));
			info.hhea = (int32)(stbtt__find_table(data, (uint32)(fontstart), "hhea"));
			info.hmtx = (int32)(stbtt__find_table(data, (uint32)(fontstart), "hmtx"));
			info.kern = (int32)(stbtt__find_table(data, (uint32)(fontstart), "kern"));
			info.gpos = (int32)(stbtt__find_table(data, (uint32)(fontstart), "GPOS"));
			if ((((cmap == 0) || (info.head == 0)) || (info.hhea == 0)) || (info.hmtx == 0))
				return (int32)(0);
			if ((info.glyf) != 0)
			{
				if (info.loca == 0)
					return (int32)(0);
			}
			else
			{
				stbtt__buf b = stbtt__buf();
				stbtt__buf topdict = stbtt__buf();
				stbtt__buf topdictidx = stbtt__buf();
				uint32 cstype = (uint32)(2);
				uint32 charstrings = (uint32)(0);
				uint32 fdarrayoff = (uint32)(0);
				uint32 fdselectoff = (uint32)(0);
				uint32 cff = 0;
				cff = (uint32)(stbtt__find_table(data, (uint32)(fontstart), "CFF "));
				if (cff == 0)
					return (int32)(0);
				info.fontdicts = (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
				info.fdselect = (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
				info.cff = (stbtt__buf)(stbtt__new_buf(data + cff, (uint64)(512 * 1024 * 1024)));
				b = (stbtt__buf)(info.cff);
				stbtt__buf_skip(&b, (int32)(2));
				stbtt__buf_seek(&b, (int32)(stbtt__buf_get8(&b)));
				stbtt__cff_get_index(&b);
				topdictidx = (stbtt__buf)(stbtt__cff_get_index(&b));
				topdict = (stbtt__buf)(stbtt__cff_index_get((stbtt__buf)(topdictidx), (int32)(0)));
				stbtt__cff_get_index(&b);
				info.gsubrs = (stbtt__buf)(stbtt__cff_get_index(&b));
				stbtt__dict_get_int32s(&topdict, (int32)(17), (int32)(1), &charstrings);
				stbtt__dict_get_int32s(&topdict, (int32)(0x100 | 6), (int32)(1), &cstype);
				stbtt__dict_get_int32s(&topdict, (int32)(0x100 | 36), (int32)(1), &fdarrayoff);
				stbtt__dict_get_int32s(&topdict, (int32)(0x100 | 37), (int32)(1), &fdselectoff);
				info.subrs = (stbtt__buf)(stbtt__get_subrs((stbtt__buf)(b), (stbtt__buf)(topdict)));
				if (cstype != 2)
					return (int32)(0);
				if ((charstrings) == (0))
					return (int32)(0);
				if ((fdarrayoff) != 0)
				{
					if (fdselectoff == 0)
						return (int32)(0);
					stbtt__buf_seek(&b, (int32)(fdarrayoff));
					info.fontdicts = (stbtt__buf)(stbtt__cff_get_index(&b));
					info.fdselect =
						(stbtt__buf)(stbtt__buf_range(&b, (int32)(fdselectoff), (int32)(b.size - (.)fdselectoff)));
				}

				stbtt__buf_seek(&b, (int32)(charstrings));
				info.charstrings = (stbtt__buf)(stbtt__cff_get_index(&b));
			}

			t = (uint32)(stbtt__find_table(data, (uint32)(fontstart), "maxp"));
			if ((t) != 0)
				info.numGlyphs = (int32)(ttUSHORT(data + t + 4));
			else
				info.numGlyphs = (int32)(0xffff);
			numTables = (int32)(ttUSHORT(data + cmap + 2));
			info.index_map = (int32)(0);
			for (i = (int32)(0); (i) < (numTables); ++i)
			{
				uint32 encoding_record = (uint32)(cmap + 4 + 8 * (.)i);
				switch (ttUSHORT(data + encoding_record))
				{
				case STBTT_PLATFORM_ID_MICROSOFT:
					switch (ttUSHORT(data + encoding_record + 2))
					{
					case STBTT_MS_EID_UNICODE_BMP:
					case STBTT_MS_EID_UNICODE_FULL:
						info.index_map = (int32)(cmap + ttULONG(data + encoding_record + 4));
						break;
					}

					break;
				case STBTT_PLATFORM_ID_UNICODE:
					info.index_map = (int32)(cmap + ttULONG(data + encoding_record + 4));
					break;
				}
			}

			if ((info.index_map) == (0))
				return (int32)(0);
			info.indexToLocFormat = (int32)(ttUSHORT(data + info.head + 50));
			return (int32)(1);
		}

		public static int32 stbtt_FindGlyphIndex(stbtt_fontinfo info, int32 unicode_codepoint32)
		{
			uint8* data = info.data;
			uint32 index_map = (uint32)(info.index_map);
			uint16 format = (uint16)(ttUSHORT(data + index_map + 0));
			if ((format) == (0))
			{
				int32 uint8s = (int32)(ttUSHORT(data + index_map + 2));
				if ((unicode_codepoint32) < (uint8s - 6))
					return (int32)(*(data + index_map + 6 + unicode_codepoint32));
				return (int32)(0);
			}
			else if ((format) == (6))
			{
				uint32 first = (uint32)(ttUSHORT(data + index_map + 6));
				uint32 count = (uint32)(ttUSHORT(data + index_map + 8));
				if ((((uint32)(unicode_codepoint32)) >= (first)) && (((uint32)(unicode_codepoint32)) < (first + count)))
					return (int32)(ttUSHORT(data + index_map + 10 + (unicode_codepoint32 - (.)first) * 2));
				return (int32)(0);
			}
			else if ((format) == (2))
			{
				return (int32)(0);
			}
			else if ((format) == (4))
			{
				uint16 segcount = (uint16)(ttUSHORT(data + index_map + 6) >> 1);
				uint16 searchRange = (uint16)(ttUSHORT(data + index_map + 8) >> 1);
				uint16 entrySelector = (uint16)(ttUSHORT(data + index_map + 10));
				uint16 rangeShift = (uint16)(ttUSHORT(data + index_map + 12) >> 1);
				uint32 endCount = (uint32)(index_map + 14);
				uint32 search = (uint32)(endCount);
				if ((unicode_codepoint32) > (0xffff))
					return (int32)(0);
				if ((unicode_codepoint32) >= (ttUSHORT(data + search + rangeShift * 2)))
					search += (uint32)(rangeShift * 2);
				search -= (uint32)(2);
				while ((entrySelector) != 0)
				{
					uint16 end = 0;
					searchRange >>= 1;
					end = (uint16)(ttUSHORT(data + search + searchRange * 2));
					if ((unicode_codepoint32) > (end))
						search += (uint32)(searchRange * 2);
					--entrySelector;
				}

				search += (uint32)(2);
				{
					uint16 offset = 0;
					uint16 start = 0;
					uint16 item = (uint16)((search - endCount) >> 1);
					start = (uint16)(ttUSHORT(data + index_map + 14 + segcount * 2 + 2 + 2 * item));
					if ((unicode_codepoint32) < (start))
						return (int32)(0);
					offset = (uint16)(ttUSHORT(data + index_map + 14 + segcount * 6 + 2 + 2 * item));
					if ((offset) == (0))
						return (int32)((uint16)(unicode_codepoint32 +
							ttSHORT(data + index_map + 14 + segcount * 4 + 2 + 2 * item)));
					return (int32)(ttUSHORT(data + (int32)offset + (int32)(unicode_codepoint32 - start) * 2 + index_map + 14 +
						(int32)segcount * 6 + 2 + 2 * (int32)item));
				}
			}
			else if (((format) == (12)) || ((format) == (13)))
			{
				uint32 ngroups = (uint32)(ttULONG(data + index_map + 12));
				int32 low = 0;
				int32 high = 0;
				low = (int32)(0);
				high = ((int32)(ngroups));
				while ((low) < (high))
				{
					int32 mid = (int32)(low + ((high - low) >> 1));
					uint32 start_char = (uint32)(ttULONG(data + index_map + 16 + mid * 12));
					uint32 end_char = (uint32)(ttULONG(data + index_map + 16 + mid * 12 + 4));
					if (((uint32)(unicode_codepoint32)) < (start_char))
						high = (int32)(mid);
					else if (((uint32)(unicode_codepoint32)) > (end_char))
						low = (int32)(mid + 1);
					else
					{
						uint32 start_glyph = (uint32)(ttULONG(data + index_map + 16 + mid * 12 + 8));
						if ((format) == (12))
							return (int32)(start_glyph + (.)unicode_codepoint32 - start_char);
						else
							return (int32)(start_glyph);
					}
				}

				return (int32)(0);
			}

			return (int32)(0);
		}

		public static int32 stbtt_GetCodepoint32Shape(stbtt_fontinfo info, int32 unicode_codepoint32, stbtt_vertex** vertices)
		{
			return (int32)(stbtt_GetGlyphShape(info, (int32)(stbtt_FindGlyphIndex(info, (int32)(unicode_codepoint32))),
				vertices));
		}

		public static void stbtt_setvertex(stbtt_vertex* v, uint8 type, int32 x, int32 y, int32 cx, int32 cy)
		{
			v.type = (uint8)(type);
			v.x = ((int16)(x));
			v.y = ((int16)(y));
			v.cx = ((int16)(cx));
			v.cy = ((int16)(cy));
		}

		public static int32 stbtt__GetGlyfOffset(stbtt_fontinfo info, int32 glyph_index)
		{
			int32 g1 = 0;
			int32 g2 = 0;
			if ((glyph_index) >= (info.numGlyphs))
				return (int32)(-1);
			if ((info.indexToLocFormat) >= (2))
				return (int32)(-1);
			if ((info.indexToLocFormat) == (0))
			{
				g1 = (int32)(info.glyf + (int32)ttUSHORT(info.data + info.loca + glyph_index * 2) * 2);
				g2 = (int32)(info.glyf + (int32)ttUSHORT(info.data + info.loca + glyph_index * 2 + 2) * 2);
			}
			else
			{
				g1 = (int32)(info.glyf + (.)ttULONG(info.data + info.loca + glyph_index * 4));
				g2 = (int32)(info.glyf + (.)ttULONG(info.data + info.loca + glyph_index * 4 + 4));
			}

			return (int32)((g1)== (g2) ? -1 : g1);
		}

		public static int32 stbtt_GetGlyphBox(stbtt_fontinfo info, int32 glyph_index, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			if ((info.cff.size) != 0)
			{
				stbtt__GetGlyphInfoT2(info, (int32)(glyph_index), x0, y0, x1, y1);
			}
			else
			{
				int32 g = (int32)(stbtt__GetGlyfOffset(info, (int32)(glyph_index)));
				if ((g) < (0))
					return (int32)(0);
				if ((x0) != null)
					*x0 = (int32)(ttSHORT(info.data + g + 2));
				if ((y0) != null)
					*y0 = (int32)(ttSHORT(info.data + g + 4));
				if ((x1) != null)
					*x1 = (int32)(ttSHORT(info.data + g + 6));
				if ((y1) != null)
					*y1 = (int32)(ttSHORT(info.data + g + 8));
			}

			return (int32)(1);
		}

		public static int32 stbtt_GetCodepoint32Box(stbtt_fontinfo info, int32 codepoint32, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			return (int32)(stbtt_GetGlyphBox(info, (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32))), x0, y0, x1,
				y1));
		}

		public static int32 stbtt_IsGlyphEmpty(stbtt_fontinfo info, int32 glyph_index)
		{
			int16 numberOfContours = 0;
			int32 g = 0;
			if ((info.cff.size) != 0)
				return (int32)((stbtt__GetGlyphInfoT2(info,(int32)(glyph_index),(null),(null),(null),(null)))== (0)
					? 1
					: 0);
			g = (int32)(stbtt__GetGlyfOffset(info, (int32)(glyph_index)));
			if ((g) < (0))
				return (int32)(1);
			numberOfContours = (int16)(ttSHORT(info.data + g));
			return (int32)((numberOfContours)== (0) ? 1 : 0);
		}

		public static int32 stbtt__close_shape(stbtt_vertex* vertices, int32 num_vertices, int32 was_off, int32 start_off,
			int32 sx, int32 sy, int32 scx, int32 scy, int32 cx, int32 cy)
		{
			var num_vertices;

			if ((start_off) != 0)
			{
				if ((was_off) != 0)
					stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vcurve), (int32)((cx + scx) >> 1),
						(int32)((cy + scy) >> 1), (int32)(cx), (int32)(cy));
				stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vcurve), (int32)(sx), (int32)(sy), (int32)(scx),
					(int32)(scy));
			}
			else
			{
				if ((was_off) != 0)
					stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vcurve), (int32)(sx), (int32)(sy),
						(int32)(cx), (int32)(cy));
				else
					stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vline), (int32)(sx), (int32)(sy), (int32)(0),
						(int32)(0));
			}

			return (int32)(num_vertices);
		}

		public static int32 stbtt__GetGlyphShapeTT(stbtt_fontinfo info, int32 glyph_index, stbtt_vertex** pvertices)
		{
			int16 numberOfContours = 0;
			uint8* endPtsOfContours;
			uint8* data = info.data;
			stbtt_vertex* vertices = null;
			int32 num_vertices = (int32)(0);
			int32 g = (int32)(stbtt__GetGlyfOffset(info, (int32)(glyph_index)));
			*pvertices = (null);
			if ((g) < (0))
				return (int32)(0);
			numberOfContours = (int16)(ttSHORT(data + g));
			if ((numberOfContours) > (0))
			{
				uint8 flags = (uint8)(0);
				uint8 flagcount = 0;
				int32 ins = 0;
				int32 i = 0;
				int32 j = (int32)(0);
				int32 m = 0;
				int32 n = 0;
				int32 next_move = 0;
				int32 was_off = (int32)(0);
				int32 off = 0;
				int32 start_off = (int32)(0);
				int32 x = 0;
				int32 y = 0;
				int32 cx = 0;
				int32 cy = 0;
				int32 sx = 0;
				int32 sy = 0;
				int32 scx = 0;
				int32 scy = 0;
				uint8* point32s;
				endPtsOfContours = (data + g + 10);
				ins = (int32)(ttUSHORT(data + g + 10 + numberOfContours * 2));
				point32s = data + g + 10 + numberOfContours * 2 + 2 + ins;
				n = (int32)(1 + ttUSHORT(endPtsOfContours + numberOfContours * 2 - 2));
				m = (int32)(n + 2 * numberOfContours);
				vertices = (stbtt_vertex*)(Internal.Malloc((int)(m * sizeof(stbtt_vertex))));
				if ((vertices) == (null))
					return (int32)(0);
				next_move = (int32)(0);
				flagcount = (uint8)(0);
				off = (int32)(m - n);
				for (i = (int32)(0); (i) < (n); ++i)
				{
					if ((flagcount) == (0))
					{
						flags = (uint8)(*point32s++);
						if ((flags & 8) != 0)
							flagcount = (uint8)(*point32s++);
					}
					else
						--flagcount;

					vertices[off + i].type = (uint8)(flags);
				}

				x = (int32)(0);
				for (i = (int32)(0); (i) < (n); ++i)
				{
					flags = (uint8)(vertices[off + i].type);
					if ((flags & 2) != 0)
					{
						int16 dx = (int16)(*point32s++);
						x += (int32)((flags&16)!= 0 ? dx : -dx);
					}
					else
					{
						if ((flags & 16) == 0)
						{
							x = (int32)(x + (int16)(point32s[0] * 256 + point32s[1]));
							point32s += 2;
						}
					}

					vertices[off + i].x = ((int16)(x));
				}

				y = (int32)(0);
				for (i = (int32)(0); (i) < (n); ++i)
				{
					flags = (uint8)(vertices[off + i].type);
					if ((flags & 4) != 0)
					{
						int16 dy = (int16)(*point32s++);
						y += (int32)((flags&32)!= 0 ? dy : -dy);
					}
					else
					{
						if ((flags & 32) == 0)
						{
							y = (int32)(y + (int16)(point32s[0] * 256 + point32s[1]));
							point32s += 2;
						}
					}

					vertices[off + i].y = ((int16)(y));
				}

				num_vertices = (int32)(0);
				sx = (int32)(sy = (int32)(cx = (int32)(cy = (int32)(scx = (int32)(scy = (int32)(0))))));
				for (i = (int32)(0); (i) < (n); ++i)
				{
					flags = (uint8)(vertices[off + i].type);
					x = (int32)(vertices[off + i].x);
					y = (int32)(vertices[off + i].y);
					if ((next_move) == (i))
					{
						if (i != 0)
							num_vertices = (int32)(stbtt__close_shape(vertices, (int32)(num_vertices), (int32)(was_off),
								(int32)(start_off), (int32)(sx), (int32)(sy), (int32)(scx), (int32)(scy), (int32)(cx),
								(int32)(cy)));
						start_off = ((flags&1)!= 0 ? 0 : 1);
						if ((start_off) != 0)
						{
							scx = (int32)(x);
							scy = (int32)(y);
							if ((vertices[off + i + 1].type & 1) == 0)
							{
								sx = (int32)((x + (int32)(vertices[off + i + 1].x)) >> 1);
								sy = (int32)((y + (int32)(vertices[off + i + 1].y)) >> 1);
							}
							else
							{
								sx = ((int32)(vertices[off + i + 1].x));
								sy = ((int32)(vertices[off + i + 1].y));
								++i;
							}
						}
						else
						{
							sx = (int32)(x);
							sy = (int32)(y);
						}

						stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vmove), (int32)(sx), (int32)(sy),
							(int32)(0), (int32)(0));
						was_off = (int32)(0);
						next_move = (int32)(1 + ttUSHORT(endPtsOfContours + j * 2));
						++j;
					}
					else
					{
						if ((flags & 1) == 0)
						{
							if ((was_off) != 0)
								stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vcurve), (int32)((cx + x) >> 1),
									(int32)((cy + y) >> 1), (int32)(cx), (int32)(cy));
							cx = (int32)(x);
							cy = (int32)(y);
							was_off = (int32)(1);
						}
						else
						{
							if ((was_off) != 0)
								stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vcurve), (int32)(x), (int32)(y),
									(int32)(cx), (int32)(cy));
							else
								stbtt_setvertex(&vertices[num_vertices++], (uint8)(STBTT_vline), (int32)(x), (int32)(y),
									(int32)(0), (int32)(0));
							was_off = (int32)(0);
						}
					}
				}

				num_vertices = (int32)(stbtt__close_shape(vertices, (int32)(num_vertices), (int32)(was_off),
					(int32)(start_off), (int32)(sx), (int32)(sy), (int32)(scx), (int32)(scy), (int32)(cx), (int32)(cy)));
			}
			else if ((numberOfContours) == (-1))
			{
				int32 more = (int32)(1);
				uint8* comp = data + g + 10;
				num_vertices = (int32)(0);
				vertices = null;
				while ((more) != 0)
				{
					uint16 flags = 0;
					uint16 gidx = 0;
					int32 comp_num_verts = (int32)(0);
					int32 i = 0;
					stbtt_vertex* comp_verts = null;
					stbtt_vertex* tmp = null;
					let _m = scope float[6];
					float* mtx = &_m[0];
					mtx[0] = (float)(1);
					mtx[1] = (float)(0);
					mtx[2] = (float)(0);
					mtx[3] = (float)(1);
					mtx[4] = (float)(0);
					mtx[5] = (float)(0);
					float m = 0;
					float n = 0;
					flags = (uint16)(ttSHORT(comp));
					comp += 2;
					gidx = (uint16)(ttSHORT(comp));
					comp += 2;
					if ((flags & 2) != 0)
					{
						if ((flags & 1) != 0)
						{
							mtx[4] = (float)(ttSHORT(comp));
							comp += 2;
							mtx[5] = (float)(ttSHORT(comp));
							comp += 2;
						}
						else
						{
							mtx[4] = (float)(*(int8*)(comp));
							comp += 1;
							mtx[5] = (float)(*(int8*)(comp));
							comp += 1;
						}
					}
					else
					{
					}

					if ((flags & (1 << 3)) != 0)
					{
						mtx[0] = (float)(mtx[3] = (float)((float)ttSHORT(comp) / 16384.0f));
						comp += 2;
						mtx[1] = (float)(mtx[2] = (float)(0));
					}
					else if ((flags & (1 << 6)) != 0)
					{
						mtx[0] = (float)((float)ttSHORT(comp) / 16384.0f);
						comp += 2;
						mtx[1] = (float)(mtx[2] = (float)(0));
						mtx[3] = (float)((float)ttSHORT(comp) / 16384.0f);
						comp += 2;
					}
					else if ((flags & (1 << 7)) != 0)
					{
						mtx[0] = (float)((float)ttSHORT(comp) / 16384.0f);
						comp += 2;
						mtx[1] = (float)((float)ttSHORT(comp) / 16384.0f);
						comp += 2;
						mtx[2] = (float)((float)ttSHORT(comp) / 16384.0f);
						comp += 2;
						mtx[3] = (float)((float)ttSHORT(comp) / 16384.0f);
						comp += 2;
					}

					m = ((float)(Math.Sqrt((double)(mtx[0] * mtx[0] + mtx[1] * mtx[1]))));
					n = ((float)(Math.Sqrt((double)(mtx[2] * mtx[2] + mtx[3] * mtx[3]))));
					comp_num_verts = (int32)(stbtt_GetGlyphShape(info, (int32)(gidx), &comp_verts));
					if ((comp_num_verts) > (0))
					{
						for (i = (int32)(0); (i) < (comp_num_verts); ++i)
						{
							stbtt_vertex* v = &comp_verts[i];
							int16 x = 0;
							int16 y = 0;
							x = (int16)(v.x);
							y = (int16)(v.y);
							v.x = ((int16)(m * (mtx[0] * x + mtx[2] * y + mtx[4])));
							v.y = ((int16)(n * (mtx[1] * x + mtx[3] * y + mtx[5])));
							x = (int16)(v.cx);
							y = (int16)(v.cy);
							v.cx = ((int16)(m * (mtx[0] * x + mtx[2] * y + mtx[4])));
							v.cy = ((int16)(n * (mtx[1] * x + mtx[3] * y + mtx[5])));
						}

						tmp = (stbtt_vertex*)(Internal.Malloc(
							(int)((num_vertices + comp_num_verts) * sizeof(stbtt_vertex))));
						if (tmp == null)
						{
							if ((vertices) != null)
								Internal.Free(vertices);
							if ((comp_verts) != null)
								Internal.Free(comp_verts);
							return (int32)(0);
						}

						if ((num_vertices) > (0))
							Internal.MemCpy(tmp, vertices, (int)(num_vertices * sizeof(stbtt_vertex)));
						Internal.MemCpy(tmp + num_vertices, comp_verts,
							(int)(comp_num_verts * sizeof(stbtt_vertex)));
						if ((vertices) != null)
							Internal.Free(vertices);
						vertices = tmp;
						Internal.Free(comp_verts);
						num_vertices += (int32)(comp_num_verts);
					}

					more = (int32)(flags & (1 << 5));
				}
			}
			
			/*else if ((numberOfContours) < (0))
			{
			}
			else
			{
			}*/

			*pvertices = vertices;
			return (int32)(num_vertices);
		}

		public static void stbtt__track_vertex(stbtt__csctx* c, int32 x, int32 y)
		{
			if (((x) > (c.max_x)) || (c.started == 0))
				c.max_x = (int32)(x);
			if (((y) > (c.max_y)) || (c.started == 0))
				c.max_y = (int32)(y);
			if (((x) < (c.min_x)) || (c.started == 0))
				c.min_x = (int32)(x);
			if (((y) < (c.min_y)) || (c.started == 0))
				c.min_y = (int32)(y);
			c.started = (int32)(1);
		}

		public static void stbtt__csctx_v(stbtt__csctx* c, uint8 type, int32 x, int32 y, int32 cx, int32 cy, int32 cx1, int32 cy1)
		{
			if ((c.bounds) != 0)
			{
				stbtt__track_vertex(c, (int32)(x), (int32)(y));
				if ((type) == (STBTT_vcubic))
				{
					stbtt__track_vertex(c, (int32)(cx), (int32)(cy));
					stbtt__track_vertex(c, (int32)(cx1), (int32)(cy1));
				}
			}
			else
			{
				stbtt_setvertex(&c.pvertices[c.num_vertices], (uint8)(type), (int32)(x), (int32)(y), (int32)(cx),
					(int32)(cy));
				c.pvertices[c.num_vertices].cx1 = ((int16)(cx1));
				c.pvertices[c.num_vertices].cy1 = ((int16)(cy1));
			}

			c.num_vertices++;
		}

		public static void stbtt__csctx_close_shape(stbtt__csctx* ctx)
		{
			if ((ctx.first_x != ctx.x) || (ctx.first_y != ctx.y))
				stbtt__csctx_v(ctx, (uint8)(STBTT_vline), (int32)(ctx.first_x), (int32)(ctx.first_y), (int32)(0),
					(int32)(0), (int32)(0), (int32)(0));
		}

		public static void stbtt__csctx_rmove_to(stbtt__csctx* ctx, float dx, float dy)
		{
			stbtt__csctx_close_shape(ctx);
			ctx.first_x = (float)(ctx.x = (float)(ctx.x + dx));
			ctx.first_y = (float)(ctx.y = (float)(ctx.y + dy));
			stbtt__csctx_v(ctx, (uint8)(STBTT_vmove), (int32)(ctx.x), (int32)(ctx.y), (int32)(0), (int32)(0), (int32)(0),
				(int32)(0));
		}

		public static void stbtt__csctx_rline_to(stbtt__csctx* ctx, float dx, float dy)
		{
			ctx.x += (float)(dx);
			ctx.y += (float)(dy);
			stbtt__csctx_v(ctx, (uint8)(STBTT_vline), (int32)(ctx.x), (int32)(ctx.y), (int32)(0), (int32)(0), (int32)(0),
				(int32)(0));
		}

		public static void stbtt__csctx_rccurve_to(stbtt__csctx* ctx, float dx1, float dy1, float dx2, float dy2,
			float dx3, float dy3)
		{
			float cx1 = (float)(ctx.x + dx1);
			float cy1 = (float)(ctx.y + dy1);
			float cx2 = (float)(cx1 + dx2);
			float cy2 = (float)(cy1 + dy2);
			ctx.x = (float)(cx2 + dx3);
			ctx.y = (float)(cy2 + dy3);
			stbtt__csctx_v(ctx, (uint8)(STBTT_vcubic), (int32)(ctx.x), (int32)(ctx.y), (int32)(cx1), (int32)(cy1),
				(int32)(cx2), (int32)(cy2));
		}

		public static stbtt__buf stbtt__get_subr(stbtt__buf idx, int32 n)
		{
			var n, idx;

			int32 count = (int32)(stbtt__cff_index_count(&idx));
			int32 bias = (int32)(107);
			if ((count) >= (33900))
				bias = (int32)(32768);
			else if ((count) >= (1240))
				bias = (int32)(1131);
			n += (int32)(bias);
			if (((n) < (0)) || ((n) >= (count)))
				return (stbtt__buf)(stbtt__new_buf((null), (uint64)(0)));
			return (stbtt__buf)(stbtt__cff_index_get((stbtt__buf)(idx), (int32)(n)));
		}

		public static stbtt__buf stbtt__cid_get_glyph_subrs(stbtt_fontinfo info, int32 glyph_index)
		{
			stbtt__buf fdselect = (stbtt__buf)(info.fdselect);
			int32 nranges = 0;
			int32 start = 0;
			int32 end = 0;
			int32 v = 0;
			int32 fmt = 0;
			int32 fdselector = (int32)(-1);
			int32 i = 0;
			stbtt__buf_seek(&fdselect, (int32)(0));
			fmt = (int32)(stbtt__buf_get8(&fdselect));
			if ((fmt) == (0))
			{
				stbtt__buf_skip(&fdselect, (int32)(glyph_index));
				fdselector = (int32)(stbtt__buf_get8(&fdselect));
			}
			else if ((fmt) == (3))
			{
				nranges = (int32)(stbtt__buf_get((&fdselect), (int32)(2)));
				start = (int32)(stbtt__buf_get((&fdselect), (int32)(2)));
				for (i = (int32)(0); (i) < (nranges); i++)
				{
					v = (int32)(stbtt__buf_get8(&fdselect));
					end = (int32)(stbtt__buf_get((&fdselect), (int32)(2)));
					if (((glyph_index) >= (start)) && ((glyph_index) < (end)))
					{
						fdselector = (int32)(v);
						break;
					}

					start = (int32)(end);
				}
			}

			if ((fdselector) == (-1))
				stbtt__new_buf((null), (uint64)(0));
			return (stbtt__buf)(stbtt__get_subrs((stbtt__buf)(info.cff),
				(stbtt__buf)(stbtt__cff_index_get((stbtt__buf)(info.fontdicts), (int32)(fdselector)))));
		}

		public static int32 stbtt__run_charstring(stbtt_fontinfo info, int32 glyph_index, stbtt__csctx* c)
		{
			int32 in_header = (int32)(1);
			int32 maskbits = (int32)(0);
			int32 subr_stack_height = (int32)(0);
			int32 sp = (int32)(0);
			int32 v = 0;
			int32 i = 0;
			int32 b0 = 0;
			int32 has_subrs = (int32)(0);
			int32 clear_stack = 0;
			let _s = scope float[48];
			float* s = &_s[0];
			let ss = scope stbtt__buf[10];
			stbtt__buf* subr_stack = &ss[0];
			stbtt__buf subrs = (stbtt__buf)(info.subrs);
			stbtt__buf b = stbtt__buf();
			float f = 0;
			b = (stbtt__buf)(stbtt__cff_index_get((stbtt__buf)(info.charstrings), (int32)(glyph_index)));
			while ((b.cursor) < (b.size))
			{
				i = (int32)(0);
				clear_stack = (int32)(1);
				b0 = (int32)(stbtt__buf_get8(&b));
				switch (b0)
				{
				case 0x13, 0x14:
					
					if((in_header)!=0)
		                maskbits+=(int32)(sp/2);
		            in_header=(int32)(0);
		            stbtt__buf_skip(&b,(int32)((maskbits+7)/8));
					break;
				case 0x01, 0x03, 0x12, 0x17:
		            maskbits+=(int32)(sp/2);
					break;
				case 0x15:
		            in_header=(int32)(0);
					if((sp)<(2))
						return(int32)(0);
		            stbtt__csctx_rmove_to(c,(float)(s[sp-2]),(float)(s[sp-1]));
					break;
				case 0x04:
		            in_header=(int32)(0);
					if((sp)<(1))
						return(int32)(0);
		            stbtt__csctx_rmove_to(c,(float)(0),(float)(s[sp-1]));
					break;
				case 0x16:
		            in_header=(int32)(0);
					if((sp)<(1))
						return(int32)(0);
		        	stbtt__csctx_rmove_to(c,(float)(s[sp-1]),(float)(0));
					break;
				case 0x05:
					if((sp)<(2))
						return(int32)(0);
					for(;(i+1)<(sp); i+=(int32)(2))
					{
		                stbtt__csctx_rline_to(c,(float)(s[i]),(float)(s[i+1]));
					}

					break;
				case 0x07, 0x06:
					if((sp)<(1))
						return(int32)(0);
		            int32 goto_vlineto=(int32)((b0)==(0x07)?1:0);
					for(;;)
					{
						if((goto_vlineto)==(0))
						{
							if((i)>=(sp))
								break;
			                stbtt__csctx_rline_to(c,(float)(s[i]),(float)(0));
			                i++;
						}

		                goto_vlineto=(int32)(0);
						if((i)>=(sp))
							break;
		                stbtt__csctx_rline_to(c,(float)(0),(float)(s[i]));
		                i++;
					}

					break;
				case 0x1F, 0x1E:
					if((sp)<(4))
						return(int32)(0);
		            int32 goto_hvcurveto=(int32)((b0)==(0x1F)?1:0);
					for(;;)
					{
						if((goto_hvcurveto)==(0))
						{
							if((i+3)>=(sp))
								break;
			                stbtt__csctx_rccurve_to(c,(float)(0),(float)(s[i]),(float)(s[i+1]),
								(float)(s[i+2]),(float)(s[i+3]),
								(float)(((sp- i)==(5))? s[i+4]:0.0f));
			                i+=(int32)(4);
						}

		                goto_hvcurveto=(int32)(0);
						if((i+3)>=(sp))
							break;
		                stbtt__csctx_rccurve_to(c,(float)(s[i]),(float)(0),(float)(s[i+1]),
							(float)(s[i+2]),(float)(((sp- i)==(5))? s[i+4]:0.0f),(float)(s[i+3]));
		                i+=(int32)(4);
					}

					break;
				case 0x08:
					if((sp)<(6))
						return(int32)(0);
					for(;(i+5)<(sp); i+=(int32)(6))
					{
		                stbtt__csctx_rccurve_to(c,(float)(s[i]),(float)(s[i+1]),(float)(s[i+2]),
							(float)(s[i+3]),(float)(s[i+4]),(float)(s[i+5]));
					}

					break;
				case 0x18:
					if((sp)<(8))
						return(int32)(0);
					for(;(i+5)<(sp-2); i+=(int32)(6))
					{
		                stbtt__csctx_rccurve_to(c,(float)(s[i]),(float)(s[i+1]),(float)(s[i+2]),
							(float)(s[i+3]),(float)(s[i+4]),(float)(s[i+5]));
					}

					if((i+1)>=(sp))
						return(int32)(0);
		            stbtt__csctx_rline_to(c,(float)(s[i]),(float)(s[i+1]));
					break;
				case 0x19:
					if((sp)<(8))
						return(int32)(0);
					for(;(i+1)<(sp-6); i+=(int32)(2))
					{
		                stbtt__csctx_rline_to(c,(float)(s[i]),(float)(s[i+1]));
					}

					if((i+5)>=(sp))
						return(int32)(0);
		        	stbtt__csctx_rccurve_to(c,(float)(s[i]),(float)(s[i+1]),(float)(s[i+2]),
						(float)(s[i+3]),(float)(s[i+4]),(float)(s[i+5]));
					break;
				case 0x1A, 0x1B:
					if((sp)<(4))
						return(int32)(0);
		            f=(float)(0.0);
					if((sp&1)!=0)
					{
		                f=(float)(s[i]);
	                    i++;
					}

					for(;(i+3)<(sp); i+=(int32)(4))
					{
						if((b0)==(0x1B))
			                stbtt__csctx_rccurve_to(c,(float)(s[i]),(float)(f),(float)(s[i+1]),
								(float)(s[i+2]),(float)(s[i+3]),(float)(0.0));
						else
			                stbtt__csctx_rccurve_to(c,(float)(f),(float)(s[i]),(float)(s[i+1]),
								(float)(s[i+2]),(float)(0.0),(float)(s[i+3]));
			            f=(float)(0.0);
					}

					break;
				case 0x0A, 0x1D:
					if((b0)==(0x0A))
					{
						if(has_subrs==0)
						{
							if((info.fdselect.size)!=0)
		                        subrs=(stbtt__buf)(stbtt__cid_get_glyph_subrs(info,(int32)(glyph_index)));
		                    has_subrs=(int32)(1);
						}
					}

					if((sp)<(1))
						return(int32)(0);
		            v=((int32)(s[--sp]));
					if((subr_stack_height)>=(10))
						return(int32)(0);
		            subr_stack[subr_stack_height++]=(stbtt__buf)(b);
					let buf = (stbtt__buf)((b0)==(0x0A) ? subrs : info.gsubrs);
		            b=(stbtt__buf)(stbtt__get_subr(buf, (int32)(v)));
					if((b.size)==(0))
						return(int32)(0);
		            b.cursor=(int32)(0);
		            clear_stack=(int32)(0);
					break;
				case 0x0B:
					if(subr_stack_height<=0)
						return(int32)(0);
		            b=(stbtt__buf)(subr_stack[--subr_stack_height]);
		            clear_stack=(int32)(0);
					break;
				case 0x0E:
		            stbtt__csctx_close_shape(c);
					return(int32)(1);
				case 0x0C:
					{
                        float dx1=0;
                        float dx2=0;
                        float dx3=0;
                        float dx4=0;
                        float dx5=0;
                        float dx6=0;
                        float dy1=0;
                        float dy2=0;
                        float dy3=0;
                        float dy4=0;
                        float dy5=0;
                        float dy6=0;
                        float dx=0;
                        float dy=0;
                        int32 b1=(int32)(stbtt__buf_get8(&b));
						switch(b1)
						{
						case 0x22:
							if((sp)<(7))
								return(int32)(0);
                            dx1=(float)(s[0]);
                            dx2=(float)(s[1]);
                            dy2=(float)(s[2]);
                            dx3=(float)(s[3]);
                            dx4=(float)(s[4]);
                            dx5=(float)(s[5]);
                            dx6=(float)(s[6]);
                            stbtt__csctx_rccurve_to(c,(float)(dx1),(float)(0),(float)(dx2),(float)(dy2),
								(float)(dx3),(float)(0));
		                    stbtt__csctx_rccurve_to(c,(float)(dx4),(float)(0),(float)(dx5),(float)(-dy2),
								(float)(dx6),(float)(0));
							break;
						case 0x23:
							if((sp)<(13))
								return(int32)(0);
                            dx1=(float)(s[0]);
                            dy1=(float)(s[1]);
                            dx2=(float)(s[2]);
                            dy2=(float)(s[3]);
                            dx3=(float)(s[4]);
                            dy3=(float)(s[5]);
                            dx4=(float)(s[6]);
                            dy4=(float)(s[7]);
                            dx5=(float)(s[8]);
                            dy5=(float)(s[9]);
                            dx6=(float)(s[10]);
                            dy6=(float)(s[11]);
                            stbtt__csctx_rccurve_to(c,(float)(dx1),(float)(dy1),(float)(dx2),(float)(dy2),
								(float)(dx3),(float)(dy3));
		                    stbtt__csctx_rccurve_to(c,(float)(dx4),(float)(dy4),(float)(dx5),(float)(dy5),
								(float)(dx6),(float)(dy6));
							break;
						case 0x24:
							if((sp)<(9))
								return(int32)(0);
                            dx1=(float)(s[0]);
                            dy1=(float)(s[1]);
                            dx2=(float)(s[2]);
                            dy2=(float)(s[3]);
                            dx3=(float)(s[4]);
                            dx4=(float)(s[5]);
                            dx5=(float)(s[6]);
                            dy5=(float)(s[7]);
                            dx6=(float)(s[8]);
                            stbtt__csctx_rccurve_to(c,(float)(dx1),(float)(dy1),(float)(dx2),(float)(dy2),
								(float)(dx3),(float)(0));
		                    stbtt__csctx_rccurve_to(c,(float)(dx4),(float)(0),(float)(dx5),(float)(dy5),
								(float)(dx6),(float)(-(dy1+ dy2+ dy5)));
							break;
						case 0x25:
							if((sp)<(11))
								return(int32)(0);
                            dx1=(float)(s[0]);
                            dy1=(float)(s[1]);
                            dx2=(float)(s[2]);
                            dy2=(float)(s[3]);
                            dx3=(float)(s[4]);
                            dy3=(float)(s[5]);
                            dx4=(float)(s[6]);
                            dy4=(float)(s[7]);
                            dx5=(float)(s[8]);
                            dy5=(float)(s[9]);
                            dx6=(float)(dy6=(float)(s[10]));
                            dx=(float)(dx1+ dx2+ dx3+ dx4+ dx5);
                            dy=(float)(dy1+ dy2+ dy3+ dy4+ dy5);
							if(((float)Math.Abs((double)(dx)))>((float)Math.Abs((double)(dy))))
		                        dy6=(float)(-dy);
							else
		                        dx6=(float)(-dx);
		                    stbtt__csctx_rccurve_to(c,(float)(dx1),(float)(dy1),(float)(dx2),(float)(dy2),
								(float)(dx3),(float)(dy3));
		                    stbtt__csctx_rccurve_to(c,(float)(dx4),(float)(dy4),(float)(dx5),(float)(dy5),
								(float)(dx6),(float)(dy6));
							break;
						default:
							return(int32)(0);
						}
					}
					break;
				default:
					if (((b0 != 255) && (b0 != 28)) && (((b0) < (32)) || ((b0) > (254))))
						return (int32)(0);
					if ((b0) == (255))
					{
						f = (float)((float)((int32)(stbtt__buf_get((&b), (int32)(4)))) / 0x10000);
					}
					else
					{
						stbtt__buf_skip(&b, (int32)(-1));
						f = ((float)((int16)(stbtt__cff_int32(&b))));
					}

					if ((sp) >= (48))
						return (int32)(0);
					s[sp++] = (float)(f);
					clear_stack = (int32)(0);
					break;
				}

				if ((clear_stack) != 0)
					sp = (int32)(0);
			}

			return (int32)(0);
		}

		public static int32 stbtt__GetGlyphShapeT2(stbtt_fontinfo info, int32 glyph_index, stbtt_vertex** pvertices)
		{
			stbtt__csctx count_ctx = stbtt__csctx();
			count_ctx.bounds = (int32)(1);
			stbtt__csctx output_ctx = stbtt__csctx();
			if ((stbtt__run_charstring(info, (int32)(glyph_index), &count_ctx)) != 0)
			{
				*pvertices = (stbtt_vertex*)(Internal.Malloc((int)(count_ctx.num_vertices * sizeof(stbtt_vertex))));
				output_ctx.pvertices = *pvertices;
				if ((stbtt__run_charstring(info, (int32)(glyph_index), &output_ctx)) != 0)
				{
					return (int32)(output_ctx.num_vertices);
				}
			}

			*pvertices = (null);
			return (int32)(0);
		}

		public static int32 stbtt__GetGlyphInfoT2(stbtt_fontinfo info, int32 glyph_index, int32* x0, int32* y0, int32* x1,
			int32* y1)
		{
			stbtt__csctx c = stbtt__csctx();
			c.bounds = (int32)(1);
			int32 r = (int32)(stbtt__run_charstring(info, (int32)(glyph_index), &c));
			if ((x0) != null)
				*x0 = (int32)((r)!= 0 ? c.min_x : 0);
			if ((y0) != null)
				*y0 = (int32)((r)!= 0 ? c.min_y : 0);
			if ((x1) != null)
				*x1 = (int32)((r)!= 0 ? c.max_x : 0);
			if ((y1) != null)
				*y1 = (int32)((r)!= 0 ? c.max_y : 0);
			return (int32)((r)!= 0 ? c.num_vertices : 0);
		}

		public static int32 stbtt_GetGlyphShape(stbtt_fontinfo info, int32 glyph_index, stbtt_vertex** pvertices)
		{
			if (info.cff.size == 0)
				return (int32)(stbtt__GetGlyphShapeTT(info, (int32)(glyph_index), pvertices));
			else
				return (int32)(stbtt__GetGlyphShapeT2(info, (int32)(glyph_index), pvertices));
		}

		public static void stbtt_GetGlyphHMetrics(stbtt_fontinfo info, int32 glyph_index, int32* advanceWidth,
			int32* leftSideBearing)
		{
			uint16 numOfint64HorMetrics = (uint16)(ttUSHORT(info.data + info.hhea + 34));
			if ((glyph_index) < (numOfint64HorMetrics))
			{
				if ((advanceWidth) != null)
					*advanceWidth = (int32)(ttSHORT(info.data + info.hmtx + 4 * glyph_index));
				if ((leftSideBearing) != null)
					*leftSideBearing = (int32)(ttSHORT(info.data + info.hmtx + 4 * glyph_index + 2));
			}
			else
			{
				if ((advanceWidth) != null)
					*advanceWidth = (int32)(ttSHORT(info.data + info.hmtx + 4 * (numOfint64HorMetrics - 1)));
				if ((leftSideBearing) != null)
					*leftSideBearing = (int32)(ttSHORT(info.data + info.hmtx + 4 * numOfint64HorMetrics +
						2 * (glyph_index - numOfint64HorMetrics)));
			}
		}

		public static int32 stbtt__GetGlyphKernInfoAdvance(stbtt_fontinfo info, int32 glyph1, int32 glyph2)
		{
			uint8* data = info.data + info.kern;
			uint32 needle = 0;
			uint32 straw = 0;
			int32 l = 0;
			int32 r = 0;
			int32 m = 0;
			if (info.kern == 0)
				return (int32)(0);
			if ((ttUSHORT(data + 2)) < (1))
				return (int32)(0);
			if (ttUSHORT(data + 8) != 1)
				return (int32)(0);
			l = (int32)(0);
			r = (int32)(ttUSHORT(data + 10) - 1);
			needle = (uint32)(glyph1 << 16 | glyph2);
			while (l <= r)
			{
				m = (int32)((l + r) >> 1);
				straw = (uint32)(ttULONG(data + 18 + (m * 6)));
				if ((needle) < (straw))
					r = (int32)(m - 1);
				else if ((needle) > (straw))
					l = (int32)(m + 1);
				else
					return (int32)(ttSHORT(data + 22 + (m * 6)));
			}

			return (int32)(0);
		}

		public static int32 stbtt__GetCoverageIndex(uint8* coverageTable, int32 glyph)
		{
			uint16 coverageFormat = (uint16)(ttUSHORT(coverageTable));
			switch (coverageFormat)
			{
			case 1:
			{
		                    uint16 glyphCount=(uint16)(ttUSHORT(coverageTable+2));
		                    int32 l=(int32)(0);
		                    int32 r=(int32)(glyphCount-1);
		                    int32 m=0;
		                    int32 straw=0;
		                    int32 needle=(int32)(glyph);
					while(l<= r)
				{
		                        uint8* glyphArray= coverageTable+4;
		                        uint16 glyphID=0;
		                        m=(int32)((l+ r)>>1);
		                        glyphID=(uint16)(ttUSHORT(glyphArray+2* m));
		                        straw=(int32)(glyphID);
						if((needle)<(straw))
		                            r=(int32)(m-1);
						else if((needle)>(straw))
		                            l=(int32)(m+1);
						else
					{
						return(int32)(m);
					}
				}
			}
			break;
				case 2:
			{
		                    uint16 rangeCount=(uint16)(ttUSHORT(coverageTable+2));
		                    uint8* rangeArray= coverageTable+4;
		                    int32 l=(int32)(0);
		                    int32 r=(int32)(rangeCount-1);
		                    int32 m=0;
		                    int32 strawStart=0;
		                    int32 strawEnd=0;
		                    int32 needle=(int32)(glyph);
					while(l<= r)
				{
		                        uint8* rangeRecord;
		                        m=(int32)((l+ r)>>1);
		                        rangeRecord= rangeArray+6* m;
		                        strawStart=(int32)(ttUSHORT(rangeRecord));
		                        strawEnd=(int32)(ttUSHORT(rangeRecord+2));
						if((needle)<(strawStart))
		                            r=(int32)(m-1);
						else if((needle)>(strawEnd))
		                            l=(int32)(m+1);
						else
					{
		                            uint16 startCoverageIndex=(uint16)(ttUSHORT(rangeRecord+4));
							return(int32)(startCoverageIndex+ glyph- strawStart);
					}
				}
			}
			break;
				default:
				{
				}
				break;
			}

			return (int32)(-1);
		}

		public static int32 stbtt__GetGlyphClass(uint8* classDefTable, int32 glyph)
		{
			var classDefTable;
			uint16 classDefFormat = (uint16)(ttUSHORT(classDefTable));
			switch (classDefFormat)
			{
			case 1:
			{
		                    uint16 startGlyphID=(uint16)(ttUSHORT(classDefTable+2));
		                    uint16 glyphCount=(uint16)(ttUSHORT(classDefTable+4));
		                    uint8* classDef1ValueArray= classDefTable+6;
					if(((glyph)>=(startGlyphID))&&((glyph)<(startGlyphID+ glyphCount)))
					return(int32)(ttUSHORT(classDef1ValueArray+2*(glyph- startGlyphID)));
		                    classDefTable = classDef1ValueArray+2* glyphCount;
			}
			break;
				case 2:
			{
		                    uint16 classRangeCount=(uint16)(ttUSHORT(classDefTable+2));
		                    uint8* classRangeRecords= classDefTable+4;
		                    int32 l=(int32)(0);
		                    int32 r=(int32)(classRangeCount-1);
		                    int32 m=0;
		                    int32 strawStart=0;
		                    int32 strawEnd=0;
		                    int32 needle=(int32)(glyph);
					while(l<= r)
				{
		                        uint8* classRangeRecord;
		                        m=(int32)((l+ r)>>1);
		                        classRangeRecord= classRangeRecords+6* m;
		                        strawStart=(int32)(ttUSHORT(classRangeRecord));
		                        strawEnd=(int32)(ttUSHORT(classRangeRecord+2));
						if((needle)<(strawStart))
		                            r=(int32)(m-1);
						else if((needle)>(strawEnd))
		                            l=(int32)(m+1);
						else
						return(int32)(ttUSHORT(classRangeRecord+4));
				}

		                    classDefTable = classRangeRecords+6* classRangeCount;
			}
			break;
				default:
				{
				}
				break;
			}

			return (int32)(-1);
		}

		public static int32 stbtt__GetGlyphGPOSInfoAdvance(stbtt_fontinfo info, int32 glyph1, int32 glyph2)
		{
			uint16 lookupListOffset = 0;
			uint8* lookupList;
			uint16 lookupCount = 0;
			uint8* data;
			int32 i = 0;
			if (info.gpos == 0)
				return (int32)(0);
			data = info.data + info.gpos;
			if (ttUSHORT(data + 0) != 1)
				return (int32)(0);
			if (ttUSHORT(data + 2) != 0)
				return (int32)(0);
			lookupListOffset = (uint16)(ttUSHORT(data + 8));
			lookupList = data + lookupListOffset;
			lookupCount = (uint16)(ttUSHORT(lookupList));
			for (i = (int32)(0); (i) < (lookupCount); ++i)
			{
				uint16 lookupOffset = (uint16)(ttUSHORT(lookupList + 2 + 2 * i));
				uint8* lookupTable = lookupList + lookupOffset;
				uint16 lookupType = (uint16)(ttUSHORT(lookupTable));
				uint16 subTableCount = (uint16)(ttUSHORT(lookupTable + 4));
				uint8* subTableOffsets = lookupTable + 6;
				switch (lookupType)
				{
				case 2:
				{
		                        int32 sti=0;
						for(sti=(int32)(0);(sti)<(subTableCount); sti++)
					{
		                            uint16 subtableOffset=(uint16)(ttUSHORT(subTableOffsets+2* sti));
		                            uint8* table= lookupTable+ subtableOffset;
		                            uint16 posFormat=(uint16)(ttUSHORT(table));
		                            uint16 coverageOffset=(uint16)(ttUSHORT(table+2));
		                            int32 coverageIndex=(int32)(stbtt__GetCoverageIndex(table+ coverageOffset,(int32)(glyph1)));
							if((coverageIndex)==(-1))
							continue;
							switch(posFormat)
						{
							case 1:
							{
		                                        int32 l=0;
		                                        int32 r=0;
		                                        int32 m=0;
		                                        int32 straw=0;
		                                        int32 needle=0;
		                                        uint16 valueFormat1=(uint16)(ttUSHORT(table+4));
		                                        uint16 valueFormat2=(uint16)(ttUSHORT(table+6));
		                                        int32 valueRecordPairSizeInuint8s=(int32)(2);
		                                        
									// //uint16 pairSetCount=(uint16)(ttUSHORT(table+8));
		                                        uint16 pairPosOffset=(uint16)(ttUSHORT(table+10+2* coverageIndex));
		                                        uint8* pairValueTable= table+ pairPosOffset;
		                                        uint16 pairValueCount=(uint16)(ttUSHORT(pairValueTable));
		                                        uint8* pairValueArray= pairValueTable+2;
									if(valueFormat1!=4)
									return(int32)(0);
									if(valueFormat2!=0)
									return(int32)(0);
		                                        needle=(int32)(glyph2);
		                                        r=(int32)(pairValueCount-1);
		                                        l=(int32)(0);
									while(l<= r)
								{
		                                            uint16 secondGlyph=0;
		                                            uint8* pairValue;
		                                            m=(int32)((l+ r)>>1);
		                                            pairValue= pairValueArray+(2+ valueRecordPairSizeInuint8s)* m;
		                                            secondGlyph=(uint16)(ttUSHORT(pairValue));
		                                            straw=(int32)(secondGlyph);
										if((needle)<(straw))
		                                                r=(int32)(m-1);
										else if((needle)>(straw))
		                                                l=(int32)(m+1);
										else
									{
		                                                int16 xAdvance=(int16)(ttSHORT(pairValue+2));
											return(int32)(xAdvance);
									}
								}
							}
							break;
								case 2:
							{
		                                        uint16 valueFormat1=(uint16)(ttUSHORT(table+4));
		                                        uint16 valueFormat2=(uint16)(ttUSHORT(table+6));
		                                        uint16 classDef1Offset=(uint16)(ttUSHORT(table+8));
		                                        uint16 classDef2Offset=(uint16)(ttUSHORT(table+10));
		                                        int32 glyph1class=
									(int32)(stbtt__GetGlyphClass(table+ classDef1Offset,(int32)(glyph1)));
		                                        int32 glyph2class=
									(int32)(stbtt__GetGlyphClass(table+ classDef2Offset,(int32)(glyph2)));
		                                        uint16 class1Count=(uint16)(ttUSHORT(table+12));
		                                        uint16 class2Count=(uint16)(ttUSHORT(table+14));
									if(valueFormat1!=4)
									return(int32)(0);
									if(valueFormat2!=0)
									return(int32)(0);
									if(((((glyph1class)>=(0))&&((glyph1class)<(class1Count)))&&
									((glyph2class)>=(0)))&&((glyph2class)<(class2Count)))
								{
		                                            uint8* class1Records= table+16;
		                                            uint8* class2Records= class1Records+2*(glyph1class * class2Count);
		                                            int16 xAdvance=(int16)(ttSHORT(class2Records+2* glyph2class));
										return(int32)(xAdvance);
								}
							}
							break;
								default:
							{
								break;
							}
						}
					}

					break;
				}
				default:
					break;
				}
			}

			return (int32)(0);
		}

		public static int32 stbtt_GetGlyphKernAdvance(stbtt_fontinfo info, int32 g1, int32 g2)
		{
			int32 xAdvance = (int32)(0);
			if ((info.gpos) != 0)
				xAdvance += (int32)(stbtt__GetGlyphGPOSInfoAdvance(info, (int32)(g1), (int32)(g2)));
			if ((info.kern) != 0)
				xAdvance += (int32)(stbtt__GetGlyphKernInfoAdvance(info, (int32)(g1), (int32)(g2)));
			return (int32)(xAdvance);
		}

		public static int32 stbtt_GetCodepoint32KernAdvance(stbtt_fontinfo info, int32 ch1, int32 ch2)
		{
			if ((info.kern == 0) && (info.gpos == 0))
				return (int32)(0);
			return (int32)(stbtt_GetGlyphKernAdvance(info, (int32)(stbtt_FindGlyphIndex(info, (int32)(ch1))),
				(int32)(stbtt_FindGlyphIndex(info, (int32)(ch2)))));
		}

		public static void stbtt_GetCodepoint32HMetrics(stbtt_fontinfo info, int32 codepoint32, int32* advanceWidth,
			int32* leftSideBearing)
		{
			stbtt_GetGlyphHMetrics(info, (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32))), advanceWidth,
				leftSideBearing);
		}

		public static void stbtt_GetFontVMetrics(stbtt_fontinfo info, int32* ascent, int32* descent, int32* lineGap)
		{
			if ((ascent) != null)
				*ascent = (int32)(ttSHORT(info.data + info.hhea + 4));
			if ((descent) != null)
				*descent = (int32)(ttSHORT(info.data + info.hhea + 6));
			if ((lineGap) != null)
				*lineGap = (int32)(ttSHORT(info.data + info.hhea + 8));
		}

		public static int32 stbtt_GetFontVMetricsOS2(stbtt_fontinfo info, int32* typoAscent, int32* typoDescent,
			int32* typoLineGap)
		{
			int32 tab = (int32)(stbtt__find_table(info.data, (uint32)(info.fontstart), "OS/2"));
			if (tab == 0)
				return (int32)(0);
			if ((typoAscent) != null)
				*typoAscent = (int32)(ttSHORT(info.data + tab + 68));
			if ((typoDescent) != null)
				*typoDescent = (int32)(ttSHORT(info.data + tab + 70));
			if ((typoLineGap) != null)
				*typoLineGap = (int32)(ttSHORT(info.data + tab + 72));
			return (int32)(1);
		}

		public static void stbtt_GetFontBoundingBox(stbtt_fontinfo info, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			*x0 = (int32)(ttSHORT(info.data + info.head + 36));
			*y0 = (int32)(ttSHORT(info.data + info.head + 38));
			*x1 = (int32)(ttSHORT(info.data + info.head + 40));
			*y1 = (int32)(ttSHORT(info.data + info.head + 42));
		}

		public static float stbtt_ScaleForPixelHeight(stbtt_fontinfo info, float height)
		{
			int32 fheight = (int32)(ttSHORT(info.data + info.hhea + 4) - ttSHORT(info.data + info.hhea + 6));
			return (float)(height / fheight);
		}

		public static float stbtt_ScaleForMappingEmToPixels(stbtt_fontinfo info, float pixels)
		{
			int32 unitsPerEm = (int32)(ttUSHORT(info.data + info.head + 18));
			return (float)(pixels / unitsPerEm);
		}

		public static void stbtt_FreeShape(stbtt_fontinfo info, stbtt_vertex* v)
		{
			Internal.Free(v);
		}

		public static void stbtt_GetGlyphBitmapBoxSubpixel(stbtt_fontinfo font, int32 glyph, float scale_x, float scale_y,
			float shift_x, float shift_y, int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			int32 x0 = (int32)(0);
			int32 y0 = (int32)(0);
			int32 x1 = 0;
			int32 y1 = 0;
			if (stbtt_GetGlyphBox(font, (int32)(glyph), &x0, &y0, &x1, &y1) == 0)
			{
				if ((ix0) != null)
					*ix0 = (int32)(0);
				if ((iy0) != null)
					*iy0 = (int32)(0);
				if ((ix1) != null)
					*ix1 = (int32)(0);
				if ((iy1) != null)
					*iy1 = (int32)(0);
			}
			else
			{
				if ((ix0) != null)
					*ix0 = ((int32)(Math.Floor((double)(x0 * scale_x + shift_x))));
				if ((iy0) != null)
					*iy0 = ((int32)(Math.Floor((double)(-y1 * scale_y + shift_y))));
				if ((ix1) != null)
					*ix1 = ((int32)(Math.Ceiling((double)(x1 * scale_x + shift_x))));
				if ((iy1) != null)
					*iy1 = ((int32)(Math.Ceiling((double)(-y0 * scale_y + shift_y))));
			}
		}

		public static void stbtt_GetGlyphBitmapBox(stbtt_fontinfo font, int32 glyph, float scale_x, float scale_y,
			int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			stbtt_GetGlyphBitmapBoxSubpixel(font, (int32)(glyph), (float)(scale_x), (float)(scale_y), (float)(0.0f),
				(float)(0.0f), ix0, iy0, ix1, iy1);
		}

		public static void stbtt_GetCodepoint32BitmapBoxSubpixel(stbtt_fontinfo font, int32 codepoint32, float scale_x,
			float scale_y, float shift_x, float shift_y, int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			stbtt_GetGlyphBitmapBoxSubpixel(font, (int32)(stbtt_FindGlyphIndex(font, (int32)(codepoint32))),
				(float)(scale_x), (float)(scale_y), (float)(shift_x), (float)(shift_y), ix0, iy0, ix1, iy1);
		}

		public static void stbtt_GetCodepoint32BitmapBox(stbtt_fontinfo font, int32 codepoint32, float scale_x, float scale_y,
			int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			stbtt_GetCodepoint32BitmapBoxSubpixel(font, (int32)(codepoint32), (float)(scale_x), (float)(scale_y),
				(float)(0.0f), (float)(0.0f), ix0, iy0, ix1, iy1);
		}

		public static void* stbtt__hheap_alloc(stbtt__hheap* hh, uint64 size)
		{
			if ((hh.first_free) != null)
			{
				void* p = hh.first_free;
				hh.first_free = *(void**)(p);
				return p;
			}
			else
			{
				if ((hh.num_remaining_in_head_chunk) == (0))
				{
					int32 count = (int32)((size)< (32) ? 2000 :(size)< (128) ? 800 : 100);
					stbtt__hheap_chunk* c =
						(stbtt__hheap_chunk*)(Internal.Malloc(
						(int)((uint64)sizeof(stbtt__hheap_chunk) + size * (uint64)(count))));
					if ((c) == (null))
						return (null);
					c.next = hh.head;
					hh.head = c;
					hh.num_remaining_in_head_chunk = (int32)(count);
				}

				--hh.num_remaining_in_head_chunk;
				return (int8*)(hh.head) + sizeof(stbtt__hheap_chunk) +
					size * (uint64)hh.num_remaining_in_head_chunk;
			}
		}

		public static void stbtt__hheap_free(stbtt__hheap* hh, void* p)
		{
			*(void**)(p) = hh.first_free;
			hh.first_free = p;
		}

		public static void stbtt__hheap_cleanup(stbtt__hheap* hh)
		{
			stbtt__hheap_chunk* c = hh.head;
			while ((c) != null)
			{
				stbtt__hheap_chunk* n = c.next;
				Internal.Free(c);
				c = n;
			}
		}

		public static stbtt__active_edge* stbtt__new_active(stbtt__hheap* hh, stbtt__edge* e, int32 off_x,
			float start_point32)
		{
			stbtt__active_edge* z =
				(stbtt__active_edge*)(stbtt__hheap_alloc(hh, (uint64)(sizeof(stbtt__active_edge))));
			float dxdy = (float)((e.x1 - e.x0) / (e.y1 - e.y0));
			if (z == null)
				return z;
			z.fdx = (float)(dxdy);
			z.fdy = (float)(dxdy!= 0.0f ? (1.0f / dxdy) : 0.0f);
			z.fx = (float)(e.x0 + dxdy * (start_point32 - e.y0));
			z.fx -= (float)(off_x);
			z.direction = (float)((e.invert)!= 0 ? 1.0f : -1.0f);
			z.sy = (float)(e.y0);
			z.ey = (float)(e.y1);
			z.next = null;
			return z;
		}

		public static void stbtt__handle_clipped_edge(float* scanline, int32 x, stbtt__active_edge* e, float x0, float y0,
			float x1, float y1)
		{
			var x0, y0, x1, y1;

			if ((y0) == (y1))
				return;
			if ((y0) > (e.ey))
				return;
			if ((y1) < (e.sy))
				return;
			if ((y0) < (e.sy))
			{
				x0 += (float)((x1 - x0) * (e.sy - y0) / (y1 - y0));
				y0 = (float)(e.sy);
			}

			if ((y1) > (e.ey))
			{
				x1 += (float)((x1 - x0) * (e.ey - y1) / (y1 - y0));
				y1 = (float)(e.ey);
			}

			
			/*if ((x0) == (x))
			{
			}
			else if ((x0) == (x + 1))
			{
			}
			else if (x0 <= x)
			{
			}
			else if ((x0) >= (x + 1))
			{
			}
			else
			{
			}*/

			if ((x0 <= x) && (x1 <= x))
			{
				scanline[x] += (float)(e.direction * (y1 - y0));
			}
			else if (((x0) >= (x + 1)) && ((x1) >= (x + 1)))
			{
			}
			else
			{
				scanline[x] += (float)(e.direction * (y1 - y0) * (1 - ((x0 - x) + (x1 - x)) / 2));
			}
		}

		public static void stbtt__fill_active_edges_new(float* scanline, float* scanline_fill, int32 len,
			stbtt__active_edge* e, float y_top)
		{
			var e;

			float y_bottom = (float)(y_top + 1);
			while ((e) != null)
			{
				if ((e.fdx) == (0))
				{
					float x0 = (float)(e.fx);
					if ((x0) < (len))
					{
						if ((x0) >= (0))
						{
							stbtt__handle_clipped_edge(scanline, (int32)(x0), e, (float)(x0), (float)(y_top),
								(float)(x0), (float)(y_bottom));
							stbtt__handle_clipped_edge(scanline_fill - 1, (int32)((int32)(x0) + 1), e, (float)(x0),
								(float)(y_top), (float)(x0), (float)(y_bottom));
						}
						else
						{
							stbtt__handle_clipped_edge(scanline_fill - 1, (int32)(0), e, (float)(x0), (float)(y_top),
								(float)(x0), (float)(y_bottom));
						}
					}
				}
				else
				{
					float x0 = (float)(e.fx);
					float dx = (float)(e.fdx);
					float xb = (float)(x0 + dx);
					float x_top = 0;
					float x_bottom = 0;
					float sy0 = 0;
					float sy1 = 0;
					float dy = (float)(e.fdy);
					if ((e.sy) > (y_top))
					{
						x_top = (float)(x0 + dx * (e.sy - y_top));
						sy0 = (float)(e.sy);
					}
					else
					{
						x_top = (float)(x0);
						sy0 = (float)(y_top);
					}

					if ((e.ey) < (y_bottom))
					{
						x_bottom = (float)(x0 + dx * (e.ey - y_top));
						sy1 = (float)(e.ey);
					}
					else
					{
						x_bottom = (float)(xb);
						sy1 = (float)(y_bottom);
					}

					if (((((x_top) >= (0)) && ((x_bottom) >= (0))) && ((x_top) < (len))) && ((x_bottom) < (len)))
					{
						if (((int32)(x_top)) == ((int32)(x_bottom)))
						{
							float height = 0;
							int32 x = (int32)(x_top);
							height = (float)(sy1 - sy0);
							scanline[x] += (float)(e.direction * (1 - ((x_top - x) + (x_bottom - x)) / 2) * height);
							scanline_fill[x] += (float)(e.direction * height);
						}
						else
						{
							int32 x = 0;
							int32 x1 = 0;
							int32 x2 = 0;
							float y_crossing = 0;
							float step = 0;
							float sign = 0;
							float area = 0;
							if ((x_top) > (x_bottom))
							{
								float t = 0;
								sy0 = (float)(y_bottom - (sy0 - y_top));
								sy1 = (float)(y_bottom - (sy1 - y_top));
								t = (float)(sy0);
								sy0 = (float)(sy1);
								sy1 = (float)(t);
								t = (float)(x_bottom);
								x_bottom = (float)(x_top);
								x_top = (float)(t);
								dx = (float)(-dx);
								dy = (float)(-dy);
								t = (float)(x0);
								x0 = (float)(xb);
								xb = (float)(t);
							}

							x1 = ((int32)(x_top));
							x2 = ((int32)(x_bottom));
							y_crossing = (float)((x1 + 1 - x0) * dy + y_top);
							sign = (float)(e.direction);
							area = (float)(sign * (y_crossing - sy0));
							scanline[x1] += (float)(area * (1 - ((x_top - x1) + (x1 + 1 - x1)) / 2));
							step = (float)(sign * dy);
							for (x = (int32)(x1 + 1); (x) < (x2); ++x)
							{
								scanline[x] += (float)(area + step / 2);
								area += (float)(step);
							}

							y_crossing += (float)(dy * (x2 - (x1 + 1)));
							scanline[x2] +=
								(float)(area + sign * (1 - ((x2 - x2) + (x_bottom - x2)) / 2) * (sy1 - y_crossing));
							scanline_fill[x2] += (float)(sign * (sy1 - sy0));
						}
					}
					else
					{
						int32 x = 0;
						for (x = (int32)(0); (x) < (len); ++x)
						{
							float y0 = (float)(y_top);
							float x1 = (float)(x);
							float x2 = (float)(x + 1);
							float x3 = (float)(xb);
							float y3 = (float)(y_bottom);
							float y1 = (float)((x - x0) / dx + y_top);
							float y2 = (float)((x + 1 - x0) / dx + y_top);
							if (((x0) < (x1)) && ((x3) > (x2)))
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x1), (float)(y1));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x1), (float)(y1),
									(float)(x2), (float)(y2));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x2), (float)(y2),
									(float)(x3), (float)(y3));
							}
							else if (((x3) < (x1)) && ((x0) > (x2)))
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x2), (float)(y2));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x2), (float)(y2),
									(float)(x1), (float)(y1));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x1), (float)(y1),
									(float)(x3), (float)(y3));
							}
							else if (((x0) < (x1)) && ((x3) > (x1)))
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x1), (float)(y1));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x1), (float)(y1),
									(float)(x3), (float)(y3));
							}
							else if (((x3) < (x1)) && ((x0) > (x1)))
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x1), (float)(y1));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x1), (float)(y1),
									(float)(x3), (float)(y3));
							}
							else if (((x0) < (x2)) && ((x3) > (x2)))
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x2), (float)(y2));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x2), (float)(y2),
									(float)(x3), (float)(y3));
							}
							else if (((x3) < (x2)) && ((x0) > (x2)))
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x2), (float)(y2));
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x2), (float)(y2),
									(float)(x3), (float)(y3));
							}
							else
							{
								stbtt__handle_clipped_edge(scanline, (int32)(x), e, (float)(x0), (float)(y0),
									(float)(x3), (float)(y3));
							}
						}
					}
				}

				e = e.next;
			}
		}

		public static void stbtt__rasterize_sorted_edges(stbtt__bitmap* result, stbtt__edge* e, int32 n, int32 vsubsample,
			int32 off_x, int32 off_y)
		{
			var e;

			stbtt__hheap hh = stbtt__hheap();
			stbtt__active_edge* active = (null);
			int32 y = 0;
			int32 j = (int32)(0);
			int32 i = 0;
			let sd = scope float[129];
			float* scanline_data = &sd[0];
			float* scanline;
			float* scanline2;
			if ((result.w) > (64))
				scanline = (float*)(Internal.Malloc((int)((result.w * 2 + 1) * sizeof(float))));
			else
				scanline = scanline_data;
			scanline2 = scanline + result.w;
			y = (int32)(off_y);
			e[n].y0 = (float)((float)(off_y + result.h) + 1);
			while ((j) < (result.h))
			{
				float scan_y_top = (float)(y + 0.0f);
				float scan_y_bottom = (float)(y + 1.0f);
				stbtt__active_edge** step = &active;
				Internal.MemSet(scanline, (int32)(0), (int)(result.w * sizeof(float)));
				Internal.MemSet(scanline2, (int32)(0), (int)((result.w + 1) * sizeof(float)));
				while ((*step) != null)
				{
					stbtt__active_edge* z = *step;
					if (z.ey <= scan_y_top)
					{
						*step = z.next;
						z.direction = (float)(0);
						stbtt__hheap_free(&hh, z);
					}
					else
					{
						step = &((*step).next);
					}
				}

				while (e.y0 <= scan_y_bottom)
				{
					if (e.y0 != e.y1)
					{
						stbtt__active_edge* z = stbtt__new_active(&hh, e, (int32)(off_x), (float)(scan_y_top));
						if (z != (null))
						{
							if (((j) == (0)) && (off_y != 0))
							{
								if ((z.ey) < (scan_y_top))
								{
									z.ey = (float)(scan_y_top);
								}
							}

							z.next = active;
							active = z;
						}
					}

					++e;
				}

				if ((active) != null)
					stbtt__fill_active_edges_new(scanline, scanline2 + 1, (int32)(result.w), active,
						(float)(scan_y_top));
				{
					float sum = (float)(0);
					for (i = (int32)(0); (i) < (result.w); ++i)
					{
						float k = 0;
						int32 m = 0;
						sum += (float)(scanline2[i]);
						k = (float)(scanline[i] + sum);
						k = (float)((float)(Math.Abs((double)(k))) * 255 + 0.5f);
						m = ((int32)(k));
						if ((m) > (255))
							m = (int32)(255);
						result.pixels[j * result.stride + i] = ((uint8)(m));
					}
				}
				step = &active;
				while ((*step) != null)
				{
					stbtt__active_edge* z = *step;
					z.fx += (float)(z.fdx);
					step = &((*step).next);
				}

				++y;
				++j;
			}

			stbtt__hheap_cleanup(&hh);
			if (scanline != scanline_data)
				Internal.Free(scanline);
		}

		public static void stbtt__sort_edges_ins_sort(stbtt__edge* p, int32 n)
		{
			int32 i = 0;
			int32 j = 0;
			for (i = (int32)(1); (i) < (n); ++i)
			{
				stbtt__edge t = (stbtt__edge)(p[i]);
				stbtt__edge* a = &t;
				j = (int32)(i);
				while ((j) > (0))
				{
					stbtt__edge* b = &p[j - 1];
					int32 c = (int32)(a.y0< b.y0 ? 1 : 0);
					if (c == 0)
						break;
					p[j] = (stbtt__edge)(p[j - 1]);
					--j;
				}

				if (i != j)
					p[j] = (stbtt__edge)(t);
			}
		}

		public static void stbtt__sort_edges_quicksort(stbtt__edge* p, int32 n)
		{
			var p, n;

			while ((n) > (12))
			{
				stbtt__edge t = stbtt__edge();
				int32 c01 = 0;
				int32 c12 = 0;
				int32 c = 0;
				int32 m = 0;
				int32 i = 0;
				int32 j = 0;
				m = (int32)(n >> 1);
				c01 = (int32)(((&p[0]).y0)< ((&p[m]).y0) ? 1 : 0);
				c12 = (int32)(((&p[m]).y0)< ((&p[n - 1]).y0) ? 1 : 0);
				if (c01 != c12)
				{
					int32 z = 0;
					c = (int32)(((&p[0]).y0)< ((&p[n - 1]).y0) ? 1 : 0);
					z = (int32)(((c) == (c12)) ? 0 : n - 1);
					t = (stbtt__edge)(p[z]);
					p[z] = (stbtt__edge)(p[m]);
					p[m] = (stbtt__edge)(t);
				}

				t = (stbtt__edge)(p[0]);
				p[0] = (stbtt__edge)(p[m]);
				p[m] = (stbtt__edge)(t);
				i = (int32)(1);
				j = (int32)(n - 1);
				for (;;)
				{
					for (;; ++i)
					{
						if (!(((&p[i]).y0) < ((&p[0]).y0)))
							break;
					}

					for (;; --j)
					{
						if (!(((&p[0]).y0) < ((&p[j]).y0)))
							break;
					}

					if ((i) >= (j))
						break;
					t = (stbtt__edge)(p[i]);
					p[i] = (stbtt__edge)(p[j]);
					p[j] = (stbtt__edge)(t);
					++i;
					--j;
				}

				if ((j) < (n - i))
				{
					stbtt__sort_edges_quicksort(p, (int32)(j));
					p = p + i;
					n = (int32)(n - i);
				}
				else
				{
					stbtt__sort_edges_quicksort(p + i, (int32)(n - i));
					n = (int32)(j);
				}
			}
		}

		public static void stbtt__sort_edges(stbtt__edge* p, int32 n)
		{
			stbtt__sort_edges_quicksort(p, (int32)(n));
			stbtt__sort_edges_ins_sort(p, (int32)(n));
		}

		public static void stbtt__rasterize(stbtt__bitmap* result, stbtt__point32* pts, int32* wcount, int32 windings,
			float scale_x, float scale_y, float shift_x, float shift_y, int32 off_x, int32 off_y, int32 invert)
		{
			float y_scale_inv = (float)((invert)!= 0 ? -scale_y : scale_y);
			stbtt__edge* e;
			int32 n = 0;
			int32 i = 0;
			int32 j = 0;
			int32 k = 0;
			int32 m = 0;
			int32 vsubsample = (int32)(1);
			n = (int32)(0);
			for (i = (int32)(0); (i) < (windings); ++i)
			{
				n += (int32)(wcount[i]);
			}

			e = (stbtt__edge*)(Internal.Malloc((int)(sizeof(stbtt__edge) * (n + 1))));
			if ((e) == (null))
				return;
			n = (int32)(0);
			m = (int32)(0);
			for (i = (int32)(0); (i) < (windings); ++i)
			{
				stbtt__point32* p = pts + m;
				m += (int32)(wcount[i]);
				j = (int32)(wcount[i] - 1);
				for (k = (int32)(0); (k) < (wcount[i]); j = (int32)(k++))
				{
					int32 a = (int32)(k);
					int32 b = (int32)(j);
					if ((p[j].y) == (p[k].y))
						continue;
					e[n].invert = (int32)(0);
					if ((((invert) != 0) && ((p[j].y) > (p[k].y))) || ((invert == 0) && ((p[j].y) < (p[k].y))))
					{
						e[n].invert = (int32)(1);
						a = (int32)(j);
						b = (int32)(k);
					}

					e[n].x0 = (float)(p[a].x * scale_x + shift_x);
					e[n].y0 = (float)((p[a].y * y_scale_inv + shift_y) * vsubsample);
					e[n].x1 = (float)(p[b].x * scale_x + shift_x);
					e[n].y1 = (float)((p[b].y * y_scale_inv + shift_y) * vsubsample);
					++n;
				}
			}

			stbtt__sort_edges(e, (int32)(n));
			stbtt__rasterize_sorted_edges(result, e, (int32)(n), (int32)(vsubsample), (int32)(off_x), (int32)(off_y));
			Internal.Free(e);
		}

		public static void stbtt__add_point32(stbtt__point32* point32s, int32 n, float x, float y)
		{
			if (point32s == null)
				return;
			point32s[n].x = (float)(x);
			point32s[n].y = (float)(y);
		}

		public static int32 stbtt__tesselate_curve(stbtt__point32* point32s, int32* num_point32s, float x0, float y0, float x1,
			float y1, float x2, float y2, float objspace_flatness_squared, int32 n)
		{
			float mx = (float)((x0 + 2 * x1 + x2) / 4);
			float my = (float)((y0 + 2 * y1 + y2) / 4);
			float dx = (float)((x0 + x2) / 2 - mx);
			float dy = (float)((y0 + y2) / 2 - my);
			if ((n) > (16))
				return (int32)(1);
			if ((dx * dx + dy * dy) > (objspace_flatness_squared))
			{
				stbtt__tesselate_curve(point32s, num_point32s, (float)(x0), (float)(y0), (float)((x0 + x1) / 2.0f),
					(float)((y0 + y1) / 2.0f), (float)(mx), (float)(my), (float)(objspace_flatness_squared),
					(int32)(n + 1));
				stbtt__tesselate_curve(point32s, num_point32s, (float)(mx), (float)(my), (float)((x1 + x2) / 2.0f),
					(float)((y1 + y2) / 2.0f), (float)(x2), (float)(y2), (float)(objspace_flatness_squared),
					(int32)(n + 1));
			}
			else
			{
				stbtt__add_point32(point32s, (int32)(*num_point32s), (float)(x2), (float)(y2));
				*num_point32s = (int32)(*num_point32s + 1);
			}

			return (int32)(1);
		}

		public static void stbtt__tesselate_cubic(stbtt__point32* point32s, int32* num_point32s, float x0, float y0, float x1,
			float y1, float x2, float y2, float x3, float y3, float objspace_flatness_squared, int32 n)
		{
			float dx0 = (float)(x1 - x0);
			float dy0 = (float)(y1 - y0);
			float dx1 = (float)(x2 - x1);
			float dy1 = (float)(y2 - y1);
			float dx2 = (float)(x3 - x2);
			float dy2 = (float)(y3 - y2);
			float dx = (float)(x3 - x0);
			float dy = (float)(y3 - y0);
			float int64len = (float)(Math.Sqrt((double)(dx0 * dx0 + dy0 * dy0)) +
				Math.Sqrt((double)(dx1 * dx1 + dy1 * dy1)) +
				Math.Sqrt((double)(dx2 * dx2 + dy2 * dy2)));
			float int16len = (float)(Math.Sqrt((double)(dx * dx + dy * dy)));
			float flatness_squared = (float)(int64len * int64len - int16len * int16len);
			if ((n) > (16))
				return;
			if ((flatness_squared) > (objspace_flatness_squared))
			{
				float x01 = (float)((x0 + x1) / 2);
				float y01 = (float)((y0 + y1) / 2);
				float x12 = (float)((x1 + x2) / 2);
				float y12 = (float)((y1 + y2) / 2);
				float x23 = (float)((x2 + x3) / 2);
				float y23 = (float)((y2 + y3) / 2);
				float xa = (float)((x01 + x12) / 2);
				float ya = (float)((y01 + y12) / 2);
				float xb = (float)((x12 + x23) / 2);
				float yb = (float)((y12 + y23) / 2);
				float mx = (float)((xa + xb) / 2);
				float my = (float)((ya + yb) / 2);
				stbtt__tesselate_cubic(point32s, num_point32s, (float)(x0), (float)(y0), (float)(x01), (float)(y01),
					(float)(xa), (float)(ya), (float)(mx), (float)(my), (float)(objspace_flatness_squared),
					(int32)(n + 1));
				stbtt__tesselate_cubic(point32s, num_point32s, (float)(mx), (float)(my), (float)(xb), (float)(yb),
					(float)(x23), (float)(y23), (float)(x3), (float)(y3), (float)(objspace_flatness_squared),
					(int32)(n + 1));
			}
			else
			{
				stbtt__add_point32(point32s, (int32)(*num_point32s), (float)(x3), (float)(y3));
				*num_point32s = (int32)(*num_point32s + 1);
			}
		}

		public static stbtt__point32* stbtt_FlattenCurves(stbtt_vertex* vertices, int32 num_verts, float objspace_flatness,
			int32** contour_lengths, int32* num_contours)
		{
			stbtt__point32* point32s = null;
			int32 num_point32s = (int32)(0);
			float objspace_flatness_squared = (float)(objspace_flatness * objspace_flatness);
			int32 i = 0;
			int32 n = (int32)(0);
			int32 start = (int32)(0);
			int32 pass = 0;
			for (i = (int32)(0); (i) < (num_verts); ++i)
			{
				if ((vertices[i].type) == (STBTT_vmove))
					++n;
			}

			*num_contours = (int32)(n);
			if ((n) == (0))
				return null;
			*contour_lengths = (int32*)(Internal.Malloc((int)(sizeof(int32) * n)));
			if ((*contour_lengths) == (null))
			{
				*num_contours = (int32)(0);
				return null;
			}

			for (pass = (int32)(0); (pass) < (2); ++pass)
			{
				float x = (float)(0);
				float y = (float)(0);
				if ((pass) == (1))
				{
					point32s = (stbtt__point32*)(Internal.Malloc((int)(num_point32s * sizeof(stbtt__point32))));
					if ((point32s) == (null))
					{
						Internal.Free(point32s);
						Internal.Free(*contour_lengths);
						*contour_lengths = null;
						*num_contours = (int32)(0);
						return (null);
					}
				}

				num_point32s = (int32)(0);
				n = (int32)(-1);
				for (i = (int32)(0); (i) < (num_verts); ++i)
				{
					switch (vertices[i].type)
					{
					case STBTT_vmove:
						if ((n) >= (0))
							(*contour_lengths)[n] = (int32)(num_point32s - start);
						++n;
						start = (int32)(num_point32s);
						x = (float)(vertices[i].x);
						y = (float)(vertices[i].y);
						stbtt__add_point32(point32s, (int32)(num_point32s++), (float)(x), (float)(y));
						break;
					case STBTT_vline:
						x = (float)(vertices[i].x);
						y = (float)(vertices[i].y);
						stbtt__add_point32(point32s, (int32)(num_point32s++), (float)(x), (float)(y));
						break;
					case STBTT_vcurve:
						stbtt__tesselate_curve(point32s, &num_point32s, (float)(x), (float)(y),
							(float)(vertices[i].cx), (float)(vertices[i].cy), (float)(vertices[i].x),
							(float)(vertices[i].y), (float)(objspace_flatness_squared), (int32)(0));
						x = (float)(vertices[i].x);
						y = (float)(vertices[i].y);
						break;
					case STBTT_vcubic:
						stbtt__tesselate_cubic(point32s, &num_point32s, (float)(x), (float)(y),
							(float)(vertices[i].cx), (float)(vertices[i].cy), (float)(vertices[i].cx1),
							(float)(vertices[i].cy1), (float)(vertices[i].x), (float)(vertices[i].y),
							(float)(objspace_flatness_squared), (int32)(0));
						x = (float)(vertices[i].x);
						y = (float)(vertices[i].y);
						break;
					}
				}

				(*contour_lengths)[n] = (int32)(num_point32s - start);
			}

			return point32s;
		}

		public static void stbtt_Rasterize(stbtt__bitmap* result, float flatness_in_pixels, stbtt_vertex* vertices,
			int32 num_verts, float scale_x, float scale_y, float shift_x, float shift_y, int32 x_off, int32 y_off, int32 invert)
		{
			float scale = (float)((scale_x)> (scale_y) ? scale_y : scale_x);
			int32 winding_count = (int32)(0);
			int32* winding_lengths = (null);
			stbtt__point32* windings = stbtt_FlattenCurves(vertices, (int32)(num_verts),
				(float)(flatness_in_pixels / scale), &winding_lengths, &winding_count);
			if ((windings) != null)
			{
				stbtt__rasterize(result, windings, winding_lengths, (int32)(winding_count), (float)(scale_x),
					(float)(scale_y), (float)(shift_x), (float)(shift_y), (int32)(x_off), (int32)(y_off),
					(int32)(invert));
				Internal.Free(winding_lengths);
				Internal.Free(windings);
			}
		}

		public static void stbtt_FreeBitmap(uint8* bitmap)
		{
			Internal.Free(bitmap);
		}

		public static uint8* stbtt_GetGlyphBitmapSubpixel(stbtt_fontinfo info, float scale_x, float scale_y,
			float shift_x, float shift_y, int32 glyph, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			var scale_x, scale_y;

			int32 ix0 = 0;
			int32 iy0 = 0;
			int32 ix1 = 0;
			int32 iy1 = 0;
			stbtt__bitmap gbm = stbtt__bitmap();
			stbtt_vertex* vertices = ?;
			int32 num_verts = (int32)(stbtt_GetGlyphShape(info, (int32)(glyph), &vertices));
			if ((scale_x) == (0))
				scale_x = (float)(scale_y);
			if ((scale_y) == (0))
			{
				if ((scale_x) == (0))
				{
					Internal.Free(vertices);
					return (null);
				}

				scale_y = (float)(scale_x);
			}

			stbtt_GetGlyphBitmapBoxSubpixel(info, (int32)(glyph), (float)(scale_x), (float)(scale_y),
				(float)(shift_x), (float)(shift_y), &ix0, &iy0, &ix1, &iy1);
			gbm.w = (int32)(ix1 - ix0);
			gbm.h = (int32)(iy1 - iy0);
			gbm.pixels = (null);
			if ((width) != null)
				*width = (int32)(gbm.w);
			if ((height) != null)
				*height = (int32)(gbm.h);
			if ((xoff) != null)
				*xoff = (int32)(ix0);
			if ((yoff) != null)
				*yoff = (int32)(iy0);
			if (((gbm.w) != 0) && ((gbm.h) != 0))
			{
				gbm.pixels = (uint8*)(Internal.Malloc((int)(gbm.w * gbm.h)));
				if ((gbm.pixels) != null)
				{
					gbm.stride = (int32)(gbm.w);
					stbtt_Rasterize(&gbm, (float)(0.35f), vertices, (int32)(num_verts), (float)(scale_x),
						(float)(scale_y), (float)(shift_x), (float)(shift_y), (int32)(ix0), (int32)(iy0), (int32)(1));
				}
			}

			Internal.Free(vertices);
			return gbm.pixels;
		}

		public static uint8* stbtt_GetGlyphBitmap(stbtt_fontinfo info, float scale_x, float scale_y, int32 glyph,
			int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetGlyphBitmapSubpixel(info, (float)(scale_x), (float)(scale_y), (float)(0.0f),
				(float)(0.0f), (int32)(glyph), width, height, xoff, yoff);
		}

		public static void stbtt_MakeGlyphBitmapSubpixel(stbtt_fontinfo info, uint8* output, int32 out_w, int32 out_h,
			int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 glyph)
		{
			int32 ix0 = 0;
			int32 iy0 = 0;
			stbtt_vertex* vertices = ?;
			int32 num_verts = (int32)(stbtt_GetGlyphShape(info, (int32)(glyph), &vertices));
			stbtt__bitmap gbm = stbtt__bitmap();
			stbtt_GetGlyphBitmapBoxSubpixel(info, (int32)(glyph), (float)(scale_x), (float)(scale_y),
				(float)(shift_x), (float)(shift_y), &ix0, &iy0, null, null);
			gbm.pixels = output;
			gbm.w = (int32)(out_w);
			gbm.h = (int32)(out_h);
			gbm.stride = (int32)(out_stride);
			if (((gbm.w) != 0) && ((gbm.h) != 0))
				stbtt_Rasterize(&gbm, (float)(0.35f), vertices, (int32)(num_verts), (float)(scale_x),
					(float)(scale_y), (float)(shift_x), (float)(shift_y), (int32)(ix0), (int32)(iy0), (int32)(1));
			Internal.Free(vertices);
		}

		public static void stbtt_MakeGlyphBitmap(stbtt_fontinfo info, uint8* output, int32 out_w, int32 out_h,
			int32 out_stride, float scale_x, float scale_y, int32 glyph)
		{
			stbtt_MakeGlyphBitmapSubpixel(info, output, (int32)(out_w), (int32)(out_h), (int32)(out_stride),
				(float)(scale_x), (float)(scale_y), (float)(0.0f), (float)(0.0f), (int32)(glyph));
		}

		public static uint8* stbtt_GetCodepoint32BitmapSubpixel(stbtt_fontinfo info, float scale_x, float scale_y,
			float shift_x, float shift_y, int32 codepoint32, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetGlyphBitmapSubpixel(info, (float)(scale_x), (float)(scale_y), (float)(shift_x),
				(float)(shift_y), (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32))), width, height, xoff, yoff);
		}

		public static void stbtt_MakeCodepoint32BitmapSubpixelPrefilter(stbtt_fontinfo info, uint8* output, int32 out_w,
			int32 out_h, int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 oversample_x,
			int32 oversample_y, float* sub_x, float* sub_y, int32 codepoint32)
		{
			stbtt_MakeGlyphBitmapSubpixelPrefilter(info, output, (int32)(out_w), (int32)(out_h), (int32)(out_stride),
				(float)(scale_x), (float)(scale_y), (float)(shift_x), (float)(shift_y), (int32)(oversample_x),
				(int32)(oversample_y), sub_x, sub_y, (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32))));
		}

		public static void stbtt_MakeCodepoint32BitmapSubpixel(stbtt_fontinfo info, uint8* output, int32 out_w, int32 out_h,
			int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 codepoint32)
		{
			stbtt_MakeGlyphBitmapSubpixel(info, output, (int32)(out_w), (int32)(out_h), (int32)(out_stride),
				(float)(scale_x), (float)(scale_y), (float)(shift_x), (float)(shift_y),
				(int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32))));
		}

		public static uint8* stbtt_GetCodepoint32Bitmap(stbtt_fontinfo info, float scale_x, float scale_y, int32 codepoint32,
			int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetCodepoint32BitmapSubpixel(info, (float)(scale_x), (float)(scale_y), (float)(0.0f),
				(float)(0.0f), (int32)(codepoint32), width, height, xoff, yoff);
		}

		public static void stbtt_MakeCodepoint32Bitmap(stbtt_fontinfo info, uint8* output, int32 out_w, int32 out_h,
			int32 out_stride, float scale_x, float scale_y, int32 codepoint32)
		{
			stbtt_MakeCodepoint32BitmapSubpixel(info, output, (int32)(out_w), (int32)(out_h), (int32)(out_stride),
				(float)(scale_x), (float)(scale_y), (float)(0.0f), (float)(0.0f), (int32)(codepoint32));
		}

		public static int32 stbtt_BakeFontBitmap_internal(uint8* data, int32 offset, float pixel_height, uint8* pixels,
			int32 pw, int32 ph, int32 first_char, int32 num_chars, stbtt_bakedchar* chardata)
		{
			float scale = 0;
			int32 x = 0;
			int32 y = 0;
			int32 bottom_y = 0;
			int32 i = 0;
			stbtt_fontinfo f = scope stbtt_fontinfo();
			if (stbtt_InitFont(f, data, (int32)(offset)) == 0)
				return (int32)(-1);
			Internal.MemSet(pixels, (int32)(0), (int)(pw * ph));
			x = (int32)(y = (int32)(1));
			bottom_y = (int32)(1);
			scale = (float)(stbtt_ScaleForPixelHeight(f, (float)(pixel_height)));
			for (i = (int32)(0); (i) < (num_chars); ++i)
			{
				int32 advance = 0;
				int32 lsb = 0;
				int32 x0 = 0;
				int32 y0 = 0;
				int32 x1 = 0;
				int32 y1 = 0;
				int32 gw = 0;
				int32 gh = 0;
				int32 g = (int32)(stbtt_FindGlyphIndex(f, (int32)(first_char + i)));
				stbtt_GetGlyphHMetrics(f, (int32)(g), &advance, &lsb);
				stbtt_GetGlyphBitmapBox(f, (int32)(g), (float)(scale), (float)(scale), &x0, &y0, &x1, &y1);
				gw = (int32)(x1 - x0);
				gh = (int32)(y1 - y0);
				if ((x + gw + 1) >= (pw))
				{
					y = (int32)(bottom_y);
					x = (int32)(1);
				}

				if ((y + gh + 1) >= (ph))
					return (int32)(-i);
				stbtt_MakeGlyphBitmap(f, pixels + x + y * pw, (int32)(gw), (int32)(gh), (int32)(pw), (float)(scale),
					(float)(scale), (int32)(g));
				chardata[i].x0 = (uint16)((int16)(x));
				chardata[i].y0 = (uint16)((int16)(y));
				chardata[i].x1 = (uint16)((int16)(x + gw));
				chardata[i].y1 = (uint16)((int16)(y + gh));
				chardata[i].xadvance = (float)(scale * advance);
				chardata[i].xoff = ((float)(x0));
				chardata[i].yoff = ((float)(y0));
				x = (int32)(x + gw + 1);
				if ((y + gh + 1) > (bottom_y))
					bottom_y = (int32)(y + gh + 1);
			}

			return (int32)(bottom_y);
		}

		public static void stbtt_GetBakedQuad(stbtt_bakedchar* chardata, int32 pw, int32 ph, int32 char_index, float* xpos,
			float* ypos, stbtt_aligned_quad* q, int32 opengl_fillrule)
		{
			float d3d_bias = (float)((opengl_fillrule)!= 0 ? 0 : -0.5f);
			float ipw = (float)(1.0f / pw);
			float iph = (float)(1.0f / ph);
			stbtt_bakedchar* b = chardata + char_index;
			int32 round_x = ((int32)(Math.Floor((double)((*xpos + b.xoff) + 0.5f))));
			int32 round_y = ((int32)(Math.Floor((double)((*ypos + b.yoff) + 0.5f))));
			q.x0 = (float)(round_x + d3d_bias);
			q.y0 = (float)(round_y + d3d_bias);
			q.x1 = (float)(round_x + b.x1 - b.x0 + d3d_bias);
			q.y1 = (float)(round_y + b.y1 - b.y0 + d3d_bias);
			q.s0 = (float)(b.x0 * ipw);
			q.t0 = (float)(b.y0 * iph);
			q.s1 = (float)(b.x1 * ipw);
			q.t1 = (float)(b.y1 * iph);
			*xpos += (float)(b.xadvance);
		}

		public static void stbrp_init_target(stbrp_context* con, int32 pw, int32 ph, stbrp_node* nodes, int32 num_nodes)
		{
			con.width = (int32)(pw);
			con.height = (int32)(ph);
			con.x = (int32)(0);
			con.y = (int32)(0);
			con.bottom_y = (int32)(0);
		}

		public static void stbrp_pack_rects(stbrp_context* con, stbrp_rect* rects, int32 num_rects)
		{
			int32 i = 0;
			for (i = (int32)(0); (i) < (num_rects); ++i)
			{
				if ((con.x + rects[i].w) > (con.width))
				{
					con.x = (int32)(0);
					con.y = (int32)(con.bottom_y);
				}

				if ((con.y + rects[i].h) > (con.height))
					break;
				rects[i].x = (int32)(con.x);
				rects[i].y = (int32)(con.y);
				rects[i].was_packed = (int32)(1);
				con.x += (int32)(rects[i].w);
				if ((con.y + rects[i].h) > (con.bottom_y))
					con.bottom_y = (int32)(con.y + rects[i].h);
			}

			for (; (i) < (num_rects); ++i)
			{
				rects[i].was_packed = (int32)(0);
			}
		}

		public static int32 stbtt_PackBegin(stbtt_pack_context spc, uint8* pixels, int32 pw, int32 ph, int32 stride_in_uint8s,
			int32 padding, void* alloc_context)
		{
			stbrp_context* context = (stbrp_context*)(Internal.Malloc((int)(sizeof(stbrp_context))));
			int32 num_nodes = (int32)(pw - padding);
			stbrp_node* nodes = (stbrp_node*)(Internal.Malloc((int)(sizeof(stbrp_node) * num_nodes)));
			if (((context) == (null)) || ((nodes) == (null)))
			{
				if (context != (null))
					Internal.Free(context);
				if (nodes != (null))
					Internal.Free(nodes);
				return (int32)(0);
			}

			spc.user_allocator_context = alloc_context;
			spc.width = (int32)(pw);
			spc.height = (int32)(ph);
			spc.pixels = pixels;
			spc.pack_info = context;
			spc.nodes = nodes;
			spc.padding = (int32)(padding);
			spc.stride_in_uint8s = (int32)(stride_in_uint8s!= 0 ? stride_in_uint8s : pw);
			spc.h_oversample = (uint32)(1);
			spc.v_oversample = (uint32)(1);
			spc.skip_missing = (int32)(0);
			stbrp_init_target(context, (int32)(pw - padding), (int32)(ph - padding), nodes, (int32)(num_nodes));
			if ((pixels) != null)
				Internal.MemSet(pixels, (int32)(0), (int)(pw * ph));
			return (int32)(1);
		}

		public static void stbtt_PackEnd(stbtt_pack_context spc)
		{
			Internal.Free(spc.nodes);
			Internal.Free(spc.pack_info);
		}

		public static void stbtt_PackSetOversampling(stbtt_pack_context spc, uint32 h_oversample, uint32 v_oversample)
		{
			if (h_oversample <= 8)
				spc.h_oversample = (uint32)(h_oversample);
			if (v_oversample <= 8)
				spc.v_oversample = (uint32)(v_oversample);
		}

		public static void stbtt_PackSetSkipMissingCodepoint32s(stbtt_pack_context spc, int32 skip)
		{
			spc.skip_missing = (int32)(skip);
		}

		public static void stbtt__h_prefilter(uint8* pixels, int32 w, int32 h, int32 stride_in_uint8s, uint32 kernel_width)
		{
			var pixels;

			let b = scope uint8[8];
			uint8* buffer = &b[0];
			int32 safe_w = (int32)(w - (.)kernel_width);
			int32 j = 0;
			Internal.MemSet(buffer, (int32)(0), (uint64)(8));
			for (j = (int32)(0); (j) < (h); ++j)
			{
				int32 i = 0;
				uint32 total = 0;
				Internal.MemSet(buffer, (int32)(0), (int)(kernel_width));
				total = (uint32)(0);
				switch (kernel_width)
				{
				case 2:
					for(i=(int32)(0); i<= safe_w;++i)
				{
		                        total+=(uint32)(pixels[i]- buffer[i&(8-1)]);
		                        buffer[(i + (.)kernel_width)&(8-1)]=(uint8)(pixels[i]);
		                        pixels[i]=((uint8)(total/2));
				}

				break;
					case 3:
					for(i=(int32)(0); i<= safe_w;++i)
				{
		                        total+=(uint32)(pixels[i]- buffer[i&(8-1)]);
		                        buffer[(i + (.)kernel_width)&(8-1)]=(uint8)(pixels[i]);
		                        pixels[i]=((uint8)(total/3));
				}

				break;
					case 4:
					for(i=(int32)(0); i<= safe_w;++i)
				{
		                        total+=(uint32)(pixels[i]- buffer[i&(8-1)]);
		                        buffer[(i+ (.)kernel_width)&(8-1)]=(uint8)(pixels[i]);
		                        pixels[i]=((uint8)(total/4));
				}

				break;
					case 5:
					for(i=(int32)(0); i<= safe_w;++i)
				{
		                        total+=(uint32)(pixels[i]- buffer[i&(8-1)]);
		                        buffer[(i+ (.)kernel_width)&(8-1)]=(uint8)(pixels[i]);
		                        pixels[i]=((uint8)(total/5));
				}

				break;
					default:
					for (i = (int32)(0); i <= safe_w; ++i)
					{
						total += (uint32)(pixels[i] - buffer[i & (8 - 1)]);
						buffer[(i + (.)kernel_width) & (8 - 1)] = (uint8)(pixels[i]);
						pixels[i] = ((uint8)(total / kernel_width));
					}

					break;
				}

				for (; (i) < (w); ++i)
				{
					total -= (uint32)(buffer[i & (8 - 1)]);
					pixels[i] = ((uint8)(total / kernel_width));
				}

				pixels += stride_in_uint8s;
			}
		}

		public static void stbtt__v_prefilter(uint8* pixels, int32 w, int32 h, int32 stride_in_uint8s, uint32 kernel_width)
		{
			var pixels;

			let b = scope uint8[8];
			uint8* buffer = &b[0];
			int32 safe_h = (int32)(h - (.)kernel_width);
			int32 j = 0;
			Internal.MemSet(buffer, (int32)(0), (int)(8));
			for (j = (int32)(0); (j) < (w); ++j)
			{
				int32 i = 0;
				uint32 total = 0;
				Internal.MemSet(buffer, (int32)(0), (int)(kernel_width));
				total = (uint32)(0);
				switch (kernel_width)
				{
				case 2:
					for(i=(int32)(0); i<= safe_h;++i)
				{
		                        total+=(uint32)(pixels[i * stride_in_uint8s]- buffer[i&(8-1)]);
		                        buffer[(i+ (.)kernel_width)&(8-1)]=(uint8)(pixels[i * stride_in_uint8s]);
		                        pixels[i * stride_in_uint8s]=((uint8)(total/2));
				}

				break;
					case 3:
					for(i=(int32)(0); i<= safe_h;++i)
				{
		                        total+=(uint32)(pixels[i * stride_in_uint8s]- buffer[i&(8-1)]);
		                        buffer[(i+ (.)kernel_width)&(8-1)]=(uint8)(pixels[i * stride_in_uint8s]);
		                        pixels[i * stride_in_uint8s]=((uint8)(total/3));
				}

				break;
					case 4:
					for(i=(int32)(0); i<= safe_h;++i)
				{
		                        total+=(uint32)(pixels[i * stride_in_uint8s]- buffer[i & (8-1)]);
		                        buffer[(i+ (.)kernel_width) & (8-1)]=(uint8)(pixels[i * stride_in_uint8s]);
		                        pixels[i * stride_in_uint8s]=((uint8)(total/4));
				}

				break;
					case 5:
					for(i=(int32)(0); i<= safe_h;++i)
				{
		                        total+=(uint32)(pixels[i * stride_in_uint8s]- buffer[i&(8-1)]);
		                        buffer[(i+ (.)kernel_width)&(8-1)]=(uint8)(pixels[i * stride_in_uint8s]);
		                        pixels[i * stride_in_uint8s]=((uint8)(total/5));
				}

				break;
					default:
					for (i = (int32)(0); i <= safe_h; ++i)
					{
						total += (uint32)(pixels[i * stride_in_uint8s] - buffer[i & (8 - 1)]);
						buffer[(i + (.)kernel_width) & (8 - 1)] = (uint8)(pixels[i * stride_in_uint8s]);
						pixels[i * stride_in_uint8s] = ((uint8)(total / kernel_width));
					}

					break;
				}

				for (; (i) < (h); ++i)
				{
					total -= (uint32)(buffer[i & (8 - 1)]);
					pixels[i * stride_in_uint8s] = ((uint8)(total / kernel_width));
				}

				pixels += 1;
			}
		}

		public static float stbtt__oversample_shift(int32 oversample)
		{
			if (oversample == 0)
				return (float)(0.0f);
			return (float)((float)(-(oversample - 1)) / (2.0f * (float)(oversample)));
		}

		public static int32 stbtt_PackFontRangesGatherRects(stbtt_pack_context spc, stbtt_fontinfo info,
			stbtt_pack_range* ranges, int32 num_ranges, stbrp_rect* rects)
		{
			int32 i = 0;
			int32 j = 0;
			int32 k = 0;
			k = (int32)(0);
			for (i = (int32)(0); (i) < (num_ranges); ++i)
			{
				float fh = (float)(ranges[i].font_size);
				float scale = (float)((fh)> (0)
					? stbtt_ScaleForPixelHeight(info, (float)(fh))
					: stbtt_ScaleForMappingEmToPixels(info, (float)(-fh)));
				ranges[i].h_oversample = ((uint8)(spc.h_oversample));
				ranges[i].v_oversample = ((uint8)(spc.v_oversample));
				for (j = (int32)(0); (j) < (ranges[i].num_chars); ++j)
				{
					int32 x0 = 0;
					int32 y0 = 0;
					int32 x1 = 0;
					int32 y1 = 0;
					int32 codepoint32 = (int32)((ranges[i].array_of_unicode_codepoint32s)== (null)
						? ranges[i].first_unicode_codepoint32_in_range + j
						: ranges[i].array_of_unicode_codepoint32s[j]);
					int32 glyph = (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32)));
					if (((glyph) == (0)) && ((spc.skip_missing) != 0))
					{
						rects[k].w = (int32)(rects[k].h = (int32)(0));
					}
					else
					{
						stbtt_GetGlyphBitmapBoxSubpixel(info, (int32)(glyph), (float)(scale * spc.h_oversample),
							(float)(scale * spc.v_oversample), (float)(0), (float)(0), &x0, &y0, &x1, &y1);
						rects[k].w = ((int32)(x1 - x0 + spc.padding + (.)spc.h_oversample - 1));
						rects[k].h = ((int32)(y1 - y0 + spc.padding + (.)spc.v_oversample - 1));
					}

					++k;
				}
			}

			return (int32)(k);
		}

		public static void stbtt_MakeGlyphBitmapSubpixelPrefilter(stbtt_fontinfo info, uint8* output, int32 out_w,
			int32 out_h, int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 prefilter_x,
			int32 prefilter_y, float* sub_x, float* sub_y, int32 glyph)
		{
			stbtt_MakeGlyphBitmapSubpixel(info, output, (int32)(out_w - (prefilter_x - 1)),
				(int32)(out_h - (prefilter_y - 1)), (int32)(out_stride), (float)(scale_x), (float)(scale_y),
				(float)(shift_x), (float)(shift_y), (int32)(glyph));
			if ((prefilter_x) > (1))
				stbtt__h_prefilter(output, (int32)(out_w), (int32)(out_h), (int32)(out_stride), (uint32)(prefilter_x));
			if ((prefilter_y) > (1))
				stbtt__v_prefilter(output, (int32)(out_w), (int32)(out_h), (int32)(out_stride), (uint32)(prefilter_y));
			*sub_x = (float)(stbtt__oversample_shift((int32)(prefilter_x)));
			*sub_y = (float)(stbtt__oversample_shift((int32)(prefilter_y)));
		}

		public static int32 stbtt_PackFontRangesRenderint32oRects(stbtt_pack_context spc, stbtt_fontinfo info,
			stbtt_pack_range* ranges, int32 num_ranges, stbrp_rect* rects)
		{
			int32 i = 0;
			int32 j = 0;
			int32 k = 0;
			int32 return_value = (int32)(1);
			int32 old_h_over = (int32)(spc.h_oversample);
			int32 old_v_over = (int32)(spc.v_oversample);
			k = (int32)(0);
			for (i = (int32)(0); (i) < (num_ranges); ++i)
			{
				float fh = (float)(ranges[i].font_size);
				float scale = (float)((fh)> (0)
					? stbtt_ScaleForPixelHeight(info, (float)(fh))
					: stbtt_ScaleForMappingEmToPixels(info, (float)(-fh)));
				float recip_h = 0;
				float recip_v = 0;
				float sub_x = 0;
				float sub_y = 0;
				spc.h_oversample = (uint32)(ranges[i].h_oversample);
				spc.v_oversample = (uint32)(ranges[i].v_oversample);
				recip_h = (float)(1.0f / spc.h_oversample);
				recip_v = (float)(1.0f / spc.v_oversample);
				sub_x = (float)(stbtt__oversample_shift((int32)(spc.h_oversample)));
				sub_y = (float)(stbtt__oversample_shift((int32)(spc.v_oversample)));
				for (j = (int32)(0); (j) < (ranges[i].num_chars); ++j)
				{
					stbrp_rect* r = &rects[k];
					if ((((r.was_packed) != 0) && (r.w != 0)) && (r.h != 0))
					{
						stbtt_packedchar* bc = &ranges[i].chardata_for_range[j];
						int32 advance = 0;
						int32 lsb = 0;
						int32 x0 = 0;
						int32 y0 = 0;
						int32 x1 = 0;
						int32 y1 = 0;
						int32 codepoint32 = (int32)((ranges[i].array_of_unicode_codepoint32s)== (null)
							? ranges[i].first_unicode_codepoint32_in_range + j
							: ranges[i].array_of_unicode_codepoint32s[j]);
						int32 glyph = (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32)));
						int32 pad = (int32)(spc.padding);
						r.x += (int32)(pad);
						r.y += (int32)(pad);
						r.w -= (int32)(pad);
						r.h -= (int32)(pad);
						stbtt_GetGlyphHMetrics(info, (int32)(glyph), &advance, &lsb);
						stbtt_GetGlyphBitmapBox(info, (int32)(glyph), (float)(scale * spc.h_oversample),
							(float)(scale * spc.v_oversample), &x0, &y0, &x1, &y1);
						stbtt_MakeGlyphBitmapSubpixel(info, spc.pixels + r.x + r.y * spc.stride_in_uint8s,
							(int32)(r.w - (.)spc.h_oversample + 1), (int32)(r.h - (.)spc.v_oversample + 1),
							(int32)(spc.stride_in_uint8s), (float)(scale * spc.h_oversample),
							(float)(scale * spc.v_oversample), (float)(0), (float)(0), (int32)(glyph));
						if ((spc.h_oversample) > (1))
							stbtt__h_prefilter(spc.pixels + r.x + r.y * spc.stride_in_uint8s, (int32)(r.w),
								(int32)(r.h), (int32)(spc.stride_in_uint8s), (uint32)(spc.h_oversample));
						if ((spc.v_oversample) > (1))
							stbtt__v_prefilter(spc.pixels + r.x + r.y * spc.stride_in_uint8s, (int32)(r.w),
								(int32)(r.h), (int32)(spc.stride_in_uint8s), (uint32)(spc.v_oversample));
						bc.x0 = (uint16)((int16)(r.x));
						bc.y0 = (uint16)((int16)(r.y));
						bc.x1 = (uint16)((int16)(r.x + r.w));
						bc.y1 = (uint16)((int16)(r.y + r.h));
						bc.xadvance = (float)(scale * advance);
						bc.xoff = (float)((float)(x0) * recip_h + sub_x);
						bc.yoff = (float)((float)(y0) * recip_v + sub_y);
						bc.xoff2 = (float)((x0 + r.w) * recip_h + sub_x);
						bc.yoff2 = (float)((y0 + r.h) * recip_v + sub_y);
					}
					else
					{
						return_value = (int32)(0);
					}

					++k;
				}
			}

			spc.h_oversample = (uint32)(old_h_over);
			spc.v_oversample = (uint32)(old_v_over);
			return (int32)(return_value);
		}

		public static void stbtt_PackFontRangesPackRects(stbtt_pack_context spc, stbrp_rect* rects, int32 num_rects)
		{
			stbrp_pack_rects((stbrp_context*)(spc.pack_info), rects, (int32)(num_rects));
		}

		public static int32 stbtt_PackFontRanges(stbtt_pack_context spc, uint8* fontdata, int32 font_index,
			stbtt_pack_range* ranges, int32 num_ranges)
		{
			stbtt_fontinfo info = scope stbtt_fontinfo();
			int32 i = 0;
			int32 j = 0;
			int32 n = 0;
			int32 return_value = (int32)(1);
			stbrp_rect* rects;
			for (i = (int32)(0); (i) < (num_ranges); ++i)
			{
				for (j = (int32)(0); (j) < (ranges[i].num_chars); ++j)
				{
					ranges[i].chardata_for_range[j].x0 = (uint16)(ranges[i].chardata_for_range[j].y0 =
						(uint16)(ranges[i].chardata_for_range[j].x1 =
						(uint16)(ranges[i].chardata_for_range[j].y1 = (uint16)(0))));
				}
			}

			n = (int32)(0);
			for (i = (int32)(0); (i) < (num_ranges); ++i)
			{
				n += (int32)(ranges[i].num_chars);
			}

			rects = (stbrp_rect*)(Internal.Malloc((int)(sizeof(stbrp_rect) * n)));
			if ((rects) == (null))
				return (int32)(0);
			stbtt_InitFont(info, fontdata, (int32)(stbtt_GetFontOffsetForIndex(fontdata, (int32)(font_index))));
			n = (int32)(stbtt_PackFontRangesGatherRects(spc, info, ranges, (int32)(num_ranges), rects));
			stbtt_PackFontRangesPackRects(spc, rects, (int32)(n));
			return_value = (int32)(stbtt_PackFontRangesRenderint32oRects(spc, info, ranges, (int32)(num_ranges), rects));
			Internal.Free(rects);
			return (int32)(return_value);
		}

		public static int32 stbtt_PackFontRange(stbtt_pack_context spc, uint8* fontdata, int32 font_index, float font_size,
			int32 first_unicode_codepoint32_in_range, int32 num_chars_in_range, stbtt_packedchar* chardata_for_range)
		{
			stbtt_pack_range range = stbtt_pack_range();
			range.first_unicode_codepoint32_in_range = (int32)(first_unicode_codepoint32_in_range);
			range.array_of_unicode_codepoint32s = (null);
			range.num_chars = (int32)(num_chars_in_range);
			range.chardata_for_range = chardata_for_range;
			range.font_size = (float)(font_size);
			return (int32)(stbtt_PackFontRanges(spc, fontdata, (int32)(font_index), &range, (int32)(1)));
		}

		public static void stbtt_GetScaledFontVMetrics(uint8* fontdata, int32 index, float size, float* ascent,
			float* descent, float* lineGap)
		{
			int32 i_ascent = 0;
			int32 i_descent = 0;
			int32 i_lineGap = 0;
			float scale = 0;
			stbtt_fontinfo info = scope stbtt_fontinfo();
			stbtt_InitFont(info, fontdata, (int32)(stbtt_GetFontOffsetForIndex(fontdata, (int32)(index))));
			scale = (float)((size)> (0)
				? stbtt_ScaleForPixelHeight(info, (float)(size))
				: stbtt_ScaleForMappingEmToPixels(info, (float)(-size)));
			stbtt_GetFontVMetrics(info, &i_ascent, &i_descent, &i_lineGap);
			*ascent = (float)((float)(i_ascent) * scale);
			*descent = (float)((float)(i_descent) * scale);
			*lineGap = (float)((float)(i_lineGap) * scale);
		}

		public static void stbtt_GetPackedQuad(stbtt_packedchar* chardata, int32 pw, int32 ph, int32 char_index, float* xpos,
			float* ypos, stbtt_aligned_quad* q, int32 align_to_int32eger)
		{
			float ipw = (float)(1.0f / pw);
			float iph = (float)(1.0f / ph);
			stbtt_packedchar* b = chardata + char_index;
			if ((align_to_int32eger) != 0)
			{
				float x = (float)((int32)(Math.Floor((double)((*xpos + b.xoff) + 0.5f))));
				float y = (float)((int32)(Math.Floor((double)((*ypos + b.yoff) + 0.5f))));
				q.x0 = (float)(x);
				q.y0 = (float)(y);
				q.x1 = (float)(x + b.xoff2 - b.xoff);
				q.y1 = (float)(y + b.yoff2 - b.yoff);
			}
			else
			{
				q.x0 = (float)(*xpos + b.xoff);
				q.y0 = (float)(*ypos + b.yoff);
				q.x1 = (float)(*xpos + b.xoff2);
				q.y1 = (float)(*ypos + b.yoff2);
			}

			q.s0 = (float)(b.x0 * ipw);
			q.t0 = (float)(b.y0 * iph);
			q.s1 = (float)(b.x1 * ipw);
			q.t1 = (float)(b.y1 * iph);
			*xpos += (float)(b.xadvance);
		}

		public static int32 stbtt__ray_int32ersect_bezier(float* orig, float* ray, float* q0, float* q1, float* q2,
			float* hits)
		{
			float q0perp = (float)(q0[1] * ray[0] - q0[0] * ray[1]);
			float q1perp = (float)(q1[1] * ray[0] - q1[0] * ray[1]);
			float q2perp = (float)(q2[1] * ray[0] - q2[0] * ray[1]);
			float roperp = (float)(orig[1] * ray[0] - orig[0] * ray[1]);
			float a = (float)(q0perp - 2 * q1perp + q2perp);
			float b = (float)(q1perp - q0perp);
			float c = (float)(q0perp - roperp);
			float s0 = (float)(0);
			float s1 = (float)(0);
			int32 num_s = (int32)(0);
			if (a != 0.0)
			{
				float discr = (float)(b * b - a * c);
				if ((discr) > (0.0))
				{
					float rcpna = (float)(-1 / a);
					float d = (float)(Math.Sqrt((double)(discr)));
					s0 = (float)((b + d) * rcpna);
					s1 = (float)((b - d) * rcpna);
					if (((s0) >= (0.0)) && (s0 <= 1.0))
						num_s = (int32)(1);
					if ((((d) > (0.0)) && ((s1) >= (0.0))) && (s1 <= 1.0))
					{
						if ((num_s) == (0))
							s0 = (float)(s1);
						++num_s;
					}
				}
			}
			else
			{
				s0 = (float)(c / (-2 * b));
				if (((s0) >= (0.0)) && (s0 <= 1.0))
					num_s = (int32)(1);
			}

			if ((num_s) == (0))
				return (int32)(0);
			else
			{
				float rcp_len2 = (float)(1 / (ray[0] * ray[0] + ray[1] * ray[1]));
				float rayn_x = (float)(ray[0] * rcp_len2);
				float rayn_y = (float)(ray[1] * rcp_len2);
				float q0d = (float)(q0[0] * rayn_x + q0[1] * rayn_y);
				float q1d = (float)(q1[0] * rayn_x + q1[1] * rayn_y);
				float q2d = (float)(q2[0] * rayn_x + q2[1] * rayn_y);
				float rod = (float)(orig[0] * rayn_x + orig[1] * rayn_y);
				float q10d = (float)(q1d - q0d);
				float q20d = (float)(q2d - q0d);
				float q0rd = (float)(q0d - rod);
				hits[0] = (float)(q0rd + s0 * (2.0f - 2.0f * s0) * q10d + s0 * s0 * q20d);
				hits[1] = (float)(a * s0 + b);
				if ((num_s) > (1))
				{
					hits[2] = (float)(q0rd + s1 * (2.0f - 2.0f * s1) * q10d + s1 * s1 * q20d);
					hits[3] = (float)(a * s1 + b);
					return (int32)(2);
				}
				else
				{
					return (int32)(1);
				}
			}
		}

		public static int32 equal(float* a, float* b)
		{
			return (int32)(((a[0] == b[0]) && (a[1] == b[1])) ? 1 : 0);
		}

		public static int32 stbtt__compute_crossings_x(float x, float y, int32 nverts, stbtt_vertex* verts)
		{
			var y;

			int32 i = 0;
			let o = scope float[2];
			float* orig = &o[0];
			let r = scope float[2];
			float* ray = &r[0];
			ray[0] = (float)(1);
			ray[1] = (float)(0);

			float y_frac = 0;
			int32 winding = (int32)(0);
			orig[0] = (float)(x);
			orig[1] = (float)(y);
			y_frac = ((float)((double)(y) % (double)(1.0f)));
			if ((y_frac) < (0.01f))
				y += (float)(0.01f);
			else if ((y_frac) > (0.99f))
				y -= (float)(0.01f);
			orig[1] = (float)(y);
			for (i = (int32)(0); (i) < (nverts); ++i)
			{
				if ((verts[i].type) == (STBTT_vline))
				{
					int32 x0 = (int32)(verts[i - 1].x);
					int32 y0 = (int32)(verts[i - 1].y);
					int32 x1 = (int32)(verts[i].x);
					int32 y1 = (int32)(verts[i].y);
					if ((((y) > ((y0)< (y1) ? (y0) : (y1))) && ((y) < ((y0)< (y1) ? (y1) : (y0)))) &&
						((x) > ((x0)< (x1) ? (x0) : (x1))))
					{
						float x_int32er = (float)((y - y0) / (y1 - y0) * (x1 - x0) + x0);
						if ((x_int32er) < (x))
							winding += (int32)(((y0) < (y1)) ? 1 : -1);
					}
				}

				if ((verts[i].type) == (STBTT_vcurve))
				{
					int32 x0 = (int32)(verts[i - 1].x);
					int32 y0 = (int32)(verts[i - 1].y);
					int32 x1 = (int32)(verts[i].cx);
					int32 y1 = (int32)(verts[i].cy);
					int32 x2 = (int32)(verts[i].x);
					int32 y2 = (int32)(verts[i].y);
					int32 ax = (int32)((x0)< ((x1)< (x2) ? (x1) : (x2)) ? (x0) : ((x1)< (x2) ? (x1) : (x2)));
					int32 ay = (int32)((y0)< ((y1)< (y2) ? (y1) : (y2)) ? (y0) : ((y1)< (y2) ? (y1) : (y2)));
					int32 by = (int32)((y0)< ((y1)< (y2) ? (y2) : (y1)) ? ((y1)< (y2) ? (y2) : (y1)) : (y0));
					if ((((y) > (ay)) && ((y) < (by))) && ((x) > (ax)))
					{
						let _q0 = scope float[2];
						float* q0 = &_q0[0];
						let _q1 = scope float[2];
						float* q1 = &_q1[0];
						let _q2 = scope float[2];
						float* q2 = &_q2[0];
						let h = scope float[4];
						float* hits = &h[0];
						q0[0] = ((float)(x0));
						q0[1] = ((float)(y0));
						q1[0] = ((float)(x1));
						q1[1] = ((float)(y1));
						q2[0] = ((float)(x2));
						q2[1] = ((float)(y2));
						if (((equal(q0, q1)) != 0) || ((equal(q1, q2)) != 0))
						{
							x0 = ((int32)(verts[i - 1].x));
							y0 = ((int32)(verts[i - 1].y));
							x1 = ((int32)(verts[i].x));
							y1 = ((int32)(verts[i].y));
							if ((((y) > ((y0)< (y1) ? (y0) : (y1))) && ((y) < ((y0)< (y1) ? (y1) : (y0)))) &&
								((x) > ((x0)< (x1) ? (x0) : (x1))))
							{
								float x_int32er = (float)((y - y0) / (y1 - y0) * (x1 - x0) + x0);
								if ((x_int32er) < (x))
									winding += (int32)(((y0) < (y1)) ? 1 : -1);
							}
						}
						else
						{
							int32 num_hits = (int32)(stbtt__ray_int32ersect_bezier(orig, ray, q0, q1, q2, hits));
							if ((num_hits) >= (1))
								if ((hits[0]) < (0))
									winding += (int32)((hits[1])< (0) ? -1 : 1);
							if ((num_hits) >= (2))
								if ((hits[2]) < (0))
									winding += (int32)((hits[3])< (0) ? -1 : 1);
						}
					}
				}
			}

			return (int32)(winding);
		}

		public static float stbtt__cuberoot(float x)
		{
			if ((x) < (0))
				return (float)(-(float)(Math.Pow((double)(-x), (double)(1.0f / 3.0f))));
			else
				return (float)(Math.Pow((double)(x), (double)(1.0f / 3.0f)));
		}

		public static int32 stbtt__solve_cubic(float a, float b, float c, float* r)
		{
			float s = (float)(-a / 3);
			float p = (float)(b - a * a / 3);
			float q = (float)(a * (2 * a * a - 9 * b) / 27 + c);
			float p3 = (float)(p * p * p);
			float d = (float)(q * q + 4 * p3 / 27);
			if ((d) >= (0))
			{
				float z = (float)(Math.Sqrt((double)(d)));
				float u = (float)((-q + z) / 2);
				float v = (float)((-q - z) / 2);
				u = (float)(stbtt__cuberoot((float)(u)));
				v = (float)(stbtt__cuberoot((float)(v)));
				r[0] = (float)(s + u + v);
				return (int32)(1);
			}
			else
			{
				float u = (float)(Math.Sqrt((double)(-p / 3)));
				float v = (float)((float)(Math.Acos((double)(-Math.Sqrt((double)(-27 / p3)) * q / 2))) / 3);
				float m = (float)(Math.Cos((double)(v)));
				float n = (float)((float)(Math.Cos((double)(v - 3.141592 / 2))) * 1.732050808f);
				r[0] = (float)(s + u * 2 * m);
				r[1] = (float)(s - u * (m + n));
				r[2] = (float)(s - u * (m - n));
				return (int32)(3);
			}
		}

		public static uint8* stbtt_GetGlyphSDF(stbtt_fontinfo info, float scale, int32 glyph, int32 padding,
			uint8 onedge_value, float pixel_dist_scale, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			float scale_x = (float)(scale);
			float scale_y = (float)(scale);
			int32 ix0 = 0;
			int32 iy0 = 0;
			int32 ix1 = 0;
			int32 iy1 = 0;
			int32 w = 0;
			int32 h = 0;
			uint8* data;
			if ((scale_x) == (0))
				scale_x = (float)(scale_y);
			if ((scale_y) == (0))
			{
				if ((scale_x) == (0))
					return (null);
				scale_y = (float)(scale_x);
			}

			stbtt_GetGlyphBitmapBoxSubpixel(info, (int32)(glyph), (float)(scale), (float)(scale), (float)(0.0f),
				(float)(0.0f), &ix0, &iy0, &ix1, &iy1);
			if (((ix0) == (ix1)) || ((iy0) == (iy1)))
				return (null);
			ix0 -= (int32)(padding);
			iy0 -= (int32)(padding);
			ix1 += (int32)(padding);
			iy1 += (int32)(padding);
			w = (int32)(ix1 - ix0);
			h = (int32)(iy1 - iy0);
			if ((width) != null)
				*width = (int32)(w);
			if ((height) != null)
				*height = (int32)(h);
			if ((xoff) != null)
				*xoff = (int32)(ix0);
			if ((yoff) != null)
				*yoff = (int32)(iy0);
			scale_y = (float)(-scale_y);
			{
				int32 x = 0;
				int32 y = 0;
				int32 i = 0;
				int32 j = 0;
				float* precompute;
				stbtt_vertex* verts = ?;
				int32 num_verts = (int32)(stbtt_GetGlyphShape(info, (int32)(glyph), &verts));
				data = (uint8*)(Internal.Malloc((int)(w * h)));
				precompute = (float*)(Internal.Malloc((int)(num_verts * sizeof(float))));
				for (i = (int32)(0),j = (int32)(num_verts - 1); (i) < (num_verts); j = (int32)(i++))
				{
					if ((verts[i].type) == (STBTT_vline))
					{
						float x0 = (float)(verts[i].x * scale_x);
						float y0 = (float)(verts[i].y * scale_y);
						float x1 = (float)(verts[j].x * scale_x);
						float y1 = (float)(verts[j].y * scale_y);
						float dist = (float)(Math.Sqrt((double)((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))));
						precompute[i] = (float)(((dist) == (0)) ? 0.0f : 1.0f / dist);
					}
					else if ((verts[i].type) == (STBTT_vcurve))
					{
						float x2 = (float)(verts[j].x * scale_x);
						float y2 = (float)(verts[j].y * scale_y);
						float x1 = (float)(verts[i].cx * scale_x);
						float y1 = (float)(verts[i].cy * scale_y);
						float x0 = (float)(verts[i].x * scale_x);
						float y0 = (float)(verts[i].y * scale_y);
						float bx = (float)(x0 - 2 * x1 + x2);
						float by = (float)(y0 - 2 * y1 + y2);
						float len2 = (float)(bx * bx + by * by);
						if (len2 != 0.0f)
							precompute[i] = (float)(1.0f / (bx * bx + by * by));
						else
							precompute[i] = (float)(0.0f);
					}
					else
						precompute[i] = (float)(0.0f);
				}

				for (y = (int32)(iy0); (y) < (iy1); ++y)
				{
					for (x = (int32)(ix0); (x) < (ix1); ++x)
					{
						float val = 0;
						float min_dist = (float)(999999.0f);
						float sx = (float)((float)(x) + 0.5f);
						float sy = (float)((float)(y) + 0.5f);
						float x_gspace = (float)(sx / scale_x);
						float y_gspace = (float)(sy / scale_y);
						int32 winding = (int32)(stbtt__compute_crossings_x((float)(x_gspace), (float)(y_gspace),
							(int32)(num_verts), verts));
						for (i = (int32)(0); (i) < (num_verts); ++i)
						{
							float x0 = (float)(verts[i].x * scale_x);
							float y0 = (float)(verts[i].y * scale_y);
							float dist2 = (float)((x0 - sx) * (x0 - sx) + (y0 - sy) * (y0 - sy));
							if ((dist2) < (min_dist * min_dist))
								min_dist = ((float)(Math.Sqrt((double)(dist2))));
							if ((verts[i].type) == (STBTT_vline))
							{
								float x1 = (float)(verts[i - 1].x * scale_x);
								float y1 = (float)(verts[i - 1].y * scale_y);
								float dist =
									(float)((float)(Math.Abs(
									(double)((x1 - x0) * (y0 - sy) - (y1 - y0) * (x0 - sx)))) *
									precompute[i]);
								if ((dist) < (min_dist))
								{
									float dx = (float)(x1 - x0);
									float dy = (float)(y1 - y0);
									float px = (float)(x0 - sx);
									float py = (float)(y0 - sy);
									float t = (float)(-(px * dx + py * dy) / (dx * dx + dy * dy));
									if (((t) >= (0.0f)) && (t <= 1.0f))
										min_dist = (float)(dist);
								}
							}
							else if ((verts[i].type) == (STBTT_vcurve))
							{
								float x2 = (float)(verts[i - 1].x * scale_x);
								float y2 = (float)(verts[i - 1].y * scale_y);
								float x1 = (float)(verts[i].cx * scale_x);
								float y1 = (float)(verts[i].cy * scale_y);
								float box_x0 = (float)(((x0)<(x1)?(x0):(x1))< (x2)
									? ((x0)< (x1) ? (x0) : (x1))
									: (x2));
								float box_y0 = (float)(((y0)<(y1)?(y0):(y1))< (y2)
									? ((y0)< (y1) ? (y0) : (y1))
									: (y2));
								float box_x1 = (float)(((x0)<(x1)?(x1):(x0))< (x2)
									? (x2)
									: ((x0)< (x1) ? (x1) : (x0)));
								float box_y1 = (float)(((y0)<(y1)?(y1):(y0))< (y2)
									? (y2)
									: ((y0)< (y1) ? (y1) : (y0)));
								if (((((sx) > (box_x0 - min_dist)) && ((sx) < (box_x1 + min_dist))) &&
									((sy) > (box_y0 - min_dist))) && ((sy) < (box_y1 + min_dist)))
								{
									int32 num = (int32)(0);
									float ax = (float)(x1 - x0);
									float ay = (float)(y1 - y0);
									float bx = (float)(x0 - 2 * x1 + x2);
									float by = (float)(y0 - 2 * y1 + y2);
									float mx = (float)(x0 - sx);
									float my = (float)(y0 - sy);
									let r = scope float[3];
									float* res = &r[0];
									float px = 0;
									float py = 0;
									float t = 0;
									float it = 0;
									float a_inv = (float)(precompute[i]);
									if ((a_inv) == (0.0))
									{
										float a = (float)(3 * (ax * bx + ay * by));
										float b = (float)(2 * (ax * ax + ay * ay) + (mx * bx + my * by));
										float c = (float)(mx * ax + my * ay);
										if ((a) == (0.0))
										{
											if (b != 0.0)
											{
												res[num++] = (float)(-c / b);
											}
										}
										else
										{
											float discriminant = (float)(b * b - 4 * a * c);
											if ((discriminant) < (0))
												num = (int32)(0);
											else
											{
												float root = (float)(Math.Sqrt((double)(discriminant)));
												res[0] = (float)((-b - root) / (2 * a));
												res[1] = (float)((-b + root) / (2 * a));
												num = (int32)(2);
											}
										}
									}
									else
									{
										float b = (float)(3 * (ax * bx + ay * by) * a_inv);
										float c = (float)((2 * (ax * ax + ay * ay) + (mx * bx + my * by)) * a_inv);
										float d = (float)((mx * ax + my * ay) * a_inv);
										num = (int32)(stbtt__solve_cubic((float)(b), (float)(c), (float)(d), res));
									}

									if ((((num) >= (1)) && ((res[0]) >= (0.0f))) && (res[0] <= 1.0f))
									{
										t = (float)(res[0]);
										it = (float)(1.0f - t);
										px = (float)(it * it * x0 + 2 * t * it * x1 + t * t * x2);
										py = (float)(it * it * y0 + 2 * t * it * y1 + t * t * y2);
										dist2 = (float)((px - sx) * (px - sx) + (py - sy) * (py - sy));
										if ((dist2) < (min_dist * min_dist))
											min_dist = ((float)(Math.Sqrt((double)(dist2))));
									}

									if ((((num) >= (2)) && ((res[1]) >= (0.0f))) && (res[1] <= 1.0f))
									{
										t = (float)(res[1]);
										it = (float)(1.0f - t);
										px = (float)(it * it * x0 + 2 * t * it * x1 + t * t * x2);
										py = (float)(it * it * y0 + 2 * t * it * y1 + t * t * y2);
										dist2 = (float)((px - sx) * (px - sx) + (py - sy) * (py - sy));
										if ((dist2) < (min_dist * min_dist))
											min_dist = ((float)(Math.Sqrt((double)(dist2))));
									}

									if ((((num) >= (3)) && ((res[2]) >= (0.0f))) && (res[2] <= 1.0f))
									{
										t = (float)(res[2]);
										it = (float)(1.0f - t);
										px = (float)(it * it * x0 + 2 * t * it * x1 + t * t * x2);
										py = (float)(it * it * y0 + 2 * t * it * y1 + t * t * y2);
										dist2 = (float)((px - sx) * (px - sx) + (py - sy) * (py - sy));
										if ((dist2) < (min_dist * min_dist))
											min_dist = ((float)(Math.Sqrt((double)(dist2))));
									}
								}
							}
						}

						if ((winding) == (0))
							min_dist = (float)(-min_dist);
						val = (float)(onedge_value + pixel_dist_scale * min_dist);
						if ((val) < (0))
							val = (float)(0);
						else if ((val) > (255))
							val = (float)(255);
						data[(y - iy0) * w + (x - ix0)] = ((uint8)(val));
					}
				}

				Internal.Free(precompute);
				Internal.Free(verts);
			}

			return data;
		}

		public static uint8* stbtt_GetCodepoint32SDF(stbtt_fontinfo info, float scale, int32 codepoint32, int32 padding,
			uint8 onedge_value, float pixel_dist_scale, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetGlyphSDF(info, (float)(scale), (int32)(stbtt_FindGlyphIndex(info, (int32)(codepoint32))),
				(int32)(padding), (uint8)(onedge_value), (float)(pixel_dist_scale), width, height, xoff, yoff);
		}

		public static void stbtt_FreeSDF(uint8* bitmap)
		{
			Internal.Free(bitmap);
		}

		public static int32 stbtt__CompareUTF8toUTF16_bigendian_prefix(uint8* s1, int32 len1, uint8* s2, int32 len2)
		{
			var s2, len2;

			int32 i = (int32)(0);
			while ((len2) != 0)
			{
				uint16 ch = (uint16)(s2[0] * 256 + s2[1]);
				if ((ch) < (0x80))
				{
					if ((i) >= (len1))
						return (int32)(-1);
					if (s1[i++] != ch)
						return (int32)(-1);
				}
				else if ((ch) < (0x800))
				{
					if ((i + 1) >= (len1))
						return (int32)(-1);
					if (s1[i++] != 0xc0 + (ch >> 6))
						return (int32)(-1);
					if (s1[i++] != 0x80 + (ch & 0x3f))
						return (int32)(-1);
				}
				else if (((ch) >= (0xd800)) && ((ch) < (0xdc00)))
				{
					uint32 c = 0;
					uint16 ch2 = (uint16)(s2[2] * 256 + s2[3]);
					if ((i + 3) >= (len1))
						return (int32)(-1);
					c = (uint32)(((ch - 0xd800) << 10) + (ch2 - 0xdc00) + 0x10000);
					if (s1[i++] != 0xf0 + (c >> 18))
						return (int32)(-1);
					if (s1[i++] != 0x80 + ((c >> 12) & 0x3f))
						return (int32)(-1);
					if (s1[i++] != 0x80 + ((c >> 6) & 0x3f))
						return (int32)(-1);
					if (s1[i++] != 0x80 + ((c) & 0x3f))
						return (int32)(-1);
					s2 += 2;
					len2 -= (int32)(2);
				}
				else if (((ch) >= (0xdc00)) && ((ch) < (0xe000)))
				{
					return (int32)(-1);
				}
				else
				{
					if ((i + 2) >= (len1))
						return (int32)(-1);
					if (s1[i++] != 0xe0 + (ch >> 12))
						return (int32)(-1);
					if (s1[i++] != 0x80 + ((ch >> 6) & 0x3f))
						return (int32)(-1);
					if (s1[i++] != 0x80 + ((ch) & 0x3f))
						return (int32)(-1);
				}

				s2 += 2;
				len2 -= (int32)(2);
			}

			return (int32)(i);
		}

		public static int32 stbtt_CompareUTF8toUTF16_bigendian_internal(int8* s1, int32 len1, int8* s2, int32 len2)
		{
			return (int32)((len1)== (stbtt__CompareUTF8toUTF16_bigendian_prefix((uint8*)(s1), (int32)(len1),
				(uint8*)(s2), (int32)(len2)))
				? 1
				: 0);
		}

		public static int8* stbtt_GetFontNameString(stbtt_fontinfo font, int32* length, int32 platformID, int32 encodingID,
			int32 languageID, int32 nameID)
		{
			int32 i = 0;
			int32 count = 0;
			int32 stringOffset = 0;
			uint8* fc = font.data;
			uint32 offset = (uint32)(font.fontstart);
			uint32 nm = (uint32)(stbtt__find_table(fc, (uint32)(offset), "name"));
			if (nm == 0)
				return (null);
			count = (int32)(ttUSHORT(fc + nm + 2));
			stringOffset = (int32)(nm + ttUSHORT(fc + nm + 4));
			for (i = (int32)(0); (i) < (count); ++i)
			{
				uint32 loc = (uint32)(nm + 6 + 12 * (.)i);
				if (((((platformID) == (ttUSHORT(fc + loc + 0))) && ((encodingID) == (ttUSHORT(fc + loc + 2)))) &&
					((languageID) == (ttUSHORT(fc + loc + 4)))) && ((nameID) == (ttUSHORT(fc + loc + 6))))
				{
					*length = (int32)(ttUSHORT(fc + loc + 8));
					return (int8*)(fc + stringOffset + ttUSHORT(fc + loc + 10));
				}
			}

			return (null);
		}

		public static int32 stbtt__matchpair(uint8* fc, uint32 nm, uint8* name, int32 nlen, int32 target_id, int32 next_id)
		{
			int32 i = 0;
			int32 count = (int32)(ttUSHORT(fc + nm + 2));
			int32 stringOffset = (int32)(nm + ttUSHORT(fc + nm + 4));
			for (i = (int32)(0); (i) < (count); ++i)
			{
				uint32 loc = (uint32)(nm + 6 + 12 * (.)i);
				int32 id = (int32)(ttUSHORT(fc + loc + 6));
				if ((id) == (target_id))
				{
					int32 platform = (int32)(ttUSHORT(fc + loc + 0));
					int32 encoding = (int32)(ttUSHORT(fc + loc + 2));
					int32 language = (int32)(ttUSHORT(fc + loc + 4));
					if ((((platform) == (0)) || (((platform) == (3)) && ((encoding) == (1)))) ||
						(((platform) == (3)) && ((encoding) == (10))))
					{
						int32 slen = (int32)(ttUSHORT(fc + loc + 8));
						int32 off = (int32)(ttUSHORT(fc + loc + 10));
						int32 matchlen = (int32)(stbtt__CompareUTF8toUTF16_bigendian_prefix(name, (int32)(nlen),
							fc + stringOffset + off, (int32)(slen)));
						if ((matchlen) >= (0))
						{
							if ((((((i + 1) < (count)) && ((ttUSHORT(fc + loc + 12 + 6)) == (next_id))) &&
								((ttUSHORT(fc + loc + 12)) == (platform))) &&
								((ttUSHORT(fc + loc + 12 + 2)) == (encoding))) &&
								((ttUSHORT(fc + loc + 12 + 4)) == (language)))
							{
								slen = (int32)(ttUSHORT(fc + loc + 12 + 8));
								off = (int32)(ttUSHORT(fc + loc + 12 + 10));
								if ((slen) == (0))
								{
									if ((matchlen) == (nlen))
										return (int32)(1);
								}
								else if (((matchlen) < (nlen)) && ((name[matchlen]) == (' ')))
								{
									++matchlen;
									if ((stbtt_CompareUTF8toUTF16_bigendian_internal((int8*)(name + matchlen),
										(int32)(nlen - matchlen), (int8*)(fc + stringOffset + off),
										(int32)(slen))) != 0)
										return (int32)(1);
								}
							}
							else
							{
								if ((matchlen) == (nlen))
									return (int32)(1);
							}
						}
					}
				}
			}

			return (int32)(0);
		}

		public static int32 stbtt__matches(uint8* fc, uint32 offset, uint8* name, int32 flags)
		{
			int32 nlen = (int32)(String.StrLen((char8*)(name)));
			uint32 nm = 0;
			uint32 hd = 0;
			if (stbtt__isfont(fc + offset) == 0)
				return (int32)(0);
			if ((flags) != 0)
			{
				hd = (uint32)(stbtt__find_table(fc, (uint32)(offset), "head"));
				if ((ttUSHORT(fc + hd + 44) & 7) != (flags & 7))
					return (int32)(0);
			}

			nm = (uint32)(stbtt__find_table(fc, (uint32)(offset), "name"));
			if (nm == 0)
				return (int32)(0);
			if ((flags) != 0)
			{
				if ((stbtt__matchpair(fc, (uint32)(nm), name, (int32)(nlen), (int32)(16), (int32)(-1))) != 0)
					return (int32)(1);
				if ((stbtt__matchpair(fc, (uint32)(nm), name, (int32)(nlen), (int32)(1), (int32)(-1))) != 0)
					return (int32)(1);
				if ((stbtt__matchpair(fc, (uint32)(nm), name, (int32)(nlen), (int32)(3), (int32)(-1))) != 0)
					return (int32)(1);
			}
			else
			{
				if ((stbtt__matchpair(fc, (uint32)(nm), name, (int32)(nlen), (int32)(16), (int32)(17))) != 0)
					return (int32)(1);
				if ((stbtt__matchpair(fc, (uint32)(nm), name, (int32)(nlen), (int32)(1), (int32)(2))) != 0)
					return (int32)(1);
				if ((stbtt__matchpair(fc, (uint32)(nm), name, (int32)(nlen), (int32)(3), (int32)(-1))) != 0)
					return (int32)(1);
			}

			return (int32)(0);
		}

		public static int32 stbtt_FindMatchingFont_internal(uint8* font_collection, int8* name_utf8, int32 flags)
		{
			int32 i = 0;
			for (i = (int32)(0);; ++i)
			{
				int32 off = (int32)(stbtt_GetFontOffsetForIndex(font_collection, (int32)(i)));
				if ((off) < (0))
					return (int32)(off);
				if ((stbtt__matches(font_collection, (uint32)(off), (uint8*)(name_utf8), (int32)(flags))) != 0)
					return (int32)(off);
			}
		}

		public static int32 stbtt_BakeFontBitmap(uint8* data, int32 offset, float pixel_height, uint8* pixels, int32 pw, int32 ph,
			int32 first_char, int32 num_chars, stbtt_bakedchar* chardata)
		{
			return (int32)(stbtt_BakeFontBitmap_internal(data, (int32)(offset), (float)(pixel_height), pixels,
				(int32)(pw), (int32)(ph), (int32)(first_char), (int32)(num_chars), chardata));
		}

		public static int32 stbtt_GetFontOffsetForIndex(uint8* data, int32 index)
		{
			return (int32)(stbtt_GetFontOffsetForIndex_internal(data, (int32)(index)));
		}

		public static int32 stbtt_GetNumberOfFonts(uint8* data)
		{
			return (int32)(stbtt_GetNumberOfFonts_internal(data));
		}

		public static int32 stbtt_InitFont(stbtt_fontinfo info, uint8* data, int32 offset)
		{
			return (int32)(stbtt_InitFont_internal(info, data, (int32)(offset)));
		}

		public static int32 stbtt_FindMatchingFont(uint8* fontdata, int8* name, int32 flags)
		{
			return (int32)(stbtt_FindMatchingFont_internal(fontdata, name, (int32)(flags)));
		}

		public static int32 stbtt_CompareUTF8toUTF16_bigendian(int8* s1, int32 len1, int8* s2, int32 len2)
		{
			return (int32)(stbtt_CompareUTF8toUTF16_bigendian_internal(s1, (int32)(len1), s2, (int32)(len2)));
		}
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__buf
	{
		public uint8* data;
		public int32 cursor;
		public int32 size;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt_bakedchar
	{
		public uint16 x0;
		public uint16 y0;
		public uint16 x1;
		public uint16 y1;
		public float xoff;
		public float yoff;
		public float xadvance;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt_aligned_quad
	{
		public float x0;
		public float y0;
		public float s0;
		public float t0;
		public float x1;
		public float y1;
		public float s1;
		public float t1;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt_packedchar
	{
		public uint16 x0;
		public uint16 y0;
		public uint16 x1;
		public uint16 y1;
		public float xoff;
		public float yoff;
		public float xadvance;
		public float xoff2;
		public float yoff2;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt_pack_range
	{
		public float font_size;
		public int32 first_unicode_codepoint32_in_range;
		public int32* array_of_unicode_codepoint32s;
		public int32 num_chars;
		public stbtt_packedchar* chardata_for_range;
		public uint8 h_oversample;
		public uint8 v_oversample;
	}

	[Ordered]
	[CRepr]
	public class stbtt_pack_context
	{
		public uint32 h_oversample;
		public int32 height;
		public void* nodes;
		public void* pack_info;
		public int32 padding;
		public uint8* pixels;
		public int32 skip_missing;
		public int32 stride_in_uint8s;
		public void* user_allocator_context;
		public uint32 v_oversample;
		public int32 width;
	}

	[Ordered]
	[CRepr]
	public class stbtt_fontinfo
	{
		public stbtt__buf cff = stbtt__buf();
		public stbtt__buf charstrings = stbtt__buf();
		public uint8* data;
		public stbtt__buf fdselect = stbtt__buf();
		public stbtt__buf fontdicts = stbtt__buf();
		public int32 fontstart;
		public int32 glyf;
		public int32 gpos;
		public stbtt__buf gsubrs = stbtt__buf();
		public int32 head;
		public int32 hhea;
		public int32 hmtx;
		public int32 index_map;
		public int32 indexToLocFormat;
		public int32 kern;
		public int32 loca;
		public int32 numGlyphs;
		public stbtt__buf subrs = stbtt__buf();
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt_vertex
	{
		public int16 x;
		public int16 y;
		public int16 cx;
		public int16 cy;
		public int16 cx1;
		public int16 cy1;
		public uint8 type;
		public uint8 padding;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__bitmap
	{
		public int32 w;
		public int32 h;
		public int32 stride;
		public uint8* pixels;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__csctx
	{
		public int32 bounds;
		public int32 started;
		public float first_x;
		public float first_y;
		public float x;
		public float y;
		public int32 min_x;
		public int32 max_x;
		public int32 min_y;
		public int32 max_y;
		public stbtt_vertex* pvertices;
		public int32 num_vertices;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__hheap_chunk
	{
		public stbtt__hheap_chunk* next;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__hheap
	{
		public stbtt__hheap_chunk* head;
		public void* first_free;
		public int32 num_remaining_in_head_chunk;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__edge
	{
		public float x0;
		public float y0;
		public float x1;
		public float y1;
		public int32 invert;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__active_edge
	{
		public stbtt__active_edge* next;
		public float fx;
		public float fdx;
		public float fdy;
		public float direction;
		public float sy;
		public float ey;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbtt__point32
	{
		public float x;
		public float y;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbrp_context
	{
		public int32 width;
		public int32 height;
		public int32 x;
		public int32 y;
		public int32 bottom_y;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbrp_node
	{
		public uint8 x;
	}

	[Packed]
	[Ordered]
	[CRepr]
	public struct stbrp_rect
	{
		public int32 x;
		public int32 y;
		public int32 id;
		public int32 w;
		public int32 h;
		public int32 was_packed;
	}
}