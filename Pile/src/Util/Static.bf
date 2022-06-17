using System;
using System.Text;
using System.Threading;

using internal Pile;

namespace Pile
{
	static
	{
		// Core is initialized first in this lib
		internal const int PILE_SINIT_ENTRY = 50;
		// Implementations (such as Graphics, ...) are initialized after, but before Core
		// Even in static init and destruction Core can rely on the implementation modules
		internal const int PILE_SINIT_IMPL = 40;

		// TODO: restore this, when beef issue #1027 is resolved. Doesn't work currently
		/*[AttributeUsage(.Method)]
		struct DebugCallAttribute : Attribute {} // Useless, basically

#if DEBUG || TEST
		typealias DebugOnlyAttribute = DebugCallAttribute;
#else
		typealias DebugOnlyAttribute = SkipCallAttribute;
#endif*/

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
				if (typeof(decltype(err)) == typeof(void))
					Log.Error($"{errMsg}");
				else Log.Error($"{errMsg} ({err})");
				return .Err((.)err);
			}	

			result.Get()
		}

		public static mixin DeleteNotNull(var instance)
		{
			if (instance != null) delete instance;
		}
	}
}
