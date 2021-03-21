using System;

using internal Pile;

namespace Pile
{
	extension Mesh
	{
		[SkipCall]
		protected override void SetVertices(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		protected override void SetInstances(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		protected override void SetIndices(Span<uint8> rawIndexData) {}
	}
}
