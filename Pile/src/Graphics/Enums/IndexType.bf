using System;

namespace Pile
{
	public enum IndexType : uint8
	{
		case UnsignedInt;
		case UnsignedShort;
		case UnsignedByte;

		[Inline]
		public uint GetSize()
		{
			switch (this)
			{
			case .UnsignedInt:
				return sizeof(uint32);
			case .UnsignedShort:
				return sizeof(uint16);
			case .UnsignedByte:
				return sizeof(uint8);
			}
		}
	}
}
