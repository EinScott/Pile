using System;
using System.Collections;
using FreeType;

namespace Pile
{
	public static class Charsets
	{
		public static readonly char32[] ASCII ~ delete _;

		static this()
		{
			ASCII = new char32[126 - 32 + 1];
			Make(ASCII, 32, 126);
		}

		public static void Make(List<char32> into, int32 from, int32 to)
		{
			let currLen = into.Count;
			into.Reserve(to - from + 1);
			let span = into.GetRange(currLen, to - from + 1);

			Make(span, (char32)from, (char32)to);
		}

		public static void Make(Span<char32> into, int32 from, int32 to)
		{
			Make(into, (char32)from, (char32)to);
		}

		public static void Make(Span<char32> into, char32 from, char32 to)
		{
			let limit = Math.Min(to - from + 1, into.Length);
			for (var i = 0; i < limit; i++)
			    into[i] = (char32)(from + i);
		}
	}

	public class Font
	{
		static Library* lib;

		// ---

		static bool init;
		static void EnsureInit()
		{
			if (!init)
			{
				FreeType.Init(out lib);
				init = true;
			}	
		}

		// remove above when sure its not needed

		static this()
		{
			FreeType.Init(out lib); // handle errors
		}

		static ~this()
		{
			if (lib != null)
				FreeType.Done(lib); // handle errors
		}

		public this()
		{
			Log.Message(lib);
		}
	}
}
