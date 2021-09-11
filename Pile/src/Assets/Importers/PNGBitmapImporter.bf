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
			let s = scope ArrayStream(data);
			let sr = scope Serializer(s);

			let bitmap = new Bitmap(
				sr.Read<uint32>(),
				sr.Read<uint32>());
			sr.ReadInto!(Span<uint8>((uint8*)bitmap.Pixels.Ptr, bitmap.Pixels.Count * sizeof(Color)));

			if (Importers.SubmitAsset(name, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}
			else return .Ok;
		}
	}
}
