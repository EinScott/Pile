using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	[Optimize]
	public class Assets
	{
		Packer packer = new Packer() { combineDuplicates = true } ~ delete _;
		List<Texture> atlas = new List<Texture>() ~ DeleteContainerAndItems!(_);

		Dictionary<Type, Dictionary<String, Object>> assets = new Dictionary<Type, Dictionary<String, Object>>() ~
			{
				for (let dic in _.Values)
					DeleteDictionaryAndKeysAndValues!(dic);

				delete _;
			};

		Dictionary<Type, List<StringView>> dynamicAssets = new Dictionary<Type, List<StringView>>() ~  DeleteDictionaryAndValues!(_);
		List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_);
		String packagesPath = new String() ~ delete _;

		public int TextureCount => packer.SourceImageCount;
		public int AssetCount
		{
			get
			{
				int c = 0;
				for (let typeDict in assets.Values)
					c += typeDict.Count;

				return c;
			}
		}
		public int DynamicAssetCount
		{
			get
			{
				int c = 0;
				for (let nameList in dynamicAssets.Values)
					c += nameList.Count;

				return c;
			}
		}

		public delegate void PackageEvent(Package package);
		public Event<PackageEvent> OnLoadPackage ~ _.Dispose(); // Called after a package was loaded
		public Event<PackageEvent> OnUnloadPackage ~ _.Dispose(); // Called before a package was unloaded (assets not yet deleted)

		internal this()
		{
			// Get packages path
			Path.InternalCombine(packagesPath, Core.System.DataPath, "packages");

#if DEBUG && !PILE_DISABLE_AUTOMATIC_PACKAGE_RELOAD
			Core.Window.OnFocusChanged.Add(new => OnWindowFocusChanged);
#endif
		}

		internal ~this()
		{
#if DEBUG && !PILE_DISABLE_AUTOMATIC_PACKAGE_RELOAD
			Core.Window.OnFocusChanged.Remove(scope => OnWindowFocusChanged, true);
#endif
		}

		void OnWindowFocusChanged()
		{
			// The window was just focused again and the game is not just starting
			if (Core.Window.Focus && Time.RawDuration > TimeSpan(0, 0, 1))
				HotReloadPackages();
		}

		public bool Has<T>(String name) where T : class
		{
			let type = typeof(T);

			if (!assets.ContainsKey(type))
				return false;

			if (!assets.GetValue(type).Get().ContainsKey(name))
				return false;

			return true;
		}

		public bool Has<T>() where T : class
		{
			let type = typeof(T);

			if (!assets.ContainsKey(type))
				return false;

			return true;
		}

		public bool Has(Type type, String name)
		{
			if (!type.IsObject || !type.HasDestructor)
				return false;

			if (!assets.ContainsKey(type))
				return false;

			if (!assets.GetValue(type).Get().ContainsKey(name))
				return false;

			return true;
		}

		public bool Has(Type type)
		{
			if (!type.IsObject || !type.HasDestructor)
				return false;

			if (!assets.ContainsKey(type))
				return false;

			return true;
		}

		public T Get<T>(String name) where T : class
 		{
			 if (!Has<T>(name))
				 return null;

			 return (T)assets.GetValue(typeof(T)).Get().GetValue(name).Get();
		}

		public Object Get(Type type, String name)
		{
			if (!Has(type, name))
				return false;

			return assets.GetValue(type).Get().GetValue(name).Get();
		}

		public AssetEnumerator<T> Get<T>() where T : class
		{
			if (!Has<T>())
				return AssetEnumerator<T>(null);

			return AssetEnumerator<T>(assets.GetValue(typeof(T)).Get());
		}

		public Result<Dictionary<String, Object>.ValueEnumerator> Get(Type type)
		{
			if (!Has(type))
				return .Err;

			return assets.GetValue(type).Get().Values;
		}

		//=== PACKAGE MANAGEMENT

		public Result<Package> LoadPackage(StringView packageName, bool packAndUpdateTextures = true)
		{
			Debug.Assert(packagesPath != null, "Initialize Core first!");

			if (!Directory.Exists(packagesPath))
				LogErrorReturn!(scope $"Couldn't load package {packageName}. Path directory doesn't exist: {packagesPath}");

			for (int i = 0; i < loadedPackages.Count; i++)
				if (loadedPackages[i].Name == packageName)
					LogErrorReturn!(scope $"Package {packageName} is already loaded");

			List<Packages.Node> nodes = new List<Packages.Node>();
			List<String> importerNames = new List<String>();
			defer
			{
				for (let n in nodes)
					n.Dispose();
				delete nodes;
				DeleteContainerAndItems!(importerNames);
			}

			// Read file
			String debugSourcePath;
			{
				// Normalize path
				let packagePath = scope String();
				Path.InternalCombineViews(packagePath, packagesPath, packageName);

				if (Packages.ReadPackage(packagePath, nodes, importerNames, out debugSourcePath) case .Err)
					LogErrorReturn!(scope $"Error reading package {packageName} for loading");
			}

			let package = new Package();
#if DEBUG
			if (debugSourcePath != null)
			{
				package.sourcePath = debugSourcePath;
			}
#endif
			if (packageName.EndsWith(".bin")) Path.ChangeExtension(packageName, String.Empty, package.name);
			else package.name.Set(packageName);

			loadedPackages.Add(package);

			// If the following loop errors, clean up
			defer
			{
				if (@return case .Err)
					this.UnloadPackage(package.name, false).IgnoreError();
			}

			// Import each package node
			Importer importer;
			Importers.currentPackage = package;
			for (let node in nodes)
			{
				// Find importer
				if (node.Importer < (uint32)Importers.importers.Count && Importers.importers.ContainsKey(importerNames[(int)node.Importer]))
					importer = Importers.importers.GetValue(importerNames[(int)node.Importer]).Get();
				else if (node.Importer < (uint32)Importers.importers.Count)
					LogErrorReturn!(scope $"Couldn't load package {packageName}. Couldn't find importer {importerNames[(int)node.Importer]}");
				else
					LogErrorReturn!(scope $"Couldn't load package {packageName}. Couldn't find importer name at index {node.Importer} of file's importer name array; index out of range");

				// Prepare data
				let name = StringView((char8*)node.Name.CArray(), node.Name.Count);

				if (importer.Load(name, node.Data) case .Err(let err))
					LogErrorReturn!(scope $"Couldn't load package {packageName}. Error importing asset {name} with {importerNames[(int)node.Importer]}: {err}");
			}
			Importers.currentPackage = null;

			// Finish
			if (packAndUpdateTextures)
				PackAndUpdateTextures();

			OnLoadPackage(package);
			return .Ok(package);
		}

		/// PackAndUpdate needs to be true for the texture atlas to be updated, but has some performance hit. Could be disabled on the first of two consecutive LoadPackage() calls.
		public Result<void> UnloadPackage(StringView packageName, bool packAndUpdateTextures = true)
		{
			Package package = null;
			for (int i = 0; i < loadedPackages.Count; i++)
				if (loadedPackages[i].Name == packageName)
				{
					package = loadedPackages[i];
					loadedPackages.RemoveAtFast(i);
				}

			if (package == null)
				LogErrorReturn!(scope $"Couldn't unload package {packageName}: No package with that name exists");

			OnUnloadPackage(package);

			for (let assetType in package.ownedAssets.Keys)
				for (let assetName in package.ownedAssets.GetValue(assetType).Get())
					RemoveAsset(assetType, assetName);

			for (let textureName in package.ownedTextureAssets)
				RemoveTextureAsset(textureName);

			if (packAndUpdateTextures)
				PackAndUpdateTextures();

			delete package;
			return .Ok;
		}

		public bool PackageLoaded(StringView packageName, out Package package)
		{
			for (let p in loadedPackages)
				if (p.Name == packageName)
				{
					package = p;
					return true;
				}

			package = null;
			return false;
		}

#if !DEBUG
		[SkipCall]
#endif
		/// Will try to rebuild and reload all packages. This is a debug and development feature, therefore when not compiling with DEBUG, this call will be automatically ignored!
		public Result<void> HotReloadPackages(bool force = false)
#if DEBUG
		{
			Result<void> err = .Ok;
			// These are probably going to get deleted from the original list so copy in advance
			let currentPackages = scope List<Package>();
			for (let package in loadedPackages)
				currentPackages.Add(package);

			for (let package in currentPackages)
			{
				// Make sure source path is set
				if (package.sourcePath == null)
				{
					Log.Warn(scope $"Won't try to hot reload package {package.name}. No debug hot reload info included");
					continue;
				}

				// Prepare packageSourceChanged check
				let packageName = Path.GetFileNameWithoutExtension(package.sourcePath, .. scope String());
				let outPath = Path.InternalCombineViews(.. scope String(), packagesPath, packageName);
				Path.ChangeExtension(outPath, ".bin", outPath);

				// ALWAYS rebuild if the file is not there or the source changed
				if (!force && File.Exists(outPath) && (File.GetLastWriteTimeUtc(outPath) case .Ok(let val))
					&& !Packages.PackageSourceChanged(package.sourcePath, val))
					continue;

				let name = scope String(package.name);
				if (HotReloadPackage(package) case .Err)
				{
					err = .Err;
					Log.Error(scope $"Failed to hot reload package {name}. This might cause a crash");
				}
			}

			return err;
		}

		internal Result<void> HotReloadPackage(Package package)
		{
			// @do
			// for hot reloading other platform things like shader/clip, we would probably need "Asset" behaviour inside these to then update?

			if (PackageLoaded(package.name, let p))
			{
				if (p.sourcePath == null) // Technically a duplicate check
					return .Err;

				// Extract hot reload debug info from package
				let sourcePath = scope String(p.sourcePath);
				let name = scope String(package.name);

				// Unload current package (delete packageData in the process)
				// Don't PackAndUpdateTextures, we will probably load something again
				Try!(UnloadPackage(name));

				// Since we probably know that something changed already, no need to check again (force = true)
				Packages.BuildPackage(sourcePath, packagesPath, true).IgnoreError();
				
				// In any case, we try to load the package again
				// (so if the build failed, we still try to load the old one if that still exists)
				Try!(LoadPackage(name, false));

				return .Ok;
			}
			else return .Err; // This package doesn't exist, it cannot be hot reloaded
		}
#else
		// Method body for HotReloadPackages(...)
		{
			return .Ok;
		}
#endif // #if DEBUG

		//=== DYNAMIC ASSETS

		/// Use Packages for static assets, use this for ones you don't know at build time.
		public Result<void> AddDynamicAsset(StringView name, Object asset)
		{
			let type = asset.GetType();

			// Add object in assets
			let nameView = Try!(AddAsset(type, name, asset));

			// Add object location in dynamic lookup
			if (!dynamicAssets.ContainsKey(type))
				dynamicAssets.Add(type, new List<StringView>());

			dynamicAssets.GetValue(type).Get().Add(nameView);

			return .Ok;
		}

		/// Use Packages for static assets, use this for ones you don't know at build time.
		/// PackAndUpdate needs to be true for the texture atlas to be updated, but has some performance hit. Could be disabled on the first of two consecutive calls.
		public Result<Subtexture> AddDynamicTextureAsset(StringView name, Bitmap bitmap, bool packAndUpdateTextures = true)
		{
			// Add object in assets
			let nameView = Try!(AddTextureAsset(name, bitmap, let asset));

			// Add object location in dynamic lookup
			if (!dynamicAssets.ContainsKey(typeof(Subtexture)))
				dynamicAssets.Add(typeof(Subtexture), new List<StringView>());

			dynamicAssets.GetValue(typeof(Subtexture)).Get().Add(nameView);

			if (packAndUpdateTextures)
				PackAndUpdateTextures();

			return .Ok(asset);
		}

		public void RemoveDynamicAsset(Type type, StringView name)
		{
			if (!dynamicAssets.ContainsKey(type))
				return;

			// Remove asset if dynamics assets contained one with the name
			if (dynamicAssets.GetValue(type).Get().Remove(name))
				RemoveAsset(type, name);
		}

		/// PackAndUpdate needs to be true for the texture atlas to be updated, but has some performance hit. Could be disabled on the first of two consecutive calls.
		public void RemoveDynamicTextureAsset(StringView name, bool packAndUpdateTextures = true)
		{
			if (!dynamicAssets.ContainsKey(typeof(Subtexture)))
				return;

			// Remove asset if dynamics assets contained one with the name
			if (dynamicAssets.GetValue(typeof(Subtexture)).Get().Remove(name))
				RemoveTextureAsset(name);

			if (packAndUpdateTextures)
				PackAndUpdateTextures();
		}

		//=== INTERNAL MANAGEMENT

		internal Result<StringView> AddAsset(Type type, StringView name, Object object)
		{
			Debug.Assert(Core.run);

			let nameString = new String(name);

			// Check if assets contains this name already
			if (Has(type, nameString))
			{
				delete nameString;

				LogErrorReturn!(scope $"Couldn't submit asset {name}: An object of this type ({type}) is already registered under this name");
			}

			if (!type.HasDestructor)
				LogErrorReturn!(scope $"Couldn't add asset {nameString} of type {object.GetType()}, because only classes can be treated as assets");

			if (!object.GetType().IsSubtypeOf(type))
				LogErrorReturn!(scope $"Couldn't add asset {nameString} of type {object.GetType()}, because it is not assignable to given type {type}");

			if (!assets.ContainsKey(type))
				assets.Add(type, new Dictionary<String, Object>());
			else if (assets.GetValue(type).Get().ContainsKey(nameString))
				LogErrorReturn!(scope $"Couldn't add asset {nameString} to dictionary for type {type}, because the name is already taken for this type");

			assets.GetValue(type).Get().Add(nameString, object);

			return .Ok(nameString);
		}

		internal Result<StringView> AddTextureAsset(StringView name, Bitmap bitmap, out Subtexture asset)
		{
			Debug.Assert(Core.run);
			asset = null;

			let nameString = new String(name);

			// Check if assets contains this name already
			if (Has(typeof(Subtexture), nameString))
			{
				delete nameString;

				LogErrorReturn!(scope $"Couldn't submit texture {name}: A texture is already registered under this name");
			}

			// Add to packer
			packer.AddBitmap(nameString, bitmap);

			// Even if somebody decides to have their own asset type for subtextures like class Sprite { Subtexture subtex; }
			// It's still good to store them here, because they would need to be in some lookup for updating on packer pack anyways
			// If you want to get the subtexture (even inside the importer function), just do Assets.Get<Subtexture>(name); (this also makes it clear that you are not the one to delete it)

			// Add to assets
			let type = typeof(Subtexture);
			if (!assets.ContainsKey(type))
				assets.Add(type, new Dictionary<String, Object>());
			else if (assets.GetValue(type).Get().ContainsKey(nameString))
				LogErrorReturn!(scope $"Couldn't add asset {nameString} to dictionary for type {type}, because the name is already taken for this type");

			asset = new Subtexture();
			assets.GetValue(type).Get().Add(nameString, asset); // Will be filled in on PackAndUpdate()

			return .Ok(nameString);
		}

		internal void RemoveAsset(Type type, StringView name)
		{
			let string = scope String(name);

			if (!assets.ContainsKey(type))
				return;

			let res = assets.GetValue(type).Get().GetAndRemove(string);
			if (res case .Err) return; // Asset doesn't exist

			let pair = res.Get();

			delete pair.key;
			delete pair.value;
			
			// Delete unused dicts
			if (assets.GetValue(type).Get().Count == 0)
			{
				let dict = assets.GetAndRemove(type).Get();
				delete dict.value;
			}
		}

		internal void RemoveTextureAsset(StringView name)
		{
			let string = scope String(name);

			// Remove from packer
			packer.RemoveSource(name);

			// Remove from assets
			let type = typeof(Subtexture);
			if (!assets.ContainsKey(type))
				return;

			let res = assets.GetValue(type).Get().GetAndRemove(string);
			if (res case .Err) return; // Asset doesn't exist

			let pair = res.Get();

			delete pair.key;
			delete pair.value;
			
			// Delete unused dicts
			if (assets.GetValue(type).Get().Count == 0)
			{
				let dict = assets.GetAndRemove(type).Get();
				delete dict.value;
			}
		}

		internal void PackAndUpdateTextures()
		{
			Debug.Assert(Core.run);

			// Pack sources
			let res = packer.Pack();

			if (res case .Err) return; // We can't or shouldn't pack now
			var output = res.Get();

			// Apply bitmaps to textures in atlas
			int i = 0;
			for (; i < output.Pages.Count; i++)
			{
				if (atlas.Count <= i)
					atlas.Add(new Texture(output.Pages[i]));
				else atlas[i].Set(output.Pages[i]);

				delete output.Pages[i];
			}

			// Delete unused textures from atlas
			while (i < atlas.Count)
				delete atlas.PopBack();

			// Update all Subtextures
			for (var entry in output.Entries)
			{
				// Find corresponding subtex
				let subtex = Get<Subtexture>(entry.key);

				subtex.Reset(atlas[entry.value.Page], entry.value.Source, entry.value.Frame);
				delete entry.value; // Will also delete the key, because that is the same string as the name property
			}

			output.Entries.Clear(); // We deleted these in our loops, no need to loop again
			output.Pages.Clear();

			// Get rid of output
			delete output;
		}

		// Basically copy-pasta from Dictionary.ValueEnumerator
		public struct AssetEnumerator<TAsset> : IEnumerator<TAsset>, IResettable
		{
			private Dictionary<String, Object> mDictionary;
			private int_cosize mIndex;
			private TAsset mCurrent;

			const int_cosize cDictEntry = 1;
			const int_cosize cKeyValuePair = 2;

			public this(Dictionary<String, Object> dictionary)
			{
				mDictionary = dictionary;
				mIndex = 0;
				mCurrent = default;
			}

			public bool MoveNext() mut
			{
		        // Use unsigned comparison since we set index to dictionary.count+1 when the enumeration ends.
		        // dictionary.count+1 could be negative if dictionary.count is Int32.MaxValue
				while ((uint)mIndex < (uint)mDictionary.[Friend]mCount)
				{
					if (mDictionary.[Friend]mEntries[mIndex].mHashCode >= 0)
					{
						mCurrent = (TAsset)mDictionary.[Friend]mEntries[mIndex].mValue;
						mIndex++;
						return true;
					}
					mIndex++;
				}

				mIndex = mDictionary.[Friend]mCount + 1;
				mCurrent = default;
				return false;
			}

			public TAsset Current
			{
				get { return mCurrent; }
			}

			public ref String Key
			{
				get
				{
					return ref mDictionary.[Friend]mEntries[mIndex].mKey;
				}
			}

			public void Dispose()
			{
			}

			public void Reset() mut
			{
				mIndex = 0;
				mCurrent = default;
			}

			public Result<TAsset> GetNext() mut
			{
				if (mDictionary == null || !MoveNext())
					return .Err;
				return Current;
			}
		}
	}
}
