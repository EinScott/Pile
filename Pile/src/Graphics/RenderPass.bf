namespace Pile
{
	public struct RenderPass
	{
		public RenderTarget target;
		public Rect? viewport;

		public Material material;
		public Mesh mesh;

		public uint meshIndexStart;
		public uint meshIndexCount;

		public BlendMode blendMode;
		public CullMode cullMode;
		public Compare depthFunction;
		public Rect? scissor;

		public this(RenderTarget target, Mesh mesh, Material material)
		{
			this.target = target;
			viewport = null;

			this.material = material;
			this.mesh = mesh;

			meshIndexStart = 0;
			meshIndexCount = mesh.IndexCount;

			scissor = null;
			blendMode = .Normal;
			depthFunction = .None;
			cullMode = .None;
		}
	}
}
