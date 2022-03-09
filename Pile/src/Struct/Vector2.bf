// Generator=Pile:Pile.VectorGenerator
// name=Vector2
// components=2
// type=float
// ftype=component
// ivtype=Point2;UPoint2
// fvtype=
// compatv=
// GenHash=758A736BAC81FDF35FF52C9E71A2F95A


// Generated at 3/8/2022 8:33:19 PM. Do not edit file, use extensions!
using System;

namespace Pile
{
	struct Vector2 : IFormattable, IEquatable<Vector2>, IHashable
	{
		public const Self Zero = .();
		public const Self One = .(1);
		public const Self UnitX = .(1, 0);
		public const Self UnitY = .(0, 1);
		public const Self NegateX = .(-1, 1);
		public const Self NegateY = .(1, -1);

		public float X, Y;

		[Inline]
		public this()
		{
			this = default;
		}

		[Inline]
		public this(float all)
		{
			X = all;
			Y = all;
		}

		[Inline]
		public this(float x, float y)
		{
			X = x;
			Y = y;
		}

		/// Returns the length of the vector.
		[Inline]
		public float Length => (.)Math.Sqrt((.)X * X + Y * Y);

		/// Returns the length of the vector squared. This operation is cheaper than Length.
		[Inline]
		public float LengthSquared => X * X + Y * Y;

		[Inline]
		public bool Equals(Self o) => o == this;

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

		public int GetHashCode()
		{
			var hash = X.GetHashCode();
			hash ^= (hash << 5) + (hash >> 2) + Y.GetHashCode();
			return hash;
		}

		/// Returns the Euclidean distance between the two given points.
		[Inline]
		public float DistanceTo(Self other)
		{
			return (this - other).Length;
		}

		/// Returns the Euclidean distance between the two given points squared.
		[Inline]
		public float DistanceToSquared(Self other)
		{
			return (this - other).LengthSquared;
		}

		/// Rounds the vector to a point.
		[Inline]
		public Point2 ToRounded()
		{
			return Self.Round(this);
		}

		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Vector2.Zero will still just return Vector2.Zero.
		[Inline]
		public Self ToNormalized()
		{
			return Self.Normalize(this);
		}

		/// Rounds the vector to a point.
		[Inline]
		public static Point2 Round(Self vector)
		{
			return .((int)Math.Round(vector.X), (int)Math.Round(vector.Y));
		}

		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Vector2.Zero will still just return Vector2.Zero.
		[Inline]
		public static Self Normalize(Self vector)
		{
			// Normalizing a zero vector is not possible and will return NaN.
			// We ignore this in favor of not NaN-ing vectors.

			return vector == .Zero ? Self.Zero : (Self)vector / vector.Length;
		}

		/// Returns the dot product of two vectors.
		[Inline]
		public static float Dot(Self a, Self b)
		{
			return a.X * b.X + a.Y * b.Y;
		}

		/// Returns the angle of the vector.
		[Inline]
		public static float Angle(Self vector)
		{
			return (.)Math.Atan2(vector.Y, vector.X);
		}

		/// Returns the angle betweem two vectors.
		[Inline]
		public static float Angle(Self from, Self to)
		{
			return (.)Math.Atan2(to.Y - from.Y, to.X - from.X);
		}

		/// Constructs a vector from a given angle and a length.
		[Inline]
		public static Self AngleToVector(float angle, float length = 1)
		{
			return .((.)(Math.Cos(angle) * length), (.)(Math.Sin(angle) * length));
		}

		/// Returns the Euclidean distance between the two given points.
		[Inline]
		public static float Distance(Self a, Self b)
		{
			return (a - b).Length;
		}

		/// Returns the Euclidean distance between the two given points squared.
		[Inline]
		public static float DistanceSquared(Self a, Self b)
		{
			return (a - b).LengthSquared;
		}

		/// Returns the reflection of a vector off a surface that has the specified normal.
		[Inline]
		public static Self Reflect(Self vector, Self normal)
		{
			return vector - (normal * 2 * Self.Dot(vector, normal));
		}

		/// Restricts a vector between a min and max value.
		public static Self Clamp(Self vector, Self min, Self max)
		{
			var x = vector.X;
			x = (x > max.X) ? max.X : x;
			x = (x < min.X) ? min.X : x;

			var y = vector.Y;
			y = (y > max.Y) ? max.Y : y;
			y = (y < min.Y) ? min.Y : y;

			return .(x, y);
		}

		/// Linearly interpolates between two vectors based on the given weighting.
		public static Self Lerp(Self a, Self b, float amount)
		{
			return .(a.X + (b.X - a.X) * amount, a.Y + (b.Y - a.Y) * amount);
		}

		/// Approaches the target vector by a constant given amount.
		public static Self Approach(Self from, Self target, float amount)
		{
			if (from == target)
			{
				return target;
			}
			else
			{
				let diff = target - from;
				if (diff.Length <= amount * amount)
				{
					return target;
				}
				else
				{
					return from + (Self)(Self.Normalize(diff) * amount);
				}
			}
		}

		/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.
		public static Self Min(Self a, Self b)
		{
			return .((a.X < b.X) ? a.X : b.X, (a.Y < b.Y) ? a.Y : b.Y);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Self Max(Self a, Self b)
		{
			return .((a.X > b.X) ? a.X : b.X, (a.Y > b.Y) ? a.Y : b.Y);
		}

		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		[Inline]
		public static Self Abs(Self vector)
		{
			return .(Math.Abs(vector.X), Math.Abs(vector.Y));
		}

		/// Returns a vector whose elements are the square root of each of the source vector's elements.
		[Inline]
		public static Self Sqrt(Self vector)
		{
			return .((.)Math.Sqrt(vector.X), (.)Math.Sqrt(vector.Y));
		}

		public static operator Self((float X, float Y) tuple) => .(tuple.X, tuple.Y);
		[Inline]
		public static operator Self(Point2 a) => .(a.X, a.Y);
		[Inline]
		public static operator Self(UPoint2 a) => .(a.X, a.Y);

		[Inline]
		[Commutable]
		public static bool operator==(Self a, Self b) => a.X == b.X && a.Y == b.Y;

		[Inline]
		public static Self operator+(Self a, Self b) => .(a.X + b.X, a.Y + b.Y);
		[Inline]
		public static Self operator-(Self a, Self b) => .(a.X - b.X, a.Y - b.Y);
		[Inline]
		public static Self operator*(Self a, Self b) => .(a.X * b.X, a.Y * b.Y);
		[Inline]
		public static Self operator/(Self a, Self b) => .(a.X / b.X, a.Y / b.Y);

		[Inline]
		public static Self operator*(float a, Self b) => .(a * b.X, a * b.Y);
		[Inline]
		public static Self operator*(Self a, float b) => .(a.X * b, a.Y * b);
		[Inline]
		public static Self operator/(Self a, float b) => .(a.X / b, a.Y / b);

		[Inline]
		public static Self operator-(Self a) => .(-a.X, -a.Y);
	}
}