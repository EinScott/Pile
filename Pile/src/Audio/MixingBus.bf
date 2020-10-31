using internal Pile;

namespace Pile
{
	public class MixingBus
	{
		// bundles multiple sources
		// contains filter?

		internal class Platform
		{
			
		}

		internal readonly Platform platform ~ delete _;

		public this()
		{
			platform = Core.Audio.CreateMixingBus();
		}
	}
}
