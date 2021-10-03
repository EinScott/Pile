using System;
using Pile;
using System.IO;
using System.Diagnostics;

namespace Test
{
	class Tests
	{
		[Test]
		static void TestCircularBuffer()
		{
			CircularBuffer<int> ints = scope .(5) { 1, 2, 3 };
			Test.Assert(ints.Capacity == 5);
			Test.Assert(ints.Count == 3);

			let set3 = (ints[0], ints[1], ints[2]);
			Test.Assert(set3 == (1, 2, 3));

			int i = 1;
			for (let val in ints)
			{
				Test.Assert(val == i);
				i++;
			}

			var num = ref ints.AddByRef();
			Test.Assert(num == default);
			num = 4;
			Test.Assert(ints[3] == 4);
			Test.Assert(ints.Front == 1);
			Test.Assert(ints.Back == 4);

			ints.Add(5);
			ints.Add(6);
			Test.Assert(ints.Count == 5);
			Test.Assert(ints.Front == 2);
			Test.Assert(ints.[Friend]mItems[1] == 2);
			Test.Assert(ints.Back == 6);
			Test.Assert(ints[4] == 6);
			Test.Assert(ints.[Friend]mItems[0] == 6);

			i = 2;
			for (let val in ints)
			{
				Test.Assert(val == i);
				i++;
			}

			i = 6;
			for (let val in ints.GetBackwardsEnumerator())
			{
				Test.Assert(val == i);
				i--;
			}

			ints.Resize(8);
			let set5 = (ints[0], ints[1], ints[2], ints[3], ints[4]);
			Test.Assert(set5 == (2, 3, 4, 5, 6));
			Test.Assert(ints.[Friend]mItems[0] == 2);
			Test.Assert(ints.Capacity == 8);
			Test.Assert(ints.Count == 5);

			ints.Clear();
			Test.Assert(ints.Count == 0);
		}

		// This trips up the debugger every time (due to the Runtime assert in the indexer) and generally passes.
		/*[Test(ShouldFail=true)]
		static void TestCircularBufferFail()
		{
			CircularBuffer<int> ints = scope .(5) { 1, 2, 3 };

#unwarn
			let s = ints[5];
		}*/

		[Test]
		static void TestCompression()
		{
			String s = "I am a nice string, I do lots of interesting stuff and it works totally fine. My favorite color is purple and I despise quotes..";
			uint8[128] buffer = .();
			Test.Assert(Compression.Compress(.((uint8*)s.Ptr, s.Length), buffer) case .Ok(let bufFill));

			char8[128] sOut = .();
			Test.Assert(Compression.Decompress(.(&buffer[0], bufFill), .((.)&sOut[0], 128)) case .Ok(128));

			Test.Assert(s == StringView(&sOut, 128));
		}
		
		[Test]
		static void TestCompressionStreamRead()
		{
			MemoryStream mem = scope .();

			String s = "I am a nice string, I do lots of interesting stuff and it works totally fine. My favorite color is purple and I despise quotes..";
			uint8[128] buffer = .();
			Test.Assert(Compression.Compress(.((uint8*)s.Ptr, s.Length), buffer) case .Ok(let bufFill));

			mem.TryWrite(.(&buffer[0], (.)bufFill));
			mem.Position = 0;

			CompressionStream dcom = scope .(mem, .Decompress);

			uint8[128] outBuf = .();
			Test.Assert(dcom.TryRead(outBuf) case .Ok(128));

			dcom.Close();
			mem.Position = 0;

			uint8[18] firstBit = .();
			Test.Assert(dcom.TryRead(firstBit) case .Ok(18));
			Test.Assert(StringView((.)&firstBit[0], 18) == "I am a nice string");

			uint8[60] laterBit = .();
			Test.Assert(dcom.TryRead(laterBit) case .Ok(60));
			Test.Assert(StringView((.)&laterBit[0], 60) == ", I do lots of interesting stuff and it works totally fine. ");
		}

		[Test]
		static void TestCompressionStreamBig()
		{
			const int TestCount = (int)uint16.MaxValue * 10000;
			uint8[] compData = new .[TestCount];
			defer delete compData;

			int32 data = 0;
			for (let i < compData.Count)
			{
				data += uint16.MaxValue;
				data <<= 2;
				data *= 3;
				compData[[Unchecked]i] = *(uint8*)&data;
			}
			
			MemoryStream mem = scope .();
			{
				CompressionStream comp = scope .(mem, .BEST_COMPRESSION);

				comp.TryWrite(compData);
			}

			Test.Assert(mem.Position != 0);
			Test.Assert(mem.Length != 0);
			Debug.WriteLine(scope $"Compressed {TestCount} into {mem.Length} bytes");
			mem.Position = 0;

			uint8[] dcomData = new .[TestCount];
			defer delete dcomData;
			{

				CompressionStream dcom = scope .(mem, .Decompress);
				dcom.TryRead(dcomData);
			}

			uint8 expect = 0, real = 0;
			var i = 0;
			for (; i < compData.Count; i++)
				if (compData[[Unchecked]i] != dcomData[[Unchecked]i])
				{
					expect = compData[i];
					real = dcomData[i];
					break;
				}	

			Test.Assert(i == compData.Count, scope $"{expect} != {real}");
		}

		[Test]
		static void TestCompressionStream()
		{
			MemoryStream mem = scope .();
			{
				CompressionStream comp = scope .(mem, .BEST_COMPRESSION);

				comp.Write(5, 18);
				Test.Assert(comp.WriteStrSized32("I am a String. I am indeed a String. A very nice one.") case .Ok);
				Test.Assert(comp.Flush() case .Ok);
				Test.Assert(comp.Write(uint16[16](1, 2000, 3, 168, 35, 243, 999, 32, 5566, 53, 1, 1, 35676, 7, 1, 999)) case .Ok);
				Test.Assert(comp.Close() case .Ok);
			}

			Test.Assert(mem.Position != 0);
			Test.Assert(mem.Length != 0);
			mem.Position = 0;

			{
				// Check the first bit if the original data
				let orig = uint8[37](5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 53, 0, 0, 0, (.)'I', (.)' ', (.)'a', (.)'m', (.)' ', (.)'a', (.)' ', (.)'S', (.)'t', (.)'r', (.)'i', (.)'n', (.)'g', (.)'.', (.)' ');
				
				uint8[199] buffer = .();
				let comp = Compression.Decompress(mem.[Friend]mMemory, buffer);
				Test.Assert(comp case .Ok(107));
				for (let i < 37)
				{
					Test.Assert(buffer[i] == orig[i]);
				}
			}

			{
				CompressionStream dcom = scope .(mem, .Decompress);

				for (let i < 18)
					Test.Assert(dcom.Read<uint8>() case .Ok(5));
				String s = scope .();
				Test.Assert(dcom.ReadStrSized32(s) case .Ok);
				Test.Assert(s == "I am a String. I am indeed a String. A very nice one.");
				Test.Assert(dcom.Close() case .Ok);
			}
		}
	}
}
