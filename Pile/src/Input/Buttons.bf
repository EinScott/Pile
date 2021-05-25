using System;

namespace Pile
{
	extension Buttons
	{
		// Account for extensions
		[Comptime]
		public static int Count() => typeof(Buttons).MaxValue.Underlying + 1;
	}

	enum Buttons
	{
		Unknown = 0,
		A = 1,
		B = 2,
		X = 3,
		Y = 4,
		Back = 5,
		Select = 6,
		Start = 7,
		LeftStick = 8,
		RightStick = 9,
		LeftShoulder = 10,
		RightShoulder = 11,
		Up = 12,
		Down = 13,
		Left = 14,
		Right = 15
	}
}
