using System;

namespace Pile
{
	[Ordered]
	public struct Rect
	{
		public const Rect Zero = Rect();
		public const Rect SizeOne = Rect(0, 0, 1, 1);
		public const Rect PosOne = Rect(1, 1, 0, 0);

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

		public this(Point2 position, Point2 size)
		{
			X = position.X;
			Y = position.Y;
			Width = size.X;
			Height = size.Y;
		}

		public this(int x, int y, uint width, uint height)
		{
			X = x;
			Y = y;
			Width = (.)width;
			Height = (.)height;
		}

		public this(Point2 position, UPoint2 size)
		{
			X = position.X;
			Y = position.Y;
			Width = (.)size.X;
			Height = (.)size.Y;
		}

		public Point2 Position
		{
			get => .(X, Y);
			set mut
			{
				X = value.X;
				Y = value.Y;
			}
		}

		public Point2 Size
		{
			get => .(Width, Height);
			set mut
			{
				Width = value.X;
				Height = value.Y;
			}
		}

		public Point2 TopLeft
		{
		    get => Point2(Left, Top);
		    set mut
		    {
		        Left = value.X;
		        Top = value.Y;
		    }
		}

		public Point2 TopCenter
		{
		    get => Point2(CenterX, Top);
		    set mut
		    {
		        CenterX = value.X;
		        Top = value.Y;
		    }
		}

		public Point2 TopRight
		{
		    get => Point2(Right, Top);
		    set mut
		    {
		        Right = value.X;
		        Top = value.Y;
		    }
		}

		public Point2 CenterLeft
		{
		    get => Point2(Left, CenterY);
		    set mut
		    {
		        Left = value.X;
		        CenterY = value.Y;
		    }
		}

		public Point2 Center
		{
			[Inline]
		    get => Point2(CenterX, CenterY);

			[Inline]
		    set mut
		    {
		        CenterX = value.X;
		        CenterY = value.Y;
		    }
		}

		public Point2 CenterRight
		{
		    get => Point2(Right, CenterY);
		    set mut
		    {
		        Right = value.X;
		        CenterY = value.Y;
		    }
		}

		public Point2 BottomLeft
		{
		    get => Point2(Left, Bottom);
		    set mut
		    {
		        Left = value.X;
		        Bottom = value.Y;
		    }
		}

		public Point2 BottomCenter
		{
		    get => Point2(CenterX, Bottom);
		    set mut
		    {
		        CenterX = value.X;
		        Bottom = value.Y;
		    }
		}

		public Point2 BottomRight
		{
		    get => Point2(Right, Bottom);
		    set mut
		    {
		        Right = value.X;
		        Bottom = value.Y;
		    }
		}

		public int Left
		{
			get => X;
			set	mut => X = value;
		}

		public int Right
		{
			get => X + Width;
			set	mut => X = value - Width;
		}

		public int Top
		{
			get => Y;
			set mut => Y = value;
		}

		public int Bottom
		{
			get => Y + Height;
			set mut => Y = value - Height;
		}

		public int CenterX
		{
		    get => X + Width / 2;
		    set mut => X = value - Width / 2;
		}

		public int CenterY
		{
		    get => Y + Height / 2;
		    set mut => Y = value - Height / 2;
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

		public Rect Inflate(int left, int top, int right, int bottom)
		{
		    var rect = this;
		    rect.Left -= left;
		    rect.Top -= top;
		    rect.Right += right;
		    rect.Bottom += bottom;
		    rect.Width += left + right;
		    rect.Height += top + bottom;
		    return rect;
		}

		public bool Overlaps(Rect rect)
		{
			return (X + Width) > rect.X	&& (rect.X + rect.Width) > X && (Y + Height) > rect.Y && (rect.Y + rect.Height) > Y;
		}

		public bool Contains(Rect rect)
		{
		    return (Left < rect.Left && Top < rect.Top && Bottom > rect.Bottom && Right > rect.Right);
		}

		public bool Contains(Point2 point)
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
		    var overlapX = X + Width > against.X && X < against.X + against.Width;
			var overlapY = Y + Height > against.Y && Y < against.Y + against.Height;

			var r = Rect();

			if (overlapX)
			{
			    r.Left = Math.Max(Left, against.Left);
			    r.Width = Math.Min(Right, against.Right) - r.Left;
			}

			if (overlapY)
			{
			    r.Top = Math.Max(Top, against.Top);
			    r.Height = Math.Min(Bottom, against.Bottom) - r.Top;
			}

			return r;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("Rect [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(", ");
			Width.ToString(strBuffer);
			strBuffer.Append(", ");
			Height.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static Rect Between(Point2 a, Point2 b)
		{
		    Rect rect;

		    rect.X = a.X < b.X ? a.X : b.X;
		    rect.Y = a.Y < b.Y ? a.Y : b.Y;
		    rect.Width = (a.X > b.X ? a.X : b.X) - rect.X;
		    rect.Height = (a.Y > b.Y ? a.Y : b.Y) - rect.Y;

		    return rect;
		}

		[Commutable]
		public static bool operator==(Rect a, Rect b) => a.X == b.X && a.Y == b.Y && a.Width == b.Width && a.Height == b.Height;

		public static Rect operator+(Rect a, Point2 b) => Rect(a.X + b.X, a.Y + b.Y, a.Width, a.Height);
		public static Rect operator-(Rect a, Point2 b) => Rect(a.X - b.X, a.Y - b.Y, a.Width, a.Height);
	}
}
