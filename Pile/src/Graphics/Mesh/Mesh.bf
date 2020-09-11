using System;

namespace Pile
{
	public class Mesh
	{
		public abstract class Platform
		{
			public abstract void Setup(ref Span<uint8> vertices, ref Span<uint32> indices, VertexFormat format);
		}

		readonly Platform platform ~ delete _;

		public uint32 VertexCount { get; private set; }
		public uint32 IndexCount { get; private set; }
		public VertexFormat VertexFormat { get; private set; }

		public this()
		{
			platform = Core.Graphics.[Friend]CreateMesh();
		}

		public void Setup<T>(Span<T> vertices, Span<uint32> indices, VertexFormat format)
		{
			VertexFormat = format;
			VertexCount = (uint32)vertices.Length;
			IndexCount = (uint32)indices.Length;

			let copyverts = scope T[vertices.Length]; // i'm not sure i like this
			vertices.CopyTo(Span<T>(copyverts));
			var _vertices = Span<T>(copyverts).ToRawData();

			var _indices = indices;
			platform.Setup(ref _vertices, ref _indices, format);
		}
	}
}
