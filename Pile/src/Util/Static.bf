namespace Pile
{
	static
	{
		public static mixin CondDelete(var instance)
		{
			if (instance != null) delete instance;
		}
	}
}
