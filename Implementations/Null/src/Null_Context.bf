using System;

namespace Pile.Implementations
{
	public class Null_Context : ISystemOpenGL.Context
	{
		[SkipCall]
		public override void MakeCurrent() {}
	}
}
