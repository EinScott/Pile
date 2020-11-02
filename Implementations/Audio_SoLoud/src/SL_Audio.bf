using System;
using SoLoud;
using static SoLoud.SL_Soloud;

using internal Pile;

namespace Pile.Implementations
{
	public class SL_Audio : Audio
	{
		// TODO: support things like queue, maybe voice and other sources [also 3d, filters and faders, see to.dos elsewhere]

		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SoLoud";

		String info = new String() ~ delete _;
		public override String Info => info;

		bool retMaster = true;
		MixingBus master ~ delete _;
		public override MixingBus MasterBus => master;

		readonly Backend Backend;
		readonly uint32 MaxVoiceCount;

		internal Soloud* slPtr;

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
			retMaster = false;

			slPtr = Create();
			Init(slPtr, .CLIP_ROUNDOFF, Backend, AUTO, AUTO, .TWO);
			SL_Soloud.SetMaxActiveVoiceCount(slPtr, MaxVoiceCount);

			// Version
			let ver = GetVersion(slPtr);
			majVer = (uint32)Math.Floor((float)ver / 100);
			minVer = ver - (majVer * 100);

			// Info
			info.AppendF("backend: {}, buffer size: {}", GetBackendId(slPtr), GetBackendBufferSize(slPtr));

			// try to play sound manually here ..
			//SL_Openmpt.LoadMem()

			// How do we handle this with assets AND this? should soloud always copy??? mem of the music should probably be wrapped in Clip type
			/*let s = scope String();
			System.IO.Path.InternalCombine(s, Core.System.DataPath, "test.mp3");
			let fileData = System.IO.File.ReadAllBytes(s).Get();

			wav = SL_Wav.Create();
			SL_Wav.LoadMem(wav, &fileData[0], (.)fileData.Count, true, true);

			// AudioChannel is bus and plays sounds??
			bus = SL_Bus.Create();
			SL_Bus.SetVolume(bus, 0.7f);
			SL_Bus.SetVisualizationEnable(bus, true); // enable this on master as some kind of debug option like in graphics??
			/*uint32 busHandle =*/ SL_Soloud.Play(slPtr, bus);

			// filters should probably be applied to busses instead of sounds
			/*reverb = SL_FreeverbFilter.Create();
			SL_FreeverbFilter.SetParams(reverb, 0, 0.5f, 0.5f, 1);

			SL_Bus.SetFilter(bus, 0, reverb);*/

			uint32 audioHandle = SL_Bus.Play(bus, wav);

			SL_Soloud.SetLooping(slPtr, audioHandle, true);

			delete fileData;*/

			/**

			SL_Bus.SetVisualizationEnable(bus, true);
			SL_Bus.Cal...

			soloud.getActiveVoiceCount();
			soloud.getVoiceCount();

			*/

			return .Ok;
		}

		internal override AudioSource.Platform CreateAudioSource() => new SL_AudioSource();
		internal override AudioClip.Platform CreateAudioClip() => new SL_AudioClip();
		internal override MixingBus.Platform CreateMixingBus() => !retMaster ? new SL_MixingBus() : new SL_MasterBus();
	}
}
