// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System;

namespace Pile
{
	[Ordered]
	struct Vector3 : IFormattable, IEquatable<Vector3>, IEquatable
	{
		public const Vector3 Zero = .(0, 0, 0);
		public const Vector3 One = .(1, 1, 1);
		public const Vector3 UnitX = .(1, 0, 0);
		public const Vector3 UnitY = .(0, 1, 0);
		public const Vector3 UnitZ = .(0, 0, 1);

		public const Vector3 NegateX = .(-1, 1, 1);
		public const Vector3 NegateY = .(1, -1, 1);
		public const Vector3 NegateZ = .(1, 1, -1);

		public float X, Y, Z;

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

		public this(Vector2 vector2, float z)
		{
			X = vector2.X;
			Y = vector2.Y;
			Z = z;
		}

		[Inline]
		public bool Equals(Vector3 o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Vector3) && (Vector3)o == this;

		[Inline]
		/// Rounds the vector to a point.
		public Point3 Round()
		{
			return Point3((int)Math.Round(X), (int)Math.Round(Y), (int)Math.Round(Z));
		}

		[Inline]
		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Hacky fix: Vector2.Zero will still just return Vector2.Zero instead of a NaN vector.
		public Vector3 Normalize()
		{
			// Normalizing a zero vector is not possible and will return NaN.
			// We ignore this in favor of not NaN-ing vectors.

			return this == .Zero ? .Zero : this / Length;
		}

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
		public static float Distance(Vector3 value1, Vector3 value2)
		{
		    let difference = value1 - value2;
			let ls = Vector3.Dot(difference, difference);
			return Math.Sqrt(ls);
		}

		/// Returns the Euclidean distance squared between the two given points.
		public static float DistanceSquared(Vector3 value1, Vector3 value2)
		{
		    let difference = value1 - value2;
			return Vector3.Dot(difference, difference);
		}

		[Inline]
		/// Computes the cross product of two vectors.
		public static Vector3 Cross(Vector3 vector1, Vector3 vector2)
		{
		    return Vector3(
		        vector1.Y * vector2.Z - vector1.Z * vector2.Y,
		        vector1.Z * vector2.X - vector1.X * vector2.Z,
		        vector1.X * vector2.Y - vector1.Y * vector2.X);
		}

		[Inline]
		/// Returns the reflection of a vector off a surface that has the specified normal.
		public static Vector3 Reflect(Vector3 vector, Vector3 normal)
		{
			return vector - (normal * Vector3.Dot(vector, normal) * 2);
		}

		/// Returns the dot product of two vectors.
		public static float Dot(Vector3 vector1, Vector3 vector2)
		{
		    return vector1.X * vector2.X +
		           vector1.Y * vector2.Y +
		           vector1.Z * vector2.Z;
		}

		/// Restricts a vector between a min and max value.
		public static Vector3 Clamp(Vector3 value1, Vector3 min, Vector3 max)
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

		    return Vector3(x, y, z);
		}

		/// Linearly interpolates between two vectors based on the given weighting.
		public static Vector3 Lerp(Vector3 a, Vector3 b, float amount)
		{
			/*if (t == 0)
				return a;
			else if (t == 1)
				return b;
			else
				return a + (b - a) * amount;*/

			return Vector3(
				a.X + (b.X - a.X) * amount,
				a.Y + (b.Y - a.Y) * amount,
				a.Z + (b.Z - a.Z) * amount);
		}

		/// Approaches the target vector by a constant given amount.
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
		            return from + diff.Normalize() * amount;
		    }
		}

		[Inline]
		/// Transforms a vector by the given matrix.
		public static Vector3 Transform(Vector3 position, Matrix4x4 matrix)
		{
		    return Vector3(
		        position.X * matrix.M11 + position.Y * matrix.M21 + position.Z * matrix.M31 + matrix.M41,
		        position.X * matrix.M12 + position.Y * matrix.M22 + position.Z * matrix.M32 + matrix.M42,
		        position.X * matrix.M13 + position.Y * matrix.M23 + position.Z * matrix.M33 + matrix.M43);
		}

		[Inline]
		/// Transforms a vector normal by the given matrix.
		public static Vector3 TransformNormal(Vector3 normal, Matrix4x4 matrix)
		{
		    return Vector3(
		        normal.X * matrix.M11 + normal.Y * matrix.M21 + normal.Z * matrix.M31,
		        normal.X * matrix.M12 + normal.Y * matrix.M22 + normal.Z * matrix.M32,
		        normal.X * matrix.M13 + normal.Y * matrix.M23 + normal.Z * matrix.M33);
		}

		/// Transforms a vector by the given Quaternion rotation value.
		public static Vector3 Transform(Vector3 value, Quaternion rotation)
		{
		    float x2 = rotation.X + rotation.X;
		    float y2 = rotation.Y + rotation.Y;
		    float z2 = rotation.Z + rotation.Z;

		    float wx2 = rotation.W * x2;
		    float wy2 = rotation.W * y2;
		    float wz2 = rotation.W * z2;
		    float xx2 = rotation.X * x2;
		    float xy2 = rotation.X * y2;
		    float xz2 = rotation.X * z2;
		    float yy2 = rotation.Y * y2;
		    float yz2 = rotation.Y * z2;
		    float zz2 = rotation.Z * z2;

		    return Vector3(
		        value.X * (1.0f - yy2 - zz2) + value.Y * (xy2 - wz2) + value.Z * (xz2 + wy2),
		        value.X * (xy2 + wz2) + value.Y * (1.0f - xx2 - zz2) + value.Z * (yz2 - wx2),
		        value.X * (xz2 - wy2) + value.Y * (yz2 + wx2) + value.Z * (1.0f - xx2 - yy2));
		}

		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Vector3 Min(Vector3 value1, Vector3 value2)
		{
		    return Vector3(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y,
		        (value1.Z < value2.Z) ? value1.Z : value2.Z);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Vector3 Max(Vector3 value1, Vector3 value2)
		{
		    return Vector3(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y,
		        (value1.Z > value2.Z) ? value1.Z : value2.Z);
		}

		[Inline]
		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		public static Vector3 Abs(Vector3 value)
		{
		    return Vector3(Math.Abs(value.X), Math.Abs(value.Y), Math.Abs(value.Z));
		}

		[Inline]
		/// Returns a vector whose elements are the square root of each of the source vector's elements.
		public static Vector3 SquareRoot(Vector3 value)
		{
		    return Vector3(Math.Sqrt(value.X), Math.Sqrt(value.Y), Math.Sqrt(value.Z));
		}

		public static operator Vector3((float X, float Y, float Z) tuple) => Vector3(tuple.X, tuple.Y, tuple.Z);
		public static operator Vector3(Point3 a) => Vector3(a.X, a.Y, a.Z);
		public static operator Vector3(Vector2 a) => Vector3(a, 0);
		public static operator Vector3(Point2 a) => Vector3(a, 0);

		[Commutable]
		public static bool operator==(Vector3 a, Vector3 b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z;

		public static Vector3 operator+(Vector3 a, Vector3 b) => Vector3(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
		public static Vector3 operator-(Vector3 a, Vector3 b) => Vector3(a.X - b.X, a.Y - b.Y, a.Z - b.Z);

		public static Vector3 operator*(Vector3 a, float b) => Vector3(a.X * b, a.Y * b, a.Z * b);
		public static Vector3 operator*(Vector3 a, double b) => Vector3((.)(a.X * b), (.)(a.Y * b), (.)(a.Z * b));
		public static Vector3 operator*(float b, Vector3 a) => Vector3(a.X * b, a.Y * b, a.Z * b);
		public static Vector3 operator*(double b, Vector3 a) => Vector3((.)(a.X * b), (.)(a.Y * b), (.)(a.Z * b));

		public static Vector3 operator/(Vector3 a, float b) => Vector3(a.X / b, a.Y / b, a.Z / b);
		public static Vector3 operator/(Vector3 a, double b) => Vector3((.)(a.X / b), (.)(a.Y / b), (.)(a.Z / b));

		public static Vector3 operator*(Vector3 a, Vector3 b) => Vector3(a.X * b.X, a.Y * b.Y, a.Z * b.Z);
		public static Vector3 operator/(Vector3 a, Vector3 b) => Vector3(a.X / b.X, a.Y / b.Y, a.Z / b.Z);

		public static Vector3 operator-(Vector3 a) => Vector3(-a.X, -a.Y, -a.Z);
	}
}
