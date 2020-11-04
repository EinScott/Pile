using System;
using SoLoud;
using static SoLoud.SL_Soloud;

using internal Pile;

namespace Pile.Implementations
{
	public class SL_Audio : Audio
	{
		// TODO: support things like queue, maybe voice and other sources [also 3d, filters and faders, see to.dos elsewhere], maybe some debug mode (SL_Bus.SetVisualizationEnable(bus, true);) like graphics

		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SoLoud";

		String info = new String() ~ delete _;
		public override String Info => info;

		bool createMaster = true;
		MixingBus master ~ delete _;
		public override MixingBus MasterBus => master;

		readonly Backend Backend;
		readonly uint32 MaxVoiceCount;

		internal Soloud* slPtr;

		public override uint AudibleSoundCount => (.)SL_Soloud.GetActiveVoiceCount(slPtr);
		public override uint SoundCount => (.)SL_Soloud.GetVoiceCount(slPtr);

		public this(uint32 maxVoiceCount = 16, Backend backend = .AUTO)
		{
			Backend = backend;
			MaxVoiceCount = maxVoiceCount;
		}

		internal ~this()
		{
			Deinit(slPtr);
			Destroy(slPtr);
		}

		internal override Result<void> Initialize()
		{
			// Create master bus (cant do earlier since we need to have Core.Auio assigned)
			master = new MixingBus(); // Will get special MixingBus.Platform, because retMaster == true
			createMaster = false;

			slPtr = Create();
			Init(slPtr, .CLIP_ROUNDOFF, Backend, AUTO, AUTO, .TWO);
			SL_Soloud.SetMaxActiveVoiceCount(slPtr, MaxVoiceCount);

			// Version
			let ver = GetVersion(slPtr);
			majVer = (uint32)Math.Floor((float)ver / 100);
			minVer = ver - (majVer * 100);

			// Info
			info.AppendF("backend: {}, buffer size: {}", GetBackendId(slPtr), GetBackendBufferSize(slPtr));

			return .Ok;
		}

		internal override AudioSource.Platform CreateAudioSource() => new SL_AudioSource();
		internal override AudioClip.Platform CreateAudioClip() => new SL_AudioClip();
		internal override MixingBus.Platform CreateMixingBus() => !createMaster ? new SL_MixingBus() : new SL_MasterBus();
	}
}
