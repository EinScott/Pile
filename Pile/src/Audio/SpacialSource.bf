using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class SpacialSource : AudioSource
	{
		public extern Vector3 Position { get; set; }
		public extern Vector3 Velocity { get; set; }
		public extern float MinDistance { get; set; }
		public extern float MaxDistance { get; set; }
		public extern Attenuation Attenuation { get; set; }
		public extern float AttenuationRolloffFactor { get; set; }

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
