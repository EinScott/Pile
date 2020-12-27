using System;

using internal Pile;

namespace Pile
{
	public class Audio
	{
		public extern uint32 MajorVersion { get; }
		public extern uint32 MinorVersion { get; }
		public extern String ApiName { get; }
		public extern String Info { get; }

		// These apply only to spacial (3D) sound
		/// What is "up", (0, 1, 0) by default
		public extern Vector3 SpacialListenerUp { get; set; }

		/// Where is the space the listener is
		public extern Vector3 SpacialListenerPosition { get; set; }

		/// Which direction the listener is facing
		public extern Vector3 SpacialListenerFacing { get; set; }

		/// How fast the listener currently is. Used to calculate Doppler effect. Leave at 0 for none
		public extern Vector3 SpacialListenerVelocity { get; set; }

		/// The current speed of sound.
		public extern float SpacialSoundSpeed { get; set; }

		/// Whether or not to delay played sounds by the time the sound would need to travel to the listener position
		public extern bool SimulateSpacialDelay { get; set; }
		// ---

		public extern MasterBus MasterBus { get; }

		public extern uint SoundCount { get; }
		public extern uint AudibleSoundCount { get; }

		internal this() {}
		internal ~this() {}

		protected internal extern void Initialize();
		protected internal extern void AfterUpdate();
	}
}
