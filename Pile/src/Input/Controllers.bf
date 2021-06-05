using System;

namespace Pile
{
	extension Controllers
	{
		// Account for extensions
		[Comptime]
		public static int Count() => typeof(Controllers).MaxValue.Underlying + 1;
	}

	enum Controllers
	{
		First = 0,
		Second = 1,
		Third = 2,
		Fourth = 3
	}
}
