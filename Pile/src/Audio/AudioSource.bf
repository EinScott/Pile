using internal Pile;

namespace Pile
{
	public class AudioSource
	{
		internal abstract class Platform
		{
			public abstract void Initialize(bool prioritized);

			// Changing properties should also affect already playing sounds
			// ...properties...

			// TODO: 3d audio stuff

			public abstract void Play(AudioClip clip);
		}

		internal readonly Platform platform ~ delete _;

		/// Prioritized sources will always play. Useful for stuff like global music
		public bool Prioritized { get; private set; }

		public this(bool prioritized = false)
		{
			Prioritized = prioritized;

			platform = Core.Audio.CreateAudioSource();
			platform.Initialize(prioritized);
		}

		public void Play(AudioClip clip)
		{
			
		}
	}
}
