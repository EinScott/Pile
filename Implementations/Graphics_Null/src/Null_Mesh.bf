using System;

using internal Pile;

namespace Pile
{
	extension Mesh
	{
		[SkipCall]
		protected override void Initialize() {}

		[SkipCall]
		protected override void SetVerticesInternal(Span<uint8> rawVertexData, VertexFormat format) {}

		[SkipCall]
		protected override void SetVerticesEmptyInternal(uint count, VertexFormat format) {}

		[SkipCall]
		protected override void SetVerticesPartialInternal(uint offset, Span<uint8> rawVertexData) {}

		[SkipCall]
		protected override void SetInstancesInternal(Span<uint8> rawInstanceData, VertexFormat format) {}

		[SkipCall]
		protected override void SetInstancesEmptyInternal(uint count, VertexFormat format) {}

		[SkipCall]
		protected override void SetInstancesPartialInternal(uint offset, Span<uint8> rawInstanceData) {}

		[SkipCall]
		protected override void SetIndicesInternal(Span<uint8> rawIndexData, IndexType type) {}

		[SkipCall]
		protected override void SetIndicesEmptyInternal(uint count, IndexType type) {}

		[SkipCall]
		protected override void SetIndicesPartialInternal(uint offset, Span<uint8> rawIndexData) {}
	}
}
