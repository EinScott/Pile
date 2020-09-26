using System;

namespace Pile.Implementations
{
	public class Null_Mesh : Mesh.Platform
	{
		[SkipCall]
		public override void Setup(Span<uint8> vertices, Span<uint32> indices, VertexFormat format) {}
	}
}
