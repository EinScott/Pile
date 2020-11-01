using internal Pile;

namespace Pile
{
	public class AudioSource
	{
		internal abstract class Platform
		{
			public abstract void Initialize(AudioSource source);

			// Changing properties should also affect already playing sounds
			// ...properties...

			// TODO: 3d audio stuff

			public abstract void Play(AudioClip clip);
		}

		internal readonly Platform platform ~ delete _;

		internal MixingBus output;

		/// Prioritized sources will always play. Useful for stuff like global music
		public bool Prioritized { get; private set; }

		public bool StopPlayingClipsOnDelete = true; // TODO: call stopall on delete

		/// Returns Audio.MasterBus by default. Won't be null
		public MixingBus Output
		{
			get => output;
			set
			{
				if (value != null && value == output) return;

				if (output != null) output.platform.RemoveSource(this);
				output = value;
				if (output != null) output.platform.AddSource(this);
				else Core.Audio.MasterBus.platform.AddSource(this);
			}
		}

		public this(bool prioritized = false)
		{
			AssertInit();

			Prioritized = prioritized;

			platform = Core.Audio.CreateAudioSource();
			platform.Initialize(this);
			Output = null; // Default output bus
		}

		public void Play(AudioClip clip)
		{
			
		}
	}
}
