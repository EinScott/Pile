using System;
using System.Collections;

namespace Pile
{
	public class Package
	{
		internal Dictionary<Type, List<String>> ownedAssets = new Dictionary<Type, List<String>>();
		internal List<String> ownedPackerTextures = new List<String>();
		
		internal this() {}

		public ~this()
		{
			// Manages dictionary and lists, but not strings, which are taken care of by assets and might already be deleted
			for (let entry in ownedAssets)
				delete entry.value;

			delete ownedAssets;
			delete ownedPackerTextures;
		}

		internal readonly String name = new String() ~ delete _;
		public StringView Name => name;

		public bool OwnsAsset(Type type, String name)
		{
			if (!ownedAssets.ContainsKey(type)) return false;
			if (!ownedAssets.GetValue(type).Get().Contains(name)) return false;

			return true;
		}

		public bool OwnsPackerTexture(String name)
		{
			if (!ownedPackerTextures.Contains(name)) return false;

			return true;
		}
	}
}
