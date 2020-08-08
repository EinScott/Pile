using System;

namespace Pile
{
	public abstract class Window
	{
		public bool Closed { get; private set; }

		protected this()
		{
			OnCloseRequested.Add(new => Close); // Default to closing
		}

		public ~this()
		{
			OnResized.Dispose();
			OnFocusChanged.Dispose();
			OnMoved.Dispose();
			OnVisibilityChanged.Dispose();
			OnCloseRequested.Dispose();
		}

		public abstract void SetTitle(String title);
		public abstract void GetTitle(String buffer);
		
		public abstract Point Position { get; set; }
		public abstract Point Size { get; set; }

		public abstract bool Resizable { get; set; }
		public abstract bool Transparent { get; set; }
		public abstract bool Bordered { get; set; }
		public abstract bool Fullscreen { get; set; }
		public abstract bool Visible { get; set; }

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
		public Event<Action> OnFocusChanged;
		public Event<Action> OnMoved;
		public Event<Action> OnVisibilityChanged;
		public Event<Action> OnCloseRequested;
	}
}
