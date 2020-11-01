using System.Diagnostics;
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

		public override void Initialize(MixingBus _bus)
		{
			api = _bus;
		}

		public override void SetVolume(float volume)
		{
			SL_Bus.SetVolume(bus, volume);
		}

		// Keep track of these classes in two lists (well need to reset handles later maybe)

		public override void AddBus(MixingBus bus)
		{

		}

		public override void RemoveBus(MixingBus bus)
		{

		}

		public override void AddSource(AudioSource source)
		{

		}

		public override void RemoveSource(AudioSource source)
		{

		}

		public override void RedirectInputsToMaster()
		{
			// Stop voices on this

			// Reset handle (and play) on master
		}
	}
}
