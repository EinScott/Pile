using System;

namespace Pile
{
	extension SpacialSource
	{
		public override bool Playing => false;

		[SkipCall]
		protected override void Initialize() {}

		public override float Volume { get; set; }
		public override float Speed { get; set; }
		public override bool Looping { get; set; }
		public override bool Paused { get; set; }

		public override Vector3 Position { get; set; }
		public override Vector3 Velocity { get; set; }
		public override float MinDistance { get; set; }
		public override float MaxDistance { get; set; }
		public override Attenuation Attenuation { get; set; }
		public override float AttenuationRolloffFactor { get; set; }

		[SkipCall]
		protected override void PlayInternal(AudioClip clip, float delay) {}

		[SkipCall]
		public override void Stop() {}
	}
}
