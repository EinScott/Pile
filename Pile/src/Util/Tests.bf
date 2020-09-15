#if TEST // currently, compiling tests crashes
using System;

namespace Pile
{
	static
	{
		[Test]
		static Result<void, String> FileSystemTest()
		{
			return .Ok;
		}
	}
}
#endif