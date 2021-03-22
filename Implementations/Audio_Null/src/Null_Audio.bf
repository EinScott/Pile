using System;

using internal Pile;

namespace Pile
{
	extension Audio
	{
		public static override String ApiName => "Null Audio";

		public static override String Info => String.Empty;

		static MasterBus masterBus;
		public static override MasterBus MasterBus => masterBus;

		public static override uint SoundCount => 0;

		public static override uint AudibleSoundCount => 0;

		public static override Vector3 SpacialListenerUp { get; set; }
		public static override Vector3 SpacialListenerPosition { get; set; }
		public static override Vector3 SpacialListenerFacing { get; set; }
		public static override Vector3 SpacialListenerVelocity { get; set; }
		public static override float SpacialSoundSpeed { get; set; }
		public static override bool SimulateSpacialDelay { get; set; }

		static this()
		{
			MajorVersion = 1;
			MinorVersion = 0;
		}

		protected internal static override void Initialize()
		{
			masterBus = new MasterBus();
		}

		protected internal override static void Destroy()
		{
			delete masterBus;
		}

		protected internal static override void AfterUpdate() {}
	}
}
