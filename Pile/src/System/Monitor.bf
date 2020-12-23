using System;

namespace Pile
{
	public class Monitor
	{
		public extern bool IsPrimary { get; }

		public extern StringView Name { get; }

		public extern Rect Bounds { get; }

		public extern Vector2 ContentScale { get; }
	}
}
