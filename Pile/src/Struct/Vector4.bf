// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System;

namespace Pile
{
	[Ordered]
	struct Vector4 : IFormattable, IEquatable<Vector4>, IEquatable
	{
		public const Vector4 Zero = .(0, 0, 0, 0);
		public const Vector4 One = .(1, 1, 1, 1);
		public const Vector4 UnitX = .(1, 0, 0, 0);
		public const Vector4 UnitY = .(0, 1, 0, 0);
		public const Vector4 UnitZ = .(0, 0, 1, 0);
		public const Vector4 UnitW = .(0, 0, 0, 1);

		public const Vector4 NegateX = .(-1, 1, 1, 1);
		public const Vector4 NegateY = .(1, -1, 1, 1);
		public const Vector4 NegateZ = .(1, 1, -1, 1);
		public const Vector4 NegateW = .(1, 1, 1, -1);

		public float X, Y, Z, W;

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

		public this(float all)
		{
			X = all;
			Y = all;
			Z = all;
			W = all;
		}

		public this(Vector2 vector2, float z, float w)
		{
			X = vector2.X;
			Y = vector2.Y;
			Z = z;
			W = w;
		}

		public this(Vector3 vector3, float w)
		{
			X = vector3.X;
			Y = vector3.Y;
			Z = vector3.Z;
			W = w;
		}

		public this(float x, float y, float z, float w)
		{
			X = x;
			Y = y;
			Z = z;
			W = w;
		}

		[Inline]
		public bool Equals(Vector4 o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Vector4) && (Vector4)o == this;

		[Inline]
		/// Rounds the vector to a point.
		public Point4 Round()
		{
			return Point4((int)Math.Round(X), (int)Math.Round(Y), (int)Math.Round(Z), (int)Math.Round(W));
		}

		[Inline]
		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Hacky fix: Vector2.Zero will still just return Vector2.Zero instead of a NaN vector.
		public Vector4 Normalize()
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
		public static float Distance(Vector4 value1, Vector4 value2)
		{
		    let difference = value1 - value2;
			let ls = Vector4.Dot(difference, difference);
			return Math.Sqrt(ls);
		}

		[Inline]
		/// Returns the Euclidean distance squared between the two given points.
		public static float DistanceSquared(Vector4 value1, Vector4 value2)
		{
		    let difference = value1 - value2;
			return Vector4.Dot(difference, difference);
		}

		/// Restricts a vector between a min and max value.
		public static Vector4 Clamp(Vector4 value1, Vector4 min, Vector4 max)
		{
		    float x = value1.X;
		    x = (x > max.X) ? max.X : x;
		    x = (x < min.X) ? min.X : x;

		    float y = value1.Y;
		    y = (y > max.Y) ? max.Y : y;
		    y = (y < min.Y) ? min.Y : y;

		    float z = value1.Z;
		    z = (z > max.Z) ? max.Z : z;
		    z = (z < min.Z) ? min.Z : z;

		    float w = value1.W;
		    w = (w > max.W) ? max.W : w;
		    w = (w < min.W) ? min.W : w;

		    return Vector4(x, y, z, w);
		}

		/// Linearly interpolates between two vectors based on the given weighting.
		public static Vector4 Lerp(Vector4 value1, Vector4 value2, float amount)
		{
		    return Vector4(
		        value1.X + (value2.X - value1.X) * amount,
		        value1.Y + (value2.Y - value1.Y) * amount,
		        value1.Z + (value2.Z - value1.Z) * amount,
		        value1.W + (value2.W - value1.W) * amount);
		}

		/// Approaches the target vector by a constant given amount.
		public static Vector4 Approach(Vector4 from, Vector4 target, float amount)
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
		public static Vector4 Transform(Vector2 position, Matrix4x4 matrix)
		{
		    return Vector4(
		        position.X * matrix.M11 + position.Y * matrix.M21 + matrix.M41,
		        position.X * matrix.M12 + position.Y * matrix.M22 + matrix.M42,
		        position.X * matrix.M13 + position.Y * matrix.M23 + matrix.M43,
		        position.X * matrix.M14 + position.Y * matrix.M24 + matrix.M44);
		}

		[Inline]
		/// Transforms a vector by the given matrix.
		public static Vector4 Transform(Vector3 position, Matrix4x4 matrix)
		{
		    return Vector4(
		        position.X * matrix.M11 + position.Y * matrix.M21 + position.Z * matrix.M31 + matrix.M41,
		        position.X * matrix.M12 + position.Y * matrix.M22 + position.Z * matrix.M32 + matrix.M42,
		        position.X * matrix.M13 + position.Y * matrix.M23 + position.Z * matrix.M33 + matrix.M43,
		        position.X * matrix.M14 + position.Y * matrix.M24 + position.Z * matrix.M34 + matrix.M44);
		}

		[Inline]
		/// Transforms a vector by the given matrix.
		public static Vector4 Transform(Vector4 vector, Matrix4x4 matrix)
		{
		    return Vector4(
		        vector.X * matrix.M11 + vector.Y * matrix.M21 + vector.Z * matrix.M31 + vector.W * matrix.M41,
		        vector.X * matrix.M12 + vector.Y * matrix.M22 + vector.Z * matrix.M32 + vector.W * matrix.M42,
		        vector.X * matrix.M13 + vector.Y * matrix.M23 + vector.Z * matrix.M33 + vector.W * matrix.M43,
		        vector.X * matrix.M14 + vector.Y * matrix.M24 + vector.Z * matrix.M34 + vector.W * matrix.M44);
		}

		/// Transforms a vector by the given Quaternion rotation value.
		public static Vector4 Transform(Vector2 value, Quaternion rotation)
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

		    return Vector4(
		        value.X * (1.0f - yy2 - zz2) + value.Y * (xy2 - wz2),
		        value.X * (xy2 + wz2) + value.Y * (1.0f - xx2 - zz2),
		        value.X * (xz2 - wy2) + value.Y * (yz2 + wx2),
		        1.0f);
		}

		/// Transforms a vector by the given Quaternion rotation value.
		public static Vector4 Transform(Vector3 value, Quaternion rotation)
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

		    return Vector4(
		        value.X * (1.0f - yy2 - zz2) + value.Y * (xy2 - wz2) + value.Z * (xz2 + wy2),
		        value.X * (xy2 + wz2) + value.Y * (1.0f - xx2 - zz2) + value.Z * (yz2 - wx2),
		        value.X * (xz2 - wy2) + value.Y * (yz2 + wx2) + value.Z * (1.0f - xx2 - yy2),
		        1.0f);
		}

		/// Transforms a vector by the given Quaternion rotation value.
		public static Vector4 Transform(Vector4 value, Quaternion rotation)
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

		    return Vector4(
		        value.X * (1.0f - yy2 - zz2) + value.Y * (xy2 - wz2) + value.Z * (xz2 + wy2),
		        value.X * (xy2 + wz2) + value.Y * (1.0f - xx2 - zz2) + value.Z * (yz2 - wx2),
		        value.X * (xz2 - wy2) + value.Y * (yz2 + wx2) + value.Z * (1.0f - xx2 - yy2),
		        value.W);
		}

		[Inline]
		/// Returns the dot product of two vectors.
		public static float Dot(Vector4 vector1, Vector4 vector2)
		{
		    return vector1.X * vector2.X +
		           vector1.Y * vector2.Y +
		           vector1.Z * vector2.Z +
		           vector1.W * vector2.W;
		}

		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Vector4 Min(Vector4 value1, Vector4 value2)
		{
		    return Vector4(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y,
		        (value1.Z < value2.Z) ? value1.Z : value2.Z,
		        (value1.W < value2.W) ? value1.W : value2.W);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Vector4 Max(Vector4 value1, Vector4 value2)
		{
		    return Vector4(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y,
		        (value1.Z > value2.Z) ? value1.Z : value2.Z,
		        (value1.W > value2.W) ? value1.W : value2.W);
		}

		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		public static Vector4 Abs(Vector4 value)
		{
		    return Vector4(Math.Abs(value.X), Math.Abs(value.Y), Math.Abs(value.Z), Math.Abs(value.W));
		}

		/// Returns a vector whose elements are the square root of each of the source vector's elements.
		public static Vector4 Sqrt(Vector4 value)
		{
		    return Vector4(Math.Sqrt(value.X), Math.Sqrt(value.Y), Math.Sqrt(value.Z), Math.Sqrt(value.W));
		}

		public static operator Vector4((float X, float Y, float Z, float W) tuple) => Vector4(tuple.X, tuple.Y, tuple.Z, tuple.W);
		public static operator Vector4(Point4 a) => Vector4(a.X, a.Y, a.Z, a.W);
		public static operator Vector4(Vector3 a) => Vector4(a, 0);
		public static operator Vector4(Point3 a) => Vector4(a, 0);
		public static operator Vector4(Vector2 a) => Vector4(a, 0, 0);
		public static operator Vector4(Point2 a) => Vector4(a, 0, 0);

		[Commutable]
		public static bool operator==(Vector4 a, Vector4 b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z && a.W == b.W;

		public static Vector4 operator+(Vector4 a, Vector4 b) => Vector4(a.X + b.X, a.Y + b.Y, a.Z + b.Z, a.W + b.W);
		public static Vector4 operator-(Vector4 a, Vector4 b) => Vector4(a.X - b.X, a.Y - b.Y, a.Z - b.Z, a.W - b.W);

		public static Vector4 operator*(Vector4 a, float b) => Vector4(a.X * b, a.Y * b, a.Z * b, a.W * b);
		public static Vector4 operator*(Vector4 a, double b) => Vector4((.)(a.X * b), (.)(a.Y * b), (.)(a.Z * b), (.)(a.W * b));
		public static Vector4 operator*(float b, Vector4 a) => Vector4(a.X * b, a.Y * b, a.Z * b, a.W * b);
		public static Vector4 operator*(double b, Vector4 a) => Vector4((.)(a.X * b), (.)(a.Y * b), (.)(a.Z * b), (.)(a.W * b));

		public static Vector4 operator/(Vector4 a, float b) => Vector4(a.X / b, a.Y / b, a.Z / b, a.W / b);
		public static Vector4 operator/(Vector4 a, double b) => Vector4((.)(a.X / b), (.)(a.Y / b), (.)(a.Z / b), (.)(a.W / b));

		public static Vector4 operator*(Vector4 a, Vector4 b) => Vector4(a.X * b.X, a.Y * b.Y, a.Z * b.Z, a.W * b.W);
		public static Vector4 operator/(Vector4 a, Vector4 b) => Vector4(a.X / b.X, a.Y / b.Y, a.Z / b.Z, a.W / b.W);

		public static Vector4 operator-(Vector4 a) => Vector4(-a.X, -a.Y, -a.Z, -a.W);
	}
}
