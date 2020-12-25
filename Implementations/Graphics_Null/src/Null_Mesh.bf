using System;

using internal Pile;

namespace Pile
{
	extension Mesh
	{
		[SkipCall]
		protected internal override void SetVertices(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		protected internal override void SetInstances(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		protected internal override void SetIndices(Span<uint8> rawIndexData) {}
	}
}
