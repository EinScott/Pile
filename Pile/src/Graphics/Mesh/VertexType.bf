namespace Pile
{
	enum VertexType : uint8
	{
		case Byte;
		case Short;
		case Int;
		case Float;

		public uint32 GetSize()
		{
			switch (this)
			{
			case .Byte: return 1;
			case .Short: return 2;
			case .Int: return 4;
			case .Float: return 4;
			}
		}
	}
}
