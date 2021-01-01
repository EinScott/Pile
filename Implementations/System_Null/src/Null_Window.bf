using System;

namespace Pile
{
	public extension Window
	{
		String title = new String() ~ delete _;

		public override UPoint2 RenderSize => Size;

		public override void SetTitle(StringView title)
		{
			this.title.Set(title);
		}

		public override void GetTitle(String buffer)
		{
			buffer.Append(title);
		}

		[SkipCall]
		public override System.Result<void> SetIcon(Pile.Bitmap bitmap) => .Ok;

		Point2 pos;
		public override int X { get => pos.X; set => pos.X = value; }
		public override int Y { get => pos.Y; set => pos.Y = value; }
		public override Point2 Position { get => pos; set => pos = value; }

		UPoint2 size;
		public override uint Width { get => size.X; set => size.X = value; }
		public override uint Height { get => size.Y; set => size.Y = value; }
		public override UPoint2 Size { get => size; set => size = value; }

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
		protected internal override void Present() {}

		[SkipCall]
		protected internal override void Initialize(StringView name, uint32 width, uint32 height)
		{
			title.Set(name);
			Size = UPoint2(width, height);
			Visible = true;
		}
	}
}
