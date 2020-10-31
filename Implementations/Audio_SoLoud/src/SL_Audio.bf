using System;
using SoLoud;
using static SoLoud.SL_Soloud;

using internal Pile;

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
		
		readonly Backend Backend;
		readonly uint32 MaxVoiceCount;

		Soloud* slPtr;
		Wav* wav;
		Bus* bus;
		FreeverbFilter* reverb;

		public this(uint32 maxVoiceCount = 16, Backend backend = .AUTO)
		{
			Backend = backend;
			MaxVoiceCount = maxVoiceCount;
		}

		internal ~this()
		{
			SL_Wav.Destroy(wav);
			SL_Bus.Destroy(bus);
			SL_FreeverbFilter.Destroy(reverb);

			Deinit(slPtr);
			Destroy(slPtr);
		}

		// temp
		public void Draw(Batch2D batch)
		{
			float* arr = SL_Bus.CalcFFT(bus);
			for (int i = 0; i < 256; i++)
				batch.Line(Vector2(i * 2 + 20, 128), Vector2(i * 2 + 20, 128 - arr[i] * 1), 1, Color.White);
		}
		// --

		internal override Result<void> Initialize()
		{
			slPtr = Create();
			Init(slPtr, .SOLOUD_CLIP_ROUNDOFF, Backend, AUTO, AUTO, .TWO);
			SL_Soloud.SetMaxActiveVoiceCount(slPtr, MaxVoiceCount);

			// Version
			let ver = GetVersion(slPtr);
			majVer = (uint32)Math.Floor((float)ver / 100);
			minVer = ver - (majVer * 100);

			// Info
			info.AppendF("backend: {}, buffer size: {}, sample rate: {}", GetBackendId(slPtr), GetBackendBufferSize(slPtr), GetBackendSamplerate(slPtr));

			// TODO: (impl) before delegating functionality to components, load manually here in full to see how it works
			// try to play sound manually here ..
			//SL_Openmpt.LoadMem()

			// How do we handle this with assets AND this? should soloud always copy??? mem of the music should probably be wrapped in Clip type
			let s = scope String();
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

			delete fileData;


			return .Ok;
		}

		internal override AudioSource.Platform CreateAudioSource() => new SL_AudioSource();
		internal override AudioClip.Platform CreateAudioClip() => new SL_AudioClip();
		internal override MixingBus.Platform CreateMixingBus() => new SL_MixingBus();
	}
}
