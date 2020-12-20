using System;

namespace Pile
{
	[Ordered]
	public struct Point4 : IFormattable, IEquatable<Point4>, IEquatable
	{
		public static readonly Point4 Zero = .(0, 0, 0, 0);
		public static readonly Point4 One = .(1, 1, 1, 1);
		public static readonly Point4 UnitX = .(1, 0, 0, 0);
		public static readonly Point4 UnitY = .(0, 1, 0, 0);
		public static readonly Point4 UnitZ = .(0, 0, 1, 0);
		public static readonly Point4 UnitW = .(0, 0, 0, 1);

		public static readonly Point4 NegateX = .(-1, 1, 1, 1);
		public static readonly Point4 NegateY = .(1, -1, 1, 1);
		public static readonly Point4 NegateZ = .(1, 1, -1, 1);
		public static readonly Point4 NegateW = .(1, 1, 1, -1);

		public int X, Y, Z, W;

		[Inline]
		/// Returns the length of the vector.
		public float Length => (float)Math.Sqrt((double)X * X + Y * Y + Z * Z + W * W);

		[Inline]
		/// Returns the length of the vector squared. This operation is cheaper than Length.
		public float LengthSquared => X * X + Y * Y + Z * Z + W * W;

		public this()
		{
			this = default;
		}

		public this(int all)
		{
			X = all;
			Y = all;
			Z = all;
			W = all;
		}

		public this(Point3 point3, int w)
		{
			X = point3.X;
			Y = point3.Y;
			Z = point3.Z;
			W = w;
		}

		public this(Point2 point2, int z, int w)
		{
			X = point2.X;
			Y = point2.Y;
			Z = z;
			W = w;
		}

		public this(int x, int y, int z, int w)
		{
			X = x;
			Y = y;
			Z = z;
			W = w;
		}

		[Inline]
		public bool Equals(Point4 o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Point4) && (Point4)o == this;

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("[ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(", ");
			Z.ToString(strBuffer);
			strBuffer.Append(", ");
			W.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public void ToString(String outString, String format, IFormatProvider formatProvider)
		{
			outString.Append("[ ");
			X.ToString(outString, format, formatProvider);
			outString.Append(", ");
			Y.ToString(outString, format, formatProvider);
			outString.Append(", ");
			Z.ToString(outString, format, formatProvider);
			outString.Append(", ");
			W.ToString(outString, format, formatProvider);
			outString.Append(" ]");
		}

		[Inline]
		/// Returns the Euclidean distance between the two given points.
		public static float Distance(Point4 value1, Point4 value2)
		{
		    let difference = value1 - value2;
			let ls = Point4.Dot(difference, difference);
			return Math.Sqrt(ls);
		}

		[Inline]
		/// Returns the Euclidean distance squared between the two given points.
		public static float DistanceSquared(Point4 value1, Point4 value2)
		{
		    let difference = value1 - value2;
			return Point4.Dot(difference, difference);
		}

		/// Restricts a vector between a min and max value.
		public static Point4 Clamp(Point4 value1, Point4 min, Point4 max)
		{
		    var x = value1.X;
		    x = (x > max.X) ? max.X : x;
		    x = (x < min.X) ? min.X : x;

		    var y = value1.Y;
		    y = (y > max.Y) ? max.Y : y;
		    y = (y < min.Y) ? min.Y : y;

		    var z = value1.Z;
		    z = (z > max.Z) ? max.Z : z;
		    z = (z < min.Z) ? min.Z : z;

		    var w = value1.W;
		    w = (w > max.W) ? max.W : w;
		    w = (w < min.W) ? min.W : w;

		    return Point4(x, y, z, w);
		}

		[Inline]
		/// Returns the dot product of two vectors.
		public static int Dot(Point4 vector1, Point4 vector2)
		{
		    return vector1.X * vector2.X +
		           vector1.Y * vector2.Y +
		           vector1.Z * vector2.Z +
		           vector1.W * vector2.W;
		}

		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Point4 Min(Point4 value1, Point4 value2)
		{
		    return Point4(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y,
		        (value1.Z < value2.Z) ? value1.Z : value2.Z,
		        (value1.W < value2.W) ? value1.W : value2.W);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Point4 Max(Point4 value1, Point4 value2)
		{
		    return Point4(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y,
		        (value1.Z > value2.Z) ? value1.Z : value2.Z,
		        (value1.W > value2.W) ? value1.W : value2.W);
		}

		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		public static Point4 Abs(Point4 value)
		{
		    return Point4(Math.Abs(value.X), Math.Abs(value.Y), Math.Abs(value.Z), Math.Abs(value.W));
		}

		public static operator Point4((int X, int Y, int Z, int W) tuple) => Point4(tuple.X, tuple.Y, tuple.Z, tuple.W);
		public static explicit operator Point4(Vector4 a) => Point4((int)Math.Round(a.X), (int)Math.Round(a.Y), (int)Math.Round(a.Z), (int)Math.Round(a.W));

		[Commutable]
		public static bool operator==(Point4 a, Point4 b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z && a.W == b.W;

		public static Point4 operator+(Point4 a, Point4 b) => Point4(a.X + b.X, a.Y + b.Y, a.Z + b.Z, a.W + b.W);
		public static Point4 operator-(Point4 a, Point4 b) => Point4(a.X - b.X, a.Y - b.Y, a.Z - b.Z, a.W - b.W);

		public static Point4 operator*(Point4 a, int b) => Point4(a.X * b, a.Y * b, a.Z * b, a.W * b);
		public static Point4 operator*(int b, Point4 a) => Point4(a.X * b, a.Y * b, a.Z * b, a.W * b);
		public static Point4 operator/(Point4 a, int b) => Point4(a.X / b, a.Y / b, a.Z / b, a.W / b);

		public static Point4 operator*(Point4 a, Point4 b) => Point4(a.X * b.X, a.Y * b.Y, a.Z * b.Z, a.W * b.W);
		public static Point4 operator/(Point4 a, Point4 b) => Point4(a.X / b.X, a.Y / b.Y, a.Z / b.Z, a.W / b.W);

		public static Point4 operator-(Point4 a) => Point4(-a.X, -a.Y, -a.Z, -a.W);
	}
}
