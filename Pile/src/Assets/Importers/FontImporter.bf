using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

namespace Pile
{
	[RegisterImporter]
	class FontImporter : Importer
	{
		public override String Name => "font";

		const StringView[?] ext = .("ttf");
		public override Span<StringView> TargetExtensions => ext;

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let asset = new Font(data);

			if (SubmitLoadedAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}

		public override Result<uint8[]> Build(StringView filePath)
		{
			Debug.Assert(File.Exists(filePath));

			FileStream fs = scope FileStream();
			Try!(fs.Open(filePath, .Open, .Read));

			let data = Try!(TryStreamToNewArray(fs));

			if (!Font.IsValid(data))
				LogErrorReturn!("FontImporter: Data is not a valid font");

			return data;
		}
	}
}
