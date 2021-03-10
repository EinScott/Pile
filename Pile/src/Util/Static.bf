using System;

using internal Pile;

namespace Pile
{
	static
	{
		[AttributeUsage(.Method)]
		struct DebugCallAttribute : Attribute // Useless, basically
		{

		}

		// This is somehow hacky and genius at the same time
#if DEBUG
		typealias DebugOnlyAttribute = DebugCallAttribute;
#else
		typealias DebugOnlyAttribute = SkipCallAttribute;
#endif

		public static mixin LogErrorReturn(String errMsg)
		{
			Log.Error(errMsg);
			return .Err(default);
		}

		/// errMsg should not be allocated for this call (since that would be done even if the try passes)
		internal static mixin LogErrorTry(var result, String errMsg)
		{
			if (result case .Err(var err))
			{
				Log.Error($"{errMsg} ({err})");
				return .Err((.)err);
			}	

			result.Get()
		}

		public static mixin DeleteNotNull(var instance)
		{
			if (instance != null) delete instance;
		}

		/// Useful for Dictionary<Type, TOther> and alike where the key is managed elsewhere
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
