using System;

namespace Pile
{
	[Ordered]
	struct UPoint2 : IFormattable, IEquatable<UPoint2>, IEquatable
	{
		public const UPoint2 Zero = .(0, 0);
		public const UPoint2 One = .(1, 1);
		public const UPoint2 UnitX = .(1, 0);
		public const UPoint2 UnitY = .(0, 1);

		public uint X, Y;

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

		[Inline]
		public bool Equals(Object o) => (o is UPoint2) && (UPoint2)o == this;

		[Inline]
		public bool Equals(UPoint2 o) => o == this;

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
		public static float Distance(UPoint2 value1, UPoint2 value2)
		{
		    let difference = value1 - value2;
			let ls = difference.LengthSquared;
			return Math.Sqrt(ls);
		}

		[Inline]
		/// Returns the Euclidean distance squared between the two given vectors.
		public static float DistanceSquared(UPoint2 value1, UPoint2 value2)
		{
		    let difference = value1 - value2;
			return difference.LengthSquared;
		}

		/// Restricts a vector between a min and max value.
		public static UPoint2 Clamp(UPoint2 value1, UPoint2 min, UPoint2 max)
		{
		    var x = value1.X;
		    x = (x > max.X) ? max.X : x;
		    x = (x < min.X) ? min.X : x;

		    var y = value1.Y;
		    y = (y > max.Y) ? max.Y : y;
		    y = (y < min.Y) ? min.Y : y;

		    return UPoint2(x, y);
		}

		[Inline]
		/// Returns the dot product of two vectors.
		public static uint Dot(UPoint2 val1, UPoint2 val2)
		{
			return val1.X * val2.X + val1.Y * val2.Y;
		}

		[Inline]
		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static UPoint2 Min(UPoint2 value1, UPoint2 value2)
		{
		    return UPoint2(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static UPoint2 Max(UPoint2 value1, UPoint2 value2)
		{
		    return UPoint2(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y);
		}

		public static operator UPoint2((uint X, uint Y) tuple) => UPoint2(tuple.X, tuple.Y);

		public static explicit operator UPoint2(Point2 a) => .((.)a.X, (.)a.Y);

		[Commutable]
		public static bool operator==(UPoint2 a, UPoint2 b) => a.X == b.X && a.Y == b.Y;

		public static UPoint2 operator+(UPoint2 a, UPoint2 b) => UPoint2(a.X + b.X, a.Y + b.Y);
		public static Point2 operator+(Point2 a, UPoint2 b) => Point2(a.X + (.)b.X, a.Y + (.)b.Y);
		public static Point2 operator+(UPoint2 b, Point2 a) => Point2(a.X + (.)b.X, a.Y + (.)b.Y);
		public static UPoint2 operator-(UPoint2 a, UPoint2 b) => UPoint2(a.X - b.X, a.Y - b.Y);
		public static Point2 operator-(Point2 a, UPoint2 b) => Point2(a.X - (.)b.X, a.Y - (.)b.Y);
		public static Point2 operator-(UPoint2 a, Point2 b) => Point2((.)a.X - b.X, (.)a.Y - b.Y);

		public static UPoint2 operator*(UPoint2 a, uint b) => UPoint2(a.X * b, a.Y * b);
		public static UPoint2 operator*(uint b, UPoint2 a) => UPoint2(a.X * b, a.Y * b);
		public static UPoint2 operator/(UPoint2 a, uint b) => UPoint2(a.X / b, a.Y / b);

		public static Point2 operator*(UPoint2 a, int b) => Point2((int)a.X * b, (int)a.Y * b);
		public static Point2 operator*(int b, UPoint2 a) => Point2((int)a.X * b, (int)a.Y * b);
		public static Point2 operator/(UPoint2 a, int b) => Point2((int)a.X / b, (int)a.Y / b);

		public static UPoint2 operator*(UPoint2 a, UPoint2 b) => UPoint2(a.X * b.X, a.Y * b.Y);
		public static UPoint2 operator/(UPoint2 a, UPoint2 b) => UPoint2(a.X / b.Y, a.Y / b.Y);

		public static Point2 operator-(UPoint2 a) => Point2(-(int)a.X, -(int)a.Y);
	}
}
