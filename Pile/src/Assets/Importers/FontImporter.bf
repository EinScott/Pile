using System;
using System.IO;
using System.Collections;

namespace Pile
{
	[RegisterImporter,AlwaysInclude]
	public class FontImporter : Importer
	{
		public String Name => "font";

		public Result<void> Load(StringView name, Span<uint8> data)
		{
			let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let asset = new Font(data);

			return Importers.SubmitAsset(name, asset);
		}

		public Result<uint8[]> Build(Span<uint8> data, Span<StringView> config)
		{
			if (!Font.IsValid(data))
				LogErrorReturn!("Data is not a valid font");

			let outData = new uint8[data.Length];
			data.CopyTo(outData);
			return outData;
		}
	}
}
