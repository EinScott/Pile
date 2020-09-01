using System;

namespace Pile
{
	public class ShaderUniform
	{
		readonly String name = new String() ~ CondDelete!(_);
		public StringView Name => name;
		public readonly int Location;
		public readonly int Length;
		public readonly UniformType Type;

		public this(StringView name, int location, int length, UniformType type)
		{
			this.name.Set(name);
			Location = location;
			Length = length;
			Type = type;
		}
	}
}
