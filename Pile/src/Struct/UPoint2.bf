using System;

namespace Pile
{
	[Ordered]
	public struct UPoint2 : IEquatable<UPoint2>, IEquatable
	{
		public static readonly UPoint2 UnitX = .(1, 0);
		public static readonly UPoint2 UnitY = .(0, 1);
		public static readonly UPoint2 Zero = .(0, 0);
		public static readonly UPoint2 One = .(1, 1);

		public uint X;
		public uint Y;

		public this()
		{
			this = default;
		}

		public this(uint both)
		{
			X = both;
			Y = both;
		}

		public this(uint x, uint y)
		{
			X = x;
			Y = y;
		}

		public void Set(uint x, uint y) mut
		{
			X = x;
			Y = y;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("UPoint [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static operator UPoint2((uint X, uint Y) tuple) => UPoint2(tuple.X, tuple.Y);
		public static operator Point2(UPoint2 a) => Point2((int)a.X, (int)a.Y);

		[Commutable]
		public static bool operator==(UPoint2 a, UPoint2 b) => a.X == b.X && a.Y == b.Y;

		public static UPoint2 operator+(UPoint2 a, UPoint2 b) => UPoint2(a.X + b.X, a.Y + b.Y);
		public static Point2 operator+(Point2 a, UPoint2 b) => Point2(a.X + (.)b.X, a.Y + (.)b.Y);
		public static UPoint2 operator-(UPoint2 a, UPoint2 b) => UPoint2(a.X - b.X, a.Y - b.Y);
		public static Point2 operator-(Point2 a, UPoint2 b) => Point2(a.X - (.)b.X, a.Y - (.)b.Y);

		public static UPoint2 operator*(UPoint2 a, uint b) => UPoint2(a.X * b, a.Y * b);
		public static UPoint2 operator/(UPoint2 a, uint b) => UPoint2(a.X / b, a.Y / b);

		public static Point2 operator*(UPoint2 a, int b) => Point2((int)a.X * b, (int)a.Y * b);
		public static Point2 operator/(UPoint2 a, int b) => Point2((int)a.X / b, (int)a.Y / b);

		public static Point2 operator-(UPoint2 a) => Point2(-(int)a.X, -(int)a.Y);

		public bool Equals(UPoint2 a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is UPoint2) && (UPoint2)o == this;
	}
}
