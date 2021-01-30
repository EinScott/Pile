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

			Log.Info("LOAD");
			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsTextureAsset(name)))
			{
				Log.Info("DID");
				asset = Core.Assets.Get<T>(name); // Get it
			}
		}

		void PackageUnloaded(Package package)
		{
			if (asset == null) return; // Don't have asset

			Log.Info("UNLOAD");
			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsTextureAsset(name)))
			{
				Log.Info("DID");
				asset = null; // Leave it
			}
		}

		public static operator T(Asset<T> assetHandler) => assetHandler.asset;
	}
}
