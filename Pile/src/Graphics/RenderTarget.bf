namespace Pile
{
	public abstract class RenderTarget
	{
		public bool Renderable { get; protected set; }

		public abstract UPoint2 RenderSize { get; }
	}
}
