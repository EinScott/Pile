using System;

namespace Pile
{
	abstract class RenderTarget
	{
		protected bool renderable;

		[Inline]
		public bool Renderable => renderable;

		public abstract UPoint2 RenderSize { get; }
	}
}
