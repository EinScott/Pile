using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class Mesh
	{
		public uint VertexCount { get; private set; }
		public uint InstanceCount { get; private set; }
		public uint IndexCount { get; private set; }

		[Inline]
		public uint TriangleCount => IndexCount / 3;

		public VertexFormat VertexFormat { get; private set; }
		public VertexFormat InstanceFormat { get; private set; }
		public IndexType IndexType { get; private set; }

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

			var _vertices = vertices.ToRawData();
			SetVertices(_vertices, format);
		}

		public void SetInstances<T>(Span<T> vertices, VertexFormat format) where T : struct
		{
			Debug.Assert(format != null, "Vertex format cannot be null");

			VertexFormat = format;
			VertexCount = (.)vertices.Length;

			var _vertices = vertices.ToRawData();
			SetInstances(_vertices, format);
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
			SetIndices(_indices);
		}

		protected extern void Initialize();
		protected extern void SetVertices(Span<uint8> rawVertexData, VertexFormat format);
		protected extern void SetInstances(Span<uint8> rawVertexData, VertexFormat format);
		protected extern void SetIndices(Span<uint8> rawIndexData);
	}
}
