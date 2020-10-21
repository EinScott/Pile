using System;
using SoLoud;
using static SoLoud.SL_Soloud;

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
		Backend backend;

		public this(Backend backend = .AUTO)
		{
			this.backend = backend;
		}

		internal ~this()
		{
			Deinit(slPtr);
			Destroy(slPtr);
		}

		internal override Result<void> Initialize()
		{
			slPtr = Create();
			Init(slPtr, .SOLOUD_CLIP_ROUNDOFF, backend, AUTO, AUTO, .TWO);

			version = GetVersion(slPtr);
			GetBackendId(slPtr).ToString(api);

			// TODO: (impl) before delegating functionality to components, load manually here in full to see how it works
			// try to play sound manually here ..
			//SL_Openmpt.LoadMem()

			return .Ok;
		}
	}
}
