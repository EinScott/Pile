using System;
using SoLoud;
using static SoLoud.SL_Soloud;

namespace Pile.Implementations
{
	public class SL_Audio : Audio
	{
		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SoLoud";

		String info = new String() ~ delete _;
		public override String Info => info;
		
		readonly Backend backend;

		Soloud* slPtr;

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

			// Version
			let ver = GetVersion(slPtr);
			majVer = (uint32)Math.Floor((float)ver / 100);
			minVer = ver - (majVer * 100);

			// Info
			info.AppendF("backend: {} buffer size: {}, sample rate: {}", GetBackendId(slPtr), GetBackendBufferSize(slPtr), GetBackendSamplerate(slPtr));

			// TODO: (impl) before delegating functionality to components, load manually here in full to see how it works
			// try to play sound manually here ..
			//SL_Openmpt.LoadMem()



			return .Ok;
		}
	}
}
