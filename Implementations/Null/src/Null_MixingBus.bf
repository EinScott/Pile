using System;

using internal Pile;

namespace Pile.Implementations
{
	class Null_MixingBus : MixingBus.Platform
	{
		bool masterBus;
		protected internal override bool IsMasterBus => masterBus;

		internal this(bool isMasterBus)
		{
			masterBus = isMasterBus;
		}

		[SkipCall]
		protected internal override void Initialize(MixingBus bus) {}

		[SkipCall]
		protected internal override void SetVolume(float volume) {}

		[SkipCall]
		protected internal override void AddBus(MixingBus bus) {}

		[SkipCall]
		protected internal override void RemoveBus(MixingBus bus) {}

		[SkipCall]
		protected internal override void AddSource(AudioSource source) {}

		[SkipCall]
		protected internal override void RemoveSource(AudioSource source) {}

		[SkipCall]
		protected internal override void RedirectInputsToMaster() {}
	}
}
