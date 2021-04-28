using System;
using System.Reflection;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	interface Importer
	{
		public String Name { get; }

		/// Useful for when this relies on other files included "additional"
		/// -> they will cause reloads, but if this is false, this importer won't
		/// be notified since the actual file it imports hasn't been changed.
		/// On true, Build will always be called again when an additional file has
		/// changed for all imports of this importer.
		public bool RebuildOnAdditionalChanged => false;

		public Result<void> Load(StringView name, Span<uint8> data);
		public Result<uint8[]> Build(Span<uint8> data, Span<StringView> config, StringView dataFilePath);
	}

	[AttributeUsage(.Class, .AlwaysIncludeTarget|.ReflectAttribute, AlwaysIncludeUser=.IncludeAllMethods|.AssumeInstantiated, ReflectUser=.Methods)] // todo .DefaultConstructor should work too, change later
	struct RegisterImporterAttribute : Attribute {}

	[AlwaysInclude, StaticInitPriority(-1)]
	static class Importers
	{
		public const String None = "none";

		internal static Dictionary<String, Importer> importers = new .() ~ DeleteDictionaryAndValues!(_);
		internal static Package currentPackage;

		public static this()
		{
			for (let type in Type.Types)
			{
				if (!type.IsObject || !type.HasCustomAttribute<RegisterImporterAttribute>())
					continue;

				TypeInstance currentType = type as TypeInstance;
				bool implementsImporter = false;
				repeat
				{
					for (let interf in currentType.Interfaces)
						if (interf != null && (Type)interf == typeof(Importer))
							implementsImporter = true;

					currentType = currentType.BaseType;
				}
				while (!implementsImporter && currentType != null && currentType != typeof(Object));

				if (!implementsImporter)
					continue;

				Importer i;
				switch (type.CreateObject())
				{
				case .Ok(let val):
					i = val as Importer;
				case .Err:
					Debug.FatalError(scope $"Could not construct importer {type.GetName(.. scope .())}. Make sure it has a parameter-less constructor");
					continue;
				}

				// Just a prettier error for debug builds, add won't allow duplicates anyway
				Debug.Assert(!importers.ContainsKey(i.Name), scope $"Importer with name {i.Name} already exists");

				importers.Add(i.Name, i);
			}
		}

		/// Should only be called from Importers
		public static Result<void> SubmitAsset(StringView name, Object asset)
		{
			Debug.Assert(currentPackage != null, "Importers can only submit assets while loading a Package (when called from Assets.LoadPackage(...))");

			let type = asset.GetType();

			// Add object in assets
			let nameView = Try!(Assets.AddAsset(type, name, asset));

			// Store object key in package
			if (!currentPackage.ownedAssets.ContainsKey(type))
				currentPackage.ownedAssets.Add(type, new List<StringView>());

			currentPackage.ownedAssets.GetValue(type).Get().Add(nameView);

			return .Ok;
		}

		/// Should only be called from Importers
		public static Result<Subtexture> SubmitTextureAsset(StringView name, Bitmap bitmap)
		{
			Debug.Assert(currentPackage != null, "Importers can only submit assets while loading a Package (when called from Assets.LoadPackage(...))");

			// Add object in assets
			let nameView = Try!(Assets.AddTextureAsset(name, bitmap, let asset));

			// Store object key in package
			currentPackage.ownedTextureAssets.Add(nameView);

			return .Ok(asset);
		}
	}
}
