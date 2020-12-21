using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class  Mesh
	{
		protected internal abstract class Platform
		{
			protected internal abstract void SetVertices(Span<uint8> rawVertexData, VertexFormat format);
			protected internal abstract void SetInstances(Span<uint8> rawVertexData, VertexFormat format);
			protected internal abstract void SetIndices(Span<uint8> rawIndexData);
		}

		internal readonly Platform platform ~ delete _;

		public uint VertexCount { get; private set; }
		public uint InstanceCount { get; private set; }
		public uint IndexCount { get; private set; }

		public VertexFormat VertexFormat { get; private set; }
		public VertexFormat InstanceFormat { get; private set; }
		public IndexType IndexType { get; private set; }

		public this()
		{
			Debug.Assert(Core.Graphics != null, "Core needs to be initialized before creating platform dependent objects");

			platform = Core.Graphics.CreateMesh();
		}

		public void SetVertices<T>(Span<T> vertices, VertexFormat format) where T : struct
		{
			Debug.Assert(format != null, "Vertex format cannot be null");

			VertexFormat = format;
			VertexCount = (.)vertices.Length;

			var _vertices = vertices.ToRawData();
			platform.SetVertices(_vertices, format);
		}

		public void SetInstances<T>(Span<T> vertices, VertexFormat format) where T : struct
		{
			Debug.Assert(format != null, "Vertex format cannot be null");

			VertexFormat = format;
			VertexCount = (.)vertices.Length;

			var _vertices = vertices.ToRawData();
			platform.SetInstances(_vertices, format);
		}

		public void SetIndices<T>(Span<T> indices) where T : IInteger, IUnsigned, struct
		{
			// Determine index type
			switch (typeof(T))
			{
			case typeof(uint16): IndexType = .UnsignedShort;
			case typeof(uint32): IndexType = .UnsignedInt;
			default:
				Log.Error("Unexpected index type. Expected uint16 or uint32. This might cause rendering problems");
				IndexType = .UnsignedInt;
			}

			IndexCount = (uint)indices.Length;

			var _indices = indices.ToRawData();
			platform.SetIndices(_indices);
		}
	}
}
