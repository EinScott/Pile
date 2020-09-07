using System;

namespace Pile
{
	public class ShaderUniform
	{
		readonly String name = new String() ~ delete _;
		public StringView Name => name;
		public readonly int Location;
		public readonly int Length;
		public readonly UniformType Type;

		this(StringView name, int location, int size, UniformType type)
		{
			this.name.Set(name);
			Location = location;
			Length = size;
			Type = type;
		}
	}
}
