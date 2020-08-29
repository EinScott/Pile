using System;

namespace Pile
{
	public struct Rect : IOpEquals
	{
		public static Rect Zero = Rect();

		public int X;
		public int Y;
		public int Width;
		public int Height;

		public this()
		{
			this = default;
		}

		public this(int x, int y, int width, int height)
		{
			X = x;
			Y = y;
			Width = width;
			Height = height;
		}

		public int Left
		{
			[Inline]
			get
			{
				return X;
			}

			[Inline]
			set	mut
			{
				X = value;
			}
		}

		public int Right
		{
			[Inline]
			get
			{
				return X + Width;
			}

			[Inline]
			set	mut
			{
				X = value - Width;
			}
		}

		public int Top
		{
			[Inline]
			get
			{
				return Y;
			}

			[Inline]
			set mut
			{
				Y = value;
			}
		}

		public int Bottom
		{
			[Inline]
			get
			{
				return Y + Height;
			}

			[Inline]
			set mut
			{
				Y = value - Height;
			}
		}

		public Rect MirrorX(int axis = 0)
		{
			var rect = this;
			rect.X = axis - X - Width;
			return rect;
		}

		public Rect MirrorY(int axis = 0)
		{
			var rect = this;
			rect.Y = axis - Y - Height;
			return rect;
		}

		public Rect Inflate(int amount)
		{
			return Rect(X - amount, Y - amount, Width + amount * 2, Height + amount * 2);
		}

		public bool Overlaps(Rect rect)
		{
			return (X + Width) > rect.X	&& (rect.X + rect.Width) > X && (Y + Height) > rect.Y && (rect.Y + rect.Height) > Y;
		}

		public bool Contains(Rect rect)
		{
		    return (Left < rect.Left && Top < rect.Top && Bottom > rect.Bottom && Right > rect.Right);
		}

		public bool Contains(Point point)
		{
			return point.X >= X && point.X < X + Width && point.Y >= Y && point.Y < Y + Height;
		}

		public Rect CropTo(Rect other)
		{
			Rect r = this;
		    if (r.Left < other.Left)
		        r.Left = other.Left;
		    if (r.Top < other.Top)
		        r.Top = other.Top;
		    if (r.Right > other.Right)
		        r.Right = other.Right;
		    if (r.Bottom > other.Bottom)
		        r.Bottom = other.Bottom;

		    return r;
		}

		public Rect Scale(float scale)
		{
		    return Rect((int)(X * scale), (int)(Y * scale), (int)(Width * scale), (int)(Height * scale));
		}

		public Rect MultiplyX(int scale)
		{
		    var r = Rect(X * scale, Y, Width * scale, Height);

		    if (r.Width < 0)
		    {
		        r.X += r.Width;
		        r.Width *= -1;
		    }

		    return r;
		}

		public Rect MultiplyY(int scale)
		{
		    var r = Rect(X, Y * scale, Width, Height * scale);

		    if (r.Height < 0)
		    {
		        r.Y += r.Height;
		        r.Height *= -1;
		    }

		    return r;
		}

		public Rect OverlapRect(Rect against)
		{
		    if (Overlaps(against))
		    {
		        return Rect()
		        {
		            Left = Math.Max(Left, against.Left),
		            Top = Math.Max(Top, against.Top),
		            Right = Math.Min(Right, against.Right),
		            Bottom = Math.Min(Bottom, against.Bottom)
		        };
		    }

		    return Rect(0, 0, 0, 0);
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("Rect [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(", ");
			Width.ToString(strBuffer);
			strBuffer.Append(", ");
			Height.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static Rect Between(Point a, Point b)
		{
		    Rect rect;

		    rect.X = a.X < b.X ? a.X : b.X;
		    rect.Y = a.Y < b.Y ? a.Y : b.Y;
		    rect.Width = (a.X > b.X ? a.X : b.X) - rect.X;
		    rect.Height = (a.Y > b.Y ? a.Y : b.Y) - rect.Y;

		    return rect;
		}

		public static bool operator==(Rect a, Rect b) => a.X == b.X && a.Y == b.Y && a.Width == b.Width && a.Height == b.Height;

		public static Rect operator+(Rect a, Point b) => Rect(a.X + b.X, a.Y + b.Y, a.Width, a.Height);
		public static Rect operator-(Rect a, Point b) => Rect(a.X - b.X, a.Y - b.Y, a.Width, a.Height);
	}
}
