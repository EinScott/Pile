using System;
using System.Diagnostics;
using System.IO;

namespace Pile
{
	class Serializer
	{
		public Stream s;
		bool err;

		[Inline]
		public bool HadError => err;

		bool read;
		bool write;

		public this(Stream s)
		{
			err = false;
			this.s = s;
			read = s.CanRead;
			write = s.CanWrite;
		}

		public mixin Write(Span<uint8> span)
		{
			if (!this.write || this.s.Write(span) case .Err)
				this.err = true;
		}

		public mixin ReadInto(var span)
		{
			if (!this.read || !(this.s.TryRead((Span<uint8>)span) case .Ok(((Span<uint8>)span).Length)))
				this.err = true;
			span
		}

		[Optimize]
		public void Write<T>(T num) where T : struct, INumeric
		{
			var num;

			// Making this a span avoids array access checks
			Span<uint8> data = scope:: uint8[sizeof(T)];

			switch (sizeof(T))
			{
			case 8:
				var uint = *(uint64*)&num;
				data[0] = (uint8)((uint >> 56) & 0xFF);
				data[1] = (uint8)((uint >> 48) & 0xFF);
				data[2] = (uint8)((uint >> 40) & 0xFF);
				data[3] = (uint8)((uint >> 32) & 0xFF);
				data[4] = (uint8)((uint >> 24) & 0xFF);
				data[5] = (uint8)((uint >> 16) & 0xFF);
				data[6] = (uint8)((uint >> 8) & 0xFF);
				data[7] = (uint8)(uint & 0xFF);
			case 4:
				var uint = *(uint32*)&num;
				data[0] = (uint8)((uint >> 24) & 0xFF);
				data[1] = (uint8)((uint >> 16) & 0xFF);
				data[2] = (uint8)((uint >> 8) & 0xFF);
				data[3] = (uint8)(uint & 0xFF);
			case 2:
				var uint = *(uint16*)&num;
				data[0] = (uint8)((uint >> 8) & 0xFF);
				data[1] = (uint8)(uint & 0xFF);
			case 1:
				data[0] = *(uint8*)&num;
			default:
				err = true;
				Debug.FatalError("Invalid read size");
			}

			if (!write || s.TryWrite(data) case .Err)
				err = true;
		}

		[Optimize]
		public T Read<T>() where T : struct, INumeric
		{
			T data = default;
			let tSpan = Span<uint8>((uint8*)&data, sizeof(T));
			if (!read || !(s.TryRead(tSpan) case .Ok(sizeof(T))))
				err = true;

			T res = default;
			switch (sizeof(T))
			{
			case 8:
				*(uint64*)(&res) = (
					((uint64)tSpan[0] << 56) | (((uint64)tSpan[1]) << 48) | (((uint64)tSpan[2]) << 40) | (((uint64)tSpan[3]) << 32)
					| ((uint64)tSpan[4] << 24) | (((uint64)tSpan[5]) << 16) | (((uint64)tSpan[6]) << 8) | (uint64)tSpan[7]);
			case 4:
				*(uint32*)(&res) = (((uint32)tSpan[0] << 24) | (((uint32)tSpan[1]) << 16) | (((uint32)tSpan[2]) << 8) | (uint32)tSpan[3]);
			case 2:
				*(uint16*)(&res) = ((((uint16)tSpan[0]) << 8) | (uint16)tSpan[1]);
			case 1:
				*(uint8*)(&res) = tSpan[0];
			default:
				err = true;
				Debug.FatalError("Invalid read size");
			}

			return res;
		}
	}
}
