using System;
using System.Diagnostics;

namespace Pile
{
	class MasterBus : AudioBus
	{
		float volume = 1;

		public override float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				SetVolume(Math.Max(0, value));
				volume = value;
			}
		}

		internal this()
		{
			Debug.Assert(Core.Audio != null, "Core needs to be initialized before creating platform dependent objects");

			Initialize();
		}

		internal ~this() {}
	}
}
