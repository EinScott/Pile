// Generator=Pile:Pile.VectorGenerator
// name=Point3
// components=3
// type=int
// ftype=float
// ivtype=
// fvtype=Vector3
// compatv=Point2:int:2
// GenHash=9C8BFBA67FD4378EEEFF3AAEDFA03282


// Generated at 3/8/2022 8:33:13 PM. Do not edit file, use extensions!
using System;

namespace Pile
{
	struct Point3 : IFormattable, IEquatable<Point3>, IHashable
	{
		public const Self Zero = .();
		public const Self One = .(1);
		public const Self UnitX = .(1, 0, 0);
		public const Self UnitY = .(0, 1, 0);
		public const Self UnitZ = .(0, 0, 1);
		public const Self NegateX = .(-1, 1, 1);
		public const Self NegateY = .(1, -1, 1);
		public const Self NegateZ = .(1, 1, -1);

		public int X, Y, Z;

		[Inline]
		public this()
		{
			this = default;
		}

		[Inline]
		public this(int all)
		{
			X = all;
			Y = all;
			Z = all;
		}

		[Inline]
		public this(int x, int y, int z)
		{
			X = x;
			Y = y;
			Z = z;
		}

		[Inline]
		public this(Point2 v, int z)
		{
			X = v.X;
			Y = v.Y;
			Z = z;
		}

		/// Returns the length of the vector.
		[Inline]
		public float Length => (.)Math.Sqrt((.)X * X + Y * Y + Z * Z);

		/// Returns the length of the vector squared. This operation is cheaper than Length.
		[Inline]
		public int LengthSquared => X * X + Y * Y + Z * Z;

		[Inline]
		public bool Equals(Self o) => o == this;

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

		public int GetHashCode()
		{
			var hash = X.GetHashCode();
			hash ^= (hash << 5) + (hash >> 2) + Y.GetHashCode();
			hash ^= (hash << 5) + (hash >> 2) + Z.GetHashCode();
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
		public int DistanceToSquared(Self other)
		{
			return (this - other).LengthSquared;
		}

		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Vector2.Zero will still just return Vector2.Zero.
		[Inline]
		public Vector3 ToNormalized()
		{
			return Self.Normalize(this);
		}

		/// Returns a vector with the same direction as the given vector, but with a length of 1.
		/// Vector2.Zero will still just return Vector2.Zero.
		[Inline]
		public static Vector3 Normalize(Self vector)
		{
			// Normalizing a zero vector is not possible and will return NaN.
			// We ignore this in favor of not NaN-ing vectors.

			return vector == .Zero ? Vector3.Zero : (Vector3)vector / vector.Length;
		}

		/// Returns the dot product of two vectors.
		[Inline]
		public static int Dot(Self a, Self b)
		{
			return a.X * b.X + a.Y * b.Y + a.Z * b.Z;
		}

		/// Returns the Euclidean distance between the two given points.
		[Inline]
		public static float Distance(Self a, Self b)
		{
			return (a - b).Length;
		}

		/// Returns the Euclidean distance between the two given points squared.
		[Inline]
		public static int DistanceSquared(Self a, Self b)
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

			var z = vector.Z;
			z = (z > max.Z) ? max.Z : z;
			z = (z < min.Z) ? min.Z : z;

			return .(x, y, z);
		}

		/// Linearly interpolates between two vectors based on the given weighting.
		public static Self Lerp(Self a, Self b, float amount)
		{
			return .(a.X + (.)Math.Round((b.X - a.X) * amount), a.Y + (.)Math.Round((b.Y - a.Y) * amount), a.Z + (.)Math.Round((b.Z - a.Z) * amount));
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
			return .((a.X < b.X) ? a.X : b.X, (a.Y < b.Y) ? a.Y : b.Y, (a.Z < b.Z) ? a.Z : b.Z);
		}

		/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.
		public static Self Max(Self a, Self b)
		{
			return .((a.X > b.X) ? a.X : b.X, (a.Y > b.Y) ? a.Y : b.Y, (a.Z > b.Z) ? a.Z : b.Z);
		}

		/// Returns a vector whose elements are the absolute values of each of the source vector's elements.
		[Inline]
		public static Self Abs(Self vector)
		{
			return .(Math.Abs(vector.X), Math.Abs(vector.Y), Math.Abs(vector.Z));
		}

		/// Returns a vector whose elements are the square root of each of the source vector's elements.
		[Inline]
		public static Vector3 Sqrt(Self vector)
		{
			return .((.)Math.Sqrt(vector.X), (.)Math.Sqrt(vector.Y), (.)Math.Sqrt(vector.Z));
		}

		public static operator Self((int X, int Y, int Z) tuple) => .(tuple.X, tuple.Y, tuple.Z);
		[Inline]
		public static explicit operator Self(Vector3 a) => (.)a.ToRounded();

		[Inline]
		public static explicit operator Self(Point2 a) => .(a.X, a.Y, default);

		[Inline]
		[Commutable]
		public static bool operator==(Self a, Self b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z;

		[Inline]
		public static Self operator+(Self a, Self b) => .(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
		[Inline]
		public static Self operator-(Self a, Self b) => .(a.X - b.X, a.Y - b.Y, a.Z - b.Z);
		[Inline]
		public static Self operator*(Self a, Self b) => .(a.X * b.X, a.Y * b.Y, a.Z * b.Z);
		[Inline]
		public static Self operator/(Self a, Self b) => .(a.X / b.X, a.Y / b.Y, a.Z / b.Z);

		[Inline]
		public static Self operator*(int a, Self b) => .(a * b.X, a * b.Y, a * b.Z);
		[Inline]
		public static Self operator*(Self a, int b) => .(a.X * b, a.Y * b, a.Z * b);
		[Inline]
		public static Self operator/(Self a, int b) => .(a.X / b, a.Y / b, a.Z / b);

		[Inline]
		public static Self operator-(Self a) => .(-a.X, -a.Y, -a.Z);
	}
}