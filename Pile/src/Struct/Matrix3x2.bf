// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System;

namespace Pile
{
	[Ordered]
	public struct Matrix3x2 : IFormattable, IEquatable<Matrix3x2>, IEquatable
	{
		public static readonly Matrix3x2 Identity = Matrix3x2(
			1, 0,
			0, 1,
			0, 0);

		public float M11, M12,
					 M21, M22,
					 M31, M32;

		[Inline]
		public bool IsIdentity =>
			{
				M11 == 1f && M22 == 1f && // Check diagonal element first for early out.
				             M12 == 0f &&
				M21 == 0f &&
				M31 == 0f && M32 == 0f
			};

		[Inline]
		/// Calculates the determinant of the matrix.
		public float Determinant =>
			{
			    // There isn't actually any such thing as a determinant for a non-square matrix,
			    // but this 3x2 type is really just an optimization of a 3x3 where we happen to
			    // know the rightmost column is always (0, 0, 1). So we expand to 3x3 format:
			    //
			    //  [ M11, M12, 0 ]
			    //  [ M21, M22, 0 ]
			    //  [ M31, M32, 1 ]
			    //
			    // Sum the diagonal products:
			    //  (M11 * M22 * 1) + (M12 * 0 * M31) + (0 * M21 * M32)
			    //
			    // Subtract the opposite diagonal products:
			    //  (M31 * M22 * 0) + (M32 * 0 * M11) + (1 * M21 * M12)
			    //
			    // Collapse out the constants and oh look, this is just a 2x2 determinant!

				// Evaluate
			    (M11 * M22) - (M21 * M12)
			};

		public Vector2 Translation
		{
			[Inline]
			get => Vector2(M31, M32);
			set mut
			{
				M31 = value.X;
				M32 = value.Y;
			}
		}

		public this(float m11, float m12,
					float m21, float m22,
					float m31, float m32)
		{
			M11 = m11;
			M12 = m12;
			M21 = m21;
			M22 = m22;
			M31 = m31;
			M32 = m32;
		}

		/// Attempts to invert this matrix. If the operation succeeds, the inverted matrix is stored in the .Ok result parameter.
		public Result<Matrix3x2> Invert()
		{
		    float det = (M11 * M22) - (M21 * M12);

		    if (Math.Abs(det) < float.Epsilon)
		    {
		        //result = Matrix3x2(float.NaN, float.NaN, float.NaN, float.NaN, float.NaN, float.NaN);
		        return .Err;
		    }

		    float invDet = 1.0f / det;

			return Matrix3x2(
				M22 * invDet, -M12 * invDet,
				-M21 * invDet, M11 * invDet,
				(M21 * M32 - M31 * M22) * invDet, (M31 * M12 - M11 * M32) * invDet);
		}

		[Inline]
		public bool Equals(Matrix3x2 o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Matrix3x2) && (Matrix3x2)o == this;

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("[[ ");
			M11.ToString(strBuffer);
			strBuffer.Append(", ");	
			M12.ToString(strBuffer);
			strBuffer.Append(" ], ");
			
			strBuffer.Append("[ ");
			M21.ToString(strBuffer);
			strBuffer.Append(", ");	
			M22.ToString(strBuffer);
			strBuffer.Append(" ], ");
			
			strBuffer.Append("[ ");
			M31.ToString(strBuffer);
			strBuffer.Append(", ");	
			M32.ToString(strBuffer);
			strBuffer.Append(" ]]");
		}

		public void ToString(String outString, String format, IFormatProvider formatProvider)
		{
			outString.Append("[[ ");
			M11.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M12.ToString(outString, format, formatProvider);
			outString.Append(" ], ");
			
			outString.Append("[ ");
			M21.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M22.ToString(outString, format, formatProvider);
			outString.Append(" ], ");
			
			outString.Append("[ ");
			M31.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M32.ToString(outString, format, formatProvider);
			outString.Append(" ]]");
		}

		[Inline]
		/// Creates a translation matrix from the given vector.
		public static Matrix3x2 CreateTranslation(Vector2 position)
		{
			return Matrix3x2(
				1, 0,
				0, 1,
				position.X, position.Y);
		}

		[Inline]
		/// Creates a scale matrix from the given X and Y components.
		public static Matrix3x2 CreateScale(float xScale, float yScale)
		{
			return Matrix3x2(
				xScale, 0,
				0, yScale,
				0, 0);
		}

		[Inline]
		/// Creates a scale matrix that is offset by a given center point.
		public static Matrix3x2 CreateScale(float xScale, float yScale, Vector2 centerPoint)
		{
			return Matrix3x2(
				xScale, 0,
				0, yScale,
				centerPoint.X * (1 - xScale), centerPoint.Y * (1 - yScale));
		}

		[Inline]
		/// Creates a scale matrix from the given vector scale.
		public static Matrix3x2 CreateScale(Vector2 scales)
		{
			return Matrix3x2(
				scales.X, 0,
				0, scales.Y,
				0, 0);
		}

		[Inline]
		/// Creates a scale matrix from the given vector scale with an offset from the given center point.
		public static Matrix3x2 CreateScale(Vector2 scales, Vector2 centerPoint)
		{
			return Matrix3x2(
				scales.X, 0,
				0, scales.Y,
				centerPoint.X * (1 - scales.X), centerPoint.Y * (1 - scales.Y));
		}

		[Inline]
		/// Creates a scale matrix that scales uniformly with the given scale.
		public static Matrix3x2 CreateScale(float scale)
		{
		    return Matrix3x2(
				scale, 0,
				0, scale,
				0, 0);
		}

		[Inline]
		/// Creates a scale matrix that scales uniformly with the given scale with an offset from the given center.
		public static Matrix3x2 CreateScale(float scale, Vector2 centerPoint)
		{
			return Matrix3x2(
				scale, 0,
				0, scale,
				centerPoint.X * (1 - scale), centerPoint.Y * (1 - scale));
		}

		[Inline]
		/// Creates a skew matrix from the given angles in radians.
		public static Matrix3x2 CreateSkew(float radiansX, float radiansY)
		{
			return Matrix3x2(
				1, Math.Tan(radiansY),
				Math.Tan(radiansX), 1,
				0, 0);
		}

		[Inline]
		/// Creates a skew matrix from the given angles in radians and a center point.
		public static Matrix3x2 CreateSkew(float radiansX, float radiansY, Vector2 centerPoint)
		{
			float xTan = Math.Tan(radiansX);
			float yTan = Math.Tan(radiansY);

			return Matrix3x2(
				1, yTan,
				xTan, 1,
				-centerPoint.Y * xTan, -centerPoint.X * yTan);
		}

		/// Creates a rotation matrix using the given rotation in radians.
		public static Matrix3x2 CreateRotation(float radians)
		{
		    let rad = Math.IEEERemainder(radians, Math.PI_f * 2);

		    float c, s;

		    const float epsilon = 0.001f * Math.PI_f / 180f;     // 0.1% of a degree

			// Snap to exact rotations
		    if (rad > -epsilon && rad < epsilon)
		    {
		        // Exact case for zero rotation.
		        c = 1;
		        s = 0;
		    }
		    else if (rad > Math.PI_f / 2 - epsilon && rad < Math.PI_f / 2 + epsilon)
		    {
		        // Exact case for 90 degree rotation.
		        c = 0;
		        s = 1;
		    }
		    else if (rad < -Math.PI_f + epsilon || rad > Math.PI_f - epsilon)
		    {
		        // Exact case for 180 degree rotation.
		        c = -1;
		        s = 0;
		    }
		    else if (rad > -Math.PI_f / 2 - epsilon && rad < -Math.PI_f / 2 + epsilon)
		    {
		        // Exact case for 270 degree rotation.
		        c = 0;
		        s = -1;
		    }
		    else
		    {
		        // Arbitrary rotation.
		        c = Math.Cos(rad);
		        s = Math.Sin(rad);
		    }

			return Matrix3x2(
				c, s,
				-s, c,
				0, 0);
		}

		/// Creates a rotation matrix using the given rotation in radians and a center point.
		public static Matrix3x2 CreateRotation(float radians, Vector2 centerPoint)
		{
		    let rad = (float)Math.IEEERemainder(radians, Math.PI_f * 2);

		    float c, s;

		    const float epsilon = 0.001f * Math.PI_f / 180f;     // 0.1% of a degree

			// Snap to exact rotations
		    if (rad > -epsilon && rad < epsilon)
		    {
		        // Exact case for zero rotation.
		        c = 1;
		        s = 0;
		    }
		    else if (rad > Math.PI_f / 2 - epsilon && rad < Math.PI_f / 2 + epsilon)
		    {
		        // Exact case for 90 degree rotation.
		        c = 0;
		        s = 1;
		    }
		    else if (rad < -Math.PI_f + epsilon || rad > Math.PI_f - epsilon)
		    {
		        // Exact case for 180 degree rotation.
		        c = -1;
		        s = 0;
		    }
		    else if (rad > -Math.PI_f / 2 - epsilon && rad < -Math.PI_f / 2 + epsilon)
		    {
		        // Exact case for 270 degree rotation.
		        c = 0;
		        s = -1;
		    }
		    else
		    {
		        // Arbitrary rotation.
		        c = Math.Cos(rad);
		        s = Math.Sin(rad);
		    }

			return Matrix3x2(
				c, s,
				-s, c,
				centerPoint.X * (1 - c) + centerPoint.Y * s, centerPoint.Y * (1 - c) - centerPoint.X * s);
		}

		/// Creates a transform matrix.
		public static Matrix3x2 CreateTransform(Vector2 position, Vector2 scale, float rotation)
		{
			return CreateTranslation(position) * CreateScale(scale) * CreateRotation(rotation);
		}

		/// Creates a transform matrix with origin offset.
		public static Matrix3x2 CreateTransform(Vector2 position, Vector2 origin, Vector2 scale, float rotation)
		{
			var mat = Matrix3x2.Identity;

			if (origin != .Zero)
				mat = CreateTranslation(-origin);
			else
				mat = .Identity;

			if (scale != .One)
				mat = mat * CreateScale(scale);

			if (rotation != 0)
				mat = mat * CreateRotation(rotation);

			if (position != .Zero)
				mat = mat * CreateTranslation(position);

			return mat;
		}

		/// Linearly interpolates from matrix1 to matrix2, based on the third parameter.
		public static Matrix3x2 Lerp(Matrix3x2 matrix1, Matrix3x2 matrix2, float amount)
		{
			return Matrix3x2(
				matrix1.M11 + (matrix2.M11 - matrix1.M11) * amount, matrix1.M12 + (matrix2.M12 - matrix1.M12) * amount,
				matrix1.M21 + (matrix2.M21 - matrix1.M21) * amount, matrix1.M22 + (matrix2.M22 - matrix1.M22) * amount,
				matrix1.M31 + (matrix2.M31 - matrix1.M31) * amount, matrix1.M32 + (matrix2.M32 - matrix1.M32) * amount);
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
				m.M11, m.M12,
				m.M21, m.M22,
				m.M31, m.M32);
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
		        float[2](m.M11, m.M12),
		        float[2](m.M21, m.M22),
		        float[2](m.M31, m.M32));
		}

		public static explicit operator Matrix4x4(Matrix3x2 m)
		{
			return Matrix4x4(
				m.M11, m.M12, 0, 0,
				m.M21, m.M22, 0, 0,
				0,     0,     1, 0,
				m.M31, m.M32, 0, 1);
		}

		public static Matrix3x2 operator-(Matrix3x2 value)
		{
			return Matrix3x2(
				-value.M11, -value.M12,
				-value.M21, -value.M22,
				-value.M31, -value.M32);
		}

		public static Matrix3x2 operator+(Matrix3x2 value1, Matrix3x2 value2)
		{
			return Matrix3x2(
				value1.M11 + value2.M11, value1.M12 + value2.M12,
				value1.M21 + value2.M21, value1.M22 + value2.M22,
				value1.M31 + value2.M31, value1.M32 + value2.M32);
		}

		public static Matrix3x2 operator-(Matrix3x2 value1, Matrix3x2 value2)
		{
			return Matrix3x2(
				value1.M11 - value2.M11, value1.M12 - value2.M12,
				value1.M21 - value2.M21, value1.M22 - value2.M22,
				value1.M31 - value2.M31, value1.M32 - value2.M32);
		}

		public static Matrix3x2 operator*(Matrix3x2 value1, Matrix3x2 value2)
		{
			return Matrix3x2(
				value1.M11 * value2.M11 + value1.M12 * value2.M21, 				value1.M11 * value2.M12 + value1.M12 * value2.M22,
				value1.M21 * value2.M11 + value1.M22 * value2.M21, 				value1.M21 * value2.M12 + value1.M22 * value2.M22,
				value1.M31 * value2.M11 + value1.M32 * value2.M21 + value2.M31, value1.M31 * value2.M12 + value1.M32 * value2.M22 + value2.M32);
		}

		[Commutable]
		public static Matrix3x2 operator*(Matrix3x2 value1, float value2)
		{
			return Matrix3x2(
				value1.M11 * value2, value1.M12 * value2,
				value1.M21 * value2, value1.M22 * value2,
				value1.M31 * value2, value1.M32 * value2);
		}

		public static bool operator ==(Matrix3x2 value1, Matrix3x2 value2)
		{
			return (value1.M11 == value2.M11 && value1.M22 == value2.M22 && // Check diagonal element first for early out.
					                            value1.M12 == value2.M12 &&
					value1.M21 == value2.M21 &&
					value1.M31 == value2.M31 && value1.M32 == value2.M32);
		}

		public static bool operator !=(Matrix3x2 value1, Matrix3x2 value2)
		{
		    return (value1.M11 != value2.M11 || value1.M12 != value2.M12 ||
		            value1.M21 != value2.M21 || value1.M22 != value2.M22 ||
		            value1.M31 != value2.M31 || value1.M32 != value2.M32);
		}
	}
}
