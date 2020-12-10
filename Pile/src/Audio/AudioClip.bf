using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class AudioClip
	{
		protected internal abstract class Platform
		{
			protected internal abstract void Initialize(Span<uint8> data);
		}

		internal readonly Platform platform ~ delete _;

		public this(Span<uint8> data)
		{
			Debug.Assert(Core.Audio != null, "Core needs to be initialized before creating platform dependant objects");

			platform = Core.Audio.CreateAudioClip();
			platform.Initialize(data);
		}
	}
}
