using System;
using System.Collections;
using System.Diagnostics;
using FreeType;

namespace Pile
{
	public class Font
	{
		static FT_Library lib;

		static this()
		{
			let res = FreeType.Init(out lib);
			Runtime.Assert(res == .Ok, scope String()..AppendF("Error while initializing FreeType2: {}", res));
		}

		static ~this()
		{
			if (lib != null)
			{
				let res = FreeType.Done(lib);
				Debug.Assert(res == .Ok, scope String()..AppendF("Error while deleting FreeType2: {}", res));
			}
		}

		uint8[] dataBuffer ~ delete _;

		FT_Face face;

		public this(Span<uint8> data, int32 faceIndex = 0)
		{
			dataBuffer = new uint8[data.Length];
			data.CopyTo(dataBuffer);

			let res = FreeType.NewFace(lib, &dataBuffer[0], (.)dataBuffer.Count, faceIndex, out face);
			Runtime.Assert(res == .Ok, scope String()..AppendF("Error while creating Face: {}", res));
		}

		public ~this()
		{
			let res = FreeType.DoneFace(face);
			Debug.Assert(res == .Ok, scope String()..AppendF("Error while deleting Face: {}", res));
		}

		// not.. accurrate?? look into spritefonts, then look back at this
		/*public StringView FamilyName => StringView(face.familyName ?? "Unknown");
		public StringView StyleName => StringView(face.styleName ?? "Unknown");

		public int32 Ascent => (.)face.size.metrics.ascender >> 6;
		public int32 Descent => (.)face.size.metrics.descender >> 6;
		public int32 LineSpacing => (.)face.size.metrics.height >> 6;

		public bool Scalable => HasFaceFlag((.)FT_Face_Flags.FACE_FLAG_SCALABLE);
		public bool FixedSizes => HasFaceFlag((.)FT_Face_Flags.FACE_FLAG_FIXED_SIZES);
		public bool HasColor => HasFaceFlag((.)FT_Face_Flags.FACE_FLAG_COLOR);
		public bool HasKerning => HasFaceFlag((.)FT_Face_Flags.FACE_FLAG_KERNING);*/

		//public bool HasFaceFlag(int flag) => (((int)face.faceFlags) & flag) != 0;
	}
}