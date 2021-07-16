using System;

namespace Pile
{
	/// For assets such as shaders and audoClips, where their content is set from intermediate data
	/// which can be disposed of afterwards. TReset is only guaranteed to exist for the Reset() call.
	/// If you need the asset to exist permanently, just use Asset<T> directly with your asset.
	class PersistentAsset<T, TReset> where T : IPersistentAsset<TReset>, class, delete where TReset : class, delete
	{
		readonly String resetName ~ delete _;
		readonly T persistentAsset;
		readonly bool ownsAsset;

		TReset resetAsset;

		[Inline]
		public T Asset => persistentAsset;

		public this(T persistentAsset, StringView resetAssetName, bool ownsAsset = true)
		{
			resetName = new .(resetAssetName);

			this.ownsAsset = ownsAsset;
			this.persistentAsset = persistentAsset;

			Assets.OnLoadPackage.Add(new => PackageLoaded);
			Assets.OnUnloadPackage.Add(new => PackageUnloaded);

			resetAsset = Assets.Get<TReset>(resetName); // Will set it to reference the asset or null
			if (!persistentAsset.IsSetup && resetAsset != null)
			{
				if (persistentAsset.Reset(resetAsset) case .Err)
					Log.Warn(scope $"Reset on persistent asset of {resetName} failed on construction");
			}
		}

		public ~this()
		{
			Assets.OnLoadPackage.Remove(scope => PackageLoaded, true);
			Assets.OnUnloadPackage.Remove(scope => PackageUnloaded, true);

			if (ownsAsset)
				delete persistentAsset;
		}

		void PackageLoaded(Package package)
		{
			if (resetAsset != null) return; // Already have asset

			if (package.OwnsAsset(typeof(TReset), resetName) || (typeof(TReset) == typeof(Subtexture) && package.OwnsTextureAsset(resetName)))
			{
				resetAsset = Assets.Get<TReset>(resetName); // Get it

				if (persistentAsset.Reset(resetAsset) case .Err)
					Log.Warn(scope $"Reset on persistent asset of {resetName} failed");
			}
		}

		void PackageUnloaded(Package package)
		{
			if (resetAsset == null) return; // Don't have asset

			if (package.OwnsAsset(typeof(TReset), resetName) || (typeof(TReset) == typeof(Subtexture) && package.OwnsTextureAsset(resetName)))
			{
				resetAsset = null; // Leave it
			}
		}

		[Inline]
		public static implicit operator T(PersistentAsset<T, TReset> assetHandler) => assetHandler.persistentAsset;
	}
}
