using System;
using SoLoud;
//using static SoLoud.SL_Soloud;

using internal Pile;

namespace Pile
{
	extension Audio
	{
		// TODO: support things like queue (not possible because queue is global), maybe voice and other sources [also 3d, filters and faders, see to.dos elsewhere], maybe some debug mode (SL_Bus.SetVisualizationEnable(bus, true);) like graphics

		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SoLoud";

		String info = new String() ~ delete _;
		public override String Info => info;

		MasterBus master ~ delete _;
		public override MasterBus MasterBus => master;

		readonly SL_Soloud.Backend Backend;
		readonly uint32 MaxVoiceCount;

		internal Soloud* slPtr;

		public override uint AudibleSoundCount => (.)SL_Soloud.GetActiveVoiceCount(slPtr);
		public override uint SoundCount => (.)SL_Soloud.GetVoiceCount(slPtr);

		public this(uint32 maxVoiceCount = 16, SL_Soloud.Backend backend = .AUTO)
		{
			Backend = backend;
			MaxVoiceCount = maxVoiceCount;
		}

		internal ~this()
		{
			SL_Soloud.Deinit(slPtr);
			SL_Soloud.Destroy(slPtr);
		}

		protected internal override void Initialize()
		{
			// Create master bus (cant do earlier since we need to have Core.Auio assigned)
			master = new MasterBus();

			slPtr = SL_Soloud.Create();
			SL_Soloud.Init(slPtr, .CLIP_ROUNDOFF, Backend, SL_Soloud.AUTO, SL_Soloud.AUTO, .TWO);
			SL_Soloud.SetMaxActiveVoiceCount(slPtr, MaxVoiceCount);

			// Version
			let ver = SL_Soloud.GetVersion(slPtr);
			majVer = (uint32)Math.Floor((float)ver / 100);
			minVer = ver - (majVer * 100);

			// Info
			info.AppendF("backend: {}, buffer size: {}", SL_Soloud.GetBackendId(slPtr), SL_Soloud.GetBackendBufferSize(slPtr));
		}
	}
}
