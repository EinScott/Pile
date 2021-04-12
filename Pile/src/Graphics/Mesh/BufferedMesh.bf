using System;

namespace Pile
{
	class BufferedMesh<TVert> where TVert : struct
	{
		[Inline]
		public uint VertexCount => vertexCount;
		[Inline]
		public uint IndexCount => indexCount;
		[Inline]
		public uint TriangleCount => indexCount / 3;
		[Inline]
		public Mesh UnderlyingMesh => mesh;

		Mesh mesh = new .() ~ delete _;
		uint indexCount;
		uint vertexCount;
		TVert[] vertices = new TVert[64] ~ delete _;
		uint32[] indices = new uint32[64] ~ delete _;
		bool dirty;

		readonly VertexFormat format;

		public this(VertexFormat vertexFormat)
		{
			format = vertexFormat;
		}

		public Span<TVert> PushTriangle()
		{
			let ret = EnsureBuffer(3, 3);

			let count = (uint32)ret.newVert;
			indices[[Unchecked]ret.newIndex] = count;
			indices[[Unchecked]ret.newIndex + 1] = count + 1;
			indices[[Unchecked]ret.newIndex + 2] = count + 2;

			dirty = true;
			return .(&vertices[[Unchecked]ret.newVert], 3);
		}

		public Span<TVert> PushQuad()
		{
			let ret = EnsureBuffer(4, 6);

			let count = (uint32)ret.newVert;
			indices[[Unchecked]ret.newIndex] = count;
			indices[[Unchecked]ret.newIndex + 1] = count + 1;
			indices[[Unchecked]ret.newIndex + 2] = count + 2;
			indices[[Unchecked]ret.newIndex + 3] = count + 0;
			indices[[Unchecked]ret.newIndex + 4] = count + 2;
			indices[[Unchecked]ret.newIndex + 5] = count + 3;

			dirty = true;
			return .(&vertices[[Unchecked]ret.newVert], 4);
		}

		[Inline]
		public void Clear()
		{
			indexCount = 0;
			vertexCount = 0;
		}

		public void ApplyBuffers()
		{
			if (!dirty)
				return;

			dirty = false;

			mesh.SetVertices((Span<TVert>)vertices, format);
			mesh.SetIndices((Span<uint32>)indices);
		}

		[Inline]
		protected (int newVert, int newIndex) EnsureBuffer(uint addVertex, uint addIndex)
		{
			EnsureCap(ref vertices, vertexCount, addVertex);
			EnsureCap(ref indices, indexCount, addIndex);

			let ret = ((int)vertexCount, (int)indexCount);

			vertexCount += addVertex;
			indexCount += addIndex;

			return ret;

			void EnsureCap<T>(ref T[] buffer, uint bufferFill, uint requiredSpace)
			{
				// Get required size
				var reserved = buffer.Count;
				while (bufferFill + requiredSpace >= (.)reserved) // Reserve more
					reserved *= 2;

				if (reserved != buffer.Count)
				{
					let newBuf = new T[reserved];
					Internal.MemCpy(newBuf.Ptr, buffer.Ptr, (.)bufferFill);
					delete buffer;
					buffer = newBuf;
				}
			}
		}
	}
}
