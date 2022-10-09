using System;

namespace Pile
{
	[Ordered]
	struct Color
	{
		public const Color White = Color(255, 255, 255, 255);
		public const Color Black = Color(0, 0, 0, 255);
		public const Color Transparent = Color(0, 0, 0, 0);

		public const Color Red = Color(255, 0, 0);
		public const Color Green = Color(0, 255, 0);
		public const Color Blue = Color(0, 0, 255);

		public const Color Cyan = Color(0, 255, 255);
		public const Color Magenta = Color(255, 0, 255);
		public const Color Yellow = Color(255, 255, 0);

		public const Color DarkGray = Color(0x3F, 0x3F, 0x3F);
		public const Color Gray = Color(0x7F, 0x7F, 0x7F);
		public const Color LightGray = Color(0xBF, 0xBF, 0xBF);

		public const Color Orange = Color(0xAA, 0xA5, 0);

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

		public Color Premultiply()
		{
			let af = Af;
			return Color((uint8)(R * af), (uint8)(G * af), (uint8)(B * af), A);
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("Color [ ");
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
			return Color(color.R, color.G, color.B, (.)(color.A * b));
		}

		public static Color operator*(Color a, Color b)
		{
			return Color((.)(a.R * b.Rf), (.)(a.G * b.Gf), (.)(a.B * b.Bf), (.)(a.A * b.Af));
		}

		[Commutable]
		public static bool operator==(Color a, Color b)
		{
			return a.R == b.R && a.B == b.B && a.G == b.G && a.A == b.A;
		}
	}
}
