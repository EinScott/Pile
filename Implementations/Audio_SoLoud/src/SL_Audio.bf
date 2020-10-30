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
		Wav* wav;

		public this(Backend backend = .AUTO)
		{
			this.backend = backend;
		}

		internal ~this()
		{
			SL_Wav.Destroy(wav);

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

			// How do we handle this with assets AND this? should soloud always copy??? mem of the music should probably be wrapped in Clip type
			let s = scope String();
			System.IO.Path.InternalCombine(s, Core.System.DataPath, "test.mp3");
			let fileData = System.IO.File.ReadAllBytes(s).Get();

			wav = SL_Wav.Create();
			SL_Wav.LoadMem(wav, &fileData[0], (.)fileData.Count, true, true);

			uint32 voice = SL_Soloud.Play(slPtr, wav);

			SL_Soloud.SetLooping(slPtr, voice, true);

			delete fileData;


			return .Ok;
		}
	}
}
