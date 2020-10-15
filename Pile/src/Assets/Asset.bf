using System;

namespace Pile
{
	public class Asset<T> where T : Object
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

		void PackageLoaded(Packages.Package package)
		{
			if (asset != null) return; // Already have asset

			if (package.OwnsAsset(typeof(T), name))
				asset = Assets.Get<T>(name); // Get it
		}

		void PackageUnloaded(Packages.Package package)
		{
			if (asset == null) return; // Don't have asset

			if (package.OwnsAsset(typeof(T), name))
				asset = null; // Leave it
		}

		public static operator T(Asset<T> assetHandler) => assetHandler.asset;
	}
}
