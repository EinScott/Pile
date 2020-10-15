using System;

namespace Pile.Implementations
{
	public class Null_Window : Window
	{
		String title = new String() ~ delete _;

		public this(int32 width, int32 height)
		{
			Size = Point2(width, height);
			Visible = true;
		}

		public override Point2 RenderSize => Size;

		public override void SetTitle(StringView title)
		{
			this.title.Set(title);
		}

		public override void GetTitle(String buffer)
		{
			buffer.Append(title);
		}

		public override Point2 Position { get; set; }

		public override Point2 Size { get; set; }

		public override Vector2 ContentScale => .One;

		public override bool Resizable { get; set; }

		public override bool Transparent { get; set; }

		public override bool Bordered { get; set; }

		public override bool Fullscreen { get; set; }

		public override bool Visible { get; set; }

		public override bool VSync { get; set; }

		public override bool Focus => true;

		public override bool MouseOver => true;

		[SkipCall]
		public override void Focus() {}

		[SkipCall]
		protected override void CloseInternal() {}

		[SkipCall]
		internal override void Present() {}
	}
}
