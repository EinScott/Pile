using System;
using System.Diagnostics;
using SoLoud;

using internal Pile;

namespace Pile.Implementations
{
	public class SL_AudioClip : AudioClip.Platform
	{
		// equivalent to solouds audioSource
		// we dont change any settings on this directly

		internal Wav* audio;

		internal this()
		{
			audio = SL_Wav.Create();

			Debug.Assert(audio != null, "Failed to create SL_AudioClip (Wav)");
		}

		public ~this()
		{
			SL_Wav.Destroy(audio);
		}

		public override void Initialize(Span<uint8> data)
		{
			SL_Wav.LoadMem(audio, data.Ptr, (.)data.Length, SL_TRUE, SL_TRUE);
		}
	}
}
