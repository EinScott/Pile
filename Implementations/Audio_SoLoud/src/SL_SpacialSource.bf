using System;
using System.Diagnostics;
using SoLoud;

using internal Pile;

namespace Pile
{
	extension SpacialSource
	{
		uint32 group;

		public override bool Playing => !SL_Soloud.IsVoiceGroupEmpty(Audio.slPtr, group) && !Paused;

		public ~this()
		{
			if (StopOnDelete || Paused)
				SL_Soloud.Stop(Audio.slPtr, group);
			else Looping = false; // Since we are throwing our handles into the void, lets make sure the sounds end eventually

			SL_Soloud.DestroyVoiceGroup(Audio.slPtr, group);
			SL_Bus.Destroy(slBus);
		}

		protected override void Initialize()
		{
			slBus = SL_Bus.Create();
			SL_Bus.SetInaudibleBehavior(slBus, SL_FALSE /*SL_TRUE*/, SL_FALSE); // TODO: theoretically we want it to keep ticking here and below... but soloud's broken with that rn
			group = SL_Soloud.CreateVoiceGroup(Audio.slPtr);

			Debug.Assert(slBus != null && group != 0, "Failed to create SL_AudioSource (Bus or VoiceGroup)");
		}

		protected override void PlayInternal(AudioClip clip, float delay)
		{
			uint32 handle;
			if (delay == 0 || Paused)
				handle = SL_Bus.Play3d(slBus, clip.audio, position.X, position.Y, position.Z, velocity.X, velocity.Y, velocity.Z, volume, SL_TRUE);
			else handle = SL_Bus.Play3dClocked(slBus, delay, clip.audio, position.X, position.Y, position.Z, velocity.X, velocity.Y, velocity.Z, volume);

			// Apply source config
			let ptr = Audio.slPtr;
			SL_Soloud.SetInaudibleBehavior(ptr, handle, SL_FALSE /*StopInaudible ? SL_FALSE : SL_TRUE*/, StopInaudible ? SL_TRUE : SL_FALSE);
			if (Prioritized) SL_Soloud.SetProtectVoice(ptr, handle, SL_TRUE);
			if (Audio.SimulateSpacialDelay) SL_Bus.Set3dDistanceDelay(slBus, 1);

			// Set current parameters
			SL_Soloud.SetRelativePlaySpeed(ptr, handle, Speed);
			SL_Soloud.SetLooping(ptr, handle, Looping ? SL_TRUE : SL_FALSE);
			SL_Soloud.Set3dSourceAttenuation(ptr, handle, attenuation, rolloff);
			SL_Soloud.Set3dSourceMinMaxDistance(ptr, handle, minDistance, maxDistance);
			SL_Soloud.Set3dSourcePosition(ptr, handle, position.X, position.Y, position.Z);
			SL_Soloud.Set3dSourceVelocity(ptr, handle, velocity.X, velocity.Y, velocity.Z);
			Audio.spacialDirty = true;

			// Play sound if not paused
			if (!Paused) SL_Soloud.SetPause(ptr, handle, 0);

			// Add to group
			SL_Soloud.AddVoiceToGroup(ptr, group, handle);
		}

		float volume = 1;
		float speed = 1;
		float pan;
		bool looping;
		bool paused;
		Vector3 position;
		Vector3 velocity;
		float minDistance = 1;
		float maxDistance = 1000000;
		SoLoud.Attenuation attenuation = SoLoud.Attenuation.INVERSE_DISTANCE;
		float rolloff;

		public override Pile.Attenuation Attenuation
		{
			get => (Pile.Attenuation)attenuation;
			set
			{
				if ((Pile.Attenuation)attenuation == value) return;
				
				attenuation = (SoLoud.Attenuation)value;
				SL_Soloud.Set3dSourceAttenuation(Audio.slPtr, group, attenuation, rolloff);
				Audio.spacialDirty = true;
			}
		}

		public override float AttenuationRolloffFactor
		{
			get => rolloff;
			set
			{
				if (rolloff == value) return;

				SL_Soloud.Set3dSourceAttenuation(Audio.slPtr, group, attenuation, value);
				rolloff = value;
				Audio.spacialDirty = true;
			}
		}

		public override float MinDistance
		{
			get => minDistance;

			set
			{
				if (minDistance == value) return;

				SL_Soloud.Set3dSourceMinMaxDistance(Audio.slPtr, group, value, maxDistance);
				minDistance = value;
				Audio.spacialDirty = true;
			}
		}

		public override float MaxDistance
		{
			get => maxDistance;

			set
			{
				if (maxDistance == value) return;

				SL_Soloud.Set3dSourceMinMaxDistance(Audio.slPtr, group, minDistance, value);
				maxDistance = value;
				Audio.spacialDirty = true;
			}
		}

		public override Vector3 Position
		{
			get => position;
			set
			{
				if (value == position) return;

				SL_Soloud.Set3dSourcePosition(Audio.slPtr, group, value.X, value.Y, value.Z);
				position = value;
				Audio.spacialDirty = true;
			}
		}

		public override Vector3 Velocity
		{
			get => velocity;
			set
			{
				if (value == velocity) return;

				SL_Soloud.Set3dSourceVelocity(Audio.slPtr, group, value.X, value.Y, value.Z);
				velocity = value;
				Audio.spacialDirty = true;
			}
		}

		public override float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				SL_Soloud.SetVolume(Audio.slPtr, group, Math.Max(0, value));
				volume = value;
			}
		}

		public override float Speed
		{
			get => speed;
			set
			{
				if (value == speed) return;

				SL_Soloud.SetRelativePlaySpeed(Audio.slPtr, group, Math.Max(float.Epsilon, value));
				speed = value;
			}
		}

		public override bool Looping
		{
			get => looping;
			set
			{
				if (value == looping) return;

				SL_Soloud.SetLooping(Audio.slPtr, group, value ? SL_TRUE : SL_FALSE);
				looping = value;
			}
		}

		public override bool Paused
		{
			get => paused;
			set
			{
				if (value == paused) return;

				SL_Soloud.SetPause(Audio.slPtr, group, value ? SL_TRUE : SL_FALSE);
				paused = value;
			}
		}

		public override void Stop()
		{
			SL_Soloud.Stop(Audio.slPtr, group);
		}
	}
}
