namespace Pile
{
	enum TextureFormat
	{
		case R;
		case RG;
		case RGB;
		case Color; // ARGB
		case DepthStencil;

		public bool IsColorFormat()
		{
			return
				   this == R
				|| this == RG
				|| this == RGB
				|| this == Color;
		}

		public bool IsDepthStencilFormat()
		{
			return this == DepthStencil;
		}

		public uint8 Size()
		{
			switch (this)
			{
			case R: return 1;
			case RG: return 2;
			case RGB: return 3;
			case Color: return 4;
			case DepthStencil: return 4;
			}
		}
	}
}
