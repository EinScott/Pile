namespace Pile
{
	public interface IRenderTarget
	{
		public bool Renderable { get; }

		public UPoint2 RenderSize { get; }
	}
}
