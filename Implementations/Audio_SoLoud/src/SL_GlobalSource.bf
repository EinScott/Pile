using SoLoud;
using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	extension GlobalSource
	{
		uint32 group;

		public override bool Playing => !SL_Soloud.IsVoiceGroupEmpty(Core.Audio.slPtr, group) && !Paused;

		public ~this()
		{
			if (StopOnDelete || Paused)
				SL_Soloud.Stop(Core.Audio.slPtr, group);
			else Looping = false; // Since we are throwing our handles into the void, lets make sure the sounds end eventually

			SL_Soloud.DestroyVoiceGroup(Core.Audio.slPtr, group);
			SL_Bus.Destroy(slBus);
		}

		protected internal override void Initialize()
		{
			slBus = SL_Bus.Create();
			SL_Bus.SetInaudibleBehavior(slBus, SL_TRUE, SL_FALSE);
			group = SL_Soloud.CreateVoiceGroup(Core.Audio.slPtr);

			Debug.Assert(slBus != null && group != 0, "Failed to create SL_AudioSource (Bus or VoiceGroup)");
		}

		protected internal override void PlayInternal(AudioClip clip, float delay)
		{
			uint32 handle;
			if (delay == 0 || Paused)
				handle = SL_Bus.Play(slBus, clip.audio, volume, Pan, SL_TRUE);
			else handle = SL_Bus.PlayClocked(slBus, delay, clip.audio, volume, Pan);

			// Apply source config
			let ptr = Core.Audio.slPtr;
			SL_Soloud.SetInaudibleBehavior(ptr, handle, StopInaudible ? SL_FALSE : SL_TRUE, StopInaudible ? SL_TRUE : SL_FALSE);
			if (Prioritized) SL_Soloud.SetProtectVoice(ptr, handle, SL_TRUE);

			// Set current parameters
			SL_Soloud.SetRelativePlaySpeed(ptr, handle, Speed);
			SL_Soloud.SetLooping(ptr, handle, Looping ? SL_TRUE : SL_FALSE);

			// Play sound if not paused
			if (!Paused && delay == 0) SL_Soloud.SetPause(ptr, handle, 0);

			// Add to group
			SL_Soloud.AddVoiceToGroup(ptr, group, handle);
		}

		float volume = 1;
		float speed = 1;
		float pan;
		bool looping;
		bool paused;

		public override float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				//SL_Bus.SetVolume(slBus, Math.Max(0, value));
				SL_Soloud.SetVolume(Core.Audio.slPtr, group, Math.Max(0, volume));
				volume = value;
			}
		}

		public override float Pan
		{
			get => pan;

			set
			{
				if (pan == value) return;

				SL_Soloud.SetPan(Core.Audio.slPtr, group, value);
				pan = value;
			}
		}

		public override float Speed
		{
			get => speed;
			set
			{
				if (value == speed) return;

				SL_Soloud.SetRelativePlaySpeed(Core.Audio.slPtr, group, Math.Max(float.Epsilon, value));
				speed = value;
			}
		}

		public override bool Looping
		{
			get => looping;
			set
			{
				if (value == looping) return;

				SL_Soloud.SetLooping(Core.Audio.slPtr, group, value ? SL_TRUE : SL_FALSE);
				looping = value;
			}
		}

		public override bool Paused
		{
			get => paused;
			set
			{
				if (value == paused) return;

				SL_Soloud.SetPause(Core.Audio.slPtr, group, value ? SL_TRUE : SL_FALSE);
				paused = value;
			}
		}

		public override void Stop()
		{
			SL_Soloud.Stop(Core.Audio.slPtr, group);
		}
	}
}
