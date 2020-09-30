using System;
using JSON_Beef.Types;

namespace Pile
{
	public class TestImporter : Packages.Importer
	{
		public override void Load(StringView name, uint8[] data, JSONObject dataNode)
		{
			Log.Message(dataNode);
			let asset = new TestAsset(data);

			SubmitAsset(name, asset);
		}

		public override Result<uint8[], String> Build(uint8[] data, out JSONObject dataNode)
		{
			dataNode = new JSONObject();
			dataNode.Add<int>("testEntry", 42);

			let outData = new uint8[data.Count];
			data.CopyTo(outData);
			return outData;
		}
	}

	public class TestAsset
	{
		public readonly StringView text;
		public readonly uint8[] data ~ delete _;

		public this(uint8[] copy)
		{
			data = new uint8[copy.Count];
			copy.CopyTo(data);
			text = StringView((char8*)data.CArray(), data.Count);
		}
	}
}
