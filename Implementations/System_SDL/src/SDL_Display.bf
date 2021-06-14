using System;
using SDL2;

namespace Pile
{
	extension Display
	{
		readonly int32 index;

		String name ~ delete _;
		Rect bounds;
		Vector2 contentScale;

		internal this(int32 index) : [NoExtension]this()
		{
			this.index = index;

			name = new String(SDL.GetDisplayName(index));

			SDL.GetDisplayBounds(index, let rect);
			bounds = Rect(rect.x, rect.y, rect.w, rect.h);

			float hidpiRes
#if BF_PLATFORM_WINDOWS
				= 96f;
#else
				= 72f;
#endif

			SDL.GetDisplayDPI(index, let ddpi, ?, ?);
			contentScale = .One * (ddpi / hidpiRes);
		}

		public override bool IsPrimary => index == 0;

		public override StringView Name => name;

		public override Rect Bounds => bounds;

		public override Vector2 ContentScale => contentScale;
	}
}
