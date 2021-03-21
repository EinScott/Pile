using System;

namespace Pile
{
	struct Keyboard
	{
		public const int MaxKeys = 400;

		internal bool[MaxKeys] pressed = .();
		internal bool[MaxKeys] down = .();
		internal bool[MaxKeys] released = .();
		internal int64[MaxKeys] timestamp = .();

		public readonly String Text = new String(8);

		internal this() {}

		internal void Dispose()
		{
			delete Text;
		}

		internal void Step() mut
		{
			for (int i = 0; i < MaxKeys; i++)
			{
				pressed[i] = false;
				released[i] = false;
			}

			Text.Clear();
		}

		internal void Copy(Keyboard from) mut
		{
			pressed = from.pressed;
			down = from.down;
			released = from.released;
			timestamp = from.timestamp;

			Text.Clear();
			Text.Append(from.Text);
		}

		[Inline]
		public bool Pressed(Keys key) => pressed[(int)key];

		[Inline]
		public bool Down(Keys key) => down[(int)key];

		[Inline]
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
		    return Repeated(key, Input.repeatDelay, Input.repeatInterval);
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

		[Inline] public bool Ctrl => Down(Keys.LeftControl, Keys.RightControl);
		[Inline] public bool Alt => Down(Keys.LeftAlt, Keys.RightAlt);
		[Inline] public bool Shift => Down(Keys.LeftShift, Keys.RightShift);
	}
}
