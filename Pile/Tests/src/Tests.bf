using System;
using Pile;

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

		[Test(ShouldFail=true)]
		static void TestCircularBufferFail()
		{
			CircularBuffer<int> ints = scope .(5) { 1, 2, 3 };
#unwarn
			let s = ints[5];
		}
	}
}
