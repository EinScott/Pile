using System;

namespace Pile
{
	extension Display
	{
		public override Pile.Rect Bounds => .(0, 0, 1920, 1080);

		public override Pile.Vector2 ContentScale => .One;

		public override bool IsPrimary => true;

		public override System.StringView Name => String.Empty;
	}
}
