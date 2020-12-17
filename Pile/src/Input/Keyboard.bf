using System;

namespace Pile
{
	public struct Keyboard
	{
		public const int MaxKeys = 400;

		readonly Input input;

		internal readonly bool[] pressed = new bool[MaxKeys];
		internal readonly bool[] down = new bool[MaxKeys];
		internal readonly bool[] released = new bool[MaxKeys];
		internal readonly int64[] timestamp = new int64[MaxKeys];

		public readonly String Text = new String();

		internal this(Input input)
		{
			this.input = input;
		}

		internal void Dispose()
		{
			delete pressed;
			delete down;
			delete released;
			delete timestamp;
			delete Text;
		}

		internal void Step()
		{
			for (int i = 0; i < MaxKeys; i++)
			{
				pressed[i] = false;
				released[i] = false;
			}

			Text.Clear();
		}

		internal void Copy(Keyboard from)
		{
			from.pressed.CopyTo(pressed);
			from.down.CopyTo(down);
			from.released.CopyTo(released);
			from.timestamp.CopyTo(timestamp);

			Text.Clear();
			Text.Append(from.Text);
		}

		public bool Pressed(Keys key) => pressed[(int)key];

		public bool Down(Keys key) => down[(int)key];

		public bool Released(Keys key) => released[(int)key];

		public bool Pressed(params Keys[] keys)
		{
		    for (int i = 0; i < keys.Count; i++)
		        if (pressed[(int)keys[i]])
		            return true;

		    return false;
		}

		public bool Down(params Keys[] keys)
		{
		    for (int i = 0; i < keys.Count; i++)
		        if (down[(int)keys[i]])
		            return true;

		    return false;
		}

		public bool Released(params Keys[] keys)
		{
		    for (int i = 0; i < keys.Count; i++)
		        if (released[(int)keys[i]])
		            return true;

		    return false;
		}

		public bool Repeated(Keys key)
		{
		    return Repeated(key, input.repeatDelay, input.repeatInterval);
		}

		public bool Repeated(Keys key, float delay, float interval)
		{
		    if (Pressed(key))
		        return true;

			if (Down(key))
			{
			    var time = timestamp[(int)key] / (float) TimeSpan.TicksPerSecond;
	
			    return (Time.Duration.TotalSeconds - time) > delay && Time.OnInterval(interval, time);
			}

			return false;
		}

		public int64 Timestamp(Keys key)
		{
		    return timestamp[(int)key];
		}

		public bool Ctrl => Down(Keys.LeftControl, Keys.RightControl);
		public bool Alt => Down(Keys.LeftAlt, Keys.RightAlt);
		public bool Shift => Down(Keys.LeftShift, Keys.RightShift);
	}
}
