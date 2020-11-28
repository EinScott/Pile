using System;
using System.Collections;

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

		public static void Make(List<char32> into, uint32 from, uint32 to)
		{
			let currLen = into.Count;
			into.Reserve(to - from + 1);
			let span = into.GetRange(currLen, to - from + 1);

			Make(span, (char32)from, (char32)to);
		}

		public static void Make(Span<char32> into, uint32 from, uint32 to)
		{
			Make(into, (char16)from, (char16)to);
		}

		public static void Make(Span<char32> into, char32 from, char32 to)
		{
			let limit = Math.Min(to - from + 1, into.Length);
			for (var i = 0; i < limit; i++)
			    into[i] = from + i;
		}
	}
}
