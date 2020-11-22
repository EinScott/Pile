using System;

using internal Pile;

namespace Pile.Implementations
{
	class Null_Audio : Audio
	{
		public override uint32 MajorVersion => 1;
		public override uint32 MinorVersion => 0;

		public override String ApiName => "Null Audio";

		public override String Info => String.Empty;

		MixingBus masterBus ~ delete _;
		public override MixingBus MasterBus => masterBus;

		public override uint SoundCount => 0;

		public override uint AudibleSoundCount => 0;

		internal override Result<void> Initialize()
		{
			masterBus = new MixingBus();
			(masterBus.platform as Null_MixingBus).masterBus = true;

			return .Ok;
		}

		internal override AudioSource.Platform CreateAudioSource() => new Null_AudioSource();

		internal override AudioClip.Platform CreateAudioClip() => new Null_AudioClip();

		internal override MixingBus.Platform CreateMixingBus() => new Null_MixingBus();
	}
}
