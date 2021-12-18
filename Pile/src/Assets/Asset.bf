using System;

using internal Pile;

namespace Pile
{
	struct Asset<T> where T : class, delete
	{
		readonly String name;
		uint32 knownAssetAddIteration;
		uint32 knownAssetDelIteration;
		T asset;

		public T Asset
		{
			get mut
			{
				if (asset != null && knownAssetDelIteration == Assets.assetDelIteration)
				{
					// Since we got the asset and nothing was deleted, we're still guaranteed valid
					return asset;
				}
				else
				{
					// Try to get the asset again in case anything happened
					if (asset != null && knownAssetDelIteration != Assets.assetDelIteration
						|| asset == null && knownAssetAddIteration != Assets.assetAddIteration)
					{
						// Refresh
						asset = Assets.Get<T>(name);
						knownAssetAddIteration = Assets.assetAddIteration;
						knownAssetDelIteration = Assets.assetDelIteration;
					}

					return asset;
				}
			}
		}

		public this(String constName)
		{
			name = constName;

			asset = Assets.Get<T>(name); // Will set it to reference the asset or null
			knownAssetAddIteration = Assets.assetAddIteration;
			knownAssetDelIteration = Assets.assetDelIteration;
		}

		public T AssetOrDefault(T def) mut => Asset == null ? def : asset;

		[Inline]
		public static implicit operator T(Asset<T> assetHandler) => assetHandler.asset;
	}
}
