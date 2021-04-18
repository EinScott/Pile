using System;

namespace Pile
{
	class ShaderUniform
	{
		readonly String nameStr = new String() ~ delete _;
		public readonly StringView Name;
		public readonly uint32 Location;
		public readonly uint32 Length;
		public readonly UniformType Type;

		internal this(StringView name, uint32 location, uint32 length, UniformType type)
		{
			nameStr.Set(name);
			Name = StringView(nameStr);
			
			Location = location;
			Length = length;
			Type = type;
		}
	}
}
