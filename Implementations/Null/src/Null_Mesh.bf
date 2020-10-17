using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Mesh : Mesh.Platform
	{
		[SkipCall]
		internal override void Setup(Span<uint8> vertices, Span<uint8> indices, VertexFormat format) {}
	}
}
