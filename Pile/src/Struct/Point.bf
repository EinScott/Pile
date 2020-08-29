using System;

namespace Pile
{
	public struct Point : IEquatable<Point>, IEquatable
	{
		public static readonly Point Right = .(1, 0);
		public static readonly Point Left = .(-1, 0);
		public static readonly Point Up = .(0, -1);
		public static readonly Point Down = .(0, 1);
		public static readonly Point UnitX = .(1, 0);
		public static readonly Point UnitY = .(0, 1);
		public static readonly Point Zero = .(0, 0);
		public static readonly Point One = .(1, 1);

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

		public static operator Point((int X, int Y) tuple) => Point(tuple.X, tuple.Y);
		public static explicit operator Point(Vector a) => Point((int)Math.Round(a.X), (int)Math.Round(a.Y));

		public static bool operator==(Point a, Point b) => a.X == b.X && a.Y == b.Y;

		public static Point operator+(Point a, Point b) => Point(a.X + b.X, a.Y + b.Y);
		public static Point operator-(Point a, Point b) => Point(a.X - b.X, a.Y - b.Y);

		public static Point operator*(Point a, int b) => Point(a.X * b, a.Y * b);
		public static Point operator/(Point a, int b) => Point(a.X / b, a.Y / b);

		public static Point operator-(Point a) => Point(-a.X, -a.Y);

		public bool Equals(Point a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Point) && (Point)o == this;
	}
}
