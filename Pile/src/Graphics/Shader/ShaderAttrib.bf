using System;

namespace Pile
{
	class ShaderAttrib
	{
		readonly String name = new String() ~ delete _;
		public StringView Name => name;
		public readonly uint32 Location;

		internal this(StringView name, uint32 location)
		{
			this.name.Set(name);
			Location = location;
		}
	}
}
