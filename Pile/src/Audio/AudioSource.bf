using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class AudioSource
	{
		internal AudioBus output;

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
		public readonly AudioBus Output => output;

		public float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				SetVolume(Math.Max(0, value));
				volume = value;
			}
		}

		public float Pan
		{
			get => pan;
			set
			{
				if (value == pan) return;

				SetPan(Math.Max(-1, Math.Min(1, value)));
				pan = value;
			}
		}

		public float Speed
		{
			get => speed;
			set
			{
				if (value == speed) return;

				SetSpeed(Math.Max(float.Epsilon, speed));
				speed = value;
			}
		}

		public bool Looping
		{
			get => looping;
			set
			{
				if (value == looping) return;

				SetLooping(value);
				looping = value;
			}
		}

		public bool Paused
		{
			get => paused;
			set
			{
				if (value == paused) return;

				SetPaused(value);
				paused = value;
			}
		}

		public extern bool Playing { get; }

		public this(MixingBus output = null, bool prioritized = false, bool stopOnDelete = true, bool stopInaudible = false)
		{
			Debug.Assert(Core.Audio != null, "Core needs to be initialized before creating platform dependent objects");

			Prioritized = prioritized;
			StopOnDelete = stopOnDelete;
			StopInaudible = stopInaudible;

			Initialize();

			this.output = output == null ? output : Core.Audio.MasterBus;
			Output.AddSource(this);
		}

		public ~this()
		{
			Output.RemoveSource(this);
		}

		public void Play(AudioClip clip)
		{
			Debug.Assert(clip != null, "AudioClip was null");

			PlayInternal(clip);
		}

		public extern void Stop();

		protected internal extern void Initialize();
		protected internal extern void SetVolume(float volume);
		protected internal extern void SetPan(float pan);
		protected internal extern void SetSpeed(float speed);
		protected internal extern void SetLooping(bool looping);
		protected internal extern void SetPaused(bool paused);

		// TODO: fading

		// TODO: 3d audio stuff -- somwhow integrate propertly, do just something like "bool spacial"?, how do we change/get position/space (do we need something audioListener?)

		protected internal extern void PlayInternal(AudioClip clip);
	}
}
