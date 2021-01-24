// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System;

namespace Pile
{
	[Ordered]
	public struct Matrix4x4 //: IFormattable, IEquatable<Matrix4x4>
	{
	    public const Matrix4x4 Identity = Matrix4x4(
	        1, 0, 0, 0,
	        0, 1, 0, 0,
	        0, 0, 1, 0,
	        0, 0, 0, 1);
	
	    public float M11, M12, M13, M14,
	                 M21, M22, M23, M24,
	                 M31, M32, M33, M34,
	                 M41, M42, M43, M44;

		/// Calculates the determinant of the matrix.
		public float Determinant =>
			{
				// | a b c d |     | f g h |     | e g h |     | e f h |     | e f g |
				// | e f g h | = a | j k l | - b | i k l | + c | i j l | - d | i j k |
				// | i j k l |     | n o p |     | m o p |     | m n p |     | m n o |
				// | m n o p |
				//
				//   | f g h |
				// a | j k l | = a ( f ( kp - lo ) - g ( jp - ln ) + h ( jo - kn ) )
				//   | n o p |
				//
				//   | e g h |     
				// b | i k l | = b ( e ( kp - lo ) - g ( ip - lm ) + h ( io - km ) )
				//   | m o p |     
				//
				//   | e f h |
				// c | i j l | = c ( e ( jp - ln ) - f ( ip - lm ) + h ( in - jm ) )
				//   | m n p |
				//
				//   | e f g |
				// d | i j k | = d ( e ( jo - kn ) - f ( io - km ) + g ( in - jm ) )
				//   | m n o |
				//
				// Cost of operation
				// 17 adds and 28 muls.
				//
				// add: 6 + 8 + 3 = 17
				// mul: 12 + 16 = 28

				float a = M11, b = M12, c = M13, d = M14;
				float e = M21, f = M22, g = M23, h = M24;
				float i = M31, j = M32, k = M33, l = M34;
				float m = M41, n = M42, o = M43, p = M44;

				float kp_lo = k * p - l * o;
				float jp_ln = j * p - l * n;
				float jo_kn = j * o - k * n;
				float ip_lm = i * p - l * m;
				float io_km = i * o - k * m;
				float in_jm = i * n - j * m;

				// Evaluate
				a * (f * kp_lo - g * jp_ln + h * jo_kn) -
			    b * (e * kp_lo - g * ip_lm + h * io_km) +
				c * (e * jp_ln - f * ip_lm + h * in_jm) -
			    d * (e * jo_kn - f * io_km + g * in_jm)
			};

		public bool IsIdentity =>
		{
			M11 == 1f && M22 == 1f && M33 == 1f && M44 == 1f && // Check diagonal element first for early out.
						 M12 == 0f && M13 == 0f && M14 == 0f &&
			M21 == 0f && M23 == 0f && M24 == 0f &&
			M31 == 0f && M32 == 0f && M34 == 0f &&
			M41 == 0f && M42 == 0f && M43 == 0f
		};

		public Vector3 Translation
		{
		    get => Vector3(M41, M42, M43);
		    set mut
		    {
		        M41 = value.X;
		        M42 = value.Y;
		        M43 = value.Z;
		    }
		}

	    public this(float m11, float m12, float m13, float m14,
	                float m21, float m22, float m23, float m24,
	                float m31, float m32, float m33, float m34,
	                float m41, float m42, float m43, float m44)
		{
	        M11 = m11;
	        M12 = m12;
	        M13 = m13;
	        M14 = m14;
	        
	        M21 = m21;
	        M22 = m22;
	        M23 = m23;
	        M24 = m24;
	        
	        M31 = m31;
	        M32 = m32;
	        M33 = m33;
	        M34 = m34;
	        
	        M41 = m41;
	        M42 = m42;
	        M43 = m43;
	        M44 = m44;
	    }

		public this(Matrix3x2 value)
		{
		    M11 = value.M11;
		    M12 = value.M12;
		    M13 = 0f;
		    M14 = 0f;
		    M21 = value.M21;
		    M22 = value.M22;
		    M23 = 0f;
		    M24 = 0f;
		    M31 = 0f;
		    M32 = 0f;
		    M33 = 1f;
		    M34 = 0f;
		    M41 = value.M31;
		    M42 = value.M32;
		    M43 = 0f;
		    M44 = 1f;
		}

		/// Attempts to calculate the inverse of this matrix. If successful, result will contain the inverted matrix.
		public Result<Matrix4x4> Invert()
		{
			//                                       -1
			// If you have matrix M, inverse Matrix M   can compute
			//
			//     -1       1      
			//    M   = --------- A
			//            det(M)
			//
			// A is adjugate (adjoint) of M, where,
			//
			//      T
			// A = C
			//
			// C is Cofactor matrix of M, where,
			//           i + j
			// C   = (-1)      * det(M  )
			//  ij                    ij
			//
			//     [ a b c d ]
			// M = [ e f g h ]
			//     [ i j k l ]
			//     [ m n o p ]
			//
			// First Row
			//           2 | f g h |
			// C   = (-1)  | j k l | = + ( f ( kp - lo ) - g ( jp - ln ) + h ( jo - kn ) )
			//  11         | n o p |
			//
			//           3 | e g h |
			// C   = (-1)  | i k l | = - ( e ( kp - lo ) - g ( ip - lm ) + h ( io - km ) )
			//  12         | m o p |
			//
			//           4 | e f h |
			// C   = (-1)  | i j l | = + ( e ( jp - ln ) - f ( ip - lm ) + h ( in - jm ) )
			//  13         | m n p |
			//
			//           5 | e f g |
			// C   = (-1)  | i j k | = - ( e ( jo - kn ) - f ( io - km ) + g ( in - jm ) )
			//  14         | m n o |
			//
			// Second Row
			//           3 | b c d |
			// C   = (-1)  | j k l | = - ( b ( kp - lo ) - c ( jp - ln ) + d ( jo - kn ) )
			//  21         | n o p |
			//
			//           4 | a c d |
			// C   = (-1)  | i k l | = + ( a ( kp - lo ) - c ( ip - lm ) + d ( io - km ) )
			//  22         | m o p |
			//
			//           5 | a b d |
			// C   = (-1)  | i j l | = - ( a ( jp - ln ) - b ( ip - lm ) + d ( in - jm ) )
			//  23         | m n p |
			//
			//           6 | a b c |
			// C   = (-1)  | i j k | = + ( a ( jo - kn ) - b ( io - km ) + c ( in - jm ) )
			//  24         | m n o |
			//
			// Third Row
			//           4 | b c d |
			// C   = (-1)  | f g h | = + ( b ( gp - ho ) - c ( fp - hn ) + d ( fo - gn ) )
			//  31         | n o p |
			//
			//           5 | a c d |
			// C   = (-1)  | e g h | = - ( a ( gp - ho ) - c ( ep - hm ) + d ( eo - gm ) )
			//  32         | m o p |
			//
			//           6 | a b d |
			// C   = (-1)  | e f h | = + ( a ( fp - hn ) - b ( ep - hm ) + d ( en - fm ) )
			//  33         | m n p |
			//
			//           7 | a b c |
			// C   = (-1)  | e f g | = - ( a ( fo - gn ) - b ( eo - gm ) + c ( en - fm ) )
			//  34         | m n o |
			//
			// Fourth Row
			//           5 | b c d |
			// C   = (-1)  | f g h | = - ( b ( gl - hk ) - c ( fl - hj ) + d ( fk - gj ) )
			//  41         | j k l |
			//
			//           6 | a c d |
			// C   = (-1)  | e g h | = + ( a ( gl - hk ) - c ( el - hi ) + d ( ek - gi ) )
			//  42         | i k l |
			//
			//           7 | a b d |
			// C   = (-1)  | e f h | = - ( a ( fl - hj ) - b ( el - hi ) + d ( ej - fi ) )
			//  43         | i j l |
			//
			//           8 | a b c |
			// C   = (-1)  | e f g | = + ( a ( fk - gj ) - b ( ek - gi ) + c ( ej - fi ) )
			//  44         | i j k |
			//
			// Cost of operation
			// 53 adds, 104 muls, and 1 div.
			float a = M11, b = M12, c = M13, d = M14;
			float e = M21, f = M22, g = M23, h = M24;
			float i = M31, j = M32, k = M33, l = M34;
			float m = M41, n = M42, o = M43, p = M44;

			float kp_lo = k * p - l * o;
			float jp_ln = j * p - l * n;
			float jo_kn = j * o - k * n;
			float ip_lm = i * p - l * m;
			float io_km = i * o - k * m;
			float in_jm = i * n - j * m;

			float a11 = +(f * kp_lo - g * jp_ln + h * jo_kn);
			float a12 = -(e * kp_lo - g * ip_lm + h * io_km);
			float a13 = +(e * jp_ln - f * ip_lm + h * in_jm);
			float a14 = -(e * jo_kn - f * io_km + g * in_jm);

			float det = a * a11 + b * a12 + c * a13 + d * a14;

			if (Math.Abs(det) < float.Epsilon)
			{
			    /*result = new Matrix4x4(float.NaN, float.NaN, float.NaN, float.NaN,
			                           float.NaN, float.NaN, float.NaN, float.NaN,
			                           float.NaN, float.NaN, float.NaN, float.NaN,
			                           float.NaN, float.NaN, float.NaN, float.NaN);*/
			    return .Err;
			}

			float invDet = 1.0f / det;

			Matrix4x4 result;

			result.M11 = a11 * invDet;
			result.M21 = a12 * invDet;
			result.M31 = a13 * invDet;
			result.M41 = a14 * invDet;

			result.M12 = -(b * kp_lo - c * jp_ln + d * jo_kn) * invDet;
			result.M22 = +(a * kp_lo - c * ip_lm + d * io_km) * invDet;
			result.M32 = -(a * jp_ln - b * ip_lm + d * in_jm) * invDet;
			result.M42 = +(a * jo_kn - b * io_km + c * in_jm) * invDet;

			float gp_ho = g * p - h * o;
			float fp_hn = f * p - h * n;
			float fo_gn = f * o - g * n;
			float ep_hm = e * p - h * m;
			float eo_gm = e * o - g * m;
			float en_fm = e * n - f * m;

			result.M13 = +(b * gp_ho - c * fp_hn + d * fo_gn) * invDet;
			result.M23 = -(a * gp_ho - c * ep_hm + d * eo_gm) * invDet;
			result.M33 = +(a * fp_hn - b * ep_hm + d * en_fm) * invDet;
			result.M43 = -(a * fo_gn - b * eo_gm + c * en_fm) * invDet;

			float gl_hk = g * l - h * k;
			float fl_hj = f * l - h * j;
			float fk_gj = f * k - g * j;
			float el_hi = e * l - h * i;
			float ek_gi = e * k - g * i;
			float ej_fi = e * j - f * i;

			result.M14 = -(b * gl_hk - c * fl_hj + d * fk_gj) * invDet;
			result.M24 = +(a * gl_hk - c * el_hi + d * ek_gi) * invDet;
			result.M34 = -(a * fl_hj - b * el_hi + d * ej_fi) * invDet;
			result.M44 = +(a * fk_gj - b * ek_gi + c * ej_fi) * invDet;

			return result;
		}

		/// Transforms the given matrix by applying the given Quaternion rotation.
		public Matrix4x4 Transform(Quaternion rotation)
		{
		    // Compute rotation matrix.
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

		    float q11 = 1.0f - yy2 - zz2;
		    float q21 = xy2 - wz2;
		    float q31 = xz2 + wy2;

		    float q12 = xy2 + wz2;
		    float q22 = 1.0f - xx2 - zz2;
		    float q32 = yz2 - wx2;

		    float q13 = xz2 - wy2;
		    float q23 = yz2 + wx2;
		    float q33 = 1.0f - xx2 - yy2;

		    Matrix4x4 result;

		    // First row
		    result.M11 = M11 * q11 + M12 * q21 + M13 * q31;
		    result.M12 = M11 * q12 + M12 * q22 + M13 * q32;
		    result.M13 = M11 * q13 + M12 * q23 + M13 * q33;
		    result.M14 = M14;

		    // Second row
		    result.M21 = M21 * q11 + M22 * q21 + M23 * q31;
		    result.M22 = M21 * q12 + M22 * q22 + M23 * q32;
		    result.M23 = M21 * q13 + M22 * q23 + M23 * q33;
		    result.M24 = M24;

		    // Third row
		    result.M31 = M31 * q11 + M32 * q21 + M33 * q31;
		    result.M32 = M31 * q12 + M32 * q22 + M33 * q32;
		    result.M33 = M31 * q13 + M32 * q23 + M33 * q33;
		    result.M34 = M34;

		    // Fourth row
		    result.M41 = M41 * q11 + M42 * q21 + M43 * q31;
		    result.M42 = M41 * q12 + M42 * q22 + M43 * q32;
		    result.M43 = M41 * q13 + M42 * q23 + M43 * q33;
		    result.M44 = M44;

		    return result;
		}

		/// Transposes the rows and columns of a matrix.
		public Matrix4x4 Transpose()
		{
		    return Matrix4x4(
		        M11, M21, M31, M41,
		        M12, M22, M32, M42,
		        M13, M23, M33, M43,
		        M14, M24, M34, M44 );
		}

		[Inline]
		public bool Equals(Matrix4x4 o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Matrix4x4) && (Matrix4x4)o == this;

		public override void ToString(String strBuffer)
		{
			// Row 1
			strBuffer.Append("[[ ");
			M11.ToString(strBuffer);
			strBuffer.Append(", ");	
			M12.ToString(strBuffer);
			strBuffer.Append(", "); 
			M13.ToString(strBuffer);	
			strBuffer.Append(", "); 
			M14.ToString(strBuffer);
			strBuffer.Append(" ], ");
			// Row 2
			strBuffer.Append("[ ");
			M21.ToString(strBuffer);
			strBuffer.Append(", ");	
			M22.ToString(strBuffer);
			strBuffer.Append(", "); 
			M23.ToString(strBuffer);	
			strBuffer.Append(", "); 
			M24.ToString(strBuffer);
			strBuffer.Append(" ], ");
			// Row 3
			strBuffer.Append("[ ");
			M31.ToString(strBuffer);
			strBuffer.Append(", ");	
			M32.ToString(strBuffer);
			strBuffer.Append(", "); 
			M33.ToString(strBuffer);	
			strBuffer.Append(", "); 
			M34.ToString(strBuffer);
			strBuffer.Append(" ], ");
			// Row 4
			strBuffer.Append("[ ");
			M41.ToString(strBuffer);
			strBuffer.Append(", ");	
			M42.ToString(strBuffer);
			strBuffer.Append(", "); 
			M43.ToString(strBuffer);	
			strBuffer.Append(", "); 
			M44.ToString(strBuffer);
			strBuffer.Append(" ]]");
		}

		public void ToString(String outString, String format, IFormatProvider formatProvider)
		{
			// Row 1
			outString.Append("[[ ");
			M11.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M12.ToString(outString, format, formatProvider);
			outString.Append(", "); 
			M13.ToString(outString, format, formatProvider);	
			outString.Append(", "); 
			M14.ToString(outString, format, formatProvider);
			outString.Append(" ], ");
			// Row 2
			outString.Append("[ ");
			M21.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M22.ToString(outString, format, formatProvider);
			outString.Append(", "); 
			M23.ToString(outString, format, formatProvider);	
			outString.Append(", "); 
			M24.ToString(outString, format, formatProvider);
			outString.Append(" ], ");
			// Row 3
			outString.Append("[ ");
			M31.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M32.ToString(outString, format, formatProvider);
			outString.Append(", "); 
			M33.ToString(outString, format, formatProvider);	
			outString.Append(", "); 
			M34.ToString(outString, format, formatProvider);
			outString.Append(" ], ");
			// Row 4
			outString.Append("[ ");
			M41.ToString(outString, format, formatProvider);
			outString.Append(", ");	
			M42.ToString(outString, format, formatProvider);
			outString.Append(", "); 
			M43.ToString(outString, format, formatProvider);	
			outString.Append(", "); 
			M44.ToString(outString, format, formatProvider);
			outString.Append(" ]]");
		}

		/// Creates a spherical billboard that rotates around a specified object position.
		public static Matrix4x4 CreateBillboard(Vector3 objectPosition, Vector3 cameraPosition, Vector3 cameraUpVector, Vector3 cameraForwardVector)
		{
		    const float epsilon = 1e-4f;

		    Vector3 zaxis = Vector3(
		        objectPosition.X - cameraPosition.X,
		        objectPosition.Y - cameraPosition.Y,
		        objectPosition.Z - cameraPosition.Z);

		    float norm = zaxis.LengthSquared;

		    if (norm < epsilon)
		    {
		        zaxis = -cameraForwardVector;
		    }
		    else
		    {
		        zaxis = zaxis * 1.0f / (float)Math.Sqrt(norm);
		    }

		    Vector3 xaxis = Vector3.Cross(cameraUpVector, zaxis).Normalize();

		    Vector3 yaxis = Vector3.Cross(zaxis, xaxis);

			return Matrix4x4(
				xaxis.X, xaxis.Y, xaxis.Z, 0,
				yaxis.X, yaxis.Y, yaxis.Z, 0,
				zaxis.X, zaxis.Y, zaxis.Z, 0,
				objectPosition.X, objectPosition.Y, objectPosition.Z, 1);
		}

		/// Creates a cylindrical billboard that rotates around a specified axis.
		public static Matrix4x4 CreateConstrainedBillboard(Vector3 objectPosition, Vector3 cameraPosition, Vector3 rotateAxis, Vector3 cameraForwardVector, Vector3 objectForwardVector)
		{
		    const float epsilon = 1e-4f;
		    const float minAngle = 1.0f - (0.1f * (Math.PI_f / 180.0f)); // 0.1 degrees

		    // Treat the case when object and camera positions are too close.
		    Vector3 faceDir = Vector3(
		        objectPosition.X - cameraPosition.X,
		        objectPosition.Y - cameraPosition.Y,
		        objectPosition.Z - cameraPosition.Z);

		    float norm = faceDir.LengthSquared;

		    if (norm < epsilon)
		    {
		        faceDir = -cameraForwardVector;
		    }
		    else
		    {
		        faceDir = faceDir * (1.0f / (float)Math.Sqrt(norm));
		    }

		    Vector3 yaxis = rotateAxis;
		    Vector3 xaxis;
		    Vector3 zaxis;

		    // Treat the case when angle between faceDir and rotateAxis is too close to 0.
		    float dot = Vector3.Dot(rotateAxis, faceDir);

		    if (Math.Abs(dot) > minAngle)
		    {
		        zaxis = objectForwardVector;

		        // Make sure passed values are useful for compute.
		        dot = Vector3.Dot(rotateAxis, zaxis);

		        if (Math.Abs(dot) > minAngle)
		        {
		            zaxis = (Math.Abs(rotateAxis.Z) > minAngle) ? Vector3(1, 0, 0) : Vector3(0, 0, -1);
		        }

		        xaxis = Vector3.Cross(rotateAxis, zaxis).Normalize();
		        zaxis = Vector3.Cross(xaxis, rotateAxis).Normalize();
		    }
		    else
		    {
		        xaxis = Vector3.Cross(rotateAxis, faceDir).Normalize();
		        zaxis = Vector3.Cross(xaxis, yaxis).Normalize();
		    }

			return Matrix4x4(
				xaxis.X, xaxis.Y, xaxis.Z, 0,
				yaxis.X, yaxis.Y, yaxis.Z, 0,
				zaxis.X, zaxis.Y, zaxis.Z, 0,
				objectPosition.X, objectPosition.Y, objectPosition.Z, 1);
		}

		/// Creates a translation matrix.
		public static Matrix4x4 CreateTranslation(Vector3 position)
		{
			return Matrix4x4(
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				position.X, position.Y, position.Z, 1);
		}

		/// Creates a translation matrix.
		public static Matrix4x4 CreateTranslation(Vector2 position)
		{
			return Matrix4x4(
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				position.X, position.Y, 0, 1);
		}

		/// Creates a translation matrix.
		public static Matrix4x4 CreateTranslation(float xPosition, float yPosition, float zPosition)
		{
			return Matrix4x4(
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				xPosition, yPosition, zPosition, 1);
		}

		/// Creates a scaling matrix.
		public static Matrix4x4 CreateScale(float xScale, float yScale, float zScale)
		{
			return Matrix4x4(
				xScale, 0, 0, 0,
				0, yScale, 0, 0,
				0, 0, zScale, 0,
				0, 0, 0, 1);
		}

		/// Creates a scaling matrix with a center point.
		public static Matrix4x4 CreateScale(float xScale, float yScale, float zScale, Vector3 centerPoint)
		{
			return Matrix4x4(
				xScale, 0, 0, 0,
				0, yScale, 0, 0,
				0, 0, zScale, 0,
				centerPoint.X * (1 - xScale), centerPoint.Y * (1 - yScale), centerPoint.Z * (1 - zScale), 1);
		}

		/// Creates a scaling matrix.
		public static Matrix4x4 CreateScale(Vector3 scales)
		{
			return Matrix4x4(
				scales.X, 0, 0, 0,
				0, scales.Y, 0, 0,
				0, 0, scales.Z, 0,
				0, 0, 0, 1);
		}

		/// Creates a scaling matrix.
		public static Matrix4x4 CreateScale(Vector2 scales)
		{
			return Matrix4x4(
				scales.X, 0, 0, 0,
				0, scales.Y, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1);
		}

		/// Creates a scaling matrix with a center point.
		public static Matrix4x4 CreateScale(Vector3 scales, Vector3 centerPoint)
		{
		    return Matrix4x4(
				scales.X, 0, 0, 0,
				0, scales.Y, 0, 0,
				0, 0, scales.Z, 0,
				centerPoint.X * (1 - scales.X), centerPoint.Y * (1 - scales.Y), centerPoint.Z * (1 - scales.Z), 1);
		}

		/// Creates a scaling matrix with a center point.
		public static Matrix4x4 CreateScale(Vector2 scales, Vector2 centerPoint)
		{
		    return Matrix4x4(
				scales.X, 0, 0, 0,
				0, scales.Y, 0, 0,
				0, 0, 1, 0,
				centerPoint.X * (1 - scales.X), centerPoint.Y * (1 - scales.Y), 0, 1);
		}

		/// Creates a uniform scaling matrix that scales equally on each axis.
		public static Matrix4x4 CreateScale(float scale)
		{
		    return Matrix4x4(
				scale, 0, 0, 0,
				0, scale, 0, 0,
				0, 0, scale, 0,
				0, 0, 0, 1);
		}

		/// Creates a uniform scaling matrix that scales equally on each axis with a center point.
		public static Matrix4x4 CreateScale(float scale, Vector3 centerPoint)
		{
		    return Matrix4x4(
				scale, 0, 0, 0,
				0, scale, 0, 0,
				0, 0, scale, 0,
				centerPoint.X * (1 - scale), centerPoint.Y * (1 - scale), centerPoint.Z * (1 - scale), 1);
		}

		/// Creates a matrix for rotating points around the X-axis.
		public static Matrix4x4 CreateRotationX(float radians)
		{
			float c = (float)Math.Cos(radians);
			float s = (float)Math.Sin(radians);

			return Matrix4x4(
				1, 0, 0, 0,
				0, c, s, 0,
				0, -s, c, 0,
				0, 0, 0, 1);
		}

		/// Creates a matrix for rotating points around the X-axis, from a center point.
		public static Matrix4x4 CreateRotationX(float radians, Vector3 centerPoint)
		{
		    float c = (float)Math.Cos(radians);
		    float s = (float)Math.Sin(radians);

			return Matrix4x4(
				1, 0, 0, 0,
				0, c, s, 0,
				0, -s, c, 0,
				0, centerPoint.Y * (1 - c) + centerPoint.Z * s, centerPoint.Z * (1 - c) - centerPoint.Y * s, 1);
		}

		/// Creates a matrix for rotating points around the Y-axis.
		public static Matrix4x4 CreateRotationY(float radians)
		{
		    float c = (float)Math.Cos(radians);
		    float s = (float)Math.Sin(radians);

			return Matrix4x4(
				c, 0, -s, 0,
				0, 1, 0, 0,
				s, 0, c, 0,
				0, 0, 0, 1);
		}

		/// Creates a matrix for rotating points around the Y-axis, from a center point.
		public static Matrix4x4 CreateRotationY(float radians, Vector3 centerPoint)
		{
		    float c = (float)Math.Cos(radians);
		    float s = (float)Math.Sin(radians);

			return Matrix4x4(
				c, 0, -s, 0,
				0, 1, 0, 0,
				s, 0, c, 0,
				centerPoint.X * (1 - c) - centerPoint.Z * s, 0, centerPoint.Z * (1 - c) + centerPoint.X * s, 1);
		}

		/// Creates a matrix for rotating points around the Z-axis.
		public static Matrix4x4 CreateRotationZ(float radians)
		{
		    float c = (float)Math.Cos(radians);
		    float s = (float)Math.Sin(radians);

			return Matrix4x4(
				c, s, 0, 0,
				-s, c, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1);
		}

		/// Creates a matrix for rotating points around the Z-axis, from a center point.
		public static Matrix4x4 CreateRotationZ(float radians, Vector3 centerPoint)
		{
		    float c = (float)Math.Cos(radians);
		    float s = (float)Math.Sin(radians);

			return Matrix4x4(
				c, s, 0, 0,
				-s, c, 0, 0,
				0, 0, 1, 0,
				centerPoint.X * (1 - c) + centerPoint.Y * s, centerPoint.Y * (1 - c) - centerPoint.X * s, 0, 1);
		}

		/// Creates a matrix for rotating points around the Z-axis, from a center point.
		public static Matrix4x4 CreateRotationZ(float radians, Vector2 centerPoint)
		{
		    float c = (float)Math.Cos(radians);
		    float s = (float)Math.Sin(radians);

			return Matrix4x4(
				c, s, 0, 0,
				-s, c, 0, 0,
				0, 0, 1, 0,
				centerPoint.X * (1 - c) + centerPoint.Y * s, centerPoint.Y * (1 - c) - centerPoint.X * s, 0, 1);
		}

		/// Creates a matrix that rotates around an arbitrary vector.
		public static Matrix4x4 CreateFromAxisAngle(Vector3 axis, float angle)
		{
		    // a: angle
		    // x, y, z: unit vector for axis.
		    //
		    // Rotation matrix M can compute by using below equation.
		    //
		    //        T               T
		    //  M = uu + (cos a)( I-uu ) + (sin a)S
		    //
		    // Where:
		    //
		    //  u = ( x, y, z )
		    //
		    //      [  0 -z  y ]
		    //  S = [  z  0 -x ]
		    //      [ -y  x  0 ]
		    //
		    //      [ 1 0 0 ]
		    //  I = [ 0 1 0 ]
		    //      [ 0 0 1 ]
		    //
		    //
		    //     [  xx+cosa*(1-xx)   yx-cosa*yx-sina*z zx-cosa*xz+sina*y ]
		    // M = [ xy-cosa*yx+sina*z    yy+cosa(1-yy)  yz-cosa*yz-sina*x ]
		    //     [ zx-cosa*zx-sina*y zy-cosa*zy+sina*x   zz+cosa*(1-zz)  ]
		    //
		    float x = axis.X, y = axis.Y, z = axis.Z;
		    float sa = (float)Math.Sin(angle), ca = (float)Math.Cos(angle);
		    float xx = x * x, yy = y * y, zz = z * z;
		    float xy = x * y, xz = x * z, yz = y * z;

			Matrix4x4 result;

			result.M11 = xx + ca * (1.0f - xx);
			result.M12 = xy - ca * xy + sa * z;
			result.M13 = xz - ca * xz - sa * y;
			result.M14 = 0.0f;
			result.M21 = xy - ca * xy - sa * z;
			result.M22 = yy + ca * (1.0f - yy);
			result.M23 = yz - ca * yz + sa * x;
			result.M24 = 0.0f;
			result.M31 = xz - ca * xz + sa * y;
			result.M32 = yz - ca * yz - sa * x;
			result.M33 = zz + ca * (1.0f - zz);
			result.M34 = 0.0f;
			result.M41 = 0.0f;
			result.M42 = 0.0f;
			result.M43 = 0.0f;
			result.M44 = 1.0f;

			return result;
		}

		/// Creates a perspective projection matrix based on a field of view, aspect ratio, and near and far view plane distances.
		public static Result<Matrix4x4> CreatePerspectiveFieldOfView(float fieldOfView, float aspectRatio, float nearPlaneDistance, float farPlaneDistance)
		{
		    if (fieldOfView <= 0.0f || fieldOfView >= Math.PI_f)
		        return .Err; // fieldOfView out of range

		    if (nearPlaneDistance <= 0.0f)
		        return .Err; // nearPlaneDistance out of range

		    if (farPlaneDistance <= 0.0f)
		        return .Err; // farPlaneDistance out of range

		    if (nearPlaneDistance >= farPlaneDistance)
		        return .Err; // nearPlaneDistance out of range

		    float yScale = 1.0f / Math.Tan(fieldOfView * 0.5f);

			Matrix4x4 result;

			result.M11 = yScale / aspectRatio;
			result.M12 = result.M13 = result.M14 = 0.0f;

			result.M22 = yScale;
			result.M21 = result.M23 = result.M24 = 0.0f;

			result.M31 = result.M32 = 0.0f;
			result.M33 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
			result.M34 = -1.0f;

			result.M41 = result.M42 = result.M44 = 0.0f;
			result.M43 = nearPlaneDistance * farPlaneDistance / (nearPlaneDistance - farPlaneDistance);

			return result;
		}

		/// Creates a perspective projection matrix from the given view volume dimensions.
		public static Result<Matrix4x4> CreatePerspective(float width, float height, float nearPlaneDistance, float farPlaneDistance)
		{
		    if (nearPlaneDistance <= 0.0f)
		        return .Err; // nearPlaneDistance out of range

		    if (farPlaneDistance <= 0.0f)
		        return .Err; // farPlaneDistance out of range

		    if (nearPlaneDistance >= farPlaneDistance)
		        return .Err; // nearPlaneDistance out of range

			Matrix4x4 result;

			result.M11 = 2.0f * nearPlaneDistance / width;
			result.M12 = result.M13 = result.M14 = 0.0f;

			result.M22 = 2.0f * nearPlaneDistance / height;
			result.M21 = result.M23 = result.M24 = 0.0f;

			result.M33 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
			result.M31 = result.M32 = 0.0f;
			result.M34 = -1.0f;

			result.M41 = result.M42 = result.M44 = 0.0f;
			result.M43 = nearPlaneDistance * farPlaneDistance / (nearPlaneDistance - farPlaneDistance);

			return result;
		}

		/// Creates a customized, perspective projection matrix.
		public static Result<Matrix4x4> CreatePerspectiveOffCenter(float left, float right, float bottom, float top, float nearPlaneDistance, float farPlaneDistance)
		{
		    if (nearPlaneDistance <= 0.0f)
		        return .Err; // nearPlaneDistance out of range

		    if (farPlaneDistance <= 0.0f)
		        return .Err; // farPlaneDistance out of range

		    if (nearPlaneDistance >= farPlaneDistance)
		        return .Err; // nearPlaneDistance out of range

			Matrix4x4 result;

			result.M11 = 2.0f * nearPlaneDistance / (right - left);
			result.M12 = result.M13 = result.M14 = 0.0f;

			result.M22 = 2.0f * nearPlaneDistance / (top - bottom);
			result.M21 = result.M23 = result.M24 = 0.0f;

			result.M31 = (left + right) / (right - left);
			result.M32 = (top + bottom) / (top - bottom);
			result.M33 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
			result.M34 = -1.0f;

			result.M43 = nearPlaneDistance * farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
			result.M41 = result.M42 = result.M44 = 0.0f;

			return result;
		}

		/// Creates an orthographic perspective matrix from the given view volume dimensions.
		public static Matrix4x4 CreateOrthographic(float width, float height, float zNearPlane, float zFarPlane)
		{
			Matrix4x4 result;

			result.M11 = 2.0f / width;
			result.M12 = result.M13 = result.M14 = 0.0f;

			result.M22 = 2.0f / height;
			result.M21 = result.M23 = result.M24 = 0.0f;

			result.M33 = 1.0f / (zNearPlane - zFarPlane);
			result.M31 = result.M32 = result.M34 = 0.0f;

			result.M41 = result.M42 = 0.0f;
			result.M43 = zNearPlane / (zNearPlane - zFarPlane);
			result.M44 = 1.0f;

			return result;
		}

		/// Builds a customized, orthographic projection matrix.
		public static Matrix4x4 CreateOrthographicOffCenter(float left, float right, float bottom, float top, float zNearPlane, float zFarPlane)
		{
			Matrix4x4 result;

			result.M11 = 2.0f / (right - left);
			result.M12 = result.M13 = result.M14 = 0.0f;

			result.M22 = 2.0f / (top - bottom);
			result.M21 = result.M23 = result.M24 = 0.0f;

			result.M33 = 1.0f / (zNearPlane - zFarPlane);
			result.M31 = result.M32 = result.M34 = 0.0f;

			result.M41 = (left + right) / (left - right);
			result.M42 = (top + bottom) / (bottom - top);
			result.M43 = zNearPlane / (zNearPlane - zFarPlane);
			result.M44 = 1.0f;

			return result;
		}

		/// Creates a view matrix.
		public static Matrix4x4 CreateLookAt(Vector3 cameraPosition, Vector3 cameraTarget, Vector3 cameraUpVector)
		{
		    Vector3 zaxis = (cameraPosition - cameraTarget).Normalize();
		    Vector3 xaxis = Vector3.Cross(cameraUpVector, zaxis).Normalize();
		    Vector3 yaxis = Vector3.Cross(zaxis, xaxis);

			Matrix4x4 result;

			result.M11 = xaxis.X;
			result.M12 = yaxis.X;
			result.M13 = zaxis.X;
			result.M14 = 0.0f;
			result.M21 = xaxis.Y;
			result.M22 = yaxis.Y;
			result.M23 = zaxis.Y;
			result.M24 = 0.0f;
			result.M31 = xaxis.Z;
			result.M32 = yaxis.Z;
			result.M33 = zaxis.Z;
			result.M34 = 0.0f;
			result.M41 = -Vector3.Dot(xaxis, cameraPosition);
			result.M42 = -Vector3.Dot(yaxis, cameraPosition);
			result.M43 = -Vector3.Dot(zaxis, cameraPosition);
			result.M44 = 1.0f;

			return result;
		}

		/// Creates a world matrix with the specified parameters.
		public static Matrix4x4 CreateWorld(Vector3 position, Vector3 forward, Vector3 up)
		{
		    Vector3 zaxis = (-forward).Normalize();
		    Vector3 xaxis = Vector3.Cross(up, zaxis).Normalize();
		    Vector3 yaxis = Vector3.Cross(zaxis, xaxis);

			Matrix4x4 result;

			result.M11 = xaxis.X;
			result.M12 = xaxis.Y;
			result.M13 = xaxis.Z;
			result.M14 = 0.0f;
			result.M21 = yaxis.X;
			result.M22 = yaxis.Y;
			result.M23 = yaxis.Z;
			result.M24 = 0.0f;
			result.M31 = zaxis.X;
			result.M32 = zaxis.Y;
			result.M33 = zaxis.Z;
			result.M34 = 0.0f;
			result.M41 = position.X;
			result.M42 = position.Y;
			result.M43 = position.Z;
			result.M44 = 1.0f;

			return result;
		}

		/// Creates a rotation matrix from the given Quaternion rotation value.
		public static Matrix4x4 CreateFromQuaternion(Quaternion quaternion)
		{
		    float xx = quaternion.X * quaternion.X;
		    float yy = quaternion.Y * quaternion.Y;
		    float zz = quaternion.Z * quaternion.Z;

		    float xy = quaternion.X * quaternion.Y;
		    float wz = quaternion.Z * quaternion.W;
		    float xz = quaternion.Z * quaternion.X;
		    float wy = quaternion.Y * quaternion.W;
		    float yz = quaternion.Y * quaternion.Z;
		    float wx = quaternion.X * quaternion.W;

			Matrix4x4 result;

			result.M11 = 1.0f - 2.0f * (yy + zz);
			result.M12 = 2.0f * (xy + wz);
			result.M13 = 2.0f * (xz - wy);
			result.M14 = 0.0f;
			result.M21 = 2.0f * (xy - wz);
			result.M22 = 1.0f - 2.0f * (zz + xx);
			result.M23 = 2.0f * (yz + wx);
			result.M24 = 0.0f;
			result.M31 = 2.0f * (xz + wy);
			result.M32 = 2.0f * (yz - wx);
			result.M33 = 1.0f - 2.0f * (yy + xx);
			result.M34 = 0.0f;
			result.M41 = 0.0f;
			result.M42 = 0.0f;
			result.M43 = 0.0f;
			result.M44 = 1.0f;

			return result;
		}

		/// Creates a rotation matrix from the specified yaw, pitch, and roll.
		public static Matrix4x4 CreateFromYawPitchRoll(float yaw, float pitch, float roll)
		{
		    Quaternion q = Quaternion.CreateFromYawPitchRoll(yaw, pitch, roll);

		    return Matrix4x4.CreateFromQuaternion(q);
		}

		/*/// Creates a Matrix that flattens geometry into a specified Plane as if casting a shadow from a specified light source.
		public static Matrix4x4 CreateShadow(Vector3 lightDirection, Plane plane)
		{
		    Plane p = plane.Normalize();

		    float dot = p.Normal.X * lightDirection.X + p.Normal.Y * lightDirection.Y + p.Normal.Z * lightDirection.Z;
		    float a = -p.Normal.X;
		    float b = -p.Normal.Y;
		    float c = -p.Normal.Z;
		    float d = -p.D;

			Matrix4x4 result;

			result.M11 = a * lightDirection.X + dot;
			result.M21 = b * lightDirection.X;
			result.M31 = c * lightDirection.X;
			result.M41 = d * lightDirection.X;

			result.M12 = a * lightDirection.Y;
			result.M22 = b * lightDirection.Y + dot;
			result.M32 = c * lightDirection.Y;
			result.M42 = d * lightDirection.Y;

			result.M13 = a * lightDirection.Z;
			result.M23 = b * lightDirection.Z;
			result.M33 = c * lightDirection.Z + dot;
			result.M43 = d * lightDirection.Z;

			result.M14 = 0.0f;
			result.M24 = 0.0f;
			result.M34 = 0.0f;
			result.M44 = dot;

			return result;
		}*/

		/*/// Creates a Matrix that reflects the coordinate system about a specified Plane.
		public static Matrix4x4 CreateReflection(Plane value)
		{
			var value;
		    value = value.Normalize();

		    float a = value.Normal.X;
		    float b = value.Normal.Y;
		    float c = value.Normal.Z;

		    float fa = -2.0f * a;
		    float fb = -2.0f * b;
		    float fc = -2.0f * c;

		    Matrix4x4 result;

		    result.M11 = fa * a + 1.0f;
		    result.M12 = fb * a;
		    result.M13 = fc * a;
		    result.M14 = 0.0f;

		    result.M21 = fa * b;
		    result.M22 = fb * b + 1.0f;
		    result.M23 = fc * b;
		    result.M24 = 0.0f;

		    result.M31 = fa * c;
		    result.M32 = fb * c;
		    result.M33 = fc * c + 1.0f;
		    result.M34 = 0.0f;

		    result.M41 = fa * value.D;
		    result.M42 = fb * value.D;
		    result.M43 = fc * value.D;
		    result.M44 = 1.0f;

		    return result;
		}*/

		struct CanonicalBasis
		{
		    public Vector3 Row0;
		    public Vector3 Row1;
		    public Vector3 Row2;
		};

		struct VectorBasis
		{
		    public Vector3* Element0;
		    public Vector3* Element1;
		    public Vector3* Element2;
		}

		/// Attempts to extract the scale, translation, and rotation components from the given scale/rotation/translation matrix.
		public static bool Decompose(Matrix4x4 matrix, out Vector3 scale, out Quaternion rotation, out Vector3 translation)
		{
		    bool result = true;

            float* pfScales = (float*)&scale;
            const float EPSILON = 0.0001f;
            float det;

            VectorBasis vectorBasis;
            Vector3** pVectorBasis = (Vector3**)&vectorBasis;

            Matrix4x4 matTemp = Matrix4x4.Identity;
            CanonicalBasis canonicalBasis = CanonicalBasis();
            Vector3* pCanonicalBasis = &canonicalBasis.Row0;

            canonicalBasis.Row0 = Vector3(1.0f, 0.0f, 0.0f);
            canonicalBasis.Row1 = Vector3(0.0f, 1.0f, 0.0f);
            canonicalBasis.Row2 = Vector3(0.0f, 0.0f, 1.0f);

            translation = Vector3(
                matrix.M41,
                matrix.M42,
                matrix.M43);

            pVectorBasis[0] = (Vector3*)&matTemp.M11;
            pVectorBasis[1] = (Vector3*)&matTemp.M21;
            pVectorBasis[2] = (Vector3*)&matTemp.M31;

            *(pVectorBasis[0]) = Vector3(matrix.M11, matrix.M12, matrix.M13);
            *(pVectorBasis[1]) = Vector3(matrix.M21, matrix.M22, matrix.M23);
            *(pVectorBasis[2]) = Vector3(matrix.M31, matrix.M32, matrix.M33);

            scale.X = pVectorBasis[0].Length;
            scale.Y = pVectorBasis[1].Length;
            scale.Z = pVectorBasis[2].Length;

            uint a, b, c;
            #region Ranking
            float x = pfScales[0], y = pfScales[1], z = pfScales[2];
            if (x < y)
            {
                if (y < z)
                {
                    a = 2;
                    b = 1;
                    c = 0;
                }
                else
                {
                    a = 1;

                    if (x < z)
                    {
                        b = 2;
                        c = 0;
                    }
                    else
                    {
                        b = 0;
                        c = 2;
                    }
                }
            }
            else
            {
                if (x < z)
                {
                    a = 2;
                    b = 0;
                    c = 1;
                }
                else
                {
                    a = 0;

                    if (y < z)
                    {
                        b = 2;
                        c = 1;
                    }
                    else
                    {
                        b = 1;
                        c = 2;
                    }
                }
            }
            #endregion

            if (pfScales[a] < EPSILON)
            {
                *(pVectorBasis[a]) = pCanonicalBasis[a];
            }

            *pVectorBasis[a] = (*pVectorBasis[a]).Normalize();

            if (pfScales[b] < EPSILON)
            {
                uint cc;
                float fAbsX, fAbsY, fAbsZ;

                fAbsX = Math.Abs(pVectorBasis[a].X);
                fAbsY = Math.Abs(pVectorBasis[a].Y);
                fAbsZ = Math.Abs(pVectorBasis[a].Z);

                #region Ranking
                if (fAbsX < fAbsY)
                {
                    if (fAbsY < fAbsZ)
                    {
                        cc = 0;
                    }
                    else
                    {
                        if (fAbsX < fAbsZ)
                        {
                            cc = 0;
                        }
                        else
                        {
                            cc = 2;
                        }
                    }
                }
                else
                {
                    if (fAbsX < fAbsZ)
                    {
                        cc = 1;
                    }
                    else
                    {
                        if (fAbsY < fAbsZ)
                        {
                            cc = 1;
                        }
                        else
                        {
                            cc = 2;
                        }
                    }
                }
                #endregion

                *pVectorBasis[b] = Vector3.Cross(*pVectorBasis[a], *(pCanonicalBasis + cc));
            }

            *pVectorBasis[b] = (*pVectorBasis[b]).Normalize();

            if (pfScales[c] < EPSILON)
            {
                *pVectorBasis[c] = Vector3.Cross(*pVectorBasis[a], *pVectorBasis[b]);
            }

            *pVectorBasis[c] = (*pVectorBasis[c]).Normalize();

            det = matTemp.Determinant;

            // use Kramer's rule to check for handedness of coordinate system
            if (det < 0.0f)
            {
                // switch coordinate system by negating the scale and inverting the basis vector on the x-axis
                pfScales[a] = -pfScales[a];
                *pVectorBasis[a] = -(*pVectorBasis[a]);

                det = -det;
            }

            det -= 1.0f;
            det *= det;

            if ((EPSILON < det))
            {
                // Non-SRT matrix encountered
                rotation = Quaternion.Identity;
                result = false;
            }
            else
            {
                // generate the quaternion from the matrix
                rotation = Quaternion.CreateFromRotationMatrix(matTemp);
            }

		    return result;
		}

		/// Linearly interpolates between the corresponding values of two matrices.
		public static Matrix4x4 Lerp(Matrix4x4 matrix1, Matrix4x4 matrix2, float amount)
		{
		    Matrix4x4 result;

		    // First row
		    result.M11 = matrix1.M11 + (matrix2.M11 - matrix1.M11) * amount;
		    result.M12 = matrix1.M12 + (matrix2.M12 - matrix1.M12) * amount;
		    result.M13 = matrix1.M13 + (matrix2.M13 - matrix1.M13) * amount;
		    result.M14 = matrix1.M14 + (matrix2.M14 - matrix1.M14) * amount;

		    // Second row
		    result.M21 = matrix1.M21 + (matrix2.M21 - matrix1.M21) * amount;
		    result.M22 = matrix1.M22 + (matrix2.M22 - matrix1.M22) * amount;
		    result.M23 = matrix1.M23 + (matrix2.M23 - matrix1.M23) * amount;
		    result.M24 = matrix1.M24 + (matrix2.M24 - matrix1.M24) * amount;

		    // Third row
		    result.M31 = matrix1.M31 + (matrix2.M31 - matrix1.M31) * amount;
		    result.M32 = matrix1.M32 + (matrix2.M32 - matrix1.M32) * amount;
		    result.M33 = matrix1.M33 + (matrix2.M33 - matrix1.M33) * amount;
		    result.M34 = matrix1.M34 + (matrix2.M34 - matrix1.M34) * amount;

		    // Fourth row
		    result.M41 = matrix1.M41 + (matrix2.M41 - matrix1.M41) * amount;
		    result.M42 = matrix1.M42 + (matrix2.M42 - matrix1.M42) * amount;
		    result.M43 = matrix1.M43 + (matrix2.M43 - matrix1.M43) * amount;
		    result.M44 = matrix1.M44 + (matrix2.M44 - matrix1.M44) * amount;

		    return result;
		}
	
	    public static explicit operator Matrix4x4(float[16] m)
		{
	        return Matrix4x4(
	            m[0], m[1], m[2], m[3],
	            m[4], m[5], m[6], m[7],
	            m[8], m[9], m[10], m[11],
	            m[12], m[13], m[14], m[15]);
	    }
	
	    public static explicit operator float[16](Matrix4x4 m)
		{
	        return float[16](
	            m.M11, m.M12, m.M13, m.M14,
	            m.M21, m.M22, m.M23, m.M24,
	            m.M31, m.M32, m.M33, m.M34,
	            m.M41, m.M42, m.M43, m.M44);
	    }
	
	    public static explicit operator Matrix4x4(float[4][4] m)
		{
	        return Matrix4x4(
	            m[0][0], m[0][1], m[0][2], m[0][3],
	            m[1][0], m[1][1], m[1][2], m[1][3],
	            m[2][0], m[2][1], m[2][2], m[2][3],
	            m[3][0], m[3][1], m[3][2], m[3][3]);
	    }
	
	    public static explicit operator float[4][4](Matrix4x4 m)
		{
	        return float[4][4](
	            float[4]( m.M11, m.M12, m.M13, m.M14),
	            float[4]( m.M21, m.M22, m.M23, m.M24),
	            float[4]( m.M31, m.M32, m.M33, m.M34),
	            float[4]( m.M41, m.M42, m.M43, m.M44));
	    }
	
	    public static bool operator ==(Matrix4x4 a, Matrix4x4 b)
		{
		    return (a.M11 == b.M11 && a.M22 == b.M22 && a.M33 == b.M33 && a.M44 == b.M44 && // Check diagonal element first for early out.
		                                        a.M12 == b.M12 && a.M13 == b.M13 && a.M14 == b.M14 &&
		            a.M21 == b.M21 && a.M23 == b.M23 && a.M24 == b.M24 &&
		            a.M31 == b.M31 && a.M32 == b.M32 && a.M34 == b.M34 &&
		            a.M41 == b.M41 && a.M42 == b.M42 && a.M43 == b.M43);
		}
	
		public static bool operator!=(Matrix4x4 a, Matrix4x4 b)
		{
			return a.M11 != b.M11 || a.M12 != b.M12 || a.M13 != b.M13 || a.M14 != b.M14
	            || a.M21 != b.M21 || a.M22 != b.M22 || a.M23 != b.M23 || a.M24 != b.M24
	            || a.M31 != b.M31 || a.M32 != b.M32 || a.M33 != b.M33 || a.M34 != b.M34
	            || a.M41 != b.M41 || a.M42 != b.M42 || a.M43 != b.M43 || a.M44 != b.M44;
		}

		public static Matrix4x4 operator-(Matrix4x4 value)
		{
		    return Matrix4x4(
			    -value.M11,
			    -value.M12,
			    -value.M13,
			    -value.M14,
			    -value.M21,
			    -value.M22,
			    -value.M23,
			    -value.M24,
			    -value.M31,
			    -value.M32,
			    -value.M33,
			    -value.M34,
			    -value.M41,
			    -value.M42,
			    -value.M43,
			    -value.M44);
		}

		public static Matrix4x4 operator +(Matrix4x4 value1, Matrix4x4 value2)
		{
		    return Matrix4x4(
			    value1.M11 + value2.M11,
			    value1.M12 + value2.M12,
			    value1.M13 + value2.M13,
			    value1.M14 + value2.M14,
			    value1.M21 + value2.M21,
			    value1.M22 + value2.M22,
			    value1.M23 + value2.M23,
			    value1.M24 + value2.M24,
			    value1.M31 + value2.M31,
			    value1.M32 + value2.M32,
			    value1.M33 + value2.M33,
			    value1.M34 + value2.M34,
			    value1.M41 + value2.M41,
			    value1.M42 + value2.M42,
			    value1.M43 + value2.M43,
			    value1.M44 + value2.M44);
		}

		public static Matrix4x4 operator -(Matrix4x4 value1, Matrix4x4 value2)
		{
		    return Matrix4x4(
			    value1.M11 - value2.M11,
			    value1.M12 - value2.M12,
			    value1.M13 - value2.M13,
			    value1.M14 - value2.M14,
			    value1.M21 - value2.M21,
			    value1.M22 - value2.M22,
			    value1.M23 - value2.M23,
			    value1.M24 - value2.M24,
			    value1.M31 - value2.M31,
			    value1.M32 - value2.M32,
			    value1.M33 - value2.M33,
			    value1.M34 - value2.M34,
			    value1.M41 - value2.M41,
			    value1.M42 - value2.M42,
			    value1.M43 - value2.M43,
			    value1.M44 - value2.M44);
		}

		public static Matrix4x4 operator*(Matrix4x4 a, Matrix4x4 b)
		{
	        return Matrix4x4(
	            // Row 1
	            a.M11*b.M11 + a.M12*b.M21 + a.M13*b.M31 + a.M14*b.M41,
	            a.M11*b.M12 + a.M12*b.M22 + a.M13*b.M32 + a.M14*b.M42,
	            a.M11*b.M13 + a.M12*b.M23 + a.M13*b.M33 + a.M14*b.M43,
	            a.M11*b.M14 + a.M12*b.M24 + a.M13*b.M34 + a.M14*b.M44,
	            // Row 2
	            a.M21*b.M11 + a.M22*b.M21 + a.M23*b.M31 + a.M24*b.M41,
	            a.M21*b.M12 + a.M22*b.M22 + a.M23*b.M32 + a.M24*b.M42,
	            a.M21*b.M13 + a.M22*b.M23 + a.M23*b.M33 + a.M24*b.M43,
	            a.M21*b.M14 + a.M22*b.M24 + a.M23*b.M34 + a.M24*b.M44,
	            // Row 3
	            a.M31*b.M11 + a.M32*b.M21 + a.M33*b.M31 + a.M34*b.M41,
	            a.M31*b.M12 + a.M32*b.M22 + a.M33*b.M32 + a.M34*b.M42,
	            a.M31*b.M13 + a.M32*b.M23 + a.M33*b.M33 + a.M34*b.M43,
	            a.M31*b.M14 + a.M32*b.M24 + a.M33*b.M34 + a.M34*b.M44,
	            // Row 4
	            a.M41*b.M11 + a.M42*b.M21 + a.M43*b.M31 + a.M44*b.M41,
	            a.M41*b.M12 + a.M42*b.M22 + a.M43*b.M32 + a.M44*b.M42,
	            a.M41*b.M13 + a.M42*b.M23 + a.M43*b.M33 + a.M44*b.M43,
	            a.M41*b.M14 + a.M42*b.M24 + a.M43*b.M34 + a.M44*b.M44);
		}
	
		public static Matrix4x4 operator*(Matrix4x4 a, Vector4 b)
		{
	        return Matrix4x4(
	            a.M11*b.X, a.M12*b.X, a.M13*b.X, a.M14*b.X,
	            a.M21*b.Y, a.M22*b.Y, a.M23*b.Y, a.M24*b.Y,
	            a.M31*b.Z, a.M32*b.Z, a.M33*b.Z, a.M34*b.Z,
	            a.M41*b.W, a.M42*b.W, a.M43*b.W, a.M44*b.W);
		}
	
		public static Matrix4x4 operator*(Vector4 b, Matrix4x4 a)
		{
		    return Matrix4x4(
		        a.M11*b.X, a.M12*b.X, a.M13*b.X, a.M14*b.X,
		        a.M21*b.Y, a.M22*b.Y, a.M23*b.Y, a.M24*b.Y,
		        a.M31*b.Z, a.M32*b.Z, a.M33*b.Z, a.M34*b.Z,
		        a.M41*b.W, a.M42*b.W, a.M43*b.W, a.M44*b.W);
		}
	
		public static Matrix4x4 operator*(Matrix4x4 a, float b)
		{
	        return Matrix4x4(
	            a.M11*b, a.M12*b, a.M13*b, a.M14*b,
	            a.M21*b, a.M22*b, a.M23*b, a.M24*b,
	            a.M31*b, a.M32*b, a.M33*b, a.M34*b,
	            a.M41*b, a.M42*b, a.M43*b, a.M44*b);
		}
	
		public static Matrix4x4 operator*(float a, Matrix4x4 b)
		{
	        return Matrix4x4(
	            a*b.M11, a*b.M12, a*b.M13, a*b.M14,
	            a*b.M11, a*b.M12, a*b.M13, a*b.M14,
	            a*b.M11, a*b.M12, a*b.M13, a*b.M14,
	            a*b.M11, a*b.M12, a*b.M13, a*b.M14);
		}
	}
}
