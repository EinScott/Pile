using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class AudioSource
	{
		// Can play multiple sounds at once

		protected internal abstract class Platform
		{
			protected internal abstract bool Playing { get; }

			protected internal abstract void Initialize(AudioSource source);
			protected internal abstract void SetVolume(float volume);
			protected internal abstract void SetPan(float pan);
			protected internal abstract void SetSpeed(float speed);
			protected internal abstract void SetLooping(bool looping);
			protected internal abstract void SetPaused(bool paused);

			// TODO: fading

			// TODO: 3d audio stuff -- somwhow integrate propertly, do just something like "bool spacial"?, how do we change/get position/space (do we need something audioListener?)

			protected internal abstract void Play(AudioClip clip);

			protected internal abstract void Stop();
		}

		internal readonly Platform platform ~ delete _;
		internal MixingBus output;

		float volume = 1;
		float pan;
		float speed = 1;
		bool looping;
		bool paused;

		/// Prioritized sources will always play. Useful for stuff like global music
		public bool Prioritized { get; private set; }
		public bool StopInaudible { get; private set; }
		public bool StopOnDelete { get; private set; }

		/// Returns Audio.MasterBus by default. Won't be null
		public readonly MixingBus Output => output;

		public float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				platform.SetVolume(Math.Max(0, value));
				volume = value;
			}
		}

		public float Pan
		{
			get => pan;
			set
			{
				if (value == pan) return;

				platform.SetPan(Math.Max(-1, Math.Min(1, value)));
				pan = value;
			}
		}

		public float Speed
		{
			get => speed;
			set
			{
				if (value == speed) return;

				platform.SetSpeed(Math.Max(float.Epsilon, speed));
				speed = value;
			}
		}

		public bool Looping
		{
			get => looping;
			set
			{
				if (value == looping) return;

				platform.SetLooping(value);
				looping = value;
			}
		}

		public bool Paused
		{
			get => paused;
			set
			{
				if (value == paused) return;

				platform.SetPaused(value);
				paused = value;
			}
		}

		public bool Playing => platform.Playing;

		public this(MixingBus output = null, bool prioritized = false, bool stopOnDelete = true, bool stopInaudible = false)
		{
			Debug.Assert(Core.Audio != null, "Core needs to be initialized before creating platform dependant objects");

			Prioritized = prioritized;
			StopOnDelete = stopOnDelete;
			StopInaudible = stopInaudible;

			platform = Core.Audio.CreateAudioSource();
			platform.Initialize(this);

			this.output = output??Core.Audio.MasterBus;
			Output.platform.AddSource(this);
		}

		public ~this()
		{
			Output.platform.RemoveSource(this);
		}

		public void Play(AudioClip clip)
		{
			Debug.Assert(clip != null, "AudioClip was null");

			platform.Play(clip);
		}

		public void Stop()
		{
			platform.Stop();
		}
	}
}
