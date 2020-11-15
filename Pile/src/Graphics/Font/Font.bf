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
			Runtime.Assert(res == .Ok, scope $"Error while initializing FreeType2: {res}");
		}

		static ~this()
		{
			if (lib != null)
			{
				let res = FreeType.Done(lib);
				Debug.Assert(res == .Ok, scope $"Error while deleting FreeType2: {res}");
			}
		}

		uint8[] dataBuffer ~ delete _;

		internal FT_Face face;

		public this(Span<uint8> data, int32 faceIndex = 0)
		{
			dataBuffer = new uint8[data.Length];
			data.CopyTo(dataBuffer);

			let res = FreeType.NewFace(lib, &dataBuffer[0], (.)dataBuffer.Count, faceIndex, out face);
			Runtime.Assert(res == .Ok, scope $"Error while creating Face: {res}");
		}

		public ~this()
		{
			let res = FreeType.DoneFace(face);
			Debug.Assert(res == .Ok, scope $"Error while deleting Face: {res}");
		}

		// not.. accurrate?? look into spritefonts, then look back at this
		public StringView FamilyName => StringView(face.familyName ?? "Unknown");
		public StringView StyleName => StringView(face.styleName ?? "Unknown");

		public int32 Ascent => (.)face.size.metrics.ascender >> 6;
		public int32 Descent => (.)face.size.metrics.descender >> 6;
		public int32 LineSpacing => (.)face.size.metrics.height >> 6;

		public bool Scalable => HasFaceFlag(.FACE_FLAG_SCALABLE);
		public bool FixedSizes => HasFaceFlag(.FACE_FLAG_FIXED_SIZES);
		public bool HasColor => HasFaceFlag(.FACE_FLAG_COLOR);
		public bool HasKerning => HasFaceFlag(.FACE_FLAG_KERNING);
		public bool IsVertical => HasFaceFlag(.FACE_FLAG_VERTICAL);

		public bool HasFaceFlag(FT_FaceFlags flag) => (face.faceFlags & flag.Underlying) != 0;

		uint32 currentSize = 0;

		public Result<void> RenderChar(uint32 size, char16 unicode)
		{
			if (size == 0) LogErrorReturn!("Font size must be greater than 0");

			// Set size if it changed
			if (size != currentSize)
			{
				FT_Error res;
				if (!IsVertical)
					res = FreeType.SetPixelSize(face, 0, size);
				else res = FreeType.SetPixelSize(face, size, 0);

				if (res != .Ok) LogErrorReturn!(scope $"Error while setting Font pixel size to {size}: {res}");
			}

			// Load the char
			let res = FreeType.LoadChar(face, (uint64)unicode, .LOAD_RENDER);
			if (res != .Ok) LogErrorReturn!(scope $"Error while loading char '{unicode}': {res}");

			return .Ok;
		}
	}
}
