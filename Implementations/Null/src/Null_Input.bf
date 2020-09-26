using System;

namespace Pile.Implementations
{
	public class Null_Input : Input
	{
		[SkipCall]
		public override void SetMouseCursor(Cursors cursor) {}

		[SkipCall]
		public override void SetClipboardString(System.String value) {}

		[SkipCall]
		public override void GetClipboardString(System.String buffer) {}

		public override Point2 MousePosition
		{
			get => .Zero;

			[SkipCall]
			set {}
		}
	}
}
