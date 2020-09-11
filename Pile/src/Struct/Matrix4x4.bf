using System;

namespace Pile
{
	[Packed]
	[Ordered]
	public struct Matrix4x4 : IFormattable
	{

	    public static readonly Matrix4x4 Identity = Matrix4x4(
	        1, 0, 0, 0,
	        0, 1, 0, 0,
	        0, 0, 1, 0,
	        0, 0, 0, 1 );
	
	    public float m11, m12, m13, m14,
	                 m21, m22, m23, m24,
	                 m31, m32, m33, m34,
	                 m41, m42, m43, m44;
	
	    public this(float m11, float m12, float m13, float m14,
	                float m21, float m22, float m23, float m24,
	                float m31, float m32, float m33, float m34,
	                float m41, float m42, float m43, float m44)
		{
	
	        // Row 1
	        this.m11 = m11;
	        this.m12 = m12;
	        this.m13 = m13;
	        this.m14 = m14;
	        // Row 2
	        this.m21 = m21;
	        this.m22 = m22;
	        this.m23 = m23;
	        this.m24 = m24;
	        // Row 3
	        this.m31 = m31;
	        this.m32 = m32;
	        this.m33 = m33;
	        this.m34 = m34;
	        // Row 4
	        this.m41 = m41;
	        this.m42 = m42;
	        this.m43 = m43;
	        this.m44 = m44;
	    }
	
	    public Matrix4x4 Transpose()
		{
	        return Matrix4x4(
	            m11, m21, m31, m41,
	            m12, m22, m32, m42,
	            m13, m23, m33, m43,
	            m14, m24, m34, m44 );
	    }
	
	    public static Matrix4x4 FromPosition(Vector position)
		{
	        return Matrix4x4(
	            1, 0, 0, 0,
	            0, 1, 0, 0,
	            0, 0, 1, 0,
	            position.X, position.Y, 0, 1 );
	    }

		public static Matrix4x4 FromPosition(float x, float y, float z)
		{
		    return Matrix4x4(
		        1, 0, 0, 0,
		        0, 1, 0, 0,
		        0, 0, 1, 0,
		        x, y, z, 1 );
		}

	    public static Matrix4x4 FromScale(Vector scale)
		{
	        return Matrix4x4(
	            scale.X, 0, 0, 0,
	            0, scale.Y, 0, 0,
	            0, 0, 1, 0,
	            0, 0, 0, 1 );
	    }

		public static Matrix4x4 FromScale(float x, float y, float z)
		{
		    return Matrix4x4(
		        x, 0, 0, 0,
		        0, y, 0, 0,
		        0, 0, z, 0,
		        0, 0, 0, 1 );
		}
	
	    public static Matrix4x4 FromRotationX(float angle)
		{
	        let c = Math.Cos(angle);
	        let s = Math.Sin(angle);
	
	        return Matrix4x4(
	            1, 0, 0, 0,
	            0, c, s, 0,
	            0,-s, c, 0,
	            0, 0, 0, 1 );
	    }
	
	    public static Matrix4x4 FromRotationY(float angle)
		{
	        let c = Math.Cos(angle);
	        let s = Math.Sin(angle);

	        return Matrix4x4(
	            c, 0,-s, 0,
	            0, 1, 0, 0,
	            s, 0, c, 0,
	            0, 0, 0, 1 );
	    }
	
	    public static Matrix4x4 FromRotationZ(float angle)
		{
	        let c = Math.Cos(angle);
	        let s = Math.Sin(angle);
	
	        return Matrix4x4(
	            c, s, 0, 0,
	           -s, c, 0, 0,
	            0, 0, 1, 0,
	            0, 0, 0, 1 );
	    }
	
	    public static Matrix4x4 FromRotation(float x, float y, float z)
		{
	        return FromRotationX(x) * FromRotationY(y) * FromRotationZ(z);
	    }

		public static Matrix4x4 FromTransform(float px, float py, float pz, float rx, float ry, float rz, float sx, float sy, float sz)
		{
		    return FromPosition(px, py, pz) * FromScale(sx, sy, sz) * FromRotation(rx, ry, rz);
		}

		public static Matrix4x4 FromTransform(Vector position, Vector scale, float rotation)
		{
		    return FromPosition(position) * FromScale(scale) * FromRotationZ(rotation);
		}
	
	    public static Matrix4x4 FromPerspective(float fovy, float ratio, float znear, float zfar)
		{
	    
	        let t = Math.Tan(fovy/180*Math.PI_f/2);
	
	        return Matrix4x4(
	            1/(ratio*t), 0, 0, 0,
	            0, 1/t, 0, 0,
	            0, 0, -(zfar+znear)/(zfar-znear), -(2*zfar*znear)/(zfar-znear),
	            0, 0, -1, 0 );
	    }
	
	    public static Matrix4x4 FromOrthographic(float left, float right, float top, float bottom, float znear, float zfar)
		{
			var result = Matrix4x4.Identity;

			float invRL = 1 / (right - left);
			float invTB = 1 / (top - bottom);
			float invFN = 1 / (zfar - znear);

			result.m11 = 2 * invRL;
			result.m22 = 2 * invTB;
			result.m33 = -2 * invFN;

			result.m41 = -(right + left) * invRL;
			result.m42 = -(top + bottom) * invTB;
			result.m43 = -(zfar + znear) * invFN;
			result.m44 = 1;

	        return result;
	    }
	
	    // https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
		const float[9] Matrix3x3Identity = float[9](
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		);

	    public Matrix4x4 Inverse()
		{
	
	        float[4][4] grid = (float[4][4]) this;
	
	        // Step 1: Matrix of Minors
	        float[4][4] minors = (float[4][4]) Matrix4x4.Identity;
	
	        for (int minorRow = 0; minorRow < 4; minorRow++ )
			{
	            for (int minorColumn = 0; minorColumn < 4; minorColumn++ )
				{
	                // Find all the components not in the current row or column
	                float[9] cmp = Matrix3x3Identity;
	                int componentsIndex = 0;
	            
	                for (int detRow = 0; detRow < 4; detRow++ )
					{
	
	                    if (detRow == minorRow)
	                        continue;
	                    
	                    for (int detColumn = 0; detColumn < 4; detColumn++ )
						{
	
	                        if (detColumn == minorColumn)
	                            continue;
	
	                        cmp[componentsIndex] = grid[detRow][detColumn];
	                        componentsIndex++;
	                    }
	                }
	
	                // Calculate the determinant of the components not in the current row or column
	                float minor =  cmp[0] * cmp[4] * cmp[8]
					             + cmp[1] * cmp[5] * cmp[6]
					             + cmp[2] * cmp[3] * cmp[7]
					         
					             - cmp[1] * cmp[3] * cmp[8]
					             - cmp[0] * cmp[5] * cmp[7]
					             - cmp[2] * cmp[4] * cmp[6];

	                minors[minorRow][minorColumn] = minor;
	            }
			}
	    
	        // Step 2: Matrix of Cofactors
	        // Apply a "checkerboard" of minuses to the "Matrix of Minors"
	        // + - + -
	        // - + - +
	        // + - + -
	        // - + - +
	        float[4][4] cofactors = (float[4][4]) Matrix4x4.Identity;
	
	        for (int cofactorsRow = 0; cofactorsRow < 4; cofactorsRow++ )
			{
	            for (int cofactorsColumn = 0; cofactorsColumn < 4; cofactorsColumn++ )
				{
	                bool isEven = (cofactorsRow + cofactorsColumn) % 2f == 0;
	                float scalar = isEven ? 1f : -1f;
	                cofactors[cofactorsRow][cofactorsColumn] = minors[cofactorsRow][cofactorsColumn] * scalar;
	            }
			}
	
	        // Step 3: Adjugate 
	        let adjugate = ((Matrix4x4) cofactors).Transpose();
	
	        // Step 4: Multiply by 1/Determinant
	        let determinant =
	            grid[0][0] * minors[0][0] +
	            grid[0][1] * minors[0][1] +
	            grid[0][2] * minors[0][2] +
	            grid[0][3] * minors[0][3];
	
	        // Matrix is singular :(
	        if (determinant == 0f)
	            return Identity;
	
	        return adjugate * (1/determinant);
	    }
	
		public void ToString(String outString, String format, IFormatProvider formatProvider)
		{
			// Row 1
			outString.Append("|");
			m11.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m12.ToString(outString, format, formatProvider);
			outString.Append(","); 
			m13.ToString(outString, format, formatProvider);	
			outString.Append(","); 
			m14.ToString(outString, format, formatProvider);
			outString.Append("|\n");
			// Row 2
			outString.Append("|");
			m21.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m22.ToString(outString, format, formatProvider);
			outString.Append(","); 
			m23.ToString(outString, format, formatProvider);	
			outString.Append(","); 
			m24.ToString(outString, format, formatProvider);
			outString.Append("|\n");
			// Row 3
			outString.Append("|");
			m31.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m32.ToString(outString, format, formatProvider);
			outString.Append(","); 
			m33.ToString(outString, format, formatProvider);	
			outString.Append(","); 
			m34.ToString(outString, format, formatProvider);
			outString.Append("|\n");
			// Row 4
			outString.Append("|");
			m41.ToString(outString, format, formatProvider);
			outString.Append(",");	
			m42.ToString(outString, format, formatProvider);
			outString.Append(","); 
			m43.ToString(outString, format, formatProvider);	
			outString.Append(","); 
			m44.ToString(outString, format, formatProvider);
			outString.Append("|");
		}
	
	    /*public static explicit operator Matrix4x4(mat3 m)
		{
	        return Matrix4x4(
	            m.m11, m.m12, m.m13, 0,
	            m.m21, m.m22, m.m23, 0,
	            m.m31, m.m32, m.m33, 0,
	            0, 0, 0, 1 );
	    }*/
	
	    public static explicit operator Matrix4x4(float[16] m)
		{
	        return Matrix4x4(
	            m[0], m[1], m[2], m[3],
	            m[4], m[5], m[6], m[7],
	            m[8], m[9], m[10], m[11],
	            m[12], m[13], m[14], m[15] );
	    }
	
	    public static explicit operator float[16](Matrix4x4 m)
		{
	        return float[16](
	            m.m11, m.m12, m.m13, m.m14,
	            m.m21, m.m22, m.m23, m.m24,
	            m.m31, m.m32, m.m33, m.m34,
	            m.m41, m.m42, m.m43, m.m44 );
	    }
	
	    public static explicit operator Matrix4x4(float[4][4] m)
		{
	        return Matrix4x4(
	            m[0][0], m[0][1], m[0][2], m[0][3],
	            m[1][0], m[1][1], m[1][2], m[1][3],
	            m[2][0], m[2][1], m[2][2], m[2][3],
	            m[3][0], m[3][1], m[3][2], m[3][3] );
	    }
	
	    public static explicit operator float[4][4](Matrix4x4 m)
		{
	        return float[4][4](
	            float[4]( m.m11, m.m12, m.m13, m.m14 ),
	            float[4]( m.m21, m.m22, m.m23, m.m24 ),
	            float[4]( m.m31, m.m32, m.m33, m.m34 ),
	            float[4]( m.m41, m.m42, m.m43, m.m44 ) );
	    }
	
	    public static bool operator==(Matrix4x4 a, Matrix4x4 b)
		{
			return a.m11 == b.m11 && a.m12 == b.m12 && a.m13 == b.m13 && a.m14 == b.m14
	            && a.m21 == b.m21 && a.m22 == b.m22 && a.m23 == b.m23 && a.m24 == b.m24
	            && a.m31 == b.m31 && a.m32 == b.m32 && a.m33 == b.m33 && a.m34 == b.m34
	            && a.m41 == b.m41 && a.m42 == b.m42 && a.m43 == b.m43 && a.m44 == b.m44;
		}
	
		public static bool operator!=(Matrix4x4 a, Matrix4x4 b)
		{
			return a.m11 != b.m11 || a.m12 != b.m12 || a.m13 != b.m13 || a.m14 != b.m14
	            || a.m21 != b.m21 || a.m22 != b.m22 || a.m23 != b.m23 || a.m24 != b.m24
	            || a.m31 != b.m31 || a.m32 != b.m32 || a.m33 != b.m33 || a.m34 != b.m34
	            || a.m41 != b.m41 || a.m42 != b.m42 || a.m43 != b.m43 || a.m44 != b.m44;
		}
	
		public static Matrix4x4 operator*(Matrix4x4 a, Matrix4x4 b)
		{
	        return Matrix4x4(
	            // Row 1
	            a.m11*b.m11 + a.m12*b.m21 + a.m13*b.m31 + a.m14*b.m41,
	            a.m11*b.m12 + a.m12*b.m22 + a.m13*b.m32 + a.m14*b.m42,
	            a.m11*b.m13 + a.m12*b.m23 + a.m13*b.m33 + a.m14*b.m43,
	            a.m11*b.m14 + a.m12*b.m24 + a.m13*b.m34 + a.m14*b.m44,
	            // Row 2
	            a.m21*b.m11 + a.m22*b.m21 + a.m23*b.m31 + a.m24*b.m41,
	            a.m21*b.m12 + a.m22*b.m22 + a.m23*b.m32 + a.m24*b.m42,
	            a.m21*b.m13 + a.m22*b.m23 + a.m23*b.m33 + a.m24*b.m43,
	            a.m21*b.m14 + a.m22*b.m24 + a.m23*b.m34 + a.m24*b.m44,
	            // Row 3
	            a.m31*b.m11 + a.m32*b.m21 + a.m33*b.m31 + a.m34*b.m41,
	            a.m31*b.m12 + a.m32*b.m22 + a.m33*b.m32 + a.m34*b.m42,
	            a.m31*b.m13 + a.m32*b.m23 + a.m33*b.m33 + a.m34*b.m43,
	            a.m31*b.m14 + a.m32*b.m24 + a.m33*b.m34 + a.m34*b.m44,
	            // Row 4
	            a.m41*b.m11 + a.m42*b.m21 + a.m43*b.m31 + a.m44*b.m41,
	            a.m41*b.m12 + a.m42*b.m22 + a.m43*b.m32 + a.m44*b.m42,
	            a.m41*b.m13 + a.m42*b.m23 + a.m43*b.m33 + a.m44*b.m43,
	            a.m41*b.m14 + a.m42*b.m24 + a.m43*b.m34 + a.m44*b.m44 );
		}
	
		/*public static Matrix4x4 operator*(Matrix4x4 a, vec4 b)
		{
	        return Matrix4x4(
	            a.m11*b.x, a.m12*b.x, a.m13*b.x, a.m14*b.x,
	            a.m21*b.y, a.m22*b.y, a.m23*b.y, a.m24*b.y,
	            a.m31*b.z, a.m32*b.z, a.m33*b.z, a.m34*b.z,
	            a.m41*b.w, a.m42*b.w, a.m43*b.w, a.m44*b.w );
		}*/
	
		/*public static Matrix4x4 operator*(vec4 a, Matrix4x4 b)
		{
	        return Matrix4x4(
	            a.x*b.m11, a.x*b.m12, a.x*b.m13, a.x*b.m14,
	            a.y*b.m11, a.y*b.m12, a.y*b.m13, a.y*b.m14,
	            a.z*b.m11, a.z*b.m12, a.z*b.m13, a.z*b.m14,
	            a.w*b.m11, a.w*b.m12, a.w*b.m13, a.w*b.m14 );
		}*/
	
		public static Matrix4x4 operator*(Matrix4x4 a, float b)
		{
	        return Matrix4x4(
	            a.m11*b, a.m12*b, a.m13*b, a.m14*b,
	            a.m21*b, a.m22*b, a.m23*b, a.m24*b,
	            a.m31*b, a.m32*b, a.m33*b, a.m34*b,
	            a.m41*b, a.m42*b, a.m43*b, a.m44*b );
		}
	
		public static Matrix4x4 operator*(float a, Matrix4x4 b)
		{
	        return Matrix4x4(
	            a*b.m11, a*b.m12, a*b.m13, a*b.m14,
	            a*b.m11, a*b.m12, a*b.m13, a*b.m14,
	            a*b.m11, a*b.m12, a*b.m13, a*b.m14,
	            a*b.m11, a*b.m12, a*b.m13, a*b.m14 );
		}
	
	}
}
