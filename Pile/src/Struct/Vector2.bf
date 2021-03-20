// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System;

namespace Pile
{
	[Ordered]
	struct Vector2 : IFormattable, IEquatable<Vector2>, IEquatable
	{
		public const Vector2 Zero = .(0, 0);
		public const Vector2 One = .(1, 1);
		public const Vector2 UnitX = .(1, 0);
		public const Vector2 UnitY = .(0, 1);

		public const Vector2 NegateX = .(-1, 1);
		public const Vector2 NegateY = .(1, -1);

		public float X, Y;

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

		[Inline]
		public bool Equals(Vector2 o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Vector2) && (Vector2)o == this;

		[Inline]
		/// Rounds the vector to a point.
		public Point2 Round()
		{
			return Point2((int)Math.Round(X), (int)Math.Round(Y));
		}

		[Inline]
		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Hacky fix: Vector2.Zero will still just return Vector2.Zero instead of a NaN vector.
		public Vector2 Normalize()
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
		/// Returns the Euclidean distance between the two given points.
		public static float Distance(Vector2 value1, Vector2 value2)
		{
		    let difference = value1 - value2;
			let ls = difference.LengthSquared;
			return Math.Sqrt(ls);
		}

		[Inline]
		/// Returns the Euclidean distance squared between the two given points.
		public static float DistanceSquared(Vector2 value1, Vector2 value2)
		{
		    let difference = value1 - value2;
			return difference.LengthSquared;
		}

		[Inline]
		/// Returns the reflection of a vector off a surface that has the specified normal.
		public static Vector2 Reflect(Vector2 vector, Vector2 normal)
		{
			return vector - (normal * 2 * Vector2.Dot(vector, normal));
		}

		/// Restricts a vector between a min and max value.
		public static Vector2 Clamp(Vector2 value1, Vector2 min, Vector2 max)
		{
		    var x = value1.X;
		    x = (x > max.X) ? max.X : x;
		    x = (x < min.X) ? min.X : x;

		    var y = value1.Y;
		    y = (y > max.Y) ? max.Y : y;
		    y = (y < min.Y) ? min.Y : y;

		    return Vector2(x, y);
		}

		/// Linearly interpolates between two vectors based on the given weighting.
		public static Vector2 Lerp(Vector2 a, Vector2 b, float amount)
		{
			/*if (t == 0)
				return a;
			else if (t == 1)
				return b;
			else
				return a + (b - a) * amount;*/

			return Vector2(a.X + (b.X - a.X) * amount, a.Y + (b.Y - a.Y) * amount);
		}

		/// Approaches the target vector by a constant given amount.
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
		            return from + diff.Normalize() * amount;
		    }
		}

		[Inline]
		/// Transforms a vector by the given matrix.
		public static Vector2 Transform(Vector2 position, Matrix3x2 matrix)
		{
		    return Vector2(
		        position.X * matrix.M11 + position.Y * matrix.M21 + matrix.M31,
		        position.X * matrix.M12 + position.Y * matrix.M22 + matrix.M32);
		}

		[Inline]
		/// Transforms a vector by the given matrix.
		public static Vector2 Transform(Vector2 position, Matrix4x4 matrix)
		{
		    /*return Vector2(
		        position.X * matrix.M11 + position.Y * matrix.M21 + matrix.M41,
		        position.X * matrix.M12 + position.Y * matrix.M22 + matrix.M42);*/

			const float e = 0.0000001F;
			Vector3 v3 = Vector3.Transform(Vector3(position, 1), matrix);
			return Vector2(v3.X, v3.Y) / Math.Max(v3.Z, e);
		}

		[Inline]
		/// Transforms a vector normal by the given matrix.
		public static Vector2 TransformNormal(Vector2 normal, Matrix3x2 matrix)
		{
		    return Vector2(
		        normal.X * matrix.M11 + normal.Y * matrix.M21,
		        normal.X * matrix.M12 + normal.Y * matrix.M22);
		}

		[Inline]
		/// Transforms a vector normal by the given matrix.
		public static Vector2 TransformNormal(Vector2 normal, Matrix4x4 matrix)
		{
		    return Vector2(
		        normal.X * matrix.M11 + normal.Y * matrix.M21,
		        normal.X * matrix.M12 + normal.Y * matrix.M22);
		}

		/// Transforms a vector by the given Quaternion rotation value.
		public static Vector2 Transform(Vector2 value, Quaternion rotation)
		{
		    float x2 = rotation.X + rotation.X;
		    float y2 = rotation.Y + rotation.Y;
		    float z2 = rotation.Z + rotation.Z;

		    float wz2 = rotation.W * z2;
		    float xx2 = rotation.X * x2;
		    float xy2 = rotation.X * y2;
		    float yy2 = rotation.Y * y2;
		    float zz2 = rotation.Z * z2;

		    return Vector2(
		        value.X * (1.0f - yy2 - zz2) + value.Y * (xy2 - wz2),
		        value.X * (xy2 + wz2) + value.Y * (1.0f - xx2 - zz2));
		}

		[Inline]
		/// Returns the dot product of two vectors.
		public static float Dot(Vector2 val1, Vector2 val2)
		{
			return val1.X * val2.X + val1.Y * val2.Y;
		}

		[Inline]
		/// Returns the angle of the vector.
		public static float Angle(Vector2 vec)
		{
		    return Math.Atan2(vec.Y, vec.X);
		}

		[Inline]
		/// Returns the angle betweem two vectors.
		public static float Angle(Vector2 from, Vector2 to)
		{
		    return Math.Atan2(to.Y - from.Y, to.X - from.X);
		}

		/// Constructs a vector from a given angle and a length
		public static Vector2 AngleToVector(float angle, float length = 1)
		{
		    return Vector2(Math.Cos(angle) * length, Math.Sin(angle) * length);
		}

		[Inline]
		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Vector2 Min(Vector2 value1, Vector2 value2)
		{
		    return Vector2(
		        (value1.X < value2.X) ? value1.X : value2.X,
		        (value1.Y < value2.Y) ? value1.Y : value2.Y);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Vector2 Max(Vector2 value1, Vector2 value2)
		{
		    return Vector2(
		        (value1.X > value2.X) ? value1.X : value2.X,
		        (value1.Y > value2.Y) ? value1.Y : value2.Y);
		}

		[Inline]
		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		public static Vector2 Abs(Vector2 value)
		{
		    return Vector2(Math.Abs(value.X), Math.Abs(value.Y));
		}

		[Inline]
		/// Returns a vector whose elements are the square root of each of the source vector's elements.
		public static Vector2 Sqrt(Vector2 value)
		{
		    return Vector2(Math.Sqrt(value.X), Math.Sqrt(value.Y));
		}

		/// Returns if a vector point is inside a triangle of three vector vertices.
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
		public static Vector2 operator*(float b, Vector2 a) => Vector2(a.X * b, a.Y * b);
		public static Vector2 operator*(double b, Vector2 a) => Vector2((.)(a.X * b), (.)(a.Y * b));

		public static Vector2 operator/(Vector2 a, float b) => Vector2(a.X / b, a.Y / b);
		public static Vector2 operator/(Vector2 a, double b) => Vector2((.)(a.X / b), (.)(a.Y / b));

		public static Vector2 operator*(Vector2 a, Vector2 b) => Vector2(a.X * b.X, a.Y * b.Y);
		public static Vector2 operator/(Vector2 a, Vector2 b) => Vector2(a.X / b.X, a.Y / b.Y);

		public static Vector2 operator-(Vector2 a) => Vector2(-a.X, -a.Y);

	}
}
