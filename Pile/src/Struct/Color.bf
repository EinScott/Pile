using System;

namespace Pile
{
	public struct Color
	{
		public static readonly Color White 			= 0xFFFFFFFF;
		public static readonly Color Black 			= 0x000000FF;
		public static readonly Color Transparent 	= 0x00000000;
		public static readonly Color Red 			= 0xFF0000FF;
		public static readonly Color Green 			= 0x00FF00FF;
		public static readonly Color Blue 			= 0x0000FFFF;
		public static readonly Color Cyan 			= 0xFF00FFFF;
		public static readonly Color Magenta 		= 0xFFFF00FF;
		public static readonly Color Yellow 		= 0x00FFFFFF;
		public static readonly Color DarkGray		= 0x3F3F3FFF;
		public static readonly Color Gray			= 0x7F7F7FFF;
		public static readonly Color LightGray		= 0xBFBFBFFF;

		public uint8 R;
		public uint8 G;
		public uint8 B;
		public uint8 A;

		public this(uint8 red, uint8 green, uint8 blue, uint8 alpha = 255)
		{
			R = red;
			G = green;
			B = blue;
			A = alpha;
		}

		public this(float red, float green, float blue, float alpha = 1f)
		{
			R = (uint8)(red * 255);
			G = (uint8)(green * 255);
			B = (uint8)(blue * 255);
			A = (uint8)(alpha * 255);
		}

		public float Rf
		{
			[Inline]
			get
			{
				return R / 255f;
			}

			[Inline]
			set	mut
			{
				R = (uint8)(value * 255);
			}
		}

		public float Gf
		{
			[Inline]
			get
			{
				return G / 255f;
			}

			[Inline]
			set	mut
			{
				G = (uint8)(value * 255);
			}
		}

		public float Bf
		{
			[Inline]
			get
			{
				return B / 255f;
			}

			[Inline]
			set	mut
			{
				B = (uint8)(value * 255);
			}
		}

		public float Af
		{
			[Inline]
			get
			{
				return A / 255f;
			}

			[Inline]
			set	mut
			{
				A = (uint8)(value * 255);
			}
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Set("Color [ ");
			((uint)R).ToString(strBuffer);
			strBuffer.Append(", ");
			((uint)G).ToString(strBuffer);
			strBuffer.Append(", ");
			((uint)B).ToString(strBuffer);
			strBuffer.Append(", ");
			((uint)A).ToString(strBuffer);
			strBuffer.Append(" ]");
		}

		public static Color Lerp(Color a, Color b, float t)
		{
			return Color(
				Math.Lerp(a.Rf, b.Rf, t),
				Math.Lerp(a.Gf, b.Gf, t),
				Math.Lerp(a.Bf, b.Bf, t),
				Math.Lerp(a.Af, b.Af, t)
			);
		}

		public static implicit operator Color(uint32 from)
		{
			return Color(
				(uint8)((from >> 24) & 0xFF),
				(uint8)((from >> 16) & 0xFF),
				(uint8)((from >> 8) & 0xFF),
				(uint8)(from & 0xFF)
			);
		}

		public static implicit operator uint32(Color from)
		{
			return (((uint32)from.R) << 24) | (((uint32)from.G) << 16) | (((uint32)from.B) << 8) | ((uint32)from.A);
		}

		public static Color operator/(Color a, Color b)
		{
			return Lerp(a, b, 0.5f);
		}

		public static Color operator*(Color color, float b)
		{
			return Color(color.R, color.G, color.B, (uint8)(color.A * b));
		}
	}
}