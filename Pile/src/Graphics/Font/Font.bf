using System;
using System.Collections;
using System.Diagnostics;
using FreeType;

namespace Pile
{
	public class Font
	{
		static FT_Library* lib;

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

		FT_Face* face;

		public this(Span<uint8> data, int32 faceIndex = 0)
		{
			let res = FreeType.NewFace(lib, data.Ptr, (.)data.Length, faceIndex, out face);
			Runtime.Assert(res == .Ok, scope String()..AppendF("Error while create FreeType2 Face: {}", res));
		}

		public ~this()
		{

		}
	}
}
