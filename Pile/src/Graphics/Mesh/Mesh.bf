using System;

using internal Pile;

namespace Pile
{
	public class  Mesh
	{
		internal abstract class Platform
		{
			internal abstract void Setup(Span<uint8> vertices, Span<uint8> indices, VertexFormat format);
		}

		internal readonly Platform platform ~ delete _;

		public uint VertexCount { get; private set; }
		public uint IndexCount { get; private set; } 
		public VertexFormat VertexFormat { get; private set; }
		public IndexType IndexType { get; private set; }

		public this()
		{
			AssertInit();

			platform = Core.Graphics.CreateMesh();
		}

		public void Setup<TVertex, TIndex>(Span<TVertex> vertices, Span<TIndex> indices, VertexFormat format) where TIndex : IInteger, IUnsigned, struct
		{
			VertexFormat = format;

			// Determin index format
			switch (typeof(TIndex))
			{
			case typeof(uint16): IndexType = .UnsignedShort;
			case typeof(uint32): IndexType = .UnsignedInt;
			default:
				Log.Error("Unexpected index type. Expected uint16 or uint32. This might cause rendering problems");
				IndexType = .UnsignedInt;
			}

			VertexCount = (uint)vertices.Length;
			IndexCount = (uint)indices.Length;

			var _vertices = vertices.ToRawData();
			var _indices = indices.ToRawData();
			platform.Setup(_vertices, _indices, format);
		}
	}
}
