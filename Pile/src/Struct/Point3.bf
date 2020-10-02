using System;

namespace Pile
{
	[Ordered]
	public struct Point3 : IEquatable<Point3>, IEquatable
	{
		public static readonly Point3 UnitX = .(1, 0, 0);
		public static readonly Point3 UnitY = .(0, 1, 0);
		public static readonly Point3 UnitZ = .(0, 0, 1);
		public static readonly Point3 UnitNegativeX = .(-1, 0, 0);
		public static readonly Point3 UnitNegativeY = .(0, -1, 0);
		public static readonly Point3 UnitNegativeZ = .(0, 0, -1);
		public static readonly Point3 Zero = .(0, 0, 0);
		public static readonly Point3 One = .(1, 1, 1);

		public int X;
		public int Y;
		public int Z;

		public this()
		{
			this = default;
		}

		public this(int x, int y, int z)
		{
			X = x;
			Y = y;
			Z = z;
		}

		public void Set(int x, int y, int z) mut
		{
			X = x;
			Y = y;
			Z = z;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("Point [ ");
			X.ToString(strBuffer);
			strBuffer.Append(", ");
			Y.ToString(strBuffer);
			strBuffer.Append(", ");
			Z.ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static operator Point3((int X, int Y, int Z) tuple) => Point3(tuple.X, tuple.Y, tuple.Z);
		public static explicit operator Point3(Vector3 a) => Point3((int)Math.Round(a.X), (int)Math.Round(a.Y), (int)Math.Round(a.Z));

		public static bool operator==(Point3 a, Point3 b) => a.X == b.X && a.Y == b.Y && a.Z == b.Z;

		public static Point3 operator+(Point3 a, Point3 b) => Point3(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
		public static Point3 operator-(Point3 a, Point3 b) => Point3(a.X - b.X, a.Y - b.Y, a.Z - b.Z);

		public static Point3 operator*(Point3 a, int b) => Point3(a.X * b, a.Y * b, a.Z * b);
		public static Point3 operator/(Point3 a, int b) => Point3(a.X / b, a.Y / b, a.Z / b);

		public static Point3 operator-(Point3 a) => Point3(-a.X, -a.Y, -a.Z);

		public bool Equals(Point3 a) => a.X == X && a.Y == Y;
		public bool Equals(Object o) => (o is Point3) && (Point3)o == this;
	}
}
