using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class AudioClip
	{
		public this(Span<uint8> data)
		{
			Debug.Assert(Core.Audio != null, "Core needs to be initialized before creating platform dependent objects");

			Initialize(data);
		}

		protected internal extern void Initialize(Span<uint8> data);
	}
}
