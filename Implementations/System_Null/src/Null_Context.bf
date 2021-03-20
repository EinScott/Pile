using System;

namespace Pile
{
	class Null_Context : ISystemOpenGL.Context
	{
		[SkipCall]
		public override void MakeCurrent() {}
	}
}
