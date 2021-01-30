using System;
using System.Collections;

namespace Pile
{
	//todo: remove AlwaysInclude off importers once .AlwaysIncludeTarget on the other attribute is fixed
	[RegisterImporter,AlwaysInclude]
	public class RawImporter : Importer
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

		public virtual Result<uint8[]> Build(Span<uint8> data, Span<StringView> config, StringView dataFilePath)
		{
			let outData = new uint8[data.Length];
			data.CopyTo(outData);
			return outData;
		}
	}

	public class RawAsset
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
