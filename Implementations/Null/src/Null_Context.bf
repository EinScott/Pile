using System;

namespace Pile.Implementations
{
	public class Null_Context : ISystemOpenGL.Context
	{
		public override bool Disposed => false;

		[SkipCall]
		public override void Dispose() {}

		[SkipCall]
		public override void MakeCurrent() {}
	}
}
