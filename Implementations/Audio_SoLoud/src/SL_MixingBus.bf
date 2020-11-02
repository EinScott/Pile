using System.Diagnostics;
using System.Collections;
using SoLoud;

using internal Pile;

namespace Pile.Implementations
{
	public class SL_MixingBus : MixingBus.Platform
	{
		public override bool IsMasterBus => false;

		readonly SL_Audio audio;

		internal uint32 busHandle; // external only. Is set when this is played on SoLoud or another Bus, used again when removing
		internal Bus* bus;

		List<MixingBus> busInputs = new List<MixingBus>() ~ delete _;
		List<AudioSource> sourceInputs = new List<AudioSource>() ~ delete _;
		MixingBus api;

		internal this()
		{
			audio = Core.Audio as SL_Audio;

			bus = SL_Bus.Create();

			Debug.Assert(bus != null, "Failed to create SL_MixingBus (Bus)");
		}

		public ~this()
		{
			SL_Bus.Destroy(bus);
		}

		public override void Initialize(MixingBus mixingBus)
		{
			api = mixingBus;
		}

		public override void SetVolume(float volume)
		{
			SL_Bus.SetVolume(bus, volume);
		}

		public override void AddBus(MixingBus mixingBus)
		{
			let slBus = (mixingBus.platform as SL_MixingBus);
			slBus.busHandle = SL_Bus.Play(bus, slBus.bus);

			busInputs.Add(mixingBus);
		}

		public override void RemoveBus(MixingBus mixingBus)
		{
			let slBus = (mixingBus.platform as SL_MixingBus);
			SL_Soloud.Stop(audio.slPtr, slBus.busHandle);

			busInputs.Remove(mixingBus);
		}

		public override void AddSource(AudioSource source)
		{
			let slSource = (source.platform as SL_AudioSource);
			slSource.busHandle = SL_Bus.Play(bus, slSource.bus);

			sourceInputs.Add(source);
		}

		public override void RemoveSource(AudioSource source)
		{
			let slSource = (source.platform as SL_AudioSource);
			SL_Soloud.Stop(audio.slPtr, slSource.busHandle);

			sourceInputs.Remove(source);
		}

		public override void RedirectInputsToMaster()
		{
			for (let mixingBus in busInputs)
			{
				// Stop voice
				let slBus = (mixingBus.platform as SL_MixingBus);
				SL_Soloud.Stop(audio.slPtr, slBus.busHandle);

				// Replay
				mixingBus.output = Core.Audio.MasterBus;
				Core.Audio.MasterBus.platform.AddBus(mixingBus);
			}
			busInputs.Clear();

			for (let mixingBus in sourceInputs)
			{
				// Stop voice
				let slBus = (mixingBus.platform as SL_AudioSource);
				SL_Soloud.Stop(audio.slPtr, slBus.busHandle);

				// Replay
				mixingBus.output = Core.Audio.MasterBus;
				Core.Audio.MasterBus.platform.AddSource(mixingBus);
			}
			busInputs.Clear();
		}
	}
}
