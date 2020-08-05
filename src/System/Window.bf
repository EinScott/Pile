using System;

namespace Pile
{
	public abstract class Window
	{
		public ~this()
		{
			OnResized.Dispose();
			OnFocusChanged.Dispose();
			OnMoved.Dispose();
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

		public Event<Action> OnResized;
		public Event<Action> OnFocusChanged;
		public Event<Action> OnMoved;
		public Event<Action> OnVisibilityChanged;

		//SetIcon?
	}
}
