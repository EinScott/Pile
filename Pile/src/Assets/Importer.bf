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

				LogErrorReturn!(scope String()..AppendF("Couldn't submit asset {}: An object of this type ({}) is already registered under this name", name, type));
			}

			// Add object in assets
			if (Assets.AddAsset(type, nameString, asset) case .Err) return .Err;

			// Add object location in package
			if (!package.ownedAssets.ContainsKey(type))
				package.ownedAssets.Add(type, new List<String>());

			package.ownedAssets.GetValue(type).Get().Add(nameString);

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

				LogErrorReturn!(scope String()..AppendF("Couldn't submit texture {}: A texture is already registered under this name", name));
			}

			// Add object in assets
			if (Assets.AddPackerTexture(nameString, bitmap) case .Err) return .Err;

			// Add object location in package
			package.ownedPackerTextures.Add(nameString);

			return .Ok;
		}
	}
}
