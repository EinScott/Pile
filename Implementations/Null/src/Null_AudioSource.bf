using System;

using internal Pile;

namespace Pile
{
	extension AudioSource
	{
		public override bool Playing => false;

		[SkipCall]
		protected internal override void Initialize() {}

		[SkipCall]
		protected internal override void SetVolume(float volume) {}

		[SkipCall]
		protected internal override void SetPan(float pan) {}

		[SkipCall]
		protected internal override void SetSpeed(float speed) {}

		[SkipCall]
		protected internal override void SetLooping(bool looping) {}

		[SkipCall]
		protected internal override void SetPaused(bool paused) {}

		[SkipCall]
		protected internal override void PlayInternal(AudioClip clip) {}

		[SkipCall]
		public override void Stop() {}
	}
}
