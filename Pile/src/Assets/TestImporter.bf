using System;
using JSON_Beef.Types;

namespace Pile
{
	public class TestImporter : Assets.Importer
	{
		public override Object Load(uint8[] data, JSONObject dataNode)
		{
			return default;
		}

		public override Result<uint8[], String> Import(uint8[] data, out JSONObject dataNode)
		{
			dataNode = new JSONObject();
			dataNode.Add<int>("testEntry", 42);

			let outData = new uint8[data.Count];
			data.CopyTo(outData);
			return outData;
		}
	}
}
