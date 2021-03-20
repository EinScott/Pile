using System;
using System.Collections;
using System.Diagnostics;

namespace Pile
{
	struct ReadOnlySpan<T>
	{
		readonly T* mPtr;
		readonly int mLength;

		public this(Span<T> span)
		{
			mPtr = span.Ptr;
			mLength = span.Length;
		}

		public this(List<T> list)
		{
			mPtr = list.Ptr;
			mLength = list.Count;
		}

		public this(T* ptr, int length)
		{
			mPtr = ptr;
			mLength = length;
		}

		[Inline]
		public int Length => mLength;

		[Inline]
		public bool IsEmpty => mLength == 0;

		[Inline]
		public bool IsNull => mPtr == null;

		public T this[int index]
		{
			[Inline]
		    get
			{
				return mPtr[index];
			}
		}

		public ReadOnlySpan<T> Slice(int index)
		{
			Debug.Assert((uint)index <= (uint)mLength);
			ReadOnlySpan<T> span = .(mPtr + index, mLength - index);
			return span;
		}

		public ReadOnlySpan<T> Slice(int index, int length)
		{
			Debug.Assert((uint)index + (uint)length <= (uint)length);
			ReadOnlySpan<T> span = .(mPtr + index, length);
			return span;
		}

		public int IndexOf(T item)
		{
			for (int i = 0; i < mLength; i++)
				if (mPtr[i] == item)
					return i;
			return -1;
		}

		public int IndexOfStrict(T item)
		{
			for (int i = 0; i < mLength; i++)
				if (mPtr[i] === item)
					return i;
			return -1;
		}

		public Enumerator GetEnumerator()
		{
			return Enumerator(this);
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("(");
			typeof(T).GetFullName(strBuffer);
			strBuffer.AppendF("*)0x{0:A}[{1}]", (uint)(void*)mPtr, mLength);
		}

		public struct Enumerator : IEnumerator<T>
		{
		    ReadOnlySpan<T> mList;
		    int mIndex;
		    T* mCurrent;

		    public this(ReadOnlySpan<T> list)
		    {
		        this.mList = list;
		        mIndex = 0;
		        mCurrent = null;
		    }

		    public void Dispose()
		    {
		    }

		    public bool MoveNext() mut
		    {
		        if ((uint(mIndex) < uint(mList.mLength)))
		        {
		            mCurrent = &mList.mPtr[mIndex];
		            mIndex++;
		            return true;
		        }			   
		        return MoveNextRare();
		    }

		    bool MoveNextRare() mut
		    {
		    	mIndex = mList.mLength + 1;
		        mCurrent = null;
		        return false;
		    }

		    public T Current
		    {
		        get
		        {
		            return *mCurrent;
		        }
		    }

			public int Index
			{
				get
				{
					return mIndex - 1;
				}				
			}

			public int Length
			{
				get
				{
					return mList.mLength;
				}				
			}

		    public void Reset() mut
		    {
		        mIndex = 0;
		        mCurrent = null;
		    }

			public Result<T> GetNext() mut
			{
				if (!MoveNext())
					return .Err;
				return Current;
			}
		}

		public static operator ReadOnlySpan<T>(Span<T> span) => ReadOnlySpan<T>(span);
		public static operator ReadOnlySpan<T>(List<T> list) => ReadOnlySpan<T>(list);
		public static operator ReadOnlySpan<T>(T[] list) => ReadOnlySpan<T>(list);
	}
}
