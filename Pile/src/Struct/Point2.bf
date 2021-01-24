using System;

namespace Pile
{
	[Ordered]
	public struct Point2 : IFormattable, IEquatable<Point2>, IEquatable
	{
		public const Point2 Zero = .(0, 0);
		public const Point2 One = .(1, 1);
		public const Point2 UnitX = .(1, 0);
		public const Point2 UnitY = .(0, 1);

		public const Point2 NegateX = .(-1, 1);
		public const Point2 NegateY = .(1, -1);

		public int X, Y;

		[Inline]
		/// Returns the length of the vector.
		public float Length => (float)Math.Sqrt((double)X * X + Y * Y);

		[Inline]
		/// Returns the length of the vector squared. This operation is cheaper than Length.
		public float LengthSquared => X * X + Y * Y;

		public this()
		{
			this = default;
		}

		public this(int both)
		{
			X = both;
			Y = both;
		}

		public this(int x, int y)
		{
			X = x;
			Y = y;
		}

		[Inline]
		public bool Equals(Object o) => (o is Point2) && (Point2)o == this;

		[Inline]
		public bool Equals(Point2 o) => o == this;

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("[ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		
		public void ToString(String outString, String format, IFormatProvider formatProvider)
		{
			outString.Append("[ ");
			X.ToString(outString, format, formatProvider);
			outString.Append(", ");
			Y.ToString(outString, format, formatProvider);
			outString.Append(" ]");
		}

		[Inline]
		/// Returns the Euclidean distance between the two given vectors.
		public static float Distance(Point2 value1, Point2 value2)
		{
		    let difference = value1 - value2;
			let ls = difference.LengthSquared;
			return Math.Sqrt(ls);
		}

		[Inline]
		/// Returns the Euclidean distance squared between the two given vectors.
		public static float DistanceSquared(Point2 value1, Point2 value2)
		{
		    let difference = value1 - value2;
			return difference.LengthSquared;
		}

		[Inline]
		/// Returns the reflection of a vector off a surface that has the specified normal.
		public static Point2 Reflect(Point2 point, Point2 normal)
		{
			return point - (normal * 2 * Point2.Dot(point, normal));
		}

		/// Restricts a vector between a min and max value.
		public static Point2 Clamp(Point2 value1, Point2 min, Point2 max)
		{
		    var x = value1.X;
		    x = (x > max.X) ? max.X : x;
		    x = (x < min.X) ? min.X : x;

		    var y = value1.Y;
		    y = (y > max.Y) ? max.Y : y;
		    y = (y < min.Y) ? min.Y : y;

		    return Point2(x, y);
		}

		[Inline]
		/// Returns the dot product of two vectors.
		public static int Dot(Point2 val1, Point2 val2)
		{
			return val1.X * val2.X + val1.Y * val2.Y;
		}

		[Inline]
		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Point2 Min(Point2 value1, Point2 value2)
		{
		    return Point2(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Point2 Max(Point2 value1, Point2 value2)
		{
		    return Point2(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y);
		}

		[Inline]
		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		public static Point2 Abs(Point2 value)
		{
		    return Point2(Math.Abs(value.X), Math.Abs(value.Y));
		}

		public static operator Point2((int X, int Y) tuple) => Point2(tuple.X, tuple.Y);
		public static operator Point2(UPoint2 a) => Point2((int)a.X, (int)a.Y);

		public static explicit operator Point2(Vector2 a) => a.Round();

		[Commutable]
		public static bool operator==(Point2 a, Point2 b) => a.X == b.X && a.Y == b.Y;

		public static Point2 operator+(Point2 a, Point2 b) => Point2(a.X + b.X, a.Y + b.Y);
		public static Point2 operator-(Point2 a, Point2 b) => Point2(a.X - b.X, a.Y - b.Y);

		public static Point2 operator*(Point2 a, int b) => Point2(a.X * b, a.Y * b);
		public static Point2 operator*(int b, Point2 a) => Point2(a.X * b, a.Y * b);
		public static Point2 operator/(Point2 a, int b) => Point2(a.X / b, a.Y / b);

		public static Point2 operator*(Point2 a, uint b) => Point2(a.X * (.)b, a.Y * (.)b);
		public static Point2 operator*(uint b, Point2 a) => Point2(a.X * (.)b, a.Y * (.)b);
		public static Point2 operator/(Point2 a, uint b) => Point2(a.X / (.)b, a.Y / (.)b);

		public static Point2 operator*(Point2 a, Point2 b) => Point2(a.X * b.X, a.Y * b.Y);
		public static Point2 operator/(Point2 a, Point2 b) => Point2(a.X / b.X, a.Y / b.Y);

		public static Point2 operator-(Point2 a) => Point2(-a.X, -a.Y);
	}
}
