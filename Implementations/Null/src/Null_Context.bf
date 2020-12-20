using System;

namespace Pile
{
	public class Null_Context : ISystemOpenGL.Context
	{
		[SkipCall]
		public override void MakeCurrent() {}
	}
}
