using System;

namespace Pile
{
	abstract class AudioBus
	{
		public abstract float Volume { get; set; }

		protected abstract extern void Initialize();
		protected abstract extern void SetVolume(float volume);

		// Called from other MixingBusses
		protected internal abstract extern void AddBus(MixingBus bus);
		protected internal abstract extern void RemoveBus(MixingBus bus);

		// Called from AudioSource
		protected internal abstract extern void AddSource(AudioSource source);
		protected internal abstract extern void RemoveSource(AudioSource source);

		// Filter stuff
	}
}
