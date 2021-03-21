using System;

using internal Pile;

namespace Pile
{
	extension MasterBus
	{
		[SkipCall]
		protected override void Initialize() {}

		[SkipCall]
		protected override void SetVolume(float volume) {}

		[SkipCall]
		protected internal override void AddBus(MixingBus bus) {}

		[SkipCall]
		protected internal override void RemoveBus(MixingBus bus) {}

		[SkipCall]
		protected internal override void AddSource(AudioSource source) {}

		[SkipCall]
		protected internal override void RemoveSource(AudioSource source) {}
	}
}
