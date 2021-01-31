using System.IO;
using System;

namespace Pile
{
	[RegisterImporter]
	class PNGBitmapImporter : PNGImporter
	{
		public override String Name => "png_bitmap";

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let bitmap = new Bitmap(
				(((uint32)data[0]) << 24) | (((uint32)data[1]) << 16) | (((uint32)data[2]) << 8) | ((uint32)data[3]),
				(((uint32)data[4]) << 24) | (((uint32)data[5]) << 16) | (((uint32)data[6]) << 8) | ((uint32)data[7]),
				Span<Color>((Color*)&data[2 * sizeof(uint32)], data.Length / sizeof(uint32) - 2)); // sizeof(Color) == sizeof(uint32)

			if (Importers.SubmitAsset(name, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}
			else return .Ok;
		}
	}
}
