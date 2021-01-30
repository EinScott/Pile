using System;
using System.Reflection;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public interface Importer
	{
		public String Name { get; }

		public Result<void> Load(StringView name, Span<uint8> data);
		public Result<uint8[]> Build(Span<uint8> data, Span<StringView> config, StringView dataFilePath);
	}

	[AttributeUsage(.Class, .AlwaysIncludeTarget|.ReflectAttribute, AlwaysIncludeUser=.IncludeAllMethods|.AssumeInstantiated, ReflectUser=.Methods)] // .DefaultConstructor should work too, change later
	public struct RegisterImporterAttribute : Attribute
	{

	}

	[AlwaysInclude,StaticInitPriority(-1)]
	public static class Importers
	{
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
			let nameView = Try!(Core.Assets.AddAsset(type, name, asset));

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
			let nameView = Try!(Core.Assets.AddTextureAsset(name, bitmap, let asset));

			// Store object key in package
			currentPackage.ownedTextureAssets.Add(nameView);

			return .Ok(asset);
		}
	}
}
