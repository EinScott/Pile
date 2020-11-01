using System;

using internal Pile;

namespace Pile
{
	public class AudioClip
	{
		internal abstract class Platform
		{
			public abstract void Initialize(Span<uint8> data);
		}

		internal readonly Platform platform ~ delete _;

		public this(Span<uint8> data)
		{
			AssertInit();

			platform = Core.Audio.CreateAudioClip();
			platform.Initialize(data);
		}
	}
}
