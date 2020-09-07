using System;

namespace Pile
{
	public struct VertexAttribute : IDisposable
	{
		readonly String name = new String();
		public StringView Name => name;

		public readonly VertexAttrib Attribute;
		public readonly VertexType Type;
		public readonly VertexComponents Components;

		public readonly int32 ComponentSize;
		public readonly int32 AttributeSize;

		public readonly bool Normalized;

		public this(StringView name, VertexAttrib attribute, VertexType type, VertexComponents components, bool normalized = false)
		{
			this.name.Set(name);

			Attribute = attribute;
			Type = type;
			Components = components;
			Normalized = normalized;

			ComponentSize = type.GetSize();
			AttributeSize = (int32)components * ComponentSize;
		}

		public void Dispose()
		{
			delete name;
		}
	}
}
