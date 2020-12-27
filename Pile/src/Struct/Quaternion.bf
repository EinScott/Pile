// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System;

namespace Pile
{
	[Ordered]
	/// A structure encapsulating a four-dimensional vector (x,y,z,w), 
	/// which is used to efficiently rotate an object about the (x,y,z) vector by the angle theta, where w = cos(theta/2).
	public struct Quaternion : IFormattable, IEquatable<Quaternion>, IEquatable
	{
		public static readonly Quaternion Identity = Quaternion(0, 0, 0, 1);

		public float X, Y, Z, W;

		[Inline]
		public bool IsIdentity => X == 0f && Y == 0f && Z == 0f && W == 1f;

		[Inline]
		/// Calculates the length of the Quaternion.
		public float Length => (float)Math.Sqrt((double)X * X + Y * Y + Z * Z + W * W);

		[Inline]
		/// Calculates the length squared of the Quaternion. This operation is cheaper than Length().
		public float LengthSquared => X * X + Y * Y + Z * Z + W * W;

		public this(float x, float y, float z, float w)
		{
		    X = x;
		    Y = y;
		    Z = z;
		    W = w;
		}

		public this(Vector3 vectorPart, float scalarPart)
		{
		    X = vectorPart.X;
		    Y = vectorPart.Y;
		    Z = vectorPart.Z;
		    W = scalarPart;
		}

		[Inline]
		public bool Equals(Quaternion o) => o == this;

		[Inline]
		public bool Equals(Object o) => (o is Quaternion) && (Quaternion)o == this;

		/// Divides each component of this Quaternion by its length.
		public Quaternion Normalize()
		{
			float ls = X * X + Y * Y + Z * Z + W * W;

			float invNorm = 1.0f / (float)Math.Sqrt((double)ls);

			return Quaternion(
				X * invNorm,
				Y * invNorm,
				Z * invNorm,
				W * invNorm);
		}

		/// Creates the conjugate of this Quaternion.
		public Quaternion Conjugate()
		{
		    return Quaternion(-X, -Y, -Z, W);
		}

		/// Returns the inverse of this Quaternion.
		public Quaternion Inverse()
		{
		    //  -1   (       a              -v       )
		    // q   = ( -------------   ------------- )
		    //       (  a^2 + |v|^2  ,  a^2 + |v|^2  )

		    float ls = X * X + Y * Y + Z * Z + W * W;
		    float invNorm = 1.0f / ls;

			return Quaternion(
			    -X * invNorm,
			    -Y * invNorm,
			    -Z * invNorm,
			    W * invNorm);
		}

		// Derived from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToEuler/
		public Vector3 EulerAngles()
		{
			float sqw = W * W;
			float sqx = X * X;
			float sqy = Y * Y;
			float sqz = Z * Z;
			float unit = sqx + sqy + sqz + sqw; // If normalized is one, otherwise is correction factor
			float test = X * Y + Z * W;
			if (test > 0.499 * unit) // Singularity at north pole
				return Vector3(0, 2 * Math.Atan2(X, W), Math.PI_f / 2);
			if (test < -0.499 * unit) // Singularity at south pole
				return Vector3(0, -Math.PI_f / 2, -2 * Math.Atan2(X, W));

			return Vector3(Math.Atan2(2 * X * W - 2 * Y * Z, -sqx + sqy - sqz + sqw), Math.Asin(2*test/unit), Math.Atan2(2 * Y * W - 2 * X * Z, sqx - sqy - sqz + sqw));
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

		/// Creates a Quaternion from a vector and an angle to rotate about the vector.
		public static Quaternion CreateFromAxisAngle(Vector3 axis, float angle)
		{
		    Quaternion ans;

		    float halfAngle = angle * 0.5f;
		    float s = (float)Math.Sin(halfAngle);
		    float c = (float)Math.Cos(halfAngle);

		    ans.X = axis.X * s;
		    ans.Y = axis.Y * s;
		    ans.Z = axis.Z * s;
		    ans.W = c;

		    return ans;
		}

		/// Creates a new Quaternion from the given yaw, pitch, and roll, in radians.
		public static Quaternion CreateFromYawPitchRoll(float yaw, float pitch, float roll)
		{
		    //  Roll first, about axis the object is facing, then
		    //  pitch upward, then yaw to face into the new heading
		    float sr, cr, sp, cp, sy, cy;

		    float halfRoll = roll * 0.5f;
		    sr = (float)Math.Sin(halfRoll);
		    cr = (float)Math.Cos(halfRoll);

		    float halfPitch = pitch * 0.5f;
		    sp = (float)Math.Sin(halfPitch);
		    cp = (float)Math.Cos(halfPitch);

		    float halfYaw = yaw * 0.5f;
		    sy = (float)Math.Sin(halfYaw);
		    cy = (float)Math.Cos(halfYaw);

		    Quaternion result;

		    result.X = cy * sp * cr + sy * cp * sr;
		    result.Y = sy * cp * cr - cy * sp * sr;
		    result.Z = cy * cp * sr - sy * sp * cr;
		    result.W = cy * cp * cr + sy * sp * sr;

		    return result;
		}

		/// Creates a Quaternion from the given rotation matrix.
		public static Quaternion CreateFromRotationMatrix(Matrix4x4 matrix)
		{
		    float trace = matrix.M11 + matrix.M22 + matrix.M33;

		    Quaternion q;

		    if (trace > 0.0f)
		    {
		        float s = (float)Math.Sqrt(trace + 1.0f);
		        q.W = s * 0.5f;
		        s = 0.5f / s;
		        q.X = (matrix.M23 - matrix.M32) * s;
		        q.Y = (matrix.M31 - matrix.M13) * s;
		        q.Z = (matrix.M12 - matrix.M21) * s;
		    }
		    else
		    {
		        if (matrix.M11 >= matrix.M22 && matrix.M11 >= matrix.M33)
		        {
		            float s = (float)Math.Sqrt(1.0f + matrix.M11 - matrix.M22 - matrix.M33);
		            float invS = 0.5f / s;
		            q.X = 0.5f * s;
		            q.Y = (matrix.M12 + matrix.M21) * invS;
		            q.Z = (matrix.M13 + matrix.M31) * invS;
		            q.W = (matrix.M23 - matrix.M32) * invS;
		        }
		        else if (matrix.M22 > matrix.M33)
		        {
		            float s = (float)Math.Sqrt(1.0f + matrix.M22 - matrix.M11 - matrix.M33);
		            float invS = 0.5f / s;
		            q.X = (matrix.M21 + matrix.M12) * invS;
		            q.Y = 0.5f * s;
		            q.Z = (matrix.M32 + matrix.M23) * invS;
		            q.W = (matrix.M31 - matrix.M13) * invS;
		        }
		        else
		        {
		            float s = (float)Math.Sqrt(1.0f + matrix.M33 - matrix.M11 - matrix.M22);
		            float invS = 0.5f / s;
		            q.X = (matrix.M31 + matrix.M13) * invS;
		            q.Y = (matrix.M32 + matrix.M23) * invS;
		            q.Z = 0.5f * s;
		            q.W = (matrix.M12 - matrix.M21) * invS;
		        }
		    }

		    return q;
		}

		/// Calculates the dot product of two Quaternions.
		public static float Dot(Quaternion quaternion1, Quaternion quaternion2)
		{
		    return quaternion1.X * quaternion2.X +
		           quaternion1.Y * quaternion2.Y +
		           quaternion1.Z * quaternion2.Z +
		           quaternion1.W * quaternion2.W;
		}

		/// Interpolates between two quaternions, using spherical linear interpolation.
		public static Quaternion Slerp(Quaternion quaternion1, Quaternion quaternion2, float amount)
		{
		    const float epsilon = 1e-6f;

		    float t = amount;

		    float cosOmega = quaternion1.X * quaternion2.X + quaternion1.Y * quaternion2.Y +
		                     quaternion1.Z * quaternion2.Z + quaternion1.W * quaternion2.W;

		    bool flip = false;

		    if (cosOmega < 0.0f)
		    {
		        flip = true;
		        cosOmega = -cosOmega;
		    }

		    float s1, s2;

		    if (cosOmega > (1.0f - epsilon))
		    {
		        // Too close, do straight linear interpolation.
		        s1 = 1.0f - t;
		        s2 = (flip) ? -t : t;
		    }
		    else
		    {
		        float omega = (float)Math.Acos(cosOmega);
		        float invSinOmega = (float)(1 / Math.Sin(omega));

		        s1 = (float)Math.Sin((1.0f - t) * omega) * invSinOmega;
		        s2 = (flip)
		            ? -(float)Math.Sin(t * omega) * invSinOmega
		            : (float)Math.Sin(t * omega) * invSinOmega;
		    }

		    Quaternion ans;

		    ans.X = s1 * quaternion1.X + s2 * quaternion2.X;
		    ans.Y = s1 * quaternion1.Y + s2 * quaternion2.Y;
		    ans.Z = s1 * quaternion1.Z + s2 * quaternion2.Z;
		    ans.W = s1 * quaternion1.W + s2 * quaternion2.W;

		    return ans;
		}

		///  Linearly interpolates between two quaternions.
		public static Quaternion Lerp(Quaternion quaternion1, Quaternion quaternion2, float amount)
		{
		    float t = amount;
		    float t1 = 1.0f - t;

		    Quaternion r;

		    float dot = quaternion1.X * quaternion2.X + quaternion1.Y * quaternion2.Y +
		                quaternion1.Z * quaternion2.Z + quaternion1.W * quaternion2.W;

		    if (dot >= 0.0f)
		    {
		        r.X = t1 * quaternion1.X + t * quaternion2.X;
		        r.Y = t1 * quaternion1.Y + t * quaternion2.Y;
		        r.Z = t1 * quaternion1.Z + t * quaternion2.Z;
		        r.W = t1 * quaternion1.W + t * quaternion2.W;
		    }
		    else
		    {
		        r.X = t1 * quaternion1.X - t * quaternion2.X;
		        r.Y = t1 * quaternion1.Y - t * quaternion2.Y;
		        r.Z = t1 * quaternion1.Z - t * quaternion2.Z;
		        r.W = t1 * quaternion1.W - t * quaternion2.W;
		    }

		    // Normalize it.
		    float ls = r.X * r.X + r.Y * r.Y + r.Z * r.Z + r.W * r.W;
		    float invNorm = 1.0f / (float)Math.Sqrt((double)ls);

		    r.X *= invNorm;
		    r.Y *= invNorm;
		    r.Z *= invNorm;
		    r.W *= invNorm;

		    return r;
		}

		/// Concatenates two Quaternions; the result represents the value1 rotation followed by the value2 rotation.
		public static Quaternion Concatenate(Quaternion value1, Quaternion value2)
		{
		    Quaternion ans;

		    // Concatenate rotation is actually q2 * q1 instead of q1 * q2.
		    // So that's why value2 goes q1 and value1 goes q2.
		    float q1x = value2.X;
		    float q1y = value2.Y;
		    float q1z = value2.Z;
		    float q1w = value2.W;

		    float q2x = value1.X;
		    float q2y = value1.Y;
		    float q2z = value1.Z;
		    float q2w = value1.W;

		    // cross(av, bv)
		    float cx = q1y * q2z - q1z * q2y;
		    float cy = q1z * q2x - q1x * q2z;
		    float cz = q1x * q2y - q1y * q2x;

		    float dot = q1x * q2x + q1y * q2y + q1z * q2z;

		    ans.X = q1x * q2w + q2x * q1w + cx;
		    ans.Y = q1y * q2w + q2y * q1w + cy;
		    ans.Z = q1z * q2w + q2z * q1w + cz;
		    ans.W = q1w * q2w - dot;

		    return ans;
		}

		[Commutable]
		public static bool operator==(Quaternion a, Quaternion b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z && a.W == b.W;

		public static Quaternion operator-(Quaternion a) => Quaternion(-a.X, -a.Y, -a.Z, -a.W);

		public static Quaternion operator+(Quaternion a, Quaternion b) => Quaternion(a.X + b.X, a.Y + b.Y, a.Z + b.Z, a.W + b.W);
		public static Quaternion operator-(Quaternion a, Quaternion b) => Quaternion(a.X - b.X, a.Y - b.Y, a.Z - b.Z, a.W - b.W);

		public static Quaternion operator*(Quaternion a, Quaternion b)
		{
		    Quaternion ans;

		    float q1x = a.X;
		    float q1y = a.Y;
		    float q1z = a.Z;
		    float q1w = a.W;

		    float q2x = b.X;
		    float q2y = b.Y;
		    float q2z = b.Z;
		    float q2w = b.W;

		    // cross(av, bv)
		    float cx = q1y * q2z - q1z * q2y;
		    float cy = q1z * q2x - q1x * q2z;
		    float cz = q1x * q2y - q1y * q2x;

		    float dot = q1x * q2x + q1y * q2y + q1z * q2z;

		    ans.X = q1x * q2w + q2x * q1w + cx;
		    ans.Y = q1y * q2w + q2y * q1w + cy;
		    ans.Z = q1z * q2w + q2z * q1w + cz;
		    ans.W = q1w * q2w - dot;

		    return ans;
		}

		public static Quaternion operator/(Quaternion a, Quaternion b)
		{
		    Quaternion ans;

		    float q1x = a.X;
		    float q1y = a.Y;
		    float q1z = a.Z;
		    float q1w = a.W;

		    //-------------------------------------
		    // Inverse part.
		    float ls = b.X * b.X + b.Y * b.Y +
		               b.Z * b.Z + b.W * b.W;
		    float invNorm = 1.0f / ls;

		    float q2x = -b.X * invNorm;
		    float q2y = -b.Y * invNorm;
		    float q2z = -b.Z * invNorm;
		    float q2w = b.W * invNorm;

		    //-------------------------------------
		    // Multiply part.

		    // cross(av, bv)
		    float cx = q1y * q2z - q1z * q2y;
		    float cy = q1z * q2x - q1x * q2z;
		    float cz = q1x * q2y - q1y * q2x;

		    float dot = q1x * q2x + q1y * q2y + q1z * q2z;

		    ans.X = q1x * q2w + q2x * q1w + cx;
		    ans.Y = q1y * q2w + q2y * q1w + cy;
		    ans.Z = q1z * q2w + q2z * q1w + cz;
		    ans.W = q1w * q2w - dot;

		    return ans;
		}

		public static Quaternion operator*(Quaternion a, float b) => Quaternion(a.X * b, a.Y * b, a.Z * b, a.W * b);
		public static Quaternion operator*(float b, Quaternion a) => Quaternion(a.X * b, a.Y * b, a.Z * b, a.W * b);
	}
}
