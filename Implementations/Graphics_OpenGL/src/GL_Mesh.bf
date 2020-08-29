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

		private this(GL_Graphics graphics)
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
			

			// this binds the vertex array object and binds the vertex and index buffer to it
			// if the materials shader changed, or the vertex format was changed when setupping, redo attrib pointers to the shader attributes
			// here, we look through each attribute of the shader and find if the format has something to pass in
			// if it does, we setup the pointer at the location to the attribute (look into glsl for this, how many components each needs etc)
			// else that attribute is disabled? i dunno

			// Anyways, when shader is used with material and mesh is bound with material (which is actually just used as a container for the shader here and could just take shader)
			// we are ready and can draw elements!!
		}
	}
}
