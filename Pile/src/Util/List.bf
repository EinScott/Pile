using System.Diagnostics;

namespace System.Collections
{
	extension List<T>
	{
		public void Reverse()
		{				   
			Reverse(0, Count);
		}

		// --copy-paste from Array.Reverse()
		// Reverses the elements in a range of an array. Following a call to this
		// method, an element in the range given by index and count
		// which was previously located at index i will now be located at
		// index index + (index + count - i - 1).
		// Reliability note: This may fail because it may have to box objects.
		public void Reverse(int index, int length)
		{
			Debug.Assert(index >= 0);
			Debug.Assert(length >= 0);
			Debug.Assert(length >= Count - index);
			
			int i = index;
			int j = index + length - 1;
			while (i < j)
			{
				let temp = this[i];
				this[i] = this[j];
				this[j] = temp;
				i++;
				j--;
			}
		}
	}
}
