using System;

namespace Pile
{
	[Ordered]
	public struct Point3 : IFormattable, IEquatable<Point3>, IEquatable
	{
		public static readonly Point3 Zero = .(0, 0, 0);
		public static readonly Point3 One = .(1, 1, 1);
		public static readonly Point3 UnitX = .(1, 0, 0);
		public static readonly Point3 UnitY = .(0, 1, 0);
		public static readonly Point3 UnitZ = .(0, 0, 1);

		public static readonly Point3 NegateX = .(-1, 1, 1);
		public static readonly Point3 NegateY = .(1, -1, 1);
		public static readonly Point3 NegateZ = .(1, 1, -1);

		public int X, Y, Z;

		[Inline]
		/// Returns the length of the vector.
		public float Length => (float)Math.Sqrt((double)X * X + Y * Y + Z * Z);

		[Inline]
		/// Returns the length of the vector squared. This operation is cheaper than Length.
		public float LengthSquared => X * X + Y * Y + Z * Z;

		public this()
		{
			this = default;
		}

		public this(int all)
		{
			X = all;
			Y = all;
			Z = all;
		}

		public this(Point2 point2, int z)
		{
			X = point2.X;
			Y = point2.Y;
			Z = z;
		}

		public this(int x, int y, int z)
		{
			X = x;
			Y = y;
			Z = z;
		}

		[Inline]
		public bool Equals(Object o) => (o is Point3) && (Point3)o == this;

		[Inline]
		public bool Equals(Point3 a) => a.X == X && a.Y == Y;

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("[ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(", ");
			Z.ToString(strBuffer);
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
			outString.Append(" ]");
		}

		/// Returns the Euclidean distance between the two given points.
		public static float Distance(Point3 value1, Point3 value2)
		{
		    let difference = value1 - value2;
			let ls = Point3.Dot(difference, difference);
			return Math.Sqrt(ls);
		}

		/// Returns the Euclidean distance squared between the two given points.
		public static float DistanceSquared(Point3 value1, Point3 value2)
		{
		    let difference = value1 - value2;
			return Vector3.Dot(difference, difference);
		}

		[Inline]
		/// Computes the cross product of two vectors.
		public static Point3 Cross(Point3 vector1, Point3 vector2)
		{
		    return Point3(
		        vector1.Y * vector2.Z - vector1.Z * vector2.Y,
		        vector1.Z * vector2.X - vector1.X * vector2.Z,
		        vector1.X * vector2.Y - vector1.Y * vector2.X);
		}

		[Inline]
		/// Returns the reflection of a vector off a surface that has the specified normal.
		public static Point3 Reflect(Point3 vector, Point3 normal)
		{
			return vector - (normal * Point3.Dot(vector, normal) * 2);
		}

		/// Returns the dot product of two vectors.
		public static int Dot(Point3 vector1, Point3 vector2)
		{
		    return vector1.X * vector2.X +
		           vector1.Y * vector2.Y +
		           vector1.Z * vector2.Z;
		}

		/// Restricts a vector between a min and max value.
		public static Point3 Clamp(Point3 value1, Point3 min, Point3 max)
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

		    return Point3(x, y, z);
		}

		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Point3 Min(Point3 value1, Point3 value2)
		{
		    return Point3(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y,
		        (value1.Z < value2.Z) ? value1.Z : value2.Z);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Point3 Max(Point3 value1, Point3 value2)
		{
		    return Point3(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y,
		        (value1.Z > value2.Z) ? value1.Z : value2.Z);
		}

		[Inline]
		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		public static Point3 Abs(Point3 value)
		{
		    return Point3(Math.Abs(value.X), Math.Abs(value.Y), Math.Abs(value.Z));
		}

		public static operator Point3((int X, int Y, int Z) tuple) => Point3(tuple.X, tuple.Y, tuple.Z);
		public static explicit operator Point3(Vector3 a) => Point3((int)Math.Round(a.X), (int)Math.Round(a.Y), (int)Math.Round(a.Z));

		[Commutable]
		public static bool operator==(Point3 a, Point3 b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z;

		public static Point3 operator+(Point3 a, Point3 b) => Point3(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
		public static Point3 operator-(Point3 a, Point3 b) => Point3(a.X - b.X, a.Y - b.Y, a.Z - b.Z);

		public static Point3 operator*(Point3 a, int b) => Point3(a.X * b, a.Y * b, a.Z * b);
		public static Point3 operator*(int b, Point3 a) => Point3(a.X * b, a.Y * b, a.Z * b);
		public static Point3 operator/(Point3 a, int b) => Point3(a.X / b, a.Y / b, a.Z / b);

		public static Point3 operator*(Point3 a, Point3 b) => Point3(a.X * b.X, a.Y * b.Y, a.Z * b.Z);
		public static Point3 operator/(Point3 a, Point3 b) => Point3(a.X / b.X, a.Y / b.Y, a.Z / b.Z);

		public static Point3 operator-(Point3 a) => Point3(-a.X, -a.Y, -a.Z);
	}
}
