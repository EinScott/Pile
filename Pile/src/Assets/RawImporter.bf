using System;
using JSON_Beef.Types;

namespace Pile
{
	public class RawImporter : Importer
	{
		public override Result<void> Load(StringView name, Span<uint8> data, JSONObject dataNode)
		{
			let asset = new RawAsset(data);

			return SubmitAsset(name, asset);
		}

		public override Result<uint8[]> Build(Span<uint8> data, out JSONObject dataNode)
		{
			dataNode = null;

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
