using System;

namespace Pile
{
	public class ShaderAttribute
	{
		readonly String name = new String() ~ CondDelete!(_);
		public StringView Name => name;
		public readonly uint Location;

		public this(StringView name, uint location)
		{
			this.name.Set(name);
			Location = location;
		}
	}
}
