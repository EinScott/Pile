using System;
using OpenGL43;

using internal Pile;

namespace Pile
{
	extension Mesh
	{
		uint32 vertexArrayID;

		uint32 indexBufferID;
		uint32 vertexBufferID;
		uint32 instanceBufferID;

		int indexBufferSize;
		int vertexBufferSize;
		int instanceBufferSize;

		VertexFormat lastVertexFormat;
		VertexFormat lastInstanceFormat;

		Material lastMaterial;
		Shader lastShader;
		bool bound;

		protected override void Initialize()
		{

		}

		public ~this()
		{
			if (vertexArrayID > 0) Graphics.vertexArraysToDelete.Add(vertexArrayID);

			if (vertexBufferID > 0) Graphics.buffersToDelete.Add(vertexBufferID);
			if (instanceBufferID > 0) Graphics.buffersToDelete.Add(instanceBufferID);
			if (indexBufferID > 0) Graphics.buffersToDelete.Add(indexBufferID);

			vertexArrayID = 0;

			vertexBufferID = 0;
			instanceBufferID = 0;
			indexBufferID = 0;
			bound = false;
		}

		protected override void SetVertices(Span<uint8> rawVertexData, VertexFormat format)
		{
			if (lastVertexFormat != format)
			{
				bound = false;
				lastVertexFormat = format;
			}

			SetBuffer(ref vertexBufferID, .GL_ARRAY_BUFFER, rawVertexData.Ptr, (.)rawVertexData.Length, ref vertexBufferSize);
		}

		protected override void SetInstances(Span<uint8> rawVertexData, VertexFormat format)
		{
			if (lastInstanceFormat != format)
			{
				bound = false;
				lastInstanceFormat = format;
			}

			SetBuffer(ref vertexBufferID, .GL_ARRAY_BUFFER, rawVertexData.Ptr, (.)rawVertexData.Length, ref instanceBufferSize);
		}

		protected override void SetIndices(Span<uint8> rawIndexData)
		{
			SetBuffer(ref indexBufferID, .GL_ELEMENT_ARRAY_BUFFER, rawIndexData.Ptr, (.)rawIndexData.Length, ref indexBufferSize);
		}

		void SetBuffer(ref uint32 bufferID, GL.BufferTargetARB glBufferType, void* data, int32 size, ref int currentSize)
		{
			if (bufferID == 0) GL.glGenBuffers(1, &bufferID);

			GL.glBindBuffer(glBufferType, bufferID);

			if (size > currentSize)
			{
				GL.glBufferData(glBufferType, size, data, .GL_DYNAMIC_DRAW);
				currentSize = size;
			}
			else GL.glBufferSubData(glBufferType, 0, size, data);

			GL.glBindBuffer(glBufferType, 0);
		}

		internal void Bind(Material material)
		{
			if (vertexArrayID == 0) GL.glGenVertexArrays(1, &vertexArrayID);

			GL.glBindVertexArray(vertexArrayID);

			if (lastMaterial != null && lastShader != material.Shader) bound = false;

			if (!bound)
			{
				bound = true;

				for (let attribute in material.Shader.Attributes)
				{
					if (lastVertexFormat != null)
					{
						// Bind vertex buffer
						GL.glBindBuffer(.GL_ARRAY_BUFFER, vertexBufferID);

						// Determine active attributes
						if (TrySetupAttributePointer(attribute, lastVertexFormat, 0))
							continue;
					}

					if (lastInstanceFormat != null)
					{
						// Bind vertex buffer
						GL.glBindBuffer(.GL_ARRAY_BUFFER, instanceBufferID);

						// Determine active attributes
						if (TrySetupAttributePointer(attribute, lastInstanceFormat, 1))
							continue;
					}

					// Disable unused attributes
					GL.glDisableVertexAttribArray(attribute.Location);
				}

				// Bind index buffer
				GL.glBindBuffer(.GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
			}

			bool TrySetupAttributePointer(ShaderAttrib attribute, VertexFormat format, uint32 divisor)
			{
				if (format.TryGetAttribute(attribute.Name, let vertexAttr, var offset))
				{
					// this is kind of messy because some attributes can take up multiple slots [FOSTERCOMMENT]
					// ex. a marix4x4 actually takes up 4 (size 16)
					for (int i = 0, uint32 loc = 0; i < (int32)vertexAttr.Components; i += 4, loc++)
					{
						let componentsInLoc = (int32)Math.Min((int)vertexAttr.Components - i, 4);
						let location = attribute.Location + loc;

						GL.glEnableVertexAttribArray(location);
						GL.glVertexAttribPointer(location, componentsInLoc, ToVertexType(vertexAttr.Type), vertexAttr.Normalized, format.Stride, (void*)offset);
						GL.glVertexAttribDivisor(location, divisor);

						offset += componentsInLoc * vertexAttr.ComponentSize;
					}

					return true;
				}

				return false;
			}
		}

		static GL.VertexAttribPointerType ToVertexType(VertexType type)
		{
			switch (type)
			{
			case .Byte: return .GL_UNSIGNED_BYTE;
			case .Short: return .GL_SHORT;
			case .Int: return .GL_INT;
			case .Float: return .GL_FLOAT;
			}
		}
	}
}
