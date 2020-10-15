using System;

using internal Pile;

namespace Pile
{
	public class  Mesh
	{
		internal abstract class Platform
		{
			internal abstract void Setup(Span<uint8> vertices, Span<uint32> indices, VertexFormat format);
		}

		internal readonly Platform platform ~ delete _;

		public uint32 VertexCount { get; private set; }
		public uint32 IndexCount { get; private set; } 
		public VertexFormat VertexFormat { get; private set; }

		public this()
		{
			platform = Core.Graphics.CreateMesh();
		}

		public void Setup<T>(Span<T> vertices, Span<uint32> indices, VertexFormat format)
		{
			VertexFormat = format;
			VertexCount = (uint32)vertices.Length;
			IndexCount = (uint32)indices.Length;

			var _vertices = vertices.ToRawData();
			platform.Setup(_vertices, indices, format);
		}
	}
}
