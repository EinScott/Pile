using System;

namespace Pile
{
	public class Asset<T> where T : class
	{
		readonly String name ~ delete _;
		T asset;

		public T Asset => asset;

		public this(StringView assetName)
		{
			this.name = new String(assetName);

			Packages.OnLoadPackage.Add(new => PackageLoaded);
			Packages.OnUnloadPackage.Add(new => PackageUnloaded);

			asset = Assets.Get<T>(name); // Will set it to reference the asset or null
		}

		public ~this()
		{
			Packages.OnLoadPackage.Remove(scope => PackageLoaded, true);
			Packages.OnUnloadPackage.Remove(scope => PackageUnloaded, true);
		}

		public T AssetOrDefault(T def) => asset == null ? def : asset;

		void PackageLoaded(Package package)
		{
			if (asset != null) return; // Already have asset

			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsPackerTexture(name)))
				asset = Assets.Get<T>(name); // Get it
		}

		void PackageUnloaded(Package package)
		{
			if (asset == null) return; // Don't have asset

			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsPackerTexture(name)))
				asset = null; // Leave it
		}

		public static operator T(Asset<T> assetHandler) => assetHandler.asset;
	}
}
