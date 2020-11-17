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

		internal FT_Face face;

		uint8[] dataBuffer ~ delete _;
		uint32 currentSize = 0;

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

		public StringView FamilyName => StringView(face.familyName ?? "Unknown"); // get this the other way, this seems to be null always
		public StringView StyleName => StringView(face.styleName ?? "Unknown");

		public int32 Ascent => 0; // scale all of these and figure out what they are
		public int32 Descent => 0;
		public int32 LineSpacing => 0;

		public bool Scalable => HasFaceFlag(.FACE_FLAG_SCALABLE);
		public bool FixedSizes => HasFaceFlag(.FACE_FLAG_FIXED_SIZES);
		public bool HasColor => HasFaceFlag(.FACE_FLAG_COLOR);
		public bool HasKerning => HasFaceFlag(.FACE_FLAG_KERNING);

		bool HasFaceFlag(FT_FaceFlags flag) => (face.faceFlags & flag.Underlying) != 0;

		public struct CharacterInfo
		{
			public bool hasGlyph;
			public Point2 offset;
			public uint32 advance;
		}

		// resetBitmap will resize the bitmap to fit perfectly, this reallocating. Otherwise the glyph will be placed origin-to-origin at the top left corner and only reallocate if necessary to fit
		public Result<void> RenderChar(uint32 size, char16 unicode, Bitmap glyph, out CharacterInfo info, bool resetBitmap = true)
		{
			info = CharacterInfo();

			if (size == 0) LogErrorReturn!("Font size must be greater than 0");

			// Set size if it changed
			if (size != currentSize)
			{
				let res = FreeType.SetPixelSize(face, 0, size);
				if (res != .Ok) LogErrorReturn!(scope $"Error while setting Font pixel size to {size}: {res}");
			}

			// todo: font charmaps/encoding?
			
			// Load the char
			let res = FreeType.LoadChar(face, (uint64)unicode, .LOAD_RENDER);
			if (res != .Ok || face.glyph == null) LogErrorReturn!(scope $"Error while loading char '{unicode}': {res}");

			// TODO: scale all return values

			// Glyph bitmap
			if (face.glyph.bitmap.width > 0 && face.glyph.bitmap.rows > 0)
			{
				if (resetBitmap || face.glyph.bitmap.width > glyph.Width || face.glyph.bitmap.rows > glyph.Height)
					glyph.Reset((.)face.glyph.bitmap.width, (.)face.glyph.bitmap.rows, Span<Color>((Color*)face.glyph.bitmap.buffer, face.glyph.bitmap.width * face.glyph.bitmap.rows));
				else
				{
					glyph.Clear();
					glyph.SetPixels(Rect(0, 0, face.glyph.bitmap.width, face.glyph.bitmap.rows), Span<Color>((Color*)face.glyph.bitmap.buffer, face.glyph.bitmap.width * face.glyph.bitmap.rows));
				}

				info.hasGlyph = true;
			}

			info.offset.Set(face.glyph.bitmapLeft, face.glyph.bitmapTop);
			info.advance = (.)face.glyph.advance.x;

			return .Ok;
		}
	}
}
