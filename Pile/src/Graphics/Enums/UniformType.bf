using System;

namespace Pile
{
	enum UniformType
	{
		case Unknown;
		case Int;
		case Float;
		case Float2;
		case Float3;
		case Float4;
		case Matrix3x2;
		case Matrix4x4;
		case Sampler;

		[Inline]
		public int Elements =>
			{
				int count = 1;
				switch (this)
				{
				case .Float2:
					count = 2;
				case .Float3:
					count = 3;
				case .Float4:
					count = 4;
				case .Matrix3x2:
					count = 6;
				case .Matrix4x4:
					count = 16;
				default:
				}

				count
			}

		public int Size(int length)
		{
			switch (this)
			{
			case .Float, .Float2, .Float3, .Float4, .Matrix3x2, .Matrix4x4:
				return sizeof(float) * Elements * length;
			case .Int:
				return sizeof(int32) * length;
			case .Sampler:
				return sizeof(Texture) * length;
			default:
				Runtime.FatalError("Unknown uniform type");
			}
		}
	}
}
