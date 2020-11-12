using System;

namespace FreeType
{
	public enum FT_Error : int32
	{
		// Generic errors
		Ok                               = 0x00,
		Cannot_Open_Resource             = 0x01,
		Unknown_File_Format              = 0x02,
		Invalid_File_Format              = 0x03,
		Invalid_Version                  = 0x04,
		Lower_Module_Version             = 0x05,
		Invalid_Argument                 = 0x06,
		Unimplemented_Feature            = 0x07,
		Invalid_Table                    = 0x08,
		Invalid_Offset                   = 0x09,
		Array_Too_Large                  = 0x0A,
		Missing_Module                   = 0x0B,
		Missing_Property                 = 0x0C,

		// Glyph/Character errors
		Invalid_Glyph_Index              = 0x10,
		Invalid_Character_Code           = 0x11,
		Invalid_Glyph_Format             = 0x12,
		Cannot_Render_Glyph              = 0x13,
		Invalid_Outline                  = 0x14,
		Invalid_Composite                = 0x15,
		Too_Many_Hints                   = 0x16,
		Invalid_Pixel_Size               = 0x17,

		// Handle errors
		Invalid_Handle                   = 0x20,
		Invalid_Library_Handle           = 0x21,
		Invalid_Driver_Handle            = 0x22,
		Invalid_Face_Handle              = 0x23,
		Invalid_Size_Handle              = 0x24,
		Invalid_Slot_Handle              = 0x25,
		Invalid_CharMap_Handle           = 0x26,
		Invalid_Cache_Handle             = 0x27,
		Invalid_Stream_Handle            = 0x28,

		// Driver errors
		Too_Many_Drivers                 = 0x30,
		Too_Many_Extensions              = 0x31,

		// Memory errors
		Out_Of_Memory                    = 0x40,
		Unlisted_Object                  = 0x41,

		// Stream errors
		Cannot_Open_Stream               = 0x51,
		Invalid_Stream_Seek              = 0x52,
		Invalid_Stream_Skip              = 0x53,
		Invalid_Stream_Read              = 0x54,
		Invalid_Stream_Operation         = 0x55,
		Invalid_Frame_Operation          = 0x56,
		Nested_Frame_Access              = 0x57,
		Invalid_Frame_Read               = 0x58,

		// Raster errors
		Raster_Uninitialized             = 0x60,
		Raster_Corrupted                 = 0x61,
		Raster_Overflow                  = 0x62,
		Raster_Negative_Height           = 0x63,

		// Cache errors
		Too_Many_Caches                  = 0x70,

		// TrueType and SFNT errors
		Invalid_Opcode                   = 0x80,
		Too_Few_Arguments                = 0x81,
		Stack_Overflow                   = 0x82,
		Code_Overflow                    = 0x83,
		Bad_Argument                     = 0x84,
		Divide_By_Zero                   = 0x85,
		Invalid_Reference                = 0x86,
		Debug_OpCode                     = 0x87,
		ENDF_In_Exec_Stream              = 0x88,
		Nested_DEFS                      = 0x89,
		Invalid_CodeRange                = 0x8A,
		Execution_Too_Long               = 0x8B,
		Too_Many_Function_Defs           = 0x8C,
		Too_Many_Instruction_Defs        = 0x8D,
		Table_Missing                    = 0x8E,
		Horiz_Header_Missing             = 0x8F,
		Locations_Missing                = 0x90,
		Name_Table_Missing               = 0x91,
		CMap_Table_Missing               = 0x92,
		Hmtx_Table_Missing               = 0x93,
		Post_Table_Missing               = 0x94,
		Invalid_Horiz_Metrics            = 0x95,
		Invalid_CharMap_Format           = 0x96,
		Invalid_PPem                     = 0x97,
		Invalid_Vert_Metrics             = 0x98,
		Could_Not_Find_Context           = 0x99,
		Invalid_Post_Table_Format        = 0x9A,
		Invalid_Post_Table               = 0x9B,
		DEF_In_Glyf_Bytecode             = 0x9C,
		Missing_Bitmap                   = 0x9D,

		// CFF, CID, and Type 1 errors
		Syntax_Error                     = 0xA0,
		Stack_Underflow                  = 0xA1,
		Ignore                           = 0xA2,
		No_Unicode_Glyph_Name            = 0xA3,
		Glyph_Too_Big                    = 0xA4,

		// BDF errors
		Missing_Startfont_Field          = 0xB0,
		Missing_Font_Field               = 0xB1,
		Missing_Size_Field               = 0xB2,
		Missing_Fontboundingbox_Field    = 0xB3,
		Missing_Chars_Field              = 0xB4,
		Missing_Startchar_Field          = 0xB5,
		Missing_Encoding_Field           = 0xB6,
		Missing_Bbx_Field                = 0xB7,
		Bbx_Too_Big                      = 0xB8,
		Corrupted_Font_Header            = 0xB9,
		Corrupted_Font_Glyphs            = 0xBA
	}

	public enum FT_Encoding : int32
	{
	    ENCODING_NONE = 0,

	    ENCODING_MS_SYMBOL = ((uint32)'s' << 24) | ((uint32)'y' << 16) | ((uint32)'m' << 8) | (uint32)'b',
	    ENCODING_UNICODE = ((uint32)'u' << 24) | ((uint32)'n' << 16) | ((uint32)'i' << 8) | (uint32)'c',

	    ENCODING_SJIS = ((uint32)'s' << 24) | ((uint32)'j' << 16) | ((uint32)'i' << 8) | (uint32)'s',
	    ENCODING_PRC = ((uint32)'g' << 24) | ((uint32)'b' << 16) | ((uint32)' ' << 8) | (uint32)' ',
	    ENCODING_BIG5 = ((uint32)'b' << 24) | ((uint32)'i' << 16) | ((uint32)'g' << 8) | (uint32)'5',
	    ENCODING_WANSUNG = ((uint32)'w' << 24) | ((uint32)'a' << 16) | ((uint32)'n' << 8) | (uint32)'s',
	    ENCODING_JOHAB = ((uint32)'j' << 24) | ((uint32)'o' << 16) | ((uint32)'h' << 8) | (uint32)'a',

	    ENCODING_ADOBE_STANDARD = ((uint32)'A' << 24) | ((uint32)'D' << 16) | ((uint32)'O' << 8) | (uint32)'B',
	    ENCODING_ADOBE_EXPERT = ((uint32)'A' << 24) | ((uint32)'D' << 16) | ((uint32)'B' << 8) | (uint32)'E',
	    ENCODING_ADOBE_CUSTOM = ((uint32)'A' << 24) | ((uint32)'D' << 16) | ((uint32)'B' << 8) | (uint32)'C',
	    ENCODING_ADOBE_LATIN_1 = ((uint32)'l' << 24) | ((uint32)'a' << 16) | ((uint32)'t' << 8) | (uint32)'1',

	    ENCODING_OLD_LATIN_2 = ((uint32)'l' << 24) | ((uint32)'a' << 16) | ((uint32)'t' << 8) | (uint32)'2',

	    ENCODING_APPLE_ROMAN = ((uint32)'a' << 24) | ((uint32)'r' << 16) | ((uint32)'m' << 8) | (uint32)'n'
	}

	public enum FT_Glyph_Format : int32
	{
		GLYPH_FORMAT_NONE = 0,

		GLYPH_FORMAT_COMPOSITE = ((uint32)'c' << 24) | ((uint32)'o' << 16) | ((uint32)'m' << 8) | (uint32)'p',
		GLYPH_FORMAT_BITMAP = ((uint32)'b' << 24) | ((uint32)'i' << 16) | ((uint32)'t' << 8) | (uint32)'s',
		GLYPH_FORMAT_OUTLINE = ((uint32)'o' << 24) | ((uint32)'u' << 16) | ((uint32)'t' << 8) | (uint32)'l',
		GLYPH_FORMAT_PLOTTER = ((uint32)'p' << 24) | ((uint32)'l' << 16) | ((uint32)'o' << 8) | (uint32)'t'
	}

	public enum FT_Face_Flags : int32
	{
		FACE_FLAG_SCALABLE = 1 << 0,
		FACE_FLAG_FIXED_SIZES = 1 << 1,
		FACE_FLAG_FIXED_WIDTH = 1 << 2,
		FACE_FLAG_SFNT = 1 << 3,
		FACE_FLAG_HORIZONTAL = 1 << 4,
		FACE_FLAG_VERTICAL = 1 << 5,
		FACE_FLAG_KERNING = 1 << 6,
		FACE_FLAG_FAST_GLYPHS = 1 << 7,
		FACE_FLAG_MULTIPLE_MASTERS = 1 << 8,
		FACE_FLAG_GLYPH_NAMES = 1 << 9,
		FACE_FLAG_EXTERNAL_STREAM = 1 << 10,
		FACE_FLAG_HINTER = 1 << 11,
		FACE_FLAG_CID_KEYED = 1 << 12,
		FACE_FLAG_TRICKY = 1 << 13,
		FACE_FLAG_COLOR = 1 << 14,
		FACE_FLAG_VARIATION = 1 << 15
	}

	public enum FT_Pixel_Mode : uint8
	{
		PIXEL_MODE_NONE = 0,
		PIXEL_MODE_MONO = 1,
		PIXEL_MODE_GRAY = 2,
		PIXEL_MODE_GRAY2 = 3,
		PIXEL_MODE_GRAY4 = 4,
		PIXEL_MODE_LCD = 5,
		PIXEL_MODE_LCD_V = 6,
		PIXEL_MODE_BGRA = 7,

		PIXEL_MODE_MAX = 8
	}

	public typealias FT_Library = void*; // FT_LibraryRec*

	public typealias FT_Face = FT_FaceRec*;
	public typealias FT_CharMap = FT_CharMapRec*;
	public typealias FT_GlyphSlot = FT_GlyphSlotRec*;
	public typealias FT_SubGlyph = FT_SubGlyphRec*;
	public typealias FT_Size = FT_SizeRec*;

	public typealias FT_Face_Internal = void*;
	public typealias FT_Size_Internal = void*;
	public typealias FT_Slot_Internal = void*;

	public typealias FT_ListNode = void*;

	public typealias FT_Pos = int64;
	public typealias FT_Fixed = int64;

	public function void FT_Generic_Finalizer(void* object);

	[CRepr]
	public struct FT_Generic
	{
		public uint8* data;
		public FT_Generic_Finalizer finalizer;
	}

	[CRepr]
	public struct FT_BBox
	{
		public FT_Pos xMin, yMin;
		public FT_Pos xMax, yMax;
	}

	[CRepr]
	public struct FT_Vector
	{
		public FT_Pos x;
		public FT_Pos y;
	}

	[CRepr]
	public struct FT_Matrix
	{
		public FT_Fixed xx, xy;
		public FT_Fixed yx, yy;
	}

	[CRepr]
	public struct FT_Outline
	{
		public int16 nContour;
		public int16 nPoints;

		public FT_Vector* points;
		public uint8* tags;
		public int16* contours;

		public int32 flags;
	}

	[CRepr]
	public struct FT_Bitmap
	{
		public uint32 rows;
		public uint32 width;
		public int32 pitch;
		public uint8* buffer;
		public uint16 numGrays; // used only with pixelModeGray
		public FT_Pixel_Mode pixelMode;
		public uint8 paletteMode; // unused
		public void* palette; // unused
	}

	[CRepr]
	public struct FT_Size_Metrics
	{
		public uint16 x_ppem;
		public uint16 y_ppem;

		public FT_Fixed xScale;
		public FT_Fixed yScale;

		public FT_Pos ascender;
		public FT_Pos descender;
		public FT_Pos height;
		public FT_Pos maxAdvance;
	}

	[CRepr]
	public struct FT_Glyph_Metrics
	{
		public FT_Pos width;
		public FT_Pos height;

		public FT_Pos horiBearingX;
		public FT_Pos horiBearingY;
		public FT_Pos horiAdvance;

		public FT_Pos vertBearingX;
		public FT_Pos vertBearingY;
		public FT_Pos vertAdvance;
	}

	[CRepr]
	public struct FT_BitmapSize
	{
		public int16 height;
		public int16 width;

		public FT_Pos size;

		public FT_Pos x_ppem;
		public FT_Pos y_ppem;
	}
	
	[CRepr]
	public struct FT_ListRec
	{
		public FT_ListNode head;
		public FT_ListNode tail;
	}

	[CRepr]
	public struct FT_SizeRec
	{
		public FT_Face face;
		public FT_Generic generic;
		public FT_Size_Metrics metrics;
		public FT_Size_Internal _internal;
	}

	[CRepr]
	public struct FT_CharMapRec
	{
		public FT_Face face;
		public FT_Encoding encoding;

		public uint16 platformID;
		public uint16 encodingID;
	}

	[CRepr]
	public struct FT_SubGlyphRec
	{
		public int32 index;
		public uint16 flags;
		public int32 arg1;
		public int32 arg2;
		public FT_Matrix transform;
	}

	[CRepr]
	public struct FT_GlyphSlotRec
	{
		public FT_Library library;
		public FT_Face face;
		public FT_GlyphSlot next;
		public uint32 glyphIndex;
		public FT_Generic generic;

		public FT_Glyph_Metrics metrics;
		public FT_Fixed linearHoriAdvance;
		public FT_Fixed linearVertAdvance;
		public FT_Vector advance;

		public FT_Glyph_Format format;

		public FT_Bitmap bitmap;
		public int32 bitmapLeft;
		public int32 bitmapTop;

		public FT_Outline outline;

		// Array
		public uint32 numSubglyphs;
		public FT_SubGlyph subglyphs;

		public void* controlData;
		public int64 controlLen;

		public FT_Pos lsbDelta;
		public FT_Pos rsbDelta;

		public void* other;

		public FT_Slot_Internal _internal;
	}

	[CRepr]
	public struct FT_FaceRec
	{
		public int64 numFaces;
		public int64 faceIndex;

		public int64 faceFlags;
		public int64 styleFlags;

		public int64 numGlyphs;

		public char8* familyName;
		public char8* styleName;

		// Array
		public int32 numFixedSizes;
		public FT_BitmapSize* availableSizes;

		// Array
		public int32 numCharmaps;
		public FT_CharMap* charmaps;

		public FT_Generic generic;

		// -- only relevant for scalable outlines
		public FT_BBox bbox;

		public uint16 unitsPerEM;
		public int16 ascender;
		public int16 descender;
		public int16 height;

		public int16 maxAdvanceWidth;
		public int16 maxAdvanceHeight;

		public int16 underlinePosition;
		public int16 underlineThickness;
		// --

		public FT_GlyphSlot glyph;
		public FT_Size size;
		public FT_CharMap charmap;

		// private
		void* driver;
		void* memory;
		void* stream;

		FT_ListRec sizesList;

		FT_Generic autohint;
		void* extensions; // unused

		FT_Face_Internal _internal;
	}

	public static class FreeType
	{
		[LinkName("FT_Init_FreeType")]
		public static extern FT_Error Init(out FT_Library library);

		[LinkName("FT_Done_FreeType")]
		public static extern FT_Error Done(FT_Library library);

		[LinkName("FT_New_Memory_Face")]
		public static extern FT_Error NewFace(FT_Library library, uint8* data, int32 length, int32 faceIndex, out FT_Face face);

		[LinkName("FT_Done_Face")]
		public static extern FT_Error DoneFace(FT_Face face);
	}
}
