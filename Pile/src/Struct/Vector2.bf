using System;

namespace Pile
{
	[Packed]
	[Ordered]
	public struct Vector2 : IEquatable<Vector2>, IEquatable
	{
		public static readonly Vector2 Right = .(1, 0);
		public static readonly Vector2 Left = .(-1, 0);
		public static readonly Vector2 Up = .(0, -1);
		public static readonly Vector2 Down = .(0, 1);

		public static readonly Vector2 UnitX = .(1, 0);
		public static readonly Vector2 UnitY = .(0, 1);
		public static readonly Vector2 Zero = .(0, 0);
		public static readonly Vector2 One = .(1, 1);

		public float X;
		public float Y;

		public this()
		{
			this = default;
		}

		public this(float x, float y)
		{
			X = x;
			Y = y;
		}

		public void Set(float x, float y) mut
		{
			X = x;
			Y = y;
		}

		public float Length
		{
			[Inline]
			get
			{
				return Math.Sqrt(LengthSquared);
			}
		}

		public float LengthSquared
		{
			[Inline]
			get
			{
				return X * X + Y * Y;
			}
		}

		[Inline]
		public Point2 Round()
		{
			return Point2((int)Math.Round(X), (int)Math.Round(Y));
		}

		[Inline]
		public Vector2 Normalized()
		{
			return this / Length;
		}

		public static Vector2 Lerp(Vector2 a, Vector2 b, float t)
		{
			if (t == 0)
				return a;
			else if (t == 1)
				return b;
			else
				return a + (b - a) * t;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("Vector [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static operator Vector2((float X, float Y) tuple) => Vector2(tuple.X, tuple.Y);
		public static operator Vector2(Point2 a) => Vector2(a.X, a.Y);

		public static bool operator==(Vector2 a, Vector2 b) => a.X == b.X && a.Y == b.Y;

		public static Vector2 operator+(Vector2 a, Vector2 b) => Vector2(a.X + b.X, a.Y + b.Y);
		public static Vector2 operator-(Vector2 a, Vector2 b) => Vector2(a.X - b.X, a.Y - b.Y);

		public static Vector2 operator*(Vector2 a, float b) => Vector2(a.X * b, a.Y * b);
		public static Vector2 operator/(Vector2 a, float b) => Vector2(a.X / b, a.Y / b);

		public static Vector2 operator-(Vector2 a) => Vector2(-a.X, -a.Y);

		public bool Equals(Vector2 a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Vector2) && (Vector2)o == this;
	}
}
