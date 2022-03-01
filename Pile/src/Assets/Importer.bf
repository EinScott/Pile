using System;
using System.IO;
using System.Reflection;
using System.Collections;
using System.Diagnostics;
using Bon;

using internal Pile;

namespace Pile
{
	// TODO: replace more strings with IDs, AssetId ?? or not!
	// make it easier to interface with Assets, make it usable for SpriteFont, remove atlas building from it and put that in an importer!
	// separate package load & hot reload stuff from resource management!

	// explicit passes of specified things with collective configs? - optional offset folder, but importer "chooses" files

	// importers may use other importers - helper function

	interface IImporter
	{
		String Name { get; }

		Span<StringView> TargetExtensions { get; } // Which exts should be sent to this importer
		Span<StringView> DependantExtensions { get; } // Which exts cause this importer to rebuild
		// TODO maybe-- instead make rebuild trigger filter part of pass spec, by default same as target path

		void ClearConfig();
		Result<void> SetConfig(StringView bonStr);

		Result<void> Build(Stream inStream, Stream outStream);
		Result<void> Load(StringView name, Span<uint8> data);

		public bool FileSupported(StringView path)
		{
			let extStr = scope String(5);
			if (Path.GetExtension(path, extStr) case .Err)
				return false;
			Debug.Assert(extStr.StartsWith('.'));
			let extView = StringView(extStr, 1);

			for (var ext in TargetExtensions)
			{
				if (ext.StartsWith('.'))
					ext.RemoveFromStart(1);

				if (ext == extView)
					return true;
			}
			return false;
		}
	}

	abstract class Importer : IImporter
	{
		public abstract Span<StringView> TargetExtensions { get; }
		public abstract Span<StringView> DependantExtensions { get; }

		// No config!
		[SkipCall]
		public void ClearConfig() {}
		public Result<void> SetConfig(StringView bonStr) => bonStr.Length == 0 ? .Ok : .Err;

		public abstract Result<void> Build(Stream inStream, Stream outStream);
		public abstract Result<void> Load(StringView name, Span<uint8> data);
	}

	abstract class Importer<TConfig> : IImporter where TConfig : struct, new
	{
		public TConfig config;

		public abstract Span<StringView> TargetExtensions { get; }
		public abstract Span<StringView> DependantExtensions { get; }

		[Inline]
		public void ClearConfig()
		{
			config = .();
		}

		public Result<void> SetConfig(StringView bonStr)
		{
			if (Bon.Deserialize(ref config, bonStr) case .Ok)
				return .Ok;
			return .Err;
		}

		public abstract Result<void> Build(Stream inStream, Stream outStream);
		public abstract Result<void> Load(StringView name, Span<uint8> data);

		/*public String Name { get; }

		/// Useful for when this relies on other files included "additional"
		/// -> they will cause reloads, but if this is false, this importer won't
		/// be notified since the actual file it imports hasn't been changed.
		/// On true, Build will always be called again when an additional file has
		/// changed for all imports of this importer.
		public bool RebuildOnAdditionalChanged => false;

		public abstract void ClearConfig()

		public Result<void> Load(StringView name, Span<uint8> data);
		public Result<uint8[]> Build(Stream data, Span<StringView> config, StringView dataFilePath);

		public static mixin TryStreamToArray(Stream data)
		{
			let outData = new uint8[data.Length];
			if (!(data.TryRead(outData) case .Ok(data.Length)))
			{
				delete outData;
				LogErrorReturn!("Importer: Failed to read data from stream");
			}
			outData
		}*/
	}

	[AttributeUsage(.Class, .AlwaysIncludeTarget|.ReflectAttribute, AlwaysIncludeUser=.IncludeAllMethods|.AssumeInstantiated, ReflectUser=.DefaultConstructor)]
	struct RegisterImporterAttribute : Attribute {}

	[AlwaysInclude, StaticInitPriority(-1)]
	static class Importers
	{
		internal static Dictionary<String, IImporter> importers = new .() ~ DeleteDictionaryAndValues!(_);
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
					// TODO: no clue if this still works!
					for (let interf in currentType.Interfaces)
						if (interf != null && (Type)interf == typeof(IImporter))
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

		public Result<void> Import(StringView name, StringView config)
		{
			// "hide" clear & set config calls!
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
				currentPackage.ownedAssets.Add(type, new HashSet<StringView>());

			currentPackage.ownedAssets.GetValue(type).Get().Add(nameView);

			return .Ok;
		}

		/// Should only be called from Importers. DOES NOT CONSUME BITMAP!
		public static Result<Subtexture> SubmitTextureAsset(StringView name, Bitmap bitmap, TextureFilter filter = Core.Defaults.TextureFilter)
		{
			Debug.Assert(currentPackage != null, "Importers can only submit assets while loading a Package (when called from Assets.LoadPackage(...))");

			// Add object in assets
			let nameView = Try!(Assets.AddTextureAsset(name, bitmap, let asset, filter));

			// Store object key in package
			currentPackage.ownedTextureAssets.Add(nameView);

			return .Ok(asset);
		}
	}
}
