using System.IO;
using System;

namespace Pile
{
	[RegisterImporter]
	class PNGBitmapImporter : RawImporter
	{
		public override String Name => "png_bitmap";

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let mem = scope ArrayStream(data);
			let bitmap = new Bitmap();
			defer delete bitmap;
			if (PNG.Read(mem, bitmap) case .Err)
				return .Err;

			if (Importers.SubmitAsset(name, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}
			else return .Ok;
		}
	}
}
