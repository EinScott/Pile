using System;

namespace Pile
{
	extension MouseButtons
	{
		// Account for extensions
		[Comptime]
		public static int Count() => typeof(MouseButtons).MaxValue.Underlying + 1;
	}

	enum MouseButtons
	{
		Unknown = 0,
		Left = 1,
		Middle = 2,
		Right = 3,
		Extra1 = 4,
		Extra2 = 5
	}
}
