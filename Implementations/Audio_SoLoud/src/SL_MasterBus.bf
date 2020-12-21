using SoLoud;

using internal Pile;

namespace Pile
{
	extension MasterBus
	{
		protected internal override void Initialize() {}

		protected internal override void SetVolume(float volume)
		{
			SL_Soloud.SetGlobalVolume(Core.Audio.slPtr, volume);
		}

		protected internal override void AddBus(MixingBus bus)
		{
			bus.slBusHandle = SL_Soloud.Play(Core.Audio.slPtr, bus.slBus);
		}

		protected internal override void RemoveBus(MixingBus bus)
		{
			SL_Soloud.Stop(Core.Audio.slPtr, bus.slBusHandle);
		}

		protected internal override void AddSource(AudioSource source)
		{
			source.slBusHandle = SL_Soloud.Play(Core.Audio.slPtr, source.slBus);
		}

		protected internal override void RemoveSource(AudioSource source)
		{
			SL_Soloud.Stop(Core.Audio.slPtr, source.slBusHandle);
		}
	}
}
