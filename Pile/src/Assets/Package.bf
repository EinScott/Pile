using System;
using System.Collections;

namespace Pile
{
	public class Package
	{
		internal Dictionary<Type, List<StringView>> ownedAssets = new Dictionary<Type, List<StringView>>() ~ DeleteDictionaryAndItems!(_);
		internal List<StringView> ownedPackerTextures = new List<StringView>() ~ delete _;
		
		internal this() {}

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
