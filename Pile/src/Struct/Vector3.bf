using System;

namespace Pile
{
	[Ordered]
	public struct Vector3 : IEquatable<Vector3>, IEquatable
	{
		public static readonly Vector3 UnitX = .(1, 0, 0);
		public static readonly Vector3 UnitY = .(0, 1, 0);
		public static readonly Vector3 UnitZ = .(0, 0, 1);
		public static readonly Vector3 Zero = .(0, 0, 0);
		public static readonly Vector3 One = .(1, 1, 1);

		public static readonly Vector3 NegateX = .(-1, 1, 1);
		public static readonly Vector3 NegateY = .(1, -1, 1);
		public static readonly Vector3 NegateZ = .(1, 1, -1);

		public float X;
		public float Y;
		public float Z;

		public this()
		{
			this = default;
		}

		public this(float all)
		{
			X = all;
			Y = all;
			Z = all;
		}

		public this(float x, float y, float z)
		{
			X = x;
			Y = y;
			Z = z;
		}

		public void Set(float x, float y, float z) mut
		{
			X = x;
			Y = y;
			Z = z;
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
				return X * X + Y * Y + Z * Z;
			}
		}

		[Inline]
		public Point3 Round()
		{
			return Point3((int)Math.Round(X), (int)Math.Round(Y), (int)Math.Round(Z));
		}

		[Inline]
		public Vector3 Normalized()
		{
			return this == .Zero ? .Zero : this / Length;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("Vector [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static Vector3 Lerp(Vector3 a, Vector3 b, float t)
		{
			if (t == 0)
				return a;
			else if (t == 1)
				return b;
			else
				return a + (b - a) * t;
		}

		public static Vector3 Approach(Vector3 from, Vector3 target, float amount)
		{
		    if (from == target)
		        return target;
		    else
		    {
		        var diff = target - from;
		        if (diff.Length <= amount * amount)
		            return target;
		        else
		            return from + diff.Normalized() * amount;
		    }
		}

		public static operator Vector3((float X, float Y, float Z) tuple) => Vector3(tuple.X, tuple.Y, tuple.Z);
		public static operator Vector3(Point3 a) => Vector3(a.X, a.Y, a.Z);

		public static bool operator==(Vector3 a, Vector3 b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z;

		public static Vector3 operator+(Vector3 a, Vector3 b) => Vector3(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
		public static Vector3 operator-(Vector3 a, Vector3 b) => Vector3(a.X - b.X, a.Y - b.Y, a.Z - b.Z);

		public static Vector3 operator*(Vector3 a, float b) => Vector3(a.X * b, a.Y * b, a.Z * b);
		public static Vector3 operator*(Vector3 a, double b) => Vector3((.)(a.X * b), (.)(a.Y * b), (.)(a.Z * b));
		public static Vector3 operator/(Vector3 a, float b) => Vector3(a.X / b, a.Y / b, a.Z / b);
		public static Vector3 operator/(Vector3 a, double b) => Vector3((.)(a.X / b), (.)(a.Y / b), (.)(a.Z / b));

		public static Vector3 operator-(Vector3 a) => Vector3(-a.X, -a.Y, -a.Z);

		public bool Equals(Vector3 a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Vector3) && (Vector3)o == this;
	}
}
