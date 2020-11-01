using System;

using internal Pile;

namespace Pile
{
	static
	{
#if !DEBUG
		[SkipCall]
#endif
		internal static void AssertInit() // Mostly copy-pasta from Debug.Assert
		{
			if (!Core.initialized)
			{
				String failStr = scope .()..AppendF("Pile Assert failed: Core needs to be initialized before creating platform dependant objects, {} at line {} in {}", Compiler.CallerExpression[0], Compiler.CallerFilePath, Compiler.CallerLineNum);
				Internal.FatalError(failStr, 1);
			}
		}

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
