using System;

namespace Pile
{
	extension Axes
	{
		// Account for extensions
		[Comptime]
		public static int Count() => typeof(Axes).MaxValue.Underlying + 1;
	}

	enum Axes
	{
		Unknown = 0,
		LeftX = 1,
		LeftY = 2,
		RightX = 3,
		RightY = 4,
		LeftTrigger = 5,
		RightTrigger = 6
	}
}
