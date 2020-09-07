using System;

namespace Pile
{
	[Packed]
	[Ordered]
	public struct Vector : IEquatable<Vector>, IEquatable
	{
		public static readonly Vector Right = .(1, 0);
		public static readonly Vector Left = .(-1, 0);
		public static readonly Vector Up = .(0, -1);
		public static readonly Vector Down = .(0, 1);
		public static readonly Vector UnitX = .(1, 0);
		public static readonly Vector UnitY = .(0, 1);
		public static readonly Vector Zero = .(0, 0);
		public static readonly Vector One = .(1, 1);

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
		public Point Round()
		{
			return Point((int)Math.Round(X), (int)Math.Round(Y));
		}

		[Inline]
		public Vector Normalized()
		{
			return this / Length;
		}

		public static Vector Lerp(Vector a, Vector b, float t)
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

		public static operator Vector((float X, float Y) tuple) => Vector(tuple.X, tuple.Y);
		public static operator Vector(Point a) => Vector(a.X, a.Y);

		public static bool operator==(Vector a, Vector b) => a.X == b.X && a.Y == b.Y;

		public static Vector operator+(Vector a, Vector b) => Vector(a.X + b.X, a.Y + b.Y);
		public static Vector operator-(Vector a, Vector b) => Vector(a.X - b.X, a.Y - b.Y);

		public static Vector operator*(Vector a, float b) => Vector(a.X * b, a.Y * b);
		public static Vector operator/(Vector a, float b) => Vector(a.X / b, a.Y / b);

		public static Vector operator-(Vector a) => Vector(-a.X, -a.Y);

		public bool Equals(Vector a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Vector) && (Vector)o == this;
	}
}
