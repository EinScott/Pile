using System;
using System.Collections;

namespace Pile
{
	public struct ReadOnlyList<T> : IEnumerable<T>
	{
		// Read only list wrapper
		List<T> underlying;

		[Inline]
		public int AllocSize => underlying.AllocSize;

		[Inline]
		public bool IsDynAlloc => underlying.IsDynAlloc;

		public this(List<T> list)
		{
			underlying = list;
		}

		[Inline]
		public int Capacity => underlying.Capacity;

		[Inline]
		public int Count => underlying.Count;

		[Inline]
		public bool IsEmpty => underlying.IsEmpty;

		[Inline]
		public T this[int index] => underlying[index];

		[Inline]
		public T Front => underlying.Front;

		[Inline]
		public T Back => underlying.Back;

		[Inline]
		public ReadOnlySpan<T> GetRange(int offset) => underlying.GetRange(offset);

		[Inline]
		public ReadOnlySpan<T> GetRange(int offset, int count) => underlying.GetRange(offset, count);

		[Inline]
		public bool Contains(T item) => underlying.Contains(item);

		public bool ContainsAlt<TAlt>(TAlt item) where TAlt : IHashable where bool : operator T == TAlt
		{
			return IndexOfAlt(item) != -1;
		}

		public void CopyTo(T[] array)
		{
			CopyTo(array, 0);
		}

		[Inline]
		public void CopyTo(List<T> destList) => underlying.CopyTo(destList);

		[Inline]
		public void CopyTo(T[] array, int arrayIndex) => underlying.CopyTo(array, arrayIndex);

		[Inline]
		public void CopyTo(int index, T[] array, int arrayIndex, int count) => underlying.CopyTo(index, array, arrayIndex, count);

		public Enumerator GetEnumerator()
		{
			return Enumerator(underlying);
		}

		[Inline]
		public int FindIndex(Predicate<T> match) => underlying.FindIndex(match);

		[Inline]
		public int IndexOf(T item) => underlying.IndexOf(item);

		[Inline]
		public int IndexOf(T item, int index) => underlying.IndexOf(item, index);

		[Inline]
		public int IndexOf(T item, int index, int count) => underlying.IndexOf(item, index, count);

		[Inline]
		public int IndexOfStrict(T item) => underlying.IndexOfStrict(item);

		[Inline]
		public int IndexOfStrict(T item, int index) => IndexOfStrict(item, index);

		[Inline]
		public int IndexOfStrict(T item, int index, int count) => underlying.IndexOfStrict(item, index, count);

		[Inline]
		public int IndexOfAlt<TAlt>(TAlt item) where TAlt : IHashable where bool : operator T == TAlt
		{
			return underlying.IndexOfAlt(item);
		}

		[Inline]
		public int LastIndexOf(T item) => underlying.LastIndexOf(item);

		[Inline]
		public int LastIndexOfStrict(T item) => underlying.LastIndexOfStrict(item);

		/// The method returns the index of the given value in the list. If the
		/// list does not contain the given value, the method returns a negative
		/// integer. The bitwise complement operator (~) can be applied to a
		/// negative result to produce the index of the first element (if any) that
		/// is larger than the given search value. This is also the index at which
		/// the search value should be inserted into the list in order for the list
		/// to remain sorted.
		/// 
		/// The method uses the Array.BinarySearch method to perform the
		/// search.
		///
		/// @brief Searches a section of the list for a given element using a binary search algorithm.
		public int BinarySearch(T item, delegate int(T lhs, T rhs) comparer)
		{
			return Array.BinarySearch(underlying.[Friend]mItems, underlying.Count, item, comparer);
		}

		public int BinarySearchAlt<TAlt>(TAlt item, delegate int(T lhs, TAlt rhs) comparer)
		{
			return Array.BinarySearchAlt(underlying.[Friend]mItems, underlying.Count, item, comparer);
		}

		[Inline]
		public int BinarySearch(int index, int count, T item, delegate int(T lhs, T rhs) comparer)
		{
			return underlying.BinarySearch(index, count, item, comparer);
		}

		public static operator ReadOnlySpan<T>(ReadOnlyList<T> list)
		{
			return ReadOnlySpan<T>(list.underlying.[Friend]mItems, list.underlying.[Friend]mSize);
		}

		public struct Enumerator : IEnumerator<T>, IResettable
		{
	        private List<T> mList;
	        private int mIndex;
	        private T* mCurrent;

	        public this(List<T> list)
	        {
	            mList = list;
	            mIndex = 0;
	            mCurrent = null;
	        }

	        public void Dispose()
	        {
	        }

	        public bool MoveNext() mut
	        {
	            List<T> localList = mList;
	            if ((uint(mIndex) < uint(localList.[Friend]mSize)))
	            {
	                mCurrent = &localList.[Friend]mItems[mIndex];
	                mIndex++;
	                return true;
	            }			   
	            return MoveNextRare();
	        }

	        private bool MoveNextRare() mut
	        {
	        	mIndex = mList.[Friend]mSize + 1;
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

			public int Index
			{
				get
				{
					return mIndex - 1;
				}				
			}

			public int Count
			{
				get
				{
					return mList.Count;
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
	}
}
