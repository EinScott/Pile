using System;

namespace Pile
{
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

		public static readonly Vector2 NegateX = .(-1, 1);
		public static readonly Vector2 NegateY = .(1, -1);

		public float X;
		public float Y;

		public this()
		{
			this = default;
		}

		public this(float both)
		{
			X = both;
			Y = both;
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
			return this == .Zero ? .Zero : this / Length;
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

		public static float Dot(Vector2 val1, Vector2 val2)
		{
			return val1.X * val2.X + val1.Y * val2.Y;
		}

		public static float Angle(Vector2 vec)
		{
		    return Math.Atan2(vec.Y, vec.X);
		}

		public static float Angle(Vector2 from, Vector2 to)
		{
		    return Math.Atan2(to.Y - from.Y, to.X - from.X);
		}

		public static Vector2 AngleToVector(float angle, float length = 1)
		{
		    return Vector2(Math.Cos(angle) * length, Math.Sin(angle) * length);
		}

		public static Vector2 Approach(Vector2 from, Vector2 target, float amount)
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

		public static Vector2 Max(Vector2 value1, Vector2 value2)
		{
		    return Vector2(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y);
		}

		public static Vector2 Min(Vector2 value1, Vector2 value2)
		{
		    return Vector2(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y);
		}

		public static float Distance(Vector2 value1, Vector2 value2)
		{
		    Vector2 difference = value1 - value2;
			float ls = difference.LengthSquared;
			return Math.Sqrt(ls);
		}

		public static float DistanceSquared(Vector2 value1, Vector2 value2)
		{
		    Vector2 difference = value1 - value2;
			return difference.LengthSquared;
		}

		public static Vector2 Transform(Vector2 position, Matrix3x2 matrix)
		{
		    return Vector2(
		        position.X * matrix.m11 + position.Y * matrix.m21 + matrix.m31,
		        position.X * matrix.m12 + position.Y * matrix.m22 + matrix.m32);
		}

		public static Vector2 Transform(Vector2 position, Matrix4x4 matrix)
		{
		    return Vector2(
		        position.X * matrix.m11 + position.Y * matrix.m21 + matrix.m41,
		        position.X * matrix.m12 + position.Y * matrix.m22 + matrix.m42);
		}

		public static bool InsideTriangle(Vector2 a, Vector2 b, Vector2 c, Vector2 point)
		{
		    let p0 = c - b;
		    let p1 = a - c;
		    let p2 = b - a;

		    let ap = point - a;
		    let bp = point - b;
		    let cp = point - c;

		    return (p0.X * bp.Y - p0.Y * bp.X >= 0.0f) &&
		           (p2.X * ap.Y - p2.Y * ap.X >= 0.0f) &&
		           (p1.X * cp.Y - p1.Y * cp.X >= 0.0f);
		}

		public static operator Vector2((float X, float Y) tuple) => Vector2(tuple.X, tuple.Y);
		public static operator Vector2(Point2 a) => Vector2(a.X, a.Y);
		public static operator Vector2(UPoint2 a) => Vector2(a.X, a.Y);

		[Commutable]
		public static bool operator==(Vector2 a, Vector2 b) => a.X == b.X && a.Y == b.Y;

		public static Vector2 operator+(Vector2 a, Vector2 b) => Vector2(a.X + b.X, a.Y + b.Y);
		public static Vector2 operator-(Vector2 a, Vector2 b) => Vector2(a.X - b.X, a.Y - b.Y);

		public static Vector2 operator*(Vector2 a, float b) => Vector2(a.X * b, a.Y * b);
		public static Vector2 operator*(Vector2 a, double b) => Vector2((.)(a.X * b), (.)(a.Y * b));
		public static Vector2 operator/(Vector2 a, float b) => Vector2(a.X / b, a.Y / b);
		public static Vector2 operator/(Vector2 a, double b) => Vector2((.)(a.X / b), (.)(a.Y / b));

		public static Vector2 operator*(Vector2 a, Vector2 b) => Vector2(a.X * b.X, a.Y * b.Y);
		public static Vector2 operator/(Vector2 a, Vector2 b) => Vector2(a.X / b.X, a.Y / b.Y);

		public static Vector2 operator-(Vector2 a) => Vector2(-a.X, -a.Y);

		public bool Equals(Vector2 a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Vector2) && (Vector2)o == this;
	}
}
