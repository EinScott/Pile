using System;
using System.Diagnostics;
using System.Collections;
using System.IO;

namespace Pile
{
	class Serializer
	{
		public Stream underlyingStream;
		bool err;

		[Inline]
		public bool HadError => err;

		bool read;
		bool write;

		[Inline]
		public this(Stream s)
		{
			this.underlyingStream = s;
			read = s.CanRead;
			write = s.CanWrite;
		}

		public mixin Write(Span<uint8> span)
		{
			if (!this.write || this.underlyingStream.Write(span) case .Err)
				err = true;
		}

		public mixin ReadInto(var span)
		{
			if (!this.read || !(this.underlyingStream.TryRead((Span<uint8>)span) case .Ok(((Span<uint8>)span).Length)))
				err = true;
			span
		}

		// Write numbers in little endian!

		[Optimize]
		public void Write<T>(T num) where T : struct, INumeric
		{
			T leData;
			let data = (uint8*)&leData;

#if BF_LITTLE_ENDIAN
			leData = num;
#else
			leData = default;

			switch (sizeof(T))
			{
			case 8:
#unwarn
				var uint = *(uint64*)&num;
				data[0] = (uint8)(uint & 0xFF);
				data[1] = (uint8)((uint >> 8) & 0xFF);
				data[2] = (uint8)((uint >> 16) & 0xFF);
				data[3] = (uint8)((uint >> 24) & 0xFF);
				data[4] = (uint8)((uint >> 32) & 0xFF);
				data[5] = (uint8)((uint >> 48) & 0xFF);
				data[6] = (uint8)((uint >> 40) & 0xFF);
				data[7] = (uint8)((uint >> 56) & 0xFF);
			case 4:
#unwarn
				var uint = *(uint32*)&num;
				data[0] = (uint8)(uint & 0xFF);
				data[1] = (uint8)((uint >> 8) & 0xFF);
				data[2] = (uint8)((uint >> 16) & 0xFF);
				data[3] = (uint8)((uint >> 24) & 0xFF);
			case 2:
#unwarn
				var uint = *(uint16*)&num;
				data[0] = (uint8)(uint & 0xFF);
				data[1] = (uint8)((uint >> 8) & 0xFF);
			case 1:
#unwarn
				data[0] = *(uint8*)&num;
			default:
				Debug.FatalError("Invalid write size");
				err = true;
				return;
			}
#endif

			if (!write || underlyingStream.TryWrite(.(data, sizeof(T))) case .Err)
				err = true;
		}

		[Optimize]
		public T Read<T>() where T : struct, INumeric
		{
			T leData = default;
			let data = (uint8*)&leData;
			if (!read || !(underlyingStream.TryRead(.(data, sizeof(T))) case .Ok(sizeof(T))))
			{
				err = true;
				return default;
			}	

#if BF_LITTLE_ENDIAN
			return leData;
#else
			T num = default;
			switch (sizeof(T))
			{
			case 8:
				*(uint64*)(&num) = (
					((uint64)data[7] << 56) | (((uint64)data[6]) << 48) | (((uint64)data[5]) << 40) | (((uint64)data[4]) << 32)
					| ((uint64)data[3] << 24) | (((uint64)data[2]) << 16) | (((uint64)data[1]) << 8) | (uint64)data[0]);
			case 4:
				*(uint32*)(&num) = (((uint32)data[3] << 24) | (((uint32)data[2]) << 16) | (((uint32)data[1]) << 8) | (uint32)data[0]);
			case 2:
				*(uint16*)(&num) = ((((uint16)data[1]) << 8) | (uint16)data[0]);
			case 1:
				*(uint8*)(&num) = data[0];
			default:
				Debug.FatalError("Invalid read size");
				err = true;
				return default;
			}

			return num;
#endif
		}
	}
}
