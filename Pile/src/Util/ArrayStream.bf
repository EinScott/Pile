using System;
using System.IO;
using System.Diagnostics;

namespace Pile
{
	class ArrayStream : Stream
	{
		uint8[] mLocalData ~ { if (mOwnsData) delete _; };
		Span<uint8> mData;
		int mCount = 0;
		int mPosition = 0;
		bool mOwnsData;

		public this(Span<uint8> data)
		{
			// no own data!
			mOwnsData = false;
			mCount = data.Length;
			mData = data;
		}

		public this(int size)
		{
			mLocalData = new .[size];
			mData = mLocalData;
			mOwnsData = true;
		}

		public uint8* Ptr
		{
			get
			{
				return mData.Ptr;
			}
		}
		
		public Span<uint8> Content
		{
			get
			{
				return mData;
			}
		}

		public override int64 Position
		{
			get
			{
				return mPosition;
			}

			set
			{
				mPosition = (.)value;
			}
		}

		public override int64 Length
		{
			get
			{
				return mCount;
			}
		}

		public override bool CanRead
		{
			get
			{
				return true;
			}
		}

		public override bool CanWrite
		{
			get
			{
				return true;
			}
		}

		public uint8[] TakeOwnership()
		{
			Debug.Assert(mOwnsData);
			mOwnsData = false;
			return mLocalData;
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			if (data.Length == 0)
				return .Ok(0);
			int readBytes = Math.Min(data.Length, mCount - mPosition);
			if (readBytes <= 0)
				return .Ok(readBytes);

			Internal.MemCpy(data.Ptr, &mData[mPosition], readBytes);
			mPosition += readBytes;
			return .Ok(readBytes);
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			var count = data.Length;
			if (count == 0)
				return .Ok(0);
			int growSize = mPosition + count - mCount;
			if (growSize > 0)
			{
				mCount += growSize;
				if (mCount > mData.Length)
				{
					count -= mData.Length - mCount;
					mCount = mData.Length;
				}
			}
			Internal.MemCpy(&mData[mPosition], data.Ptr, count);
			mPosition += count;
			return .Ok(count);
		}

		public override Result<void> Close()
		{
			return .Ok;
		}
	}
}
