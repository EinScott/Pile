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

		public static bool Has<T>(StringView name)
		{
			return true;
		}

		public static bool Has(Type type, StringView name)
		{
			return true;
		}

		public static T Get<T>(StringView name) where T : Object
 		{
			 return null;
		}

		public static Object Get(Type type, StringView name)
		{
			return null;
		}

		private static void AddAsset(Type type, String name, Object object)
		{

		}

		// IF you do removing methods, think about how a package own list might still have a reference to a string of an asset here. How do you handle that?
	}
}
