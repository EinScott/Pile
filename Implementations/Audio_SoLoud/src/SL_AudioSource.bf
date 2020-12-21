using SoLoud;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	extension AudioSource
	{
		// slightly confusingly, Pile.AudioSource doesnt correspond to a SoLoud AudioSource, but rather something like a Voice playing interface

		internal uint32 slBusHandle; // external only. Is set when this is played on SoLoud or another Bus, used again when removing
		internal Bus* slBus;
		uint32 group;

		bool prioritized;

		public override bool Playing => !SL_Soloud.IsVoiceGroupEmpty(Core.Audio.slPtr, group) && !Paused;

		public ~this()
		{
			if (StopOnDelete || Paused)
				SL_Soloud.Stop(Core.Audio.slPtr, group);
			else SetLooping(false); // Since we are throwing our handles into the void, lets make sure the sounds end eventually

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

		protected internal override void PlayInternal(AudioClip clip)
		{
			let handle = SL_Bus.Play(slBus, clip.audio, 1, Pan, SL_TRUE);

			// Apply source config
			let ptr = Core.Audio.slPtr;
			SL_Soloud.SetInaudibleBehavior(ptr, handle, StopInaudible ? SL_FALSE : SL_TRUE, StopInaudible ? SL_TRUE : SL_FALSE);
			if (Prioritized) SL_Soloud.SetProtectVoice(ptr, handle, SL_TRUE);

			// Set current parameters
			SL_Soloud.SetRelativePlaySpeed(ptr, handle, Speed);
			SL_Soloud.SetLooping(ptr, handle, Looping ? SL_TRUE : SL_FALSE);

			// Play sound if not paused
			if (!Paused) SL_Soloud.SetPause(ptr, handle, 0);

			// Add to group
			SL_Soloud.AddVoiceToGroup(ptr, group, handle);
		}

		protected internal override void SetVolume(float volume)
		{
			SL_Bus.SetVolume(slBus, volume);
		}

		protected internal override void SetPan(float pan)
		{
			SL_Soloud.SetPan(Core.Audio.slPtr, group, pan);
		}

		protected internal override void SetSpeed(float speed)
		{
			SL_Soloud.SetRelativePlaySpeed(Core.Audio.slPtr, group, speed);
		}

		protected internal override void SetLooping(bool looping)
		{
			SL_Soloud.SetLooping(Core.Audio.slPtr, group, looping ? SL_TRUE : SL_FALSE);
		}

		protected internal override void SetPaused(bool paused)
		{
			SL_Soloud.SetPause(Core.Audio.slPtr, group, paused ? SL_TRUE : SL_FALSE);
		}

		public override void Stop()
		{
			SL_Soloud.Stop(Core.Audio.slPtr, group);
		}
	}
}
