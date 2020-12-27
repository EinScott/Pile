using System;

using internal Pile;

namespace Pile
{
	extension GlobalSource
	{
		public override bool Playing => false;

		[SkipCall]
		protected internal override void Initialize() {}

		public override float Volume { get; set; }
		public override float Pan { get; set; }
		public override float Speed { get; set; }
		public override bool Looping { get; set; }
		public override bool Paused { get; set; }

		[SkipCall]
		protected internal override void PlayInternal(AudioClip clip, float delay) {}

		[SkipCall]
		public override void Stop() {}
	}
}
