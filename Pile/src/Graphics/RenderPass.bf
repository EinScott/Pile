namespace Pile
{
	public struct RenderPass
	{
		public RenderTarget target;
		public Rect? viewport;

		//public Material material; // Material is basically just a thing
		// that holds a shader and all values for that shader, like setting texture, etc
		public Mesh mesh; // is this just basically a buffer? what is vertexFormat, is it neccessary? can it be integrated into the mesh (should it -> size)?

		public BlendMode blendMode;
		public CullMode cullMode;
		public Compare depthFunction;
		public Rect? scissor;

		public this(RenderTarget target, Mesh mesh)
		{
			this.mesh = mesh;
			this.target = target;
			viewport = null;

			scissor = null;
			blendMode = BlendMode.Normal;
			depthFunction = .None;
			cullMode = .None;
		}
	}
}
