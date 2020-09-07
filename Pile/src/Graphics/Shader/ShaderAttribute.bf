using System;

namespace Pile
{
	public class ShaderAttribute
	{
		readonly String name = new String() ~ delete _;
		public StringView Name => name;
		public readonly uint Location;

		this(StringView name, uint location)
		{
			this.name.Set(name);
			Location = location;
		}
	}
}
