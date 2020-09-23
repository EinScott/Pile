using System;
using System.IO;
using System.Collections;
using System.Diagnostics;
using JSON_Beef.Serialization;
using JSON_Beef.Types;

namespace Pile
{
	public static class Assets
	{
		// merge Assets, Images (loading of images with dynamic format registering)
		// 					=> bitmap loading
		// have asset packages
		// make loading assets async? - nah why, but maybe the compiling part but who cares
		// make registering assets types possible?
		//  => instead of this, register importers (tilemap importer, sprite importer and choose them by string match)

		static Packer texturePacker = new Packer() ~ delete _;
		static Dictionary<Type, Dictionary<String, Object>> assets = new Dictionary<Type, Dictionary<String, Object>>();

		static ~this()
		{
			for (let dic in assets.Values)
				DeleteDictionaryAndKeysAndItems!(dic);

			DeleteDictionaryAndKeys!(assets);
		}
	}
}
