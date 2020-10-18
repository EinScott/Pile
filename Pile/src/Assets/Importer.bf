using System;
using System.Collections;
using JSON_Beef.Types;

using internal Pile;

namespace Pile
{
	public abstract class Importer
	{
		public abstract Result<void> Load(StringView name, Span<uint8> data, JSONObject dataNode);
		public abstract Result<uint8[]> Build(Span<uint8> data, out JSONObject dataNode);

		internal Package package;
		protected Result<void> SubmitAsset(StringView name, Object asset)
		{
			if (package == null)
				LogErrorReturn!("Importers can only submit assets when called from load package function");

			let type = asset.GetType();

			let nameString = new String(name);

			// Check if assets contains this name already
			if (Assets.Has(type, nameString))
			{
				delete nameString;

				LogErrorReturn!(scope String("Couldn't submit asset {0}: An object of this type ({1}) is already registered under this name")..Format(name, type));
			}

			// Add object location in package
			if (!package.ownedAssets.ContainsKey(type))
				package.ownedAssets.Add(type, new List<String>());

			package.ownedAssets.GetValue(type).Get().Add(nameString);

			// Add object in assets
			if (Assets.AddAsset(type, nameString, asset) case .Err) return .Err;

			return .Ok;
		}

		protected Result<void> SubmitPackerTexture(StringView name, Bitmap bitmap)
		{
			if (package == null)
				LogErrorReturn!("Importers can only submit assets when called from load package function");

			let nameString = new String(name);

			// Check if assets contains this name already
			if (Assets.Has(typeof(Subtexture), nameString))
			{
				delete nameString;

				LogErrorReturn!(scope String("Couldn't submit texture {0}: A texture is already registered under this name")..Format(name));
			}

			// Add object location in package
			package.ownedPackerTextures.Add(nameString);

			// Add object in assets
			if (Assets.AddPackerTexture(nameString, bitmap) case .Err) return .Err;

			return .Ok;
		}
	}
}
