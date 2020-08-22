using System;

namespace Pile
{
	public class Mesh
	{
		public abstract class Platform
		{
			public abstract void Setup(ref Span<uint8> vertices, uint32 vertexSize, ref Span<uint32> indices, VertexFormat format);
		}

		Platform platform;

		public uint32 VertexCount { get; private set; }
		public uint32 IndexCount { get; private set; }
		public VertexFormat VertexFormat { get; private set; }

		public this()
		{
			platform = Core.Graphics.[Friend]CreateMesh();
		}

		public ~this()
		{
			delete platform;
		}

		public void Setup<T>(Span<T> vertices, Span<uint32> indices, VertexFormat format) where T : IVertex
		{
			VertexFormat = format;
			VertexCount = (uint32)vertices.Length;
			IndexCount = (uint32)indices.Length;

			var _vertices = vertices.ToRawData(); // i'm not sure i like this
			var _indices = indices;
			platform.Setup(ref _vertices, (uint32)sizeof(T), ref _indices, format);
		}
	}
}
