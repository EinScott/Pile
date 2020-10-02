using System;

namespace Pile
{
	[Ordered]
	public struct Point2 : IEquatable<Point2>, IEquatable
	{
		public static readonly Point2 Right = .(1, 0);
		public static readonly Point2 Left = .(-1, 0);
		public static readonly Point2 Up = .(0, -1);
		public static readonly Point2 Down = .(0, 1);

		public static readonly Point2 UnitX = .(1, 0);
		public static readonly Point2 UnitY = .(0, 1);
		public static readonly Point2 Zero = .(0, 0);
		public static readonly Point2 One = .(1, 1);

		public int X;
		public int Y;

		public this()
		{
			this = default;
		}

		public this(int x, int y)
		{
			X = x;
			Y = y;
		}

		public void Set(int x, int y) mut
		{
			X = x;
			Y = y;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("Point [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static operator Point2((int X, int Y) tuple) => Point2(tuple.X, tuple.Y);
		public static explicit operator Point2(Vector2 a) => Point2((int)Math.Round(a.X), (int)Math.Round(a.Y));

		public static bool operator==(Point2 a, Point2 b) => a.X == b.X && a.Y == b.Y;

		public static Point2 operator+(Point2 a, Point2 b) => Point2(a.X + b.X, a.Y + b.Y);
		public static Point2 operator-(Point2 a, Point2 b) => Point2(a.X - b.X, a.Y - b.Y);

		public static Point2 operator*(Point2 a, int b) => Point2(a.X * b, a.Y * b);
		public static Point2 operator/(Point2 a, int b) => Point2(a.X / b, a.Y / b);

		public static Point2 operator-(Point2 a) => Point2(-a.X, -a.Y);

		public bool Equals(Point2 a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Point2) && (Point2)o == this;
	}
}
