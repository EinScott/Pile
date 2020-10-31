using internal Pile;

namespace Pile.Implementations
{
	public class SL_AudioSource : AudioSource.Platform
	{
		// slightly confusingly, Pile.AudioSource doesnt correspond to a SoLoud AudioSource, but rather something like a Voice playing interface

		// look into virtual voices and probably use those (unless prioritized, then you can just create normal protected voices)
		// keep a list of current voices to update when changing properties (we generally dont configure the Wav, but the handle we create(d))

		bool Prioritized;

		internal this() {}

		public override void Initialize(bool prioritized)
		{
			Prioritized = prioritized;
		}

		public override void Play(AudioClip clip)
		{

		}
	}
}
