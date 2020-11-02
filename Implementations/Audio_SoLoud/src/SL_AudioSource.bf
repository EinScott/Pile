using SoLoud;
using System.Diagnostics;

using internal Pile;

namespace Pile.Implementations
{
	public class SL_AudioSource : AudioSource.Platform
	{
		// slightly confusingly, Pile.AudioSource doesnt correspond to a SoLoud AudioSource, but rather something like a Voice playing interface

		readonly SL_Audio audio;

		internal uint32 busHandle; // external only. Is set when this is played on SoLoud or another Bus, used again when removing
		internal Bus* bus;
		uint32 group;

		AudioSource api;
		bool prioritized;

		public override bool Playing => !SL_Soloud.IsVoiceGroupEmpty(audio.slPtr, group) && !api.Paused;

		internal this()
		{
			audio = Core.Audio as SL_Audio;

			bus = SL_Bus.Create();
			SL_Bus.SetInaudibleBehavior(bus, SL_TRUE, SL_FALSE);
			group = SL_Soloud.CreateVoiceGroup(audio.slPtr);

			Debug.Assert(bus != null && group != 0, "Failed to create SL_AudioSource (Bus or VoiceGroup)");
		}

		public ~this()
		{
			if (api.StopOnDelete || api.Paused)
				SL_Soloud.Stop(audio.slPtr, group);
			else SetLooping(false); // Since we are throwing our handles into the void, lets make sure the sounds end eventually

			SL_Soloud.DestroyVoiceGroup(audio.slPtr, group);
			SL_Bus.Destroy(bus);
		}

		public override void Initialize(AudioSource source)
		{
			prioritized = source.Prioritized;

			this.api = source;
		}

		public override void Play(AudioClip clip)
		{
			let platform = clip.platform as SL_AudioClip;
			let handle = SL_Bus.Play(bus, platform.audio, 1, api.Pan, SL_TRUE);

			// Apply source config
			SL_Soloud.SetInaudibleBehavior(audio.slPtr, handle, api.StopInaudible ? SL_FALSE : SL_TRUE, api.StopInaudible ? SL_TRUE : SL_FALSE);
			if (api.Prioritized) SL_Soloud.SetProtectVoice(audio.slPtr, handle, SL_TRUE);

			// Set current parameters
			SL_Soloud.SetRelativePlaySpeed(audio.slPtr, handle, api.Speed);
			SL_Soloud.SetLooping(audio.slPtr, handle, api.Looping ? SL_TRUE : SL_FALSE);

			// Play sound if not paused
			if (!api.Paused) SL_Soloud.SetPause(audio.slPtr, handle, 0);

			// Add to group
			SL_Soloud.AddVoiceToGroup(audio.slPtr, group, handle);
		}

		public override void SetVolume(float volume)
		{
			SL_Bus.SetVolume(bus, volume);
		}

		public override void SetPan(float pan)
		{
			SL_Soloud.SetPan(audio.slPtr, group, pan);
		}

		public override void SetSpeed(float speed)
		{
			SL_Soloud.SetRelativePlaySpeed(audio.slPtr, group, speed);
		}

		public override void SetLooping(bool looping)
		{
			SL_Soloud.SetLooping(audio.slPtr, group, looping ? SL_TRUE : SL_FALSE);
		}

		public override void SetPaused(bool paused)
		{
			SL_Soloud.SetPause(audio.slPtr, group, paused ? SL_TRUE : SL_FALSE);
		}

		public override void Stop()
		{
			SL_Soloud.Stop(audio.slPtr, group);
		}
	}
}
