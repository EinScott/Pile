using System;

using internal Pile;

namespace Pile
{
	[StaticInitPriority(PILE_SINIT_IMPL)]
	static class Audio
	{
		public static readonly uint32 MajorVersion;
		public static readonly uint32 MinorVersion;

		public static extern String ApiName { get; }
		public static extern String Info { get; }

		// These apply only to spacial (3D) sound
		/// What is "up", (0, 1, 0) by default
		public static extern Vector3 SpacialListenerUp { get; set; }

		/// Where is the space the listener is
		public static extern Vector3 SpacialListenerPosition { get; set; }

		/// Which direction the listener is facing
		public static extern Vector3 SpacialListenerFacing { get; set; }

		/// How fast the listener currently is. Used to calculate Doppler effect. Leave at 0 for none
		public static extern Vector3 SpacialListenerVelocity { get; set; }

		/// The current speed of sound.
		public static extern float SpacialSoundSpeed { get; set; }

		/// Whether or not to delay played sounds by the time the sound would need to travel to the listener position
		public static extern bool SimulateSpacialDelay { get; set; }


		public static extern MasterBus MasterBus { get; }

		public static extern uint SoundCount { get; }
		public static extern uint AudibleSoundCount { get; }

		protected internal static extern void Initialize();
		protected internal static extern void AfterUpdate();
	}
}
