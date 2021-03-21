using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class AudioClip
	{
		public this(Span<uint8> data)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");

			Initialize(data);
		}

		protected extern void Initialize(Span<uint8> data);
	}
}
