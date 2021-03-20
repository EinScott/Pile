namespace Pile
{
	struct RenderPass
	{
		public IRenderTarget target;
		public Rect? viewport;

		public Material material;
		public Mesh mesh;

		public uint meshIndexStart;
		public uint meshIndexCount;

		public uint meshInstanceCount;

		public BlendMode blendMode;
		public CullMode cullMode;
		public Compare depthFunction;
		public Rect? scissor;

		public this(IRenderTarget target, Mesh mesh, Material material)
		{
			this.target = target;
			viewport = null;

			this.material = material;
			this.mesh = mesh;

			meshIndexStart = 0;
			meshIndexCount = mesh.IndexCount;
			meshInstanceCount = mesh.InstanceCount;

			scissor = null;
			blendMode = .Normal;
			depthFunction = .None;
			cullMode = .None;
		}
	}
}
