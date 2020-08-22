namespace Pile
{
	public class Shader
	{
		public class Platform
		{

		}

		readonly Platform platform;

		public this()
		{

		}

		public ~this()
		{
			delete platform;
		}
	}
}
