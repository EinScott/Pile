using System;
using OpenGL43;

namespace Pile.Implementations
{
	public class GL_Mesh : Mesh.Platform
	{
		// does not currently support instanced rendering/instance buffers
		// this is 2D lightweight and we're probably batching anyways

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
			if (vertexArrayID > 0) graphics.[Friend]vertexArraysToDelete.Add(vertexArrayID);

			if (vertexBufferID > 0) graphics.[Friend]buffersToDelete.Add(vertexBufferID);
			if (indexBufferID > 0) graphics.[Friend]buffersToDelete.Add(indexBufferID);

			vertexArrayID = 0;

			vertexBufferID = 0;
			indexBufferID = 0;
			bound = false;
		}

		public override void Setup(ref Span<uint8> vertices, uint32 vertexSize, ref Span<uint32> indices, VertexFormat format)
		{
			if (vertexFormat != format)
			{
				bound = false;
				vertexFormat = format;
			}

			Delete();
			SetBuffer(ref vertexBufferID, GL.GL_ELEMENT_ARRAY_BUFFER, &vertices, vertexSize);
			SetBuffer(ref indexBufferID, GL.GL_ARRAY_BUFFER, &indices, sizeof(uint32));

			void SetBuffer(ref uint32 bufferID, uint glBufferType, void* data, int length)
			{
				GL.glGenBuffers(1, &bufferID);

				GL.glBindBuffer(glBufferType, bufferID);
				GL.glBufferData(glBufferType, length, data, GL.GL_STATIC_DRAW);
			}
		}

		public void Bind(Material material)
		{
			// this binds the vertex array object and binds the vertex and index buffer to it
			// if the materials shader changed, or the vertex format was changed when setupping, redo attrib pointers to the shader attributes
			// here, we look through each attribute of the shader and find if the format has something to pass in
			// if it does, we setup the pointer at the location to the attribute (look into glsl for this, how many components each needs etc)
			// else that attribute is disabled? i dunno

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
					for (let attribute in material.Shader.[Friend]Attributes)
						if (!SetupAttributePointer(attribute, vertexFormat))
							GL.glDisableVertexAttribArray(attribute.Location);

				// Bind index buffer
				GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
			}

			bool SetupAttributePointer(ShaderAttribute attribute, VertexFormat format)
			{
				if (format.TryGetAttribute(attribute.Name, let vertexAttr, var offset))
				{
					// this is kind of messy because some attributes can take up multiple slots
					// ex. a marix4x4 actually takes up 4 (size 16)
					for (int i = 0, uint loc = 0; i < (int)vertexAttr.Components; i += 4, loc++)
					{
						let componentsInLoc = Math.Min((int)vertexAttr.Components - i, 4);
						let location = (uint)(attribute.Location + loc);

						GL.glEnableVertexAttribArray(location);
						GL.glVertexAttribPointer(location, componentsInLoc, ToVertexType(vertexAttr.Type), vertexAttr.Normalized, format.Stride, (void*)offset);

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
