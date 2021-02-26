using System;
using System.Diagnostics;
using SoLoud;

using internal Pile;

namespace Pile
{
	extension AudioClip
	{
		// equivalent to solouds audioSource
		// we dont change any settings on this directly

		internal Wav* audio;

		public ~this()
		{
			SL_Wav.Destroy(audio);
		}

		protected internal override void Initialize(Span<uint8> data)
		{
			audio = SL_Wav.Create();

			Core.Assert(audio != null, "Failed to create SL_AudioClip (Wav)");

			SL_Wav.LoadMem(audio, data.Ptr, (.)data.Length, SL_TRUE, SL_TRUE);
		}
	}
}
