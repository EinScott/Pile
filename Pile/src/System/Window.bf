using System;

using internal Pile;

namespace Pile
{
	class Window : RenderTarget
	{
		public bool Closed { [Inline]get; internal set; }

		internal this(StringView name, uint32 width, uint32 height, WindowState state, bool hidden = false)
		{
			Initialize(name, width, height, state, hidden);
		}

		protected internal extern void Initialize(StringView name, uint32 width, uint32 height, WindowState state, bool hidden);

		internal ~this()
		{
			OnResized.Dispose();
			OnUserResized.Dispose();
			OnFocusChanged.Dispose();
			OnMoved.Dispose();
			OnVisibilityChanged.Dispose();
			OnClose.Dispose();
		}

		public extern void* NativeHandle { get; };

		public override extern UPoint2 RenderSize { get; }

		public extern void SetTitle(StringView title);
		public extern void GetTitle(String buffer);

		public extern Result<void> SetIcon(Bitmap bitmap);

		public extern int X { get; set; }
		public extern int Y { get; set; }
		public extern Point2 Position { get; set; }
		public extern uint Width { get; set; }
		public extern uint Height { get; set; }
		public extern UPoint2 Size { get; set; }
		public extern UPoint2 MinSize { get; set; }
		public extern Vector2 ContentScale { get; }

		public extern bool Resizable { get; set; }
		public extern bool Transparent { get; set; }
		public extern bool Bordered { get; set; }
		public extern bool Fullscreen { get; set; }
		public extern bool Visible { get; set; }
		public extern bool VSync { get; set; }
		public extern bool AlwaysOnTop { get; set; }

		public extern bool Focus { get; }
		public extern bool MouseOver { get; }
		
		public extern Display Display { get; }

		public extern void SetFocused();
		public extern void FlashWindow(WindowFlash flash);

		public void Close()
		{
			Core.Exit();
			Closed = true;
			CloseInternal();
		}
		protected extern void CloseInternal();

		public Event<Action> OnResized;
		public Event<Action> OnUserResized;
		public Event<Action> OnFocusChanged;
		public Event<Action> OnMoved;
		public Event<Action> OnVisibilityChanged;
		public Event<Action> OnClose;

		// Rendering
		internal void Render()
		{
			renderable = true;

			Core.WindowRender();

			renderable = false;
		}

		protected internal extern void Present();
	}
}
