using System;

using internal Pile;

namespace Pile
{
	/// For assets such as shaders and audoClips, where their content is set from intermediate data
	/// which can be disposed of afterwards. TReset is only guaranteed to exist for the Reset() call.
	/// If you need the asset to exist permanently, just use Asset<T> directly with your asset.
	struct PersistentAsset<T, TReset> : IDisposable where T : IPersistentAsset<TReset>, class, delete where TReset : class, delete
	{
		readonly String resetName;
		readonly T asset;
		readonly bool deleteAsset;
		uint32 knownAssetAddIteration;
		uint32 knownAssetDelIteration;
		TReset resetAsset;

		public T Asset
		{
			[Inline]
			get mut
			{
				UpdateReference();

				// Always access asset!
				return asset;
			}
		}

		public this(T persistentAsset, String constResetName, bool ownsAsset = true)
		{
			asset = persistentAsset;
			deleteAsset = ownsAsset;

			resetName = constResetName;
			resetAsset = Assets.Get<TReset>(resetName); // Will set it to reference the asset or null
			knownAssetAddIteration = Assets.assetAddIteration;
			knownAssetDelIteration = Assets.assetDelIteration;
			if (!asset.IsSetup && resetAsset != null)
				persistentAsset.Reset(resetAsset).IgnoreError();
		}

		public T AssetOrDefault(T def) mut => Asset == null ? def : asset;

		public void UpdateReference() mut
		{
			if (resetName == null)
				return;

			if (resetAsset != null && knownAssetDelIteration != Assets.assetDelIteration
				|| resetAsset == null && knownAssetAddIteration != Assets.assetAddIteration)
			{
				// Refresh
				resetAsset = Assets.Get<TReset>(resetName);
				knownAssetAddIteration = Assets.assetAddIteration;
				knownAssetDelIteration = Assets.assetDelIteration;
			}
		}

		[Inline]
		public static implicit operator T(ref PersistentAsset<T, TReset> assetHandler) => assetHandler.Asset;

		public void Dispose()
		{
			if (deleteAsset)
				delete asset;
		}
	}
}
