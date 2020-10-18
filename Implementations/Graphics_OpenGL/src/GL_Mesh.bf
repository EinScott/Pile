using System;
using OpenGL43;

using internal Pile;

namespace Pile.Implementations
{
	public class GL_Mesh : Mesh.Platform
	{
		// TODO: does not currently support instanced rendering/instance buffers

		uint32 vertexArrayID;

		uint32 indexBufferID;
		uint32 vertexBufferID;

		uint64 indexBufferSize;
		uint64 vertexBufferSize;

		VertexFormat vertexFormat;

		Material lastMaterial;
		Shader lastShader;
		bool bound;

		readonly GL_Graphics graphics;

		internal this(GL_Graphics graphics)
		{
			this.graphics = graphics;
		}

		public ~this()
		{
			Delete();
		}

		void Delete()
		{
			if (vertexArrayID > 0) graphics.vertexArraysToDelete.Add(vertexArrayID);

			if (vertexBufferID > 0) graphics.buffersToDelete.Add(vertexBufferID);
			if (indexBufferID > 0) graphics.buffersToDelete.Add(indexBufferID);

			vertexArrayID = 0;

			vertexBufferID = 0;
			indexBufferID = 0;
			bound = false;
		}

		internal override void Setup(Span<uint8> vertices, Span<uint8> indices, VertexFormat format)
		{
			if (vertexFormat != format)
			{
				bound = false;
				vertexFormat = format;
			}

			SetBuffer(ref vertexBufferID, GL.GL_ARRAY_BUFFER, vertices.Ptr, vertices.Length);
			SetBuffer(ref indexBufferID, GL.GL_ELEMENT_ARRAY_BUFFER, indices.Ptr, indices.Length);

			void SetBuffer(ref uint32 bufferID, uint glBufferType, void* data, int length)
			{
				if (bufferID == 0) GL.glGenBuffers(1, &bufferID);

				GL.glBindBuffer(glBufferType, bufferID);
				GL.glBufferData(glBufferType, length, data, GL.GL_DYNAMIC_DRAW); // TODO: This could probably be better

				GL.glBindBuffer(glBufferType, 0);
			}
		}

		public void Bind(Material material)
		{
			if (vertexArrayID == 0) GL.glGenVertexArrays(1, &vertexArrayID);

			GL.glBindVertexArray(vertexArrayID);

			if (lastMaterial != null && lastShader != material.Shader) bound = false;

			if (!bound)
			{
				bound = true;


				// Bind vertex buffer
				GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vertexBufferID);

				// Determine active attributes
				if (vertexFormat != null)
					for (let attribute in material.Shader.Attributes)
					{
						if (!SetupAttributePointer(attribute, vertexFormat))
							GL.glDisableVertexAttribArray(attribute.Location);
					}

				// Bind index buffer
				GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
			}

			bool SetupAttributePointer(ShaderAttribute attribute, VertexFormat format)
			{
				if (format.TryGetAttribute(attribute.Name, let vertexAttr, var offset))
				{
					// this is kind of messy because some attributes can take up multiple slots
					// ex. a marix4x4 actually takes up 4 (size 16)
					for (int i = 0, uint64 loc = 0; i < (int)vertexAttr.Components; i += 4, loc++)
					{
						let componentsInLoc = Math.Min((int)vertexAttr.Components - i, 4);
						let location = (uint)(attribute.Location + loc);

						GL.glVertexAttribPointer(location, componentsInLoc, ToVertexType(vertexAttr.Type), vertexAttr.Normalized, format.Stride, (void*)offset);
						GL.glEnableVertexAttribArray(location);

						offset += componentsInLoc * vertexAttr.ComponentSize;
					}

					return true;
				}

				return false;
			}
		}

		static uint ToVertexType(VertexType type)
		{
			switch (type)
			{
			case .Byte: return GL.GL_UNSIGNED_BYTE;
			case .Short: return GL.GL_SHORT;
			case .Int: return GL.GL_INT;
			case .Float: return GL.GL_FLOAT;
			}
		}
	}
}
