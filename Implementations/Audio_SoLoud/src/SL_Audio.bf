using System;
using SoLoud;

namespace Pile.Implementations
{
	public class SL_Audio : Audio
	{
		uint32 version;
		public override uint32 MajorVersion => version;

		public override uint32 MinorVersion => 0;

		String api = new String("SoLoud ") ~ delete _;
		public override String ApiName => api;

		Soloud* slPtr;

		internal ~this()
		{
			SL_Soloud.Deinit(slPtr);
			SL_Soloud.Destroy(slPtr);
		}

		internal override Result<void> Initialize()
		{
			slPtr = SL_Soloud.Create();
			version = SL_Soloud.GetVersion(slPtr);
			SL_Soloud.GetBackendId(slPtr).ToString(api);

			// TODO: (impl) before delegating functionality to components, load manually here in full to see how it works
			// try to play sound manually here ..
			//SL_Openmpt.LoadMem()

			return .Ok;
		}
	}
}
