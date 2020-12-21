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

		public extern MasterBus MasterBus { get; }

		public extern uint SoundCount { get; }
		public extern uint AudibleSoundCount { get; }

		internal this() {}
		internal ~this() {}

		protected internal extern void Initialize();
	}
}
