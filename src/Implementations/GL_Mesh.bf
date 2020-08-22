using System;
using OpenGL43;

namespace Pile.Implementations
{
	public class GL_Mesh : Mesh.Platform
	{
		uint32 indexBufferID;
		uint32 vertexBufferID;

		uint64 indexBufferSize;
		uint64 vertexBufferSize;

		VertexFormat vertexFormat;

		readonly GL_Graphics graphics;

		protected this(GL_Graphics graphics)
		{
			this.graphics = graphics;
		}

		public ~this()
		{
			Delete();
		}

		void Delete()
		{
			if (vertexBufferID > 0) graphics.[Friend]buffersToDelete.Add(vertexBufferID);
			if (indexBufferID > 0) graphics.[Friend]buffersToDelete.Add(indexBufferID);

			vertexBufferID = 0;
			indexBufferID = 0;
		}

		public override void Setup(ref Span<uint8> vertices, uint32 vertexSize, ref Span<uint32> indices, VertexFormat format)
		{
			vertexFormat = format;

			Delete();
			SetBuffer(ref vertexBufferID, GL.GL_ELEMENT_ARRAY_BUFFER, &vertices, vertexSize);
			SetBuffer(ref indexBufferID, GL.GL_ARRAY_BUFFER, &indices, sizeof(uint32));

			void SetBuffer(ref uint32 bufferID, uint glBufferType, void* data, int length)
			{
				/*if (bufferID == 0) */
				GL.glGenBuffers(1, &bufferID);

				GL.glBindBuffer(glBufferType, bufferID);

				// i dont understand why, so just do it the simple way first (delete, recreate, set)
				/*uint64 neededBufferSize = (uint64)data.Length * dataStructSize;
				if (currentBufferSize < neededBufferSize)
				{
				    currentBufferSize = neededBufferSize;
					GL.glBufferData(glBufferType, (int)((uint64)dataStructSize * currentBufferSize), null, GL.GL_STATIC_DRAW);
				}

				// upload the data
				var offset = 0;
				for (let memory in data)
				{
				    GL.glBufferSubData(glBufferType, 0, dataStructSize, new IntPtr(pinned.Pointer));
				    offset += memory.Length;
				}*/
				GL.glBufferData(glBufferType, length, data, GL.GL_STATIC_DRAW);

				// GL.glBindBuffer(glBufferType, 0); // lets assume we bind first everywhere and dont have to clean up
			}
		}

		private void Bind()
		{
			// do shader/(material) first
		}
	}
}
