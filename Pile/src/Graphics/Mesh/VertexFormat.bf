using System;

namespace Pile
{
	public class VertexFormat
	{
		public readonly VertexAttribute[] Attributes;
		public readonly int32 Stride;

		public this(params VertexAttribute[] attributes)
		{
			Attributes = new VertexAttribute[attributes.Count];
			attributes.CopyTo(Attributes);

			Stride = 0;
			for (int i = 0; i < Attributes.Count; i++)
				Stride += Attributes[i].AttributeSize;
		}

		public ~this()
		{
			// VertexAttribute needs to be disposed (manage string)
			for (let a in Attributes)
				a.Dispose();

			delete Attributes;
		}

		public bool TryGetAttribute(StringView name, out VertexAttribute attribute, out int offset)
		{
			// Get a specific attribute of this format, return it and the offset of it
			offset = 0;
			for (int i = 0; i < Attributes.Count; i++)
			{
				if (Attributes[i].Name == name)
				{
					attribute = Attributes[i];
					return true;
				}
				offset += Attributes[i].AttributeSize;
			}

			attribute = default;
			return false;
		}
	}
}
