using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
#if !DEBUG
	[Optimize]
#endif
	[StaticInitPriority(PILE_SINIT_IMPL - 10)] // After impls
	static class Assets
	{
		static Packer packer = new Packer() ~ delete _;
		static List<Texture> atlas ~ if (_ != null) DeleteContainerAndItems!(_);

		static Dictionary<Type, Dictionary<String, Object>> assets = new Dictionary<Type, Dictionary<String, Object>>() ~
			{
				for (let dic in _.Values)
					DeleteDictionaryAndKeysAndValues!(dic);

				delete _;
			};

		static Dictionary<Type, List<StringView>> dynamicAssets = new Dictionary<Type, List<StringView>>() ~  DeleteDictionaryAndValues!(_);
		static List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_);
		static String packagesPath = new String() ~ delete _;

		internal static uint32 assetAddIteration;
		internal static uint32 assetDelIteration;

		public static uint TextureCount => packer.SourceImageCount;
		public static uint AssetCount
		{
			get
			{
				uint c = 0;
				for (let typeDict in assets.Values)
					c += (.)typeDict.Count;

				return c;
			}
		}
		public static uint DynamicAssetCount
		{
			get
			{
				uint c = 0;
				for (let nameList in dynamicAssets.Values)
					c += (.)nameList.Count;

				return c;
			}
		}

		public delegate void PackageEvent(Package package);
		public static Event<PackageEvent> OnLoadPackage ~ _.Dispose(); // Called after a package was loaded
		public static Event<PackageEvent> OnUnloadPackage ~ _.Dispose(); // Called before a package was unloaded (assets not yet deleted)

		internal static void Initialize()
		{
			// Create these here to give the game time to change default settings
			atlas = new List<Texture>();

			// Get packages path
			Path.Clean(Path.InternalCombine(.. scope .(), System.DataPath, "packages"), packagesPath);

#if DEBUG
			System.Window.OnFocusChanged.Add(new => OnWindowFocusChanged);

#if BF_PLATFORM_WINDOWS // TODO: when fs-watcher is implemented for other platforms beef-side, remove this restriction (and the two ones below)
			let assetsSource = MakeScopedAssetsSourcePath!();
			if (Directory.Exists(assetsSource))
				assetsWatcher = Platform.BfpFileWatcher_WatchDirectory(assetsSource, => OnBfpDirectoryChanged, .IncludeSubdirectories, null, null);
#endif

#endif
		}

		internal static void Destroy()
		{
#if DEBUG
			System.Window.OnFocusChanged.Remove(scope => OnWindowFocusChanged, true);

#if BF_PLATFORM_WINDOWS
			if (assetsWatcher != null) Platform.BfpFileWatcher_Release(assetsWatcher);
#endif

#endif
		}

#if DEBUG
		static Platform.BfpFileWatcher* assetsWatcher;
		internal static bool assetsChanged;

		static void OnBfpDirectoryChanged(Platform.BfpFileWatcher* watcher, void* userData, Platform.BfpFileChangeKind changeKind, char8* directory, char8* fileName, char8* oldName)
		{
			Assets.assetsChanged = true;
		}

		static void OnWindowFocusChanged()
		{
			// The window was just focused again and the game is not just starting
			if (
#if BF_PLATFORM_WINDOWS
				assetsChanged &&
#endif
				System.Window.Focus && Time.RawDuration > TimeSpan(0, 0, 1))
			{
				HotReloadPackages();
				assetsChanged = false;
			}
		}
#endif		

		public static bool Has<T>(String name) where T : class, delete
		{
			Debug.Assert(name != null);

			let type = typeof(T);

			if (!assets.ContainsKey(type))
				return false;

			if (!assets.GetValue(type).Get().ContainsKey(name))
				return false;

			return true;
		}

		public static bool Has<T>() where T : class, delete
		{
			let type = typeof(T);

			if (!assets.ContainsKey(type))
				return false;

			return true;
		}

		public static bool Has(Type type, String name)
		{
			Debug.Assert(name != null);

			if (!type.IsObject || !type.HasDestructor || type.IsBoxed)
				return false;

			if (!assets.ContainsKey(type))
				return false;

			if (!assets.GetValue(type).Get().ContainsKey(name))
				return false;

			return true;
		}

		public static bool Has(Type type)
		{
			if (!type.IsObject || !type.HasDestructor || type.IsBoxed)
				return false;

			if (!assets.ContainsKey(type))
				return false;

			return true;
		}

		public static T Get<T>(String name) where T : class, delete
 		{
			 Debug.Assert(name != null);

			 if (!Has<T>(name))
				 return null;

			 return (T)assets.GetValue(typeof(T)).Get().GetValue(name).Get();
		}

		public static Object Get(Type type, String name)
		{
			if (!Has(type, name))
				return false;

			return assets.GetValue(type).Get().GetValue(name).Get();
		}

		public static AssetEnumerator<T> Get<T>() where T : class, delete
		{
			if (!Has<T>())
				return AssetEnumerator<T>(null);

			return AssetEnumerator<T>(assets.GetValue(typeof(T)).Get());
		}

		public static Result<Dictionary<String, Object>.ValueEnumerator> Get(Type type)
		{
			if (!Has(type))
				return .Err;

			return assets.GetValue(type).Get().Values;
		}

		//=== PACKAGE MANAGEMENT

		public static Result<Package> LoadPackage(StringView packageName, bool packAndUpdateTextures = true)
		{
			Debug.Assert(packagesPath != null, "Initialize Core first!");
			Debug.Assert(packageName.Ptr != null);

			if (!Directory.Exists(packagesPath))
				LogErrorReturn!(scope $"Couldn't load package {packageName}. Path directory doesn't exist: {packagesPath}");

			for (int i < loadedPackages.Count)
				if (loadedPackages[[Unchecked]i].Name == packageName)
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
			{
				// Normalize path
				let packagePath = scope String();
				Path.InternalCombine(packagePath, packagesPath, packageName);

				if (Packages.ReadPackage(packagePath, nodes, importerNames, ?) case .Err) // We don't care about the hash
					LogErrorReturn!(scope $"Error reading package {packageName} for loading");
			}

			let package = new Package();

			if (packageName.EndsWith(".bin")) Path.ChangeExtension(packageName, String.Empty, package.name);
			else package.name.Set(packageName);

			loadedPackages.Add(package);

			// If the following loop errors, clean up
			defer
			{
				if (@return case .Err)
				{
					Importers.currentPackage = null;
					Assets.UnloadPackage(package.name, false).IgnoreError();
				}
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
				let name = StringView((char8*)node.Name.Ptr, node.Name.Count);

				if (importer.Load(name, node.Data) case .Err)
					LogErrorReturn!(scope $"Couldn't load package {packageName}. Error importing asset {name} with {importerNames[(int)node.Importer]}");
			}
			Importers.currentPackage = null;

			// Finish
			if (packAndUpdateTextures)
				PackAndUpdateTextures();

			if (OnLoadPackage.HasListeners)
				OnLoadPackage(package);

			return .Ok(package);
		}

		/// PackAndUpdate needs to be true for the texture atlas to be updated, but has some performance hit. Could be disabled on the first of two consecutive LoadPackage() calls.
		public static Result<void> UnloadPackage(StringView packageName, bool packAndUpdateTextures = true)
		{
			Debug.Assert(packageName.Ptr != null);

			Package package = null;
			for (int i < loadedPackages.Count)
				if (loadedPackages[[Unchecked]i].Name == packageName)
				{
					package = loadedPackages[[Unchecked]i];
					loadedPackages.RemoveAtFast(i);
				}

			if (package == null)
				LogErrorReturn!(scope $"Couldn't unload package {packageName}: No package with that name exists");

			if (OnUnloadPackage.HasListeners)
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

		public static bool PackageLoaded(StringView packageName, out Package package)
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
		internal static Result<void> HotReloadPackages(bool force = false)
#if DEBUG
		{
			Result<void> err = .Ok;

			DateTime buildStart = DateTime.Now;
			if (RunPackager() case .Err)
				LogErrorReturn!("Failed to run Packager");

			for (let file in Directory.EnumerateFiles(packagesPath))
			{
				if (file.GetLastWriteTime() > buildStart)
				{
					let name = Path.GetFileNameWithoutExtension(file.GetFileName(.. scope String()), .. scope String());
					
					if (!PackageLoaded(name, ?))
						continue;

					if ((UnloadPackage(name) case .Ok)
						&& (LoadPackage(name) case .Err))
					{
						Log.Error(scope $"Failed to hot reload package {name}. This might cause a crash");
						err = .Err;
					}
				}
			}

			return err;
		}
#else
		{
			return .Ok;
		}
#endif // #if DEBUG

		//=== DYNAMIC ASSETS

		/// Use Packages for static assets, use this for ones you don't know at build time.
		public static Result<void> AddDynamicAsset(StringView name, Object asset)
		{
			Debug.Assert(Core.run);
			Debug.Assert(name.Ptr != null);
			Debug.AssertNotStack(asset);

			let type = asset.GetType();

			// Add object in assets
			let nameView = Try!(AddAsset(type, name, asset));

			// Add object location in dynamic lookup
			if (!dynamicAssets.ContainsKey(type))
				dynamicAssets.Add(type, new List<StringView>());

			dynamicAssets.GetValue(type).Get().Add(nameView);
			assetAddIteration++;

			return .Ok;
		}

		/// Use Packages for static assets, use this for ones you don't know at build time.
		/// PackAndUpdate needs to be true for the texture atlas to be updated, but has some performance hit. Could be disabled on the first of two consecutive calls.
		public static Result<Subtexture> AddDynamicTextureAsset(StringView name, Bitmap bitmap, bool packAndUpdateTextures = true, TextureFilter textureFilter = Core.Defaults.TextureFilter)
		{
			Debug.Assert(Core.run);
			Debug.Assert(name.Ptr != null);

			// Add object in assets
			let nameView = Try!(AddTextureAsset(name, bitmap, let asset, textureFilter));

			// Add object location in dynamic lookup
			if (!dynamicAssets.ContainsKey(typeof(Subtexture)))
				dynamicAssets.Add(typeof(Subtexture), new List<StringView>());

			dynamicAssets.GetValue(typeof(Subtexture)).Get().Add(nameView);

			if (packAndUpdateTextures)
				PackAndUpdateTextures();
			assetAddIteration++;

			return .Ok(asset);
		}

		public static void RemoveDynamicAsset(Type type, StringView name)
		{
			if (!dynamicAssets.ContainsKey(type))
				return;

			// Remove asset if dynamics assets contained one with the name
			if (dynamicAssets.GetValue(type).Get().Remove(name))
				RemoveAsset(type, name);
			assetDelIteration++;
		}

		/// PackAndUpdate needs to be true for the texture atlas to be updated, but has some performance hit. Could be disabled on the first of two consecutive calls.
		public static void RemoveDynamicTextureAsset(StringView name, bool packAndUpdateTextures = true)
		{
			if (!dynamicAssets.ContainsKey(typeof(Subtexture)))
				return;

			// Remove asset if dynamics assets contained one with the name
			if (dynamicAssets.GetValue(typeof(Subtexture)).Get().Remove(name))
			{
				RemoveTextureAsset(name);

				if (packAndUpdateTextures)
					PackAndUpdateTextures();
				assetDelIteration++;
			}
		}

		//=== INTERNAL MANAGEMENT

		internal static Result<StringView> AddAsset(Type type, StringView name, Object object)
		{
			Debug.Assert(Core.run);
			Debug.AssertNotStack(object);
			Debug.Assert(name.Ptr != null);

			let nameString = new String(name);

			// Check if assets contains this name already
			if (Has(type, nameString))
			{
				delete nameString;

				LogErrorReturn!(scope $"Couldn't submit asset {name}: An object of this type ({type}) is already registered under this name");
			}

			if (!type.HasDestructor || type.IsBoxed)
				LogErrorReturn!(scope $"Couldn't add asset {nameString} of type {object.GetType()}, because only classes can be treated as assets");

			if (!object.GetType().IsSubtypeOf(type))
				LogErrorReturn!(scope $"Couldn't add asset {nameString} of type {object.GetType()}, because it is not assignable to given type {type}");

			if (!assets.ContainsKey(type))
				assets.Add(type, new Dictionary<String, Object>());
			else if (assets.GetValue(type).Get().ContainsKey(nameString))
				LogErrorReturn!(scope $"Couldn't add asset {nameString} to dictionary for type {type}, because the name is already taken for this type");

			assets.GetValue(type).Get().Add(nameString, object);

			assetAddIteration++;
			return .Ok(nameString);
		}

		internal static Result<StringView> AddTextureAsset(StringView name, Bitmap bitmap, out Subtexture asset, TextureFilter textureFilter = Core.Defaults.TextureFilter)
		{
			Debug.Assert(Core.run);
			Debug.Assert(name.Ptr != null);
			asset = null;

			let nameString = new String(name);

			// Check if assets contains this name already
			if (Has(typeof(Subtexture), nameString))
			{
				delete nameString;

				LogErrorReturn!(scope $"Couldn't submit texture {name}: A texture is already registered under this name");
			}

			// Add to packer
			packer.AddBitmap(nameString, bitmap, GetPackerFlag(textureFilter));

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

			assetAddIteration++;
			return .Ok(nameString);
		}

		internal static uint8 GetPackerFlag(TextureFilter textureFilter)
		{
			uint8 flag = 0;
			if (textureFilter == .Linear)
				flag = 1;

			return flag;
		}

		internal static void RemoveAsset(Type type, StringView name)
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
			assetDelIteration++;
		}

		internal static void RemoveTextureAsset(StringView name)
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
			assetDelIteration++;
		}

		internal static void PackAndUpdateTextures()
		{
			Debug.Assert(Core.run);

			if (packer.SourceImageCount == 0)
				return;

			// Pack sources
			let res = packer.Pack();

			if (res case .Err) return; // We can't or shouldn't pack now
			var output = res.Get();

			// Apply bitmaps to textures in atlas
			int i = 0;
			for (; i < output.Pages.Count; i++)
			{
				if (atlas.Count <= i)
					atlas.Add(new Texture(output.Pages[[Unchecked]i].page));
				else atlas[[Unchecked]i].Set(output.Pages[[Unchecked]i].page);

				// Configure based on page flags
				let flags = output.Pages[[Unchecked]i].sortFlag;
				if ((flags & 1) > 0)
					atlas[[Unchecked]i].Filter = .Linear;
				else atlas[[Unchecked]i].Filter = .Nearest;

				delete output.Pages[[Unchecked]i].page;
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

			output.Entries.Clear();
			output.Pages.Clear();

			// Get rid of output
			delete output;
		}

		// Basically copy-pasta from Dictionary.ValueEnumerator
		public struct AssetEnumerator<TAsset> : IEnumerator<TAsset>, IResettable
		{
			Dictionary<String, Object> mDictionary;
			int_cosize mIndex;
			TAsset mCurrent;

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
