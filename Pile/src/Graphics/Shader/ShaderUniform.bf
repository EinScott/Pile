using System;

namespace Pile
{
	class ShaderUniform
	{
		readonly String nameStr = new String() ~ delete _;
		public readonly StringView Name;
		public readonly int Location;
		public readonly int Length;
		public readonly UniformType Type;

		internal this(StringView name, int location, int length, UniformType type)
		{
			nameStr.Set(name);
			Name = StringView(nameStr);
			
			Location = location;
			Length = length;
			Type = type;
		}
	}
}
