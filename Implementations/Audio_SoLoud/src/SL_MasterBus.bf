using internal Pile;
using SoLoud;

namespace Pile.Implementations
{
	public class SL_MasterBus : MixingBus.Platform
	{
		public override bool IsMasterBus => true;

		readonly SL_Audio audio;

		MixingBus api;

		internal this()
		{
			audio = Core.Audio as SL_Audio;
		}

		public override void Initialize(MixingBus bus)
		{
			api = bus;
			api.output = null;
		}

		public override void SetVolume(float volume)
		{
			SL_Soloud.SetGlobalVolume(audio.slPtr, volume);
		}

		public override void AddBus(MixingBus bus)
		{
			let slBus = (bus.platform as SL_MixingBus);
			slBus.busHandle = SL_Soloud.Play(audio.slPtr, slBus.bus);
		}

		public override void RemoveBus(MixingBus bus)
		{
			let slBus = (bus.platform as SL_MixingBus);
			SL_Soloud.Stop(audio.slPtr, slBus.busHandle);
		}

		public override void AddSource(AudioSource source)
		{
			let slSource = (source.platform as SL_AudioSource);
			slSource.busHandle = SL_Soloud.Play(audio.slPtr, slSource.bus);
		}

		public override void RemoveSource(AudioSource source)
		{
			let slSource = (source.platform as SL_AudioSource);
			SL_Soloud.Stop(audio.slPtr, slSource.busHandle);
		}

		public override void RedirectInputsToMaster()
		{
			// no... i don't think i will
		}
	}
}
