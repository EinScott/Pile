using System;
using System.Collections;

namespace Pile
{
	class Package
	{
		internal Dictionary<Type, HashSet<StringView>> ownedAssets = new Dictionary<Type, HashSet<StringView>>() ~ DeleteDictionaryAndValues!(_);
		internal HashSet<StringView> ownedTextureAssets = new HashSet<StringView>() ~ delete _;
		
		internal this() {}
		internal ~this() {}

		internal readonly String name = new String() ~ delete _;
		public StringView Name => name;

		public bool OwnsAsset(Type type, String name)
		{
			if (!ownedAssets.ContainsKey(type)) return false;
			if (!ownedAssets.GetValue(type).Get().Contains(name)) return false;

			return true;
		}

		public bool OwnsTextureAsset(String name)
		{
			if (!ownedTextureAssets.Contains(name)) return false;

			return true;
		}
	}
}
