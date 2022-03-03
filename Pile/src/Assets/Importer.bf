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
	// separate package load & hot reload stuff from resource management? -- maybe packageManager/packager all together?

	[AlwaysInclude, StaticInitPriority(-1)]
	abstract class Importer
	{
		public abstract String Name { get; }

		public abstract Span<StringView> TargetExtensions { get; } // Which exts should be sent to this importer
		public virtual Span<StringView> DependantExtensions => .(); // Which exts cause this importer to rebuild
		// TODO maybe-- instead make rebuild trigger filter part of pass spec, by default same as target path

		public virtual void ClearConfig() {}
		public virtual Result<void> SetConfig(StringView bonStr)
		{
			Debug.Assert(bonStr.Length == 0, "Config left unused!");
			return .Ok;
		}

		public virtual Result<void> Build(Substream outStream, StringView filePath)
		{
			// By default, no processing is done, we simply transfer the file contents!

			Debug.Assert(File.Exists(filePath));

			FileStream fs = scope FileStream();
			Try!(fs.Open(filePath, .Open, .Read));

			while (true)
			{
				uint8[4096] buffer;
				switch (fs.TryRead(.(&buffer, 4096)))
				{
				case .Ok(let bytes):
					if (bytes == 0)
						return .Ok;

					switch (outStream.TryWrite(.(&buffer, bytes)))
					{
					case .Err:
						return .Err;
					case .Ok(let write):
						if (write != bytes)
							return .Err;
					}
				case .Err:
					return .Err;
				}
			}
		}

		public abstract Result<void> Load(StringView name, Span<uint8> data);

		public bool TargetsFile(StringView path)
		{
			let extStr = scope String(5);
			if (!Path.GetExtension(path, extStr))
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

		public bool DependsOnFile(StringView path)
		{
			let extStr = scope String(5);
			if (!Path.GetExtension(path, extStr))
				return false;
			Debug.Assert(extStr.StartsWith('.'));
			let extView = StringView(extStr, 1);

			for (var ext in DependantExtensions)
			{
				if (ext.StartsWith('.'))
					ext.RemoveFromStart(1);

				if (ext == extView)
					return true;
			}
			return false;
		}

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

		protected static mixin ToMetaFilePath(StringView path, String into)
		{
			Path.ChangeExtension(path, ".meta.bon", into);
		}

		protected static Result<void> LoadFullFile(StringView path, ref uint8[] outDataAlloc)
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

					Debug.Assert(ptr < end);
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
