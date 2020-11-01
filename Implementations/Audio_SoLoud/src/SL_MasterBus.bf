using internal Pile;
using SoLoud;

namespace Pile.Implementations
{
	public class SL_MasterBus : MixingBus.Platform
	{
		public override bool IsMasterBus => true;

		internal this() {}

		public override void Initialize(MixingBus bus)
		{

		}

		public override void SetVolume(float volume)
		{

		}

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
	}
}
