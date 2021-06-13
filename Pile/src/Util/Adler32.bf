using System;
using System.IO;

namespace Pile
{
	[Optimize]
	static class Adler32
	{
		public static uint32 Add(uint32 adler, Span<uint8> buffer)
		{
		    const int32 BASE = 65521;
		    const int32 NMAX = 5552;
			var adler;

		    int len = buffer.Length;
		    int32 n;
		    uint32 sum2;

		    sum2 = (adler >> 16) & 0xffff;
		    adler &= 0xffff;
			uint8* buf = &buffer[0];

		    if (len == 1)
		    {
		        adler += buf[0];
		        if (adler >= BASE)
		            adler -= BASE;
		        sum2 += adler;
		        if (sum2 >= BASE)
		            sum2 -= BASE;
		        return adler | (sum2 << 16);
		    }

		    if (len < 16)
		    {
		        while (len-- > 0)
		        {
		            adler += *buf++;
		            sum2 += adler;
		        }
		        if (adler >= BASE)
		            adler -= BASE;
		        sum2 %= BASE;
		        return adler | (sum2 << 16);
		    }

		    while (len >= NMAX)
		    {
		        len -= NMAX;
		        n = NMAX / 16;
		        repeat
		        {
		            adler += buf[0];
		            sum2 += adler;
		            adler += buf[0 + 1];
		            sum2 += adler;
		            adler += buf[0 + 2];
		            sum2 += adler;
		            adler += buf[0 + 2 + 1];
		            sum2 += adler;
		            adler += buf[0 + 4];
		            sum2 += adler;
		            adler += buf[0 + 4 + 1];
		            sum2 += adler;
		            adler += buf[0 + 4 + 2];
		            sum2 += adler;
		            adler += buf[0 + 4 + 2 + 1];
		            sum2 += adler;
		            adler += buf[8];
		            sum2 += adler;
		            adler += buf[8 + 1];
		            sum2 += adler;
		            adler += buf[8 + 2];
		            sum2 += adler;
		            adler += buf[8 + 2 + 1];
		            sum2 += adler;
		            adler += buf[8 + 4];
		            sum2 += adler;
		            adler += buf[8 + 4 + 1];
		            sum2 += adler;
		            adler += buf[8 + 4 + 2];
		            sum2 += adler;
		            adler += buf[8 + 4 + 2 + 1];
		            sum2 += adler;
		            buf += 16;
		        } while (--n > 0);
		        adler %= BASE;
		        sum2 %= BASE;
		    }

		    if (len > 0)
		    {
		        while (len >= 16)
		        {
		            len -= 16;
		            adler += buf[0];
		            sum2 += adler;
		            adler += buf[0 + 1];
		            sum2 += adler;
		            adler += buf[0 + 2];
		            sum2 += adler;
		            adler += buf[0 + 2 + 1];
		            sum2 += adler;
		            adler += buf[0 + 4];
		            sum2 += adler;
		            adler += buf[0 + 4 + 1];
		            sum2 += adler;
		            adler += buf[0 + 4 + 2];
		            sum2 += adler;
		            adler += buf[0 + 4 + 2 + 1];
		            sum2 += adler;
		            adler += buf[8];
		            sum2 += adler;
		            adler += buf[8 + 1];
		            sum2 += adler;
		            adler += buf[8 + 2];
		            sum2 += adler;
		            adler += buf[8 + 2 + 1];
		            sum2 += adler;
		            adler += buf[8 + 4];
		            sum2 += adler;
		            adler += buf[8 + 4 + 1];
		            sum2 += adler;
		            adler += buf[8 + 4 + 2];
		            sum2 += adler;
		            adler += buf[8 + 4 + 2 + 1];
		            sum2 += adler;
		            buf += 16;
		        }

		        while (len-- > 0)
		        {
		            adler += *buf++;
		            sum2 += adler;
		        }
		        adler %= BASE;
		        sum2 %= BASE;
		    }

		    return adler | (sum2 << 16);
		}

		public static uint32 Add(uint32 adler, Stream stream, bool resetPos = false)
		{
			var adler;

		    var next = 0;
			var prevPos = stream.Position;

		    Span<uint8> buffer = scope uint8[1024];
		    while (Read())
		        adler = Add(adler, buffer.Slice(0, next));

			if (resetPos)
				stream.Position = prevPos;

		    return adler;

			bool Read()
			{
				let res = stream.TryRead(buffer);

				switch (res)
				{
				case .Err:
					return false;
				case .Ok(let val):
					next = val;
					return true;
				}
			}
		}
	}
}
