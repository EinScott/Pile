using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class GlobalSource : AudioSource
	{
		public extern float Pan { get; set; }

		public this(MixingBus output = null, bool prioritized = false, bool stopOnDelete = true, bool stopInaudible = false)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");

			Prioritized = prioritized;
			StopOnDelete = stopOnDelete;
			StopInaudible = stopInaudible;

			Initialize();
			SetupOutput(output);
		}
	}
}
