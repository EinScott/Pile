using System;
using System.IO;
using System.Collections;

namespace Pile
{
	[RegisterImporter]
	class PNGImporter : RawImporter
	{
		public override String Name => "png";

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let mem = scope ArrayStream(data);
			let bitmap = scope Bitmap();
			defer delete bitmap;
			if (PNG.Read(mem, bitmap) case .Err)
				return .Err;

			Try!(Importers.SubmitTextureAsset(name, bitmap));

			return .Ok;
		}
	}
}
