using System;
using System.IO;
using JSON_Beef.Types;

namespace Pile
{
	public class PNGImporter : Importer
	{
		public override Result<void> Load(StringView name, Span<uint8> data, JSONObject dataNode)
		{
			let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let asset = new Bitmap();
			Try!(PNG.Read(mem, asset));

			return SubmitTextureAsset(name, asset);
		}

		public override Result<uint8[]> Build(Span<uint8> data, JSONObject config, out JSONObject dataNode)
		{
			dataNode = null;

			if (!PNG.IsValid(data))
				LogErrorReturn!("Data is not in PNG format");

			let outData = new uint8[data.Length];
			data.CopyTo(outData);
			return outData;
		}
	}
}
