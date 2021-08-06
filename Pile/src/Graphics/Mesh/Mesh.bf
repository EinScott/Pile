using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class Mesh
	{
		public uint VertexCount { [Inline]get; [Inline]private set; }
		public uint InstanceCount { [Inline]get; [Inline]private set; }
		public uint IndexCount { [Inline]get; [Inline]private set; }

		[Inline]
		public uint TriangleCount => IndexCount / 3;

		public VertexFormat VertexFormat { [Inline]get; [Inline]private set; }
		public VertexFormat InstanceFormat { [Inline]get; [Inline]private set; }
		public IndexType IndexType { [Inline]get; [Inline]private set; }

		public this()
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");

			Initialize();
		}

		public void SetVertices<T>(Span<T> vertices, VertexFormat format) where T : struct
		{
			Debug.Assert(format != null, "Vertex format cannot be null");

			VertexFormat = format;
			VertexCount = (.)vertices.Length;

			let _vertices = vertices.ToRawData();
			SetVerticesInternal(_vertices, format);
		}

		public void SetVertices(Span<uint8> vertices, VertexFormat format)
		{
			Debug.Assert(format != null, "Vertex format cannot be null");
			Debug.Assert(vertices.Length % format.Stride == 0, "Incomplete vertex data");

			VertexFormat = format;
			VertexCount = (.)vertices.Length / format.Stride;

			SetVerticesInternal(vertices, format);
		}

		/// Allocate empty vertices to be set with SetVerticesPartial()
		public void SetVerticesEmpty(uint count, VertexFormat format)
		{
			Debug.Assert(format != null, "Vertex format cannot be null");

			VertexFormat = format;
			VertexCount = count;

			SetVerticesEmptyInternal(count * format.Stride, format);
		}

		public void SetVerticesPartial<T>(uint offset, Span<T> vertices) where T : struct
		{
			Debug.Assert(VertexCount > 0, "Call SetVertices or SetVerticesEmpty first to establish a buffer to fill");
			Debug.Assert(offset + (.)vertices.Length < VertexCount);

			let _vertices = vertices.ToRawData();
			SetVerticesPartialInternal(offset, _vertices);
		}

		public void SetVerticesPartial(uint offset, Span<uint8> vertices)
		{
			Debug.Assert(VertexCount > 0, "Call SetVertices or SetVerticesEmpty first to establish a buffer to fill");
			Debug.Assert(vertices.Length % VertexFormat.Stride == 0, "Incomplete vertex data");
			Debug.Assert(offset + ((.)vertices.Length / VertexFormat.Stride) < VertexCount, "Partial range must be within buffer bounds");

			SetVerticesPartialInternal(offset, vertices);
		}

		public void SetInstances<T>(Span<T> instances, VertexFormat format) where T : struct
		{
			Debug.Assert(format != null, "Instance format cannot be null");

			InstanceFormat = format;
			InstanceCount = (.)instances.Length;

			let _instances = instances.ToRawData();
			SetInstancesInternal(_instances, format);
		}

		public void SetInstances(Span<uint8> instances, VertexFormat format)
		{
			Debug.Assert(format != null, "Instance format cannot be null");
			Debug.Assert(instances.Length % format.Stride == 0, "Incomplete instance data");

			InstanceFormat = format;
			InstanceCount = (.)instances.Length / format.Stride;

			SetInstancesInternal(instances, format);
		}

		/// Allocate empty instances to be set with SetInstancesPartial()
		public void SetInstancesEmpty(uint count, VertexFormat format)
		{
			Debug.Assert(format != null, "Instance format cannot be null");

			InstanceFormat = format;
			InstanceCount = count;

			SetInstancesEmptyInternal(count * format.Stride, format);
		}

		public void SetInstancesPartial<T>(uint offset, Span<T> instances) where T : struct
		{
			Debug.Assert(InstanceCount > 0, "Call SetInstances or SetInstancesEmpty first to establish a buffer to fill");
			Debug.Assert(offset + (.)instances.Length < InstanceCount);

			let _vertices = instances.ToRawData();
			SetInstancesPartialInternal(offset, _vertices);
		}

		public void SetInstancesPartial(uint offset, Span<uint8> vertices)
		{
			Debug.Assert(InstanceCount > 0, "Call SetInstances or SetInstancesEmpty first to establish a buffer to fill");
			Debug.Assert(vertices.Length % InstanceFormat.Stride == 0, "Incomplete instance data");
			Debug.Assert(offset + ((.)vertices.Length / InstanceFormat.Stride) < InstanceCount, "Partial range must be within buffer bounds");

			SetInstancesPartialInternal(offset, vertices);
		}

		public void SetIndices<T>(Span<T> indices) where T : IInteger, IUnsigned, struct
		{
			// Determine index type
			switch (sizeof(T))
			{
			case sizeof(uint8): IndexType = .UnsignedByte;
			case sizeof(uint16): IndexType = .UnsignedShort;
			case sizeof(uint32): IndexType = .UnsignedInt;
			default:
				Runtime.FatalError("Unexpected index type. Expected uint8, uint16 or uint32");
			}

			IndexCount = (uint)indices.Length;

			var _indices = indices.ToRawData();
			SetIndicesInternal(_indices, IndexType);
		}

		public void SetIndices(Span<uint8> indices, IndexType indexType)
		{
			Debug.Assert(indices.Length % (.)indexType.GetSize() == 0, "Incomplete index data");

			IndexType = indexType;
			IndexCount = (uint)indices.Length / indexType.GetSize();

			SetIndicesInternal(indices, IndexType);
		}

		public void SetIndicesEmpty<T>(uint count) where T : IInteger, IUnsigned, struct
		{
			// Determine index type
			switch (sizeof(T))
			{
			case sizeof(uint8): IndexType = .UnsignedByte;
			case sizeof(uint16): IndexType = .UnsignedShort;
			case sizeof(uint32): IndexType = .UnsignedInt;
			default:
				Runtime.FatalError("Unexpected index type. Expected uint8, uint16 or uint32");
			}

			IndexCount = count;

			SetIndicesEmptyInternal(count * IndexType.GetSize(), IndexType);
		}

		public void SetIndicesEmpty(uint count, IndexType indexType)
		{
			IndexType = indexType;
			IndexCount = count;

			SetIndicesEmptyInternal(count * indexType.GetSize(), IndexType);
		}

		public void SetIndicesPartial<T>(uint offset, Span<T> indices) where T : IInteger, IUnsigned, struct
		{
			Debug.Assert(IndexCount > 0, "Call SetIndices or SetIndicesEmpty first to establish a buffer to fill");
			Debug.Assert(offset + (.)indices.Length < IndexCount);

			// Determine index type
			switch (sizeof(T))
			{
			case sizeof(uint8): IndexType = .UnsignedByte;
			case sizeof(uint16): IndexType = .UnsignedShort;
			case sizeof(uint32): IndexType = .UnsignedInt;
			default:
				Runtime.FatalError("Unexpected index type. Expected uint8, uint16 or uint32");
			}

			IndexCount = (uint)indices.Length;

			var _indices = indices.ToRawData();
			SetIndicesPartialInternal(offset, _indices);
		}

		public void SetIndicesPartial(uint offset, Span<uint8> indices, IndexType indexType)
		{
			Debug.Assert(IndexCount > 0, "Call SetIndices or SetIndicesEmpty first to establish a buffer to fill");
			Debug.Assert(indices.Length % (.)indexType.GetSize() == 0, "Incomplete index data");
			Debug.Assert(offset + ((.)indices.Length / indexType.GetSize()) < IndexCount, "Partial range must be within buffer bounds");

			IndexType = indexType;
			IndexCount = (uint)indices.Length / indexType.GetSize();

			SetIndicesPartialInternal(offset, indices);
		}

		protected extern void Initialize();

		protected extern void SetVerticesInternal(Span<uint8> rawVertexData, VertexFormat format);
		protected extern void SetVerticesEmptyInternal(uint count, VertexFormat format);
		protected extern void SetVerticesPartialInternal(uint offset, Span<uint8> rawVertexData);

		protected extern void SetInstancesInternal(Span<uint8> rawInstanceData, VertexFormat format);
		protected extern void SetInstancesEmptyInternal(uint count, VertexFormat format);
		protected extern void SetInstancesPartialInternal(uint offset, Span<uint8> rawInstanceData);

		protected extern void SetIndicesInternal(Span<uint8> rawIndexData, IndexType type);
		protected extern void SetIndicesEmptyInternal(uint count, IndexType type);
		protected extern void SetIndicesPartialInternal(uint offset, Span<uint8> rawIndexData);
	}
}
