using System;

namespace Pile
{
	public extension Input
	{
		[SkipCall]
		protected internal override void Initialize() {}

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
