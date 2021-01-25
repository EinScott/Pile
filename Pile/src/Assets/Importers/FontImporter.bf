using System;
using System.IO;
using System.Collections;

namespace Pile
{
	public class FontImporter : Importer
	{
		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let asset = new Font(data);

			return SubmitAsset(name, asset);
		}

		public override Result<uint8[]> Build(Span<uint8> data, Span<StringView> config)
		{
			if (!Font.IsValid(data))
				LogErrorReturn!("Data is not a valid font");

			let outData = new uint8[data.Length];
			data.CopyTo(outData);
			return outData;
		}
	}
}
