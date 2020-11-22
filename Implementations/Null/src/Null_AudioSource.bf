using System;

using internal Pile;

namespace Pile.Implementations
{
	class Null_AudioSource : AudioSource.Platform
	{
		internal override bool Playing => false;

		[SkipCall]
		internal override void Initialize(AudioSource source) {}

		[SkipCall]
		internal override void SetVolume(float volume) {}

		[SkipCall]
		internal override void SetPan(float pan) {}

		[SkipCall]
		internal override void SetSpeed(float speed) {}

		[SkipCall]
		internal override void SetLooping(bool looping) {}

		[SkipCall]
		internal override void SetPaused(bool paused) {}

		[SkipCall]
		internal override void Play(AudioClip clip) {}

		[SkipCall]
		internal override void Stop() {}
	}
}
