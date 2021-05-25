using System;

namespace Pile
{
	struct Mouse
	{
		public const int MaxButtons = MouseButtons.Count();

		internal bool[MaxButtons] pressed = .();
		internal bool[MaxButtons] down = .();
		internal bool[MaxButtons] released = .();
		internal int64[MaxButtons] timestamp = .();
		internal Vector2 wheelValue = .Zero;

		internal this() {}

		internal void Step() mut
		{
			for (int i = 0; i < MaxButtons; i++)
			{
				pressed[i] = false;
				released[i] = false;
			}

			wheelValue.X = 0;
			wheelValue.Y = 0;
		}

		internal void Copy(Mouse from) mut
		{
			pressed = from.pressed;
			down = from.down;
			released = from.released;
			timestamp = from.timestamp;

			wheelValue = from.wheelValue;
		}

		[Inline]
		public bool Pressed(MouseButtons button) => pressed[(int)button];
		[Inline]
		public bool Down(MouseButtons button) => down[(int)button];
		[Inline]
		public bool Released(MouseButtons button) => released[(int)button];

		public int64 Timestamp(MouseButtons button)
		{
		    return timestamp[(int)button];
		}

		public bool Repeated(MouseButtons button, float delay, float interval)
		{
		    if (Pressed(button))
		        return true;

			if (Down(button))
			{
			    var time = timestamp[(int)button] / (float) TimeSpan.TicksPerSecond;
	
			    return (Time.Duration.TotalSeconds - time) > delay && Time.OnInterval(interval, time);
			}

			return false;
		}

		[Inline] public bool LeftPressed => pressed[(int)MouseButtons.Left];
		[Inline] public bool LeftDown => down[(int)MouseButtons.Left];
		[Inline] public bool LeftReleased => released[(int)MouseButtons.Left];

		[Inline] public bool RightPressed => pressed[(int)MouseButtons.Right];
		[Inline] public bool RightDown => down[(int)MouseButtons.Right];
		[Inline] public bool RightReleased => released[(int)MouseButtons.Right];

		[Inline] public bool MiddlePressed => pressed[(int)MouseButtons.Middle];
		[Inline] public bool MiddleDown => down[(int)MouseButtons.Middle];
		[Inline] public bool MiddleReleased => released[(int)MouseButtons.Middle];

		[Inline] public Vector2 Wheel => wheelValue;
	}
}
