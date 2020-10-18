using System;

namespace Pile
{
	public enum IndexType : uint8
	{
		case UnsignedInt = 0;
		case UnsignedShort;

		[Inline]
		public uint GetSize()
		{
			switch (this)
			{
			case .UnsignedInt:
				return 4;
			case .UnsignedShort:
				return 2;
			}
		}
	}
}
