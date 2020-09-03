using System;

namespace Pile
{
	public class ShaderUniform
	{
		readonly String name = new String() ~ CondDelete!(_);
		public StringView Name => name;
		public readonly int Location;
		public readonly int Size;
		public readonly UniformType Type;

		public this(StringView name, int location, int size, UniformType type)
		{
			this.name.Set(name);
			Location = location;
			Size = size;
			Type = type;
		}
	}
}
