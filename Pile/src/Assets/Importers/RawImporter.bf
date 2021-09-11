using System;
using System.IO;
using System.Collections;

namespace Pile
{
	[RegisterImporter]
	class RawImporter : Importer
	{
		public virtual String Name => "raw";

		public virtual Result<void> Load(StringView name, Span<uint8> data)
		{
			let asset = new RawAsset(data);

			if (Importers.SubmitAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}

		public virtual Result<uint8[]> Build(Stream data, Span<StringView> config, StringView dataFilePath)
		{
			return Importer.TryStreamToArray!(data);
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
			text = StringView((char8*)data.CArray(), data.Count);
		}
	}
}
