using System;

namespace Pile
{
	class ShaderAttribute
	{
		readonly String name = new String() ~ delete _;
		public StringView Name => name;
		public readonly uint Location;

		internal this(StringView name, uint location)
		{
			this.name.Set(name);
			Location = location;
		}
	}
}
