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

			delete assets;
		}

		public static bool Has<T>(String name) where T : Object
		{
			let type = typeof(T);

			if (!assets.ContainsKey(type))
				return false;

			if (!assets.GetValue(type).Get().ContainsKey(name))
				return false;

			return true;
		}

		public static bool Has(Type type, String name)
		{
			if (!type.IsObject)
				return false;

			if (!assets.ContainsKey(type))
				return false;

			if (!assets.GetValue(type).Get().ContainsKey(name))
				return false;

			return true;
		}

		public static T Get<T>(String name) where T : Object
 		{
			 if (!Has<T>(name))
				 return null;

			 return (T)assets.GetValue(typeof(T)).Get().GetValue(name).Get();
		}

		public static Object Get(Type type, String name)
		{
			if (!Has(type, name))
				return false;

			return assets.GetValue(type).Get().GetValue(name).Get();
		}

		/** The name string passed here will be directly referenced in the dictionary, so take a fresh one, ideally the same that is also referenced in package owned assets.
		*/
		private static Result<void, String> AddAsset(Type type, String name, Object object)
		{
			if (!object.GetType().IsSubtypeOf(type))
				return .Err(new String("Couldn't add asset {0} of type {1}, because it is not assignable to given type {2}")..Format(name, object.GetType(), type));

			if (!assets.ContainsKey(type))
				assets.Add(type, new Dictionary<String, Object>());

			else if (assets.GetValue(type).Get().ContainsKey(name))
				return .Err(new String("Couldn't add asset {0} to dictionary for type {1}, because the name is already taken for this type")..Format(name, type));

			assets.GetValue(type).Get().Add(name, object);

			return .Ok;
		}
	}
}
