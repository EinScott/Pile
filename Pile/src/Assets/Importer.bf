using System;
using System.IO;
using System.Reflection;
using System.Collections;
using System.Diagnostics;
using Bon;

using internal Pile;

namespace Pile
{
	// make it easier to interface with Assets, make it usable for SpriteFont -- make textureFilter settable from importers actually

	[AlwaysInclude, StaticInitPriority(-1)]
	abstract class Importer
	{
		public abstract String Name { get; }

		public abstract Span<StringView> TargetExtensions { get; } // Which exts should be sent to this importer
		public virtual Span<StringView> DependantExtensions => .(); // Which exts cause this importer to rebuild (as it also relies on those files)

		public virtual void ClearConfig() {}
		public virtual Result<void> SetConfig(StringView bonStr)
		{
			Debug.Assert(bonStr.Length == 0, "Config left unused!");
			return .Ok;
		}

		public virtual Result<uint8[]> Build(StringView filePath)
		{
			// By default, no processing is done, we simply transfer the file contents!

			Debug.Assert(File.Exists(filePath));

			FileStream fs = scope FileStream();
			Try!(fs.Open(filePath, .Open, .Read));

			return TryStreamToNewArray(fs);
		}

		public static Result<uint8[]> TryStreamToNewArray(Stream data)
		{
			let length = data.Length - data.Position;
			let outData = new uint8[length];
			var writeOffset = 0;
			TRANSFER:while (writeOffset < length)
			{
				switch (data.TryRead(.(&outData[writeOffset], Math.Min(4096, length - writeOffset))))
				{
				case .Ok(let bytes):
					writeOffset += bytes;

					if (bytes == 0)
						break TRANSFER;

				case .Err:
					break TRANSFER;
				}
			}

			if (writeOffset != length)
			{
				delete outData;
				LogErrorReturn!("Importer: Failed to read data from stream");
			}

			return .Ok(outData);
		}

		public abstract Result<void> Load(StringView name, Span<uint8> data);

		internal static Dictionary<String, Importer> importers = new .() ~ DeleteDictionaryAndValues!(_);
		internal static Package currentPackage;

		static this()
		{
			for (let type in Type.Types)
			{
				if (!type.IsObject || !type.HasCustomAttribute<RegisterImporterAttribute>() || !type.IsSubtypeOf(typeof(Importer)))
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

				// Just a prettier error for debug builds, Add() won't allow duplicates anyway
				Debug.Assert(!importers.ContainsKey(i.Name), scope $"Importer with name {i.Name} already exists");

				importers.Add(i.Name, i);
			}
		}

		protected static mixin ToScopedMetaFilePath(StringView path)
		{
			let into = scope:mixin String(path.Length + 10);
			Path.ChangeExtension(path, ".meta.bon", into);
			into
		}

		protected static Result<void> ReadFullFile(StringView path, ref uint8[] outDataAlloc)
		{
			FileStream fs = scope FileStream();
			Try!(fs.Open(path, .Open, .Read));

			let len = fs.Length;
			if (outDataAlloc == null || outDataAlloc.Count < len)
				outDataAlloc = new uint8[len];
			var ptr = outDataAlloc.Ptr;
			var end = ptr + len;

			while (true)
			{
				switch (fs.TryRead(.(ptr, 4096)))
				{
				case .Ok(let bytes):
					if (bytes == 0)
						return .Ok;
					ptr += bytes;
					
					Debug.Assert(ptr <= end);

				case .Err:
					return .Err;
				}
			}
		}

		/// Should only be called from Load()
		protected static Result<void> SubmitLoadedAsset(StringView name, Object asset)
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

		/// Should only be called from Load(). DOES NOT CONSUME BITMAP!
		protected static Result<Subtexture> SubmitLoadedTextureAsset(StringView name, Bitmap bitmap, TextureFilter filter = Core.Defaults.TextureFilter)
		{
			Debug.Assert(currentPackage != null, "Importers can only submit assets while loading a Package (when called from Assets.LoadPackage(...))");

			// Add object in assets
			let nameView = Try!(Assets.AddTextureAsset(name, bitmap, let asset, filter));

			// Store object key in package
			currentPackage.ownedTextureAssets.Add(nameView);

			return .Ok(asset);
		}
	}

	[AttributeUsage(.Class, .AlwaysIncludeTarget|.ReflectAttribute, AlwaysIncludeUser=.IncludeAllMethods|.AssumeInstantiated, ReflectUser=.DefaultConstructor)]
	struct RegisterImporterAttribute : Attribute {}
}
