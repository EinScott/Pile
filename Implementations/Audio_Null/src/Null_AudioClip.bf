using System;

using internal Pile;

namespace Pile
{
	extension AudioClip
	{
		[SkipCall]
		protected internal override void Initialize(Span<uint8> data) {}
	}
}
