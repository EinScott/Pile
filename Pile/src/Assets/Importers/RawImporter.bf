using System;
using System.IO;
using System.Collections;

namespace Pile
{
	[RegisterImporter]
	class RawImporter : Importer
	{
		public override String Name => "raw";

		const StringView[?] ext = .("", "bin", "txt", "bon");
		public override Span<StringView> TargetExtensions => ext;

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let asset = new RawAsset(data);

			if (SubmitLoadedAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}
	}

	class RawAsset
	{
		public readonly StringView text;
		public readonly uint8[] data ~ delete _;

		public this(Span<uint8> copy)
		{
			data = new uint8[copy.Length];
			copy.CopyTo(data);
			text = StringView((char8*)data.Ptr, data.Count);
		}
	}
}
