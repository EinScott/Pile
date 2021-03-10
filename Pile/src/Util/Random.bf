namespace System
{
	extension Random
	{
		[Inline]
		/// Example: a 3 (= x) in 10 (= y) chance
		public bool XinYChance(int x, int y)
		{
			return Next(0, y) <= x - 1;
		}
	}
}
