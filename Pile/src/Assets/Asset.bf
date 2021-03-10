using System;

namespace Pile
{
	class Asset<T> where T : class
	{
		readonly String name ~ delete _;
		T asset;

		public T Asset => asset;

		public this(StringView assetName)
		{
			name = new String(assetName);

			Core.Assets.OnLoadPackage.Add(new => PackageLoaded);
			Core.Assets.OnUnloadPackage.Add(new => PackageUnloaded);

			asset = Core.Assets.Get<T>(name); // Will set it to reference the asset or null
		}

		public ~this()
		{
			Core.Assets.OnLoadPackage.Remove(scope => PackageLoaded, true);
			Core.Assets.OnUnloadPackage.Remove(scope => PackageUnloaded, true);
		}

		public T AssetOrDefault(T def) => asset == null ? def : asset;

		void PackageLoaded(Package package)
		{
			if (asset != null) return; // Already have asset

			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsTextureAsset(name)))
			{
				asset = Core.Assets.Get<T>(name); // Get it
			}
		}

		void PackageUnloaded(Package package)
		{
			if (asset == null) return; // Don't have asset

			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsTextureAsset(name)))
			{
				asset = null; // Leave it
			}
		}

		public static implicit operator T(Asset<T> assetHandler) => assetHandler.asset;
	}
}
