using System;

using internal Pile;

namespace Pile
{
	extension MixingBus
	{
		[SkipCall]
		protected internal override void Initialize() {}

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
