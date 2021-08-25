using System;
using System.Threading;
using System.Diagnostics;
using System.Collections;

namespace Pile
{
	class CircularBuffer<T> : IEnumerable<T>, IList
	{
#if BF_LARGE_COLLECTIONS
		const int_cosize SizeFlags = 0x7FFFFFFF'FFFFFFFF;
		const int_cosize DynAllocFlag = (int_cosize)0x80000000'00000000;
#else
		const int_cosize SizeFlags = 0x7FFFFFFF;
		const int_cosize DynAllocFlag = (int_cosize)0x80000000;
#endif

		T* mItems;
		int_cosize mNext;
		int_cosize mSize;
		int_cosize mAllocSizeAndFlags;

		public int AllocSize
		{
			[Inline]
			get
			{
				return mAllocSizeAndFlags & SizeFlags;
			}
		}

		public bool IsDynAlloc
		{
			[Inline]
			get
			{
				return (mAllocSizeAndFlags & DynAllocFlag) != 0;
			}
		}

		public this(IEnumerator<T> enumerator)
		{
			for (var item in enumerator)
				Add(item);
		}

		[AllowAppend]
		public this(int capacity)
		{
			Debug.Assert((uint)capacity <= (uint)SizeFlags);
			T* items = append T[capacity]* (?);
			if (capacity > 0)
			{
				mItems = items;
				mAllocSizeAndFlags = (int_cosize)(capacity & SizeFlags);
			}
		}

		public ~this()
		{
			if (IsDynAlloc)
			{
				var items = mItems;
#if BF_ENABLE_REALTIME_LEAK_CHECK
				// To avoid scanning items being deleted
				mItems = null;
				Interlocked.Fence();
#endif
				Free(items);
			}
		}

		public T* Ptr
		{
			get
			{
				return mItems;
			}
		}

		public int Capacity
		{
			get
			{
				return AllocSize;
			}

			set
			{
				if (value != AllocSize)
					Resize(value);
			}
		}

		public int Count
		{
			get
			{
				return mSize;
			}
		}

		public bool IsEmpty
		{
			get
			{
				return mSize == 0;
			}
		}

		public bool IsFull
		{
			get
			{
				return mSize == (mAllocSizeAndFlags & SizeFlags);
			}
		}

		[Inline]
		int FromRelativeIndex(int index)
		{
			return (mNext - mSize + index + AllocSize) % AllocSize;
		}

		public ref T this[int index]
		{
			[Checked]
			get
			{
				Runtime.Assert((uint)index < (uint)mSize);
				return ref mItems[FromRelativeIndex(index)];
			}

			[Unchecked, Inline]
			get => ref mItems[FromRelativeIndex(index)];

			[Checked]
			set
			{
				Runtime.Assert((uint)index < (uint)mSize);
				mItems[FromRelativeIndex(index)] = value;
			}

			[Unchecked, Inline]
			set => mItems[FromRelativeIndex(index)] = value;
		}

		public ref T Front
		{
			get
			{
				Debug.Assert(mSize != 0);
				return ref mItems[FromRelativeIndex(0)];
			}
		}

		public ref T Back
		{
			get
			{
				Debug.Assert(mSize != 0);
				return ref mItems[FromRelativeIndex(mSize - 1)];
			}
		}

		public Variant IList.this[int index]
		{
			get
			{
				return [Unbound]Variant.Create(this[index]);
			}

			set
			{
				ThrowUnimplemented();
			}
		}

		void Realloc(int newSize)
		{
			T* oldAlloc = null;
			if (newSize > 0)
			{
				T* newItems = Alloc(newSize);

				if (IsDynAlloc)
					oldAlloc = mItems;
				let prevItems = mItems;
				let prevAlloc = AllocSize;
				let prevStart = FromRelativeIndex(0);
				mAllocSizeAndFlags = (.)(newSize | DynAllocFlag);
				mItems = newItems;
				if (mSize > 0)
				{
					// Feed the old buffer into the new buffer
					let prevSize = mSize;
					mSize = 0;
					mNext = 0;
					for (var x = 0, var i = prevStart; x < prevSize; x++, i = (i + 1) % prevAlloc)
						Add(prevItems[i]);
				}
			}
			else
			{
				if (IsDynAlloc)
					oldAlloc = mItems;
				mItems = null;
				mAllocSizeAndFlags = 0;
			}

			if (oldAlloc != null)
				Free(oldAlloc);
		}

		protected virtual T* Alloc(int size)
		{
			return Internal.AllocRawArrayUnmarked<T>(size);
		}

		protected virtual void Free(T* val)
		{
			delete (void*)val;
		}

		public void Resize(int capacity)
		{
			Debug.Assert(capacity >= 0);
			Realloc(capacity);

			if (capacity < mSize)
				mSize = (.)capacity;
			if (capacity <= mNext)
				mNext = 0;
		}

		public void Add(T item)
		{
			mItems[mNext] = item;
			mNext = (mNext + 1) % (.)AllocSize;
			if (mSize < AllocSize)
				mSize++;
		}

		[NoDiscard]
		/// Returns a ref to the element to be added into, progresses the buffer fill like Add
		public ref T AddByRef()
		{
			let curr = mNext;
			mNext = (mNext + 1) % (.)AllocSize;
			if (mSize < AllocSize)
			{
				mSize++;
				mItems[curr] = default;
			}

			return ref mItems[curr];
		}

		public void Clear()
		{
			mNext = 0;
			mSize = 0;
		}

		public bool PopFront()
		{
		    if (mSize > 0)
		    {
		        mSize--;
		        return true;
		    }
		    return false;
		}

		public bool Contains(T item)
		{	
			if (AllocSize > mSize)
			{
				// Do it the proper way since we might have things left in unclaimed indices
				for (let i < mSize)
				{
					if (mItems[FromRelativeIndex(i)] == item)
						return true;
				}
			}
			else
			{
				// mItems is fully used, so we can just iterate though it whatever
				for (let i < mSize)
				{
					if (mItems[[Unchecked]i] == item)
						return true;
				}
			}
			return false;
		}

		public int IndexOf(T item)
		{	
			if (AllocSize > mSize)
			{
				// Do it the proper way since we might have things left in unclaimed indices
				for (let i < mSize)
				{
					if (mItems[FromRelativeIndex(i)] == item)
						return i;
				}
			}
			else
			{
				// mItems is fully used, so we can just iterate though it whatever
				for (let i < mSize)
				{
					if (mItems[[Unchecked]i] == item)
						return i;
				}
			}
			return -1;
		}

		public void CopyTo(T[] array)
		{
			CopyTo(array, 0);
		}

		public void CopyTo(List<T> destList)
		{
			destList.EnsureCapacity(mSize, true);
			destList.[Friend]mSize = mSize;
			if (mSize > 0)
			{
				for (let item in this)
					destList.Add(item);
			}	
		}

		public void CopyTo(T[] array, int arrayIndex)
		{
			for (int i = 0; i < mSize; i++)
				array[i + arrayIndex] = this[i];
		}

		public void CopyTo(int index, T[] array, int arrayIndex, int count)
		{
			Debug.Assert(count <= mSize);
			for (int i = 0; i < count; i++)
				array[i + arrayIndex] = this[i + index];
		}

		protected override void GCMarkMembers()
		{
			if (mItems == null)
				return;
			let type = typeof(T);
			if ((type.[Friend]mTypeFlags & .WantsMark) == 0)
				return;
			for (int i < mSize)
			{
				GC.Mark!(mItems[FromRelativeIndex(i)]);
			}
		}

		public Enumerator GetEnumerator()
		{
			return Enumerator(this, false);
		}

		public Enumerator GetBackwardsEnumerator()
		{
			return Enumerator(this, true);
		}

		public struct Enumerator : IRefEnumerator<T*>, IEnumerator<T>, IResettable
		{
			private CircularBuffer<T> mBuffer;
			private int mRelIndex;
			private T* mCurrent;
			private bool mBackwards;

			public this(CircularBuffer<T> buffer, bool backwards)
			{
				mBuffer = buffer;
				mRelIndex = backwards ? buffer.mSize - 1 : 0;
				mCurrent = null;
				mBackwards = backwards;
			}

			public bool MoveNext() mut
			{
				CircularBuffer<T> localBuf = mBuffer;
				if (uint(mRelIndex) < uint(mBuffer.mSize))
				{
					let index = localBuf.FromRelativeIndex(mRelIndex);
					mCurrent = &localBuf.mItems[index];
					mRelIndex = mBackwards ? mRelIndex - 1 : mRelIndex + 1;
					return true;
				}
				return MoveNextRare();
			}

			private bool MoveNextRare() mut
			{
				mRelIndex = mBuffer.mSize + 1;
				mCurrent = null;
				return false;
			}

			public T Current
			{
				get
				{
					return *mCurrent;
				}

				set
				{
					*mCurrent = value;
				}
			}

			public ref T CurrentRef
			{
				get
				{
					return ref *mCurrent;
				}
			}

			public int Index
			{
				get
				{
					return mRelIndex - 1;
				}
			}

			public int Count
			{
				get
				{
					return mBuffer.Count;
				}
			}

			public void Reset() mut
			{
				mRelIndex = mBackwards ? mBuffer.mSize - 1 : 0;
				mCurrent = null;
			}

			public Result<T> GetNext() mut
			{
				if (!MoveNext())
					return .Err;
				return Current;
			}

			public Result<T*> GetNextRef() mut
			{
				if (!MoveNext())
					return .Err;
				return &CurrentRef;
			}
		}
	}
}
