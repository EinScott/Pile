using System;

namespace Pile
{
	extension Vector2
	{
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
	}

	extension Vector3
	{
		public this(Vector2 xy, float z)
		{
			X = xy.X;
			Y = xy.Y;
			Z = z;
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
	}

	extension Vector4
	{
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
	}
}