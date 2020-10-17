using System;

namespace Pile
{
	static
	{
		public static mixin LogErrorReturn(String err)
		{
			Log.Error(err);
			
			return .Err(default);
		}

		public static mixin DeleteNotNull(var instance)
		{
			if (instance != null) delete instance;
		}

		public static mixin DeleteDictionaryAndItems(var container)
		{
			if (container != null)
			{
				for (var value in container)
					delete value.value;
				delete container;
			}
		}
	}
}
