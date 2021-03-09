using System;

namespace Pile
{
	/// Handles a reference to an asset across reloads etc. MUST be disposed!
	public struct Asset<T> : IDisposable where T : class
	{
		readonly String name; // If you leak this string, you forgot to call Dispose() on this
		T asset;

		Assets.PackageEvent load;
		Assets.PackageEvent unload;

		public T Asset => asset;

		public this(StringView assetName)
		{
			name = new String(assetName);

			load = new => PackageLoaded;
			unload = new => PackageUnloaded;
			Core.Assets.OnLoadPackage.Add(load);
			Core.Assets.OnUnloadPackage.Add(unload);

			asset = Core.Assets.Get<T>(name); // Will set it to reference the asset or null
		}

		public void Dispose()
		{
			Core.Assets.OnLoadPackage.Remove(load);
			Core.Assets.OnUnloadPackage.Remove(unload);

			delete name;
			delete load;
			delete unload;
		}

		public T AssetOrDefault(T def) => asset == null ? def : asset;

		void PackageLoaded(Package package) mut
		{
			if (asset != null) return; // Already have asset

			if (package.OwnsAsset(typeof(T), name) || (typeof(T) == typeof(Subtexture) && package.OwnsTextureAsset(name)))
			{
				asset = Core.Assets.Get<T>(name); // Get it
			}
		}

		void PackageUnloaded(Package package) mut
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
