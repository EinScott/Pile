using System;
using System.Diagnostics;

namespace Pile.Util
{
	// Permanent reference to a portion of a string,
	// stays valid across realloc.
	struct SubString
	{
		String str;
		int subInd;
		int subLen;

		public this(String string)
		{
			Debug.Assert(string != null);
			str = string;
			subInd = 0;
			subLen = str.Length;

			AssertValid!();
		}

		public this(String string, int startIndex)
		{
			Debug.Assert(string != null);

			str = string;
			subInd = startIndex;
			subLen = str.Length - startIndex;

			AssertValid!();
		}

		public this(String string, int index, int length)
		{
			Debug.Assert(string != null);

			str = string;
			subInd = index;
			subLen = length;

			AssertValid!();
		}

		mixin AssertValid()
		{
			Runtime.Assert((uint)subInd + (uint)subLen <= (uint)str.Length);
		}

		public ref char8 this[int index]
		{
			[Checked]
			get
			{
				Runtime.Assert((uint)index < (uint)subLen);
				AssertValid!();
				return ref str[subInd + index];
			}

			[Unchecked,Inline]
			get => ref str[[Unchecked]subInd + index];

			[Checked]
			set
			{
				Runtime.Assert((uint)index < (uint)subLen);
				AssertValid!();
				str[subInd + index] = value;
			}

			[Unchecked,Inline]
			set => str[[Unchecked]subInd + index] = value;
		}

		public char8* Ptr
		{
			[Checked]
			get
			{
				AssertValid!();
				return &str[subInd];
			}

			[Unchecked,Inline]
			get => &str[subInd];
		}

		public static implicit operator StringView(Self s) => .(s.Ptr, s.subLen);
	}
}