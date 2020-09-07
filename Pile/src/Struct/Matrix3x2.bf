using System;

namespace Pile
{
	[Packed]
	[Ordered]
	public struct Matrix3x2 : IFormattable
	{
		public static readonly Matrix3x2 Identity = Matrix3x2(
			1, 0,
			0, 1,
			0, 0);

		public float m11, m12,
					 m21, m22,
					 m31, m32;

		public this(float m11, float m12,
					float m21, float m22,
					float m31, float m32)
		{
			this.m11 = m11;
			this.m12 = m12;
			this.m21 = m21;
			this.m22 = m22;
			this.m31 = m31;
			this.m32 = m32;
		}

		public static Matrix3x2 FromPosition(Vector position)
		{
			return Matrix3x2(
				1, 0,
				0, 1,
				position.X, position.Y);
		}

		public static Matrix3x2 FromScale(Vector scale)
		{
			return Matrix3x2(
				scale.X, 0,
				0, scale.Y,
				0, 0);
		}

		public static Matrix3x2 FromRotation(float rotation)
		{
			let c = Math.Cos(rotation);
			let s = Math.Sign(rotation);

			return Matrix3x2(
				c, s,
				-s, s,
				0, 0);
		}

		public static Matrix3x2 FromTransform(Vector position, Vector scale, float rotation)
		{
			return FromPosition(position) * FromScale(scale) * FromRotation(rotation);
		}

		public static Matrix3x2 FromTransform(Vector position, Vector origin, Vector scale, float rotation)
		{
			var mat = Matrix3x2.Identity;

			if (origin != .Zero)
				mat = FromPosition(-origin);
			else
				mat = .Identity;

			if (scale != .One)
				mat *= FromScale(scale);

			if (rotation != 0)
				mat *= FromRotation(rotation);

			if (position != .Zero)
				mat *= FromPosition(position);

			return mat;
		}

		public void ToString(String outString, String format, IFormatProvider formatProvider)
		{
			// Row 1
			outString.Append("|");
			m11.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m12.ToString(outString, format, formatProvider);
			outString.Append("|\n");
			// Row 2
			outString.Append("|");
			m21.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m22.ToString(outString, format, formatProvider);
			outString.Append("|\n");
			// Row 3
			outString.Append("|");
			m31.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m32.ToString(outString, format, formatProvider);
			outString.Append("|");
		}

		public static explicit operator Matrix3x2(float[6] m)
		{
			return Matrix3x2(
				m[0], m[1],
				m[2], m[3],
				m[4], m[5]);
		}

		public static explicit operator float[6](Matrix3x2 m)
		{
			return float[6](
				m.m11, m.m12,
				m.m21, m.m22,
				m.m31, m.m32);
		}

		public static explicit operator Matrix3x2(float[3][2] m)
		{
		    return Matrix3x2(
		        m[0][0], m[0][1],
		        m[1][0], m[1][1],
		        m[2][0], m[2][1]);
		}

		public static explicit operator float[3][2](Matrix3x2 m)
		{
		    return float[3][2](
		        float[2](m.m11, m.m12),
		        float[2](m.m21, m.m22),
		        float[2](m.m31, m.m32));
		}

		public static explicit operator Matrix4x4(Matrix3x2 m)
		{
			return Matrix4x4(
				m.m11, m.m12, 0, 0,
				m.m21, m.m22, 0, 0,
				0,     0,     1, 0,
				m.m31, m.m32, 0, 1);
		}

		public static bool operator==(Matrix3x2 a, Matrix3x2 b)
		{
			return a.m11 == b.m11 && a.m12 == b.m12
		        && a.m21 == b.m21 && a.m22 == b.m22
		        && a.m31 == b.m31 && a.m32 == b.m32;
		}

		public static bool operator!=(Matrix3x2 a, Matrix3x2 b)
		{
			return a.m11 != b.m11 || a.m12 != b.m12
		        || a.m21 != b.m21 || a.m22 != b.m22
		        || a.m31 != b.m31 || a.m32 != b.m32;
		}

		public static Matrix3x2 operator*(Matrix3x2 a, Matrix3x2 b)
		{
			return Matrix3x2(
				(a.m11 * b.m11) + (a.m12 * b.m21),
				(a.m11 * b.m12) + (a.m12 * b.m22),
				(a.m21 * b.m11) + (a.m22 * b.m21),
				(a.m21 * b.m12) + (a.m22 * b.m22),
				(a.m31 * b.m11) + (a.m32 * b.m21) + b.m31,
				(a.m31 * b.m12) + (a.m32 * b.m22) + b.m32);
		}
	}
}
