using System;

using internal Pile;

namespace Pile
{
	static
	{
		public static mixin LogErrorReturn(String errMsg)
		{
			Log.Error(errMsg);
			return .Err(default);
		}

		public static mixin LogErrorTry(var result, String errMsg)
		{
			if (result case .Err(var err))
			{
				Log.Error(scope $"{errMsg} ({err})");
				return .Err((.)err);
			}	

			result.Get()
		}

		public static mixin DeleteNotNull(var instance)
		{
			if (instance != null) delete instance;
		}

		public static mixin DeleteDictionaryAndValues(var container)
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
