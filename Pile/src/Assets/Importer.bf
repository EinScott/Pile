using System;
using System.Collections;
using JSON_Beef.Types;

using internal Pile;

namespace Pile
{
	public abstract class Importer
	{
		public abstract Result<void> Load(StringView name, Span<uint8> data, JSONObject dataNode);
		public abstract Result<uint8[]> Build(Span<uint8> data, JSONObject config, out JSONObject dataNode);

		internal Package package;
		protected Result<void> SubmitAsset(StringView name, Object asset)
		{
			if (package == null)
				LogErrorReturn!("Importers can only submit assets when called from load package function");

			let type = asset.GetType();

			// Add object in assets
			let nameView = Try!(Assets.AddAsset(type, name, asset));

			// Store object key in package
			if (!package.ownedAssets.ContainsKey(type))
				package.ownedAssets.Add(type, new List<StringView>());

			package.ownedAssets.GetValue(type).Get().Add(nameView);

			return .Ok;
		}

		protected Result<void> SubmitTextureAsset(StringView name, Bitmap bitmap)
		{
			if (package == null)
				LogErrorReturn!("Importers can only submit assets when called from load package function");

			// Add object in assets
			let nameView = Try!(Assets.AddTextureAsset(name, bitmap));

			// Store object key in package
			package.ownedPackerTextures.Add(nameView);

			return .Ok;
		}
	}
}
