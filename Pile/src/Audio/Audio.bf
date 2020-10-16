using System;

namespace Pile
{
	public abstract class Audio
	{
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
		public abstract String ApiName { get; }

		internal ~this() {}

		internal abstract Result<void> Initialize();

		// Play() functions
		// Stop() functions...
		// usw...

		// handle mixing??

		public Result<AudioInstance> Play(AudioClip clip, float volume = 1, float pan = 0, bool paused = false, AudioBus bus = null)
		{
			return .Ok(null);
		}

		public abstract void PlayInternal(AudioClip clip, float volume = 1, float pan = 0, bool paused = false, AudioBus bus = null);

		public void Stop(AudioInstance instance)
		{

		}

		public void Stop(params AudioInstance[] instances)
		{

		}

		public abstract void StopInternal(params AudioInstance[] instances);
	}
}
