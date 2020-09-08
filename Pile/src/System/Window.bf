using System;

namespace Pile
{
	public abstract class Window : RenderTarget
	{
		public bool Closed { get; private set; }

		public ~this()
		{
			OnResized.Dispose();
			OnUserResized.Dispose();
			OnFocusChanged.Dispose();
			OnMoved.Dispose();
			OnVisibilityChanged.Dispose();
			OnClose.Dispose();
		}

		public abstract void SetTitle(String title);
		public abstract void GetTitle(String buffer);
		
		public abstract Point Position { get; set; }
		public abstract Point Size { get; set; }
		public abstract Vector ContentScale { get; }

		public abstract bool Resizable { get; set; }
		public abstract bool Transparent { get; set; }
		public abstract bool Bordered { get; set; }
		public abstract bool Fullscreen { get; set; }
		public abstract bool Visible { get; set; }
		public abstract bool VSync { get; set; }

		public abstract bool Focus { get; }
		public abstract bool MouseOver { get; }

		public abstract void Focus();

		public void Close()
		{
			Core.Exit();
			Closed = true;
			CloseInternal();
		}
		protected abstract void CloseInternal();

		public Event<Action> OnResized;
		public Event<Action> OnUserResized;
		public Event<Action> OnFocusChanged;
		public Event<Action> OnMoved;
		public Event<Action> OnVisibilityChanged;
		public Event<Action> OnClose;

		// Rendering
		private void Render()
		{
			Renderable = true;

			Core.[Friend]CallRender();

			Renderable = false;
		}

		protected abstract void Present();
	}
}
