using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Mesh : Mesh.Platform
	{
		[SkipCall]
		internal override void SetVertices(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		internal override void SetInstances(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		internal override void SetIndices(Span<uint8> rawIndexData) {}
	}
}
