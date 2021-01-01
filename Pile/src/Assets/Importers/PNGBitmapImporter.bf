using System.IO;

namespace Pile
{
	/// Will import images as a Bitmap asset
	class PNGBitmapImporter : Importer
	{
		public override System.Result<void> Load(System.StringView name, System.Span<uint8> data, JSON_Beef.Types.JSONObject dataNode)
		{
			/*let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let bitmap = new Bitmap();
			if (PNG.Read(mem, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}

			if (SubmitAsset(name, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}
			else*/ return .Ok;
		}

		public override System.Result<uint8[]> Build(System.Span<uint8> data, JSON_Beef.Types.JSONObject config, out JSON_Beef.Types.JSONObject dataNode)
		{
			dataNode = null;

			/*if (!PNG.IsValid(data))
				LogErrorReturn!("BitmapImpoter can only take images of type PNG");

			let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let bitmap = new Bitmap();
			if (PNG.Read(mem, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}*/

			/*let outData = new uint8[bitmap.Pixels.Count];
			bitmap.Pixels.CopyTo(outData, 0, 0, bitmap.Pixels.Count);*/

			let outData = new uint8[data.Length];
			data.CopyTo(outData);
			return outData;
		}
	}
}
