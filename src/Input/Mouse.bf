using System;

namespace Pile
{
	public class Mouse
	{
		public const int MaxButtons = 6;

		readonly bool[] pressed = new bool[MaxButtons] ~ delete _;
		readonly bool[] down = new bool[MaxButtons] ~ delete _;
		readonly bool[] released = new bool[MaxButtons] ~ delete _;
		readonly int64[] timestamp = new int64[MaxButtons] ~ delete _;
		Vector wheelValue;

		void Step()
		{
			for (int i = 0; i < MaxButtons; i++)
			{
				pressed[i] = false;
				released[i] = false; // for some reason this doesnt reset it
			}

			wheelValue.X = 0;
			wheelValue.Y = 0;
		}

		void Copy(Mouse from)
		{
			from.pressed.CopyTo(pressed);
			from.down.CopyTo(down);
			from.released.CopyTo(released);
			from.timestamp.CopyTo(timestamp);

			wheelValue = from.wheelValue;
		}

		public bool Pressed(MouseButtons button) => pressed[(int)button];
		public bool Down(MouseButtons button) => down[(int)button];
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

		public bool LeftPressed => pressed[(int)MouseButtons.Left];
		public bool LeftDown => down[(int)MouseButtons.Left];
		public bool LeftReleased => released[(int)MouseButtons.Left];

		public bool RightPressed => pressed[(int)MouseButtons.Right];
		public bool RightDown => down[(int)MouseButtons.Right];
		public bool RightReleased => released[(int)MouseButtons.Right];

		public bool MiddlePressed => pressed[(int)MouseButtons.Middle];
		public bool MiddleDown => down[(int)MouseButtons.Middle];
		public bool MiddleReleased => released[(int)MouseButtons.Middle];

		public Vector Wheel => wheelValue;
	}
}
