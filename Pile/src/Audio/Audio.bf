using System;

using internal Pile;

namespace Pile
{
	public abstract class Audio
	{
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
		public abstract String ApiName { get; }
		public abstract String Info { get; }

		public abstract MixingBus MasterBus { get; }

		public abstract uint SoundCount { get; }
		public abstract uint AudibleSoundCount { get; }

		internal ~this() {}

		internal abstract Result<void> Initialize();

		internal abstract AudioSource.Platform CreateAudioSource();
		internal abstract AudioClip.Platform CreateAudioClip();
		internal abstract MixingBus.Platform CreateMixingBus();
	}
}
