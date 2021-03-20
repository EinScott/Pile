using System;

namespace Pile
{
	class Monitor
	{
		internal this() {}
		internal ~this() {}

		public extern bool IsPrimary { get; }

		public extern StringView Name { get; }

		public extern Rect Bounds { get; }

		public extern Vector2 ContentScale { get; }
	}
}
