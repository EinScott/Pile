using System;

namespace Pile
{
	struct Keyboard
	{
		public const int MaxKeys = Keys.Count();

		internal ButtonState[MaxKeys] state = default;
		internal int64[MaxKeys] timestamp = default;

		/// This is an UTF8 string of what was actually typed and will depend on the keyboard layout (while individual key presses may be matched by ScanCode depending on config!)
		public readonly String Text = new String(8);

		internal this() {}

		internal void Dispose()
		{
			delete Text;
		}

		internal void Step() mut
		{
			for (int i = 0; i < MaxKeys; i++)
				state[i] &= ~(.Pressed|.Released);

			Text.Clear();
		}

		internal void Copy(Keyboard from) mut
		{
			state = from.state;
			timestamp = from.timestamp;

			Text.Clear();
			Text.Append(from.Text);
		}

		[Inline]
		public void ConsumeKey(Keys key) mut
		{
			state[(int)key] = .Up;
			timestamp[(int)key] = 0;
		}

		[Inline]
		public void ConsumeAll() mut
		{
			state = default;
			timestamp = default;
		}

		[Inline]
		public bool Pressed(Keys key) => (state[(int)key] & .Pressed) != 0;

		[Inline]
		public bool Down(Keys key) => (state[(int)key] & .Down) != 0;

		[Inline]
		public bool Released(Keys key) => (state[(int)key] & .Released) != 0;

		public bool AnyPressed(params Keys[] keys)
		{
		    for (int i = 0; i < keys.Count; i++)
		        if ((state[(int)keys[[Unchecked]i]] & .Pressed) != 0)
		            return true;

		    return false;
		}

		public bool AnyDown(params Keys[] keys)
		{
		    for (int i = 0; i < keys.Count; i++)
		        if ((state[(int)keys[[Unchecked]i]] & .Down) != 0)
		            return true;

		    return false;
		}

		public bool AnyReleased(params Keys[] keys)
		{
		    for (int i = 0; i < keys.Count; i++)
		        if ((state[(int)keys[[Unchecked]i]] & .Released) != 0)
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

		[Inline]
		public int64 Timestamp(Keys key) => timestamp[(int)key];

		[Inline] public bool Ctrl => AnyDown(Keys.LeftControl, Keys.RightControl);
		[Inline] public bool Alt => AnyDown(Keys.LeftAlt, Keys.RightAlt);
		[Inline] public bool Shift => AnyDown(Keys.LeftShift, Keys.RightShift);
	}
}
