using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	abstract class AudioSource
	{
		internal AudioBus output;

		/// Prioritized sources will always play. Useful for stuff like global music
		public bool Prioritized { get; private set; }

		/// Stop sounds played on this when they are inaudible.
		public bool StopInaudible { get; private set; }

		/// Stop sounds played on this AudioSource when is is deleted.
		public bool StopOnDelete { get; private set; }
		
		/// Returns Audio.MasterBus by default. Won't be null
		public readonly AudioBus Output => output;

		public abstract extern float Volume { get; set; }

		public abstract extern float Speed { get; set; }

		public abstract extern bool Looping { get; set; }

		public abstract extern bool Paused { get; set; }

		public void Play(AudioClip clip, float delay = 0)
		{
			Debug.Assert(clip != null, "AudioClip was null");
			Debug.Assert(delay >= 0, "Delay cannot be negative");

			PlayInternal(clip, delay);
		}

		protected void SetupOutput(MixingBus output)
		{
			this.output = output == null ? Audio.MasterBus : output;
			Output.AddSource(this);
		}
		
		public ~this()
		{
			Output.RemoveSource(this);
		}

		public abstract extern bool Playing { get; }
		public abstract extern void Stop();

		protected internal abstract extern void Initialize();
		protected internal abstract extern void PlayInternal(AudioClip clip, float delay);
	}
}
