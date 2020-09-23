using System;
using JSON_Beef.Types;

namespace Pile
{
	public class TestImporter : Packages.Importer
	{
		public override void Load(Packages.Package package, uint8[] data, JSONObject dataNode)
		{

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
}
