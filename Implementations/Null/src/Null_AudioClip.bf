using System;

using internal Pile;

namespace Pile.Implementations
{
	class Null_AudioClip : AudioClip.Platform
	{
		[SkipCall]
		protected internal override void Initialize(Span<uint8> data) {}
	}
}
