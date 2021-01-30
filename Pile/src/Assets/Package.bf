using System;
using System.Collections;

namespace Pile
{
	public class Package
	{
#if DEBUG // Debug info used for hot reloads
		internal String sourcePath ~ DeleteNotNull!(_);
#endif

		internal Dictionary<Type, List<StringView>> ownedAssets = new Dictionary<Type, List<StringView>>() ~ DeleteDictionaryAndValues!(_);
		internal List<StringView> ownedTextureAssets = new List<StringView>() ~ delete _;
		
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
