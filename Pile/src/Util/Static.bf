using System;
using System.Text;
using System.Threading;

using internal Pile;

namespace Pile
{
	static
	{
		// EntryPoint is initialized first in this lib
		internal const int PILE_SINIT_ENTRY = 50;
		// Implementations (such as Graphics, ...) are initialized after, but before Core
		// Even in static init and destruction Core can rely on the implementation modules
		internal const int PILE_SINIT_IMPL = 40;

		[AttributeUsage(.Method)]
		struct DebugCallAttribute : Attribute {} // Useless, basically

		// This is somehow hacky and genius at the same time
#if DEBUG
		typealias DebugOnlyAttribute = DebugCallAttribute;
#else
		typealias DebugOnlyAttribute = SkipCallAttribute;
#endif

		public static mixin LogErrorReturn(String errMsg)
		{
			Log.Error(errMsg);

			// Since this gets injected, we can't use internal
			// This will print to debug out on the main thread before we
			// potentially get frozen by the IDE/crash. Debug only call
			Log.[Friend]FlushDebugWrite();

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
	}
}
