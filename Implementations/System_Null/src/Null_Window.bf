using System;

namespace Pile
{
	extension Window
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

		public override void* NativeHandle => null;

		Point2 pos;
		public override int X { get => pos.X; set => pos.X = value; }
		public override int Y { get => pos.Y; set => pos.Y = value; }
		public override Point2 Position { get => pos; set => pos = value; }

		UPoint2 size;
		UPoint2 minSize;
		public override uint Width { get => size.X; set => size.X = value; }
		public override uint Height { get => size.Y; set => size.Y = value; }
		public override UPoint2 Size { get => size; set => size = value; }
		public override UPoint2 MinSize { get => minSize; set => size = minSize; }

		public override Vector2 ContentScale => .One;

		public override bool Resizable { get; set; }

		public override bool Transparent { get; set; }

		public override bool Bordered { get; set; }

		public override bool Fullscreen { get; set; }

		public override bool Visible { get; set; }

		public override bool VSync { get; set; }

		public override bool Focus => true;

		public override bool MouseOver => true;

		public override Display Display => System.Displays[0];

		[SkipCall]
		public override void SetFocused() {}

		[SkipCall]
		protected override void CloseInternal() {}

		[SkipCall]
		protected internal override void Present() {}

		[SkipCall]
		protected internal override void Initialize(StringView name, uint32 width, uint32 height, WindowState state, bool hidden)
		{
			title.Set(name);
			Size = UPoint2(width, height);
			Visible = !hidden;
			VSync = true;
			Bordered = true;
		}
	}
}
