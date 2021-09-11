using System;
using System.IO;
using System.Collections;

namespace Pile
{
	[RegisterImporter]
	class FontImporter : Importer
	{
		public String Name => "font";

		public Result<void> Load(StringView name, Span<uint8> data)
		{
			let asset = new Font(data);

			if (Importers.SubmitAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}

		public Result<uint8[]> Build(Stream data, Span<StringView> config, StringView dataFilePath)
		{
			if (!Font.IsValid(data))
				LogErrorReturn!("FontImporter: Data is not a valid font");

			return Importer.TryStreamToArray!(data);
		}
	}
}
