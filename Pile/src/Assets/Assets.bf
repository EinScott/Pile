using System;
using System.IO;
using System.Collections;
using JetFistGames.Toml;

namespace Pile
{
	public static class Assets
	{
		// merge Assets, Images (loading of images with dynamic format registering)
		// 					=> bitmap loading
		// have asset packages
		// make loading assets async? - nah why, but maybe the compiling part but who cares
		// make registering assets types possible?
		//  => instead of this, register importers (tilemap importer, sprite importer and choose them by string match)

		// need packer and data file format to continue

		public abstract class Importer
		{
			public abstract bool Accepts(uint8[] data);
			public abstract Object Import(uint8[] data /*, DATAFILE*/); // This also needs to have some way to access a texture/bitmap list???
			public abstract Result<void, String> Build(uint8[] data, ref uint8[] outdata /*, ref DATAFILEFORMAT, PACKER (put texture data in here)*/);
		}

		// Do simple text and copy importer

		public class Package
		{
			List<String> ownedAssets = new List<String>() ~ delete _;

			readonly String name = new String() ~ delete _;
			public StringView Name => name;
		}

		class PackageData
		{
			public List<ImportData> imports = new List<ImportData>() ~ DeleteContainerAndItems!(_);

			public class ImportData
			{
				public String path ~ delete _;
				public String importer ~ delete _;

				public this(StringView path, StringView importer)
				{
					this.path = new String(path);
					this.importer = new String(importer);
				}
			}
		}

		static class AssetLookup<T> where T : class, delete
		{
			static Dictionary<String, T> L = new Dictionary<String, T>() ~ DeleteDictionaryAndKeysAndItems!(_);
		}

		static Dictionary<String, Importer> importers = new Dictionary<String, Importer>() ~ DeleteDictionaryAndKeysAndItems!(_);
		static List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_);

		public static void RegisterImporter(StringView name, Importer importer)
		{
			for (let s in importers.Keys)
				if (s == name)
				{
					Log.Error(scope String("Couldn't register importer as {0}, because another importer was already registered for under that name")..Format(name));
					return;
				}

			importers.Add(new String(name), importer);
		}

		public static void UnregisterImporter(StringView name)
		{
			let res = importers.GetAndRemove(scope String(name));

			// Delete
			if (res != .Err)
			{
				let val = res.Get();

				delete val.key;
				delete val.value;
			}
		}

		public static Result<void, String> LoadPackage(StringView packageName)
		{
			return .Ok;
		}

		public static void UnloadPackage(StringView packageName)
		{
			
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

		public static Result<void, String> BuildPackage(StringView packagePath)
		{
			PackageData packageData = scope PackageData();

			{
				// Read package file
				String tomlFile = scope String();
				if (Core.System.FileReadAllText(packagePath, tomlFile) case .Err(let err))
				{
					return .Err(new String("Couldn't build package at {0} because the file could not be opened")..Format(packagePath));
				}
	
				// Read toml
				let res = TomlSerializer.Read(tomlFile);
	
				TomlTableNode baseNode;
				switch (res)
				{
				case .Ok(let val):
					 baseNode = val.GetTable().Get();
				case .Err(let err):
					return .Err(new String("Couldn't build package at {0}. Error while reading toml: {1}")..Format(packagePath, err));
				}

				if (baseNode.FindChild("import") == null)
					return .Err(new String("Couldn't build package at {0}. Import data file must include and 'import' array of tables")..Format(packagePath));

				let tableArray = baseNode.FindChild("import").GetArray().Get();
				for (int i = 0; i < tableArray.Count; i++)
				{
					let entry = tableArray[i].GetTable().Get();

					if (entry.FindChild("path") == null || entry.FindChild("importer") == null)
						return .Err(new String("Couldn't build package at {0}. Every import table in package data needs to include a 'path' and 'importer' string key")..Format(packagePath));

					if (entry.FindChild("path").GetString() == .Err || entry.FindChild("importer").GetString() == .Err)
						return .Err(new String("Couldn't build package at {0}. 'path' and 'import' keys need to have values of type String")..Format(packagePath));

					packageData.imports.Add(new PackageData.ImportData(entry.FindChild("path").GetString().Get(), entry.FindChild("importer").GetString().Get()));
				}
	
				delete baseNode;
			}

			// Resolve imports
			List<String> importPaths = new List<String>(); // All of these paths exist
			let rootPath = scope String();
			Path.GetDirectoryPath(packagePath, rootPath);
			for (let import in packageData.imports)
			{
				// Interpret path string
				for (var path in import.path.Split(';'))
				{
					path.Trim();

					let fullPath = new String();
					Path.InternalCombine(fullPath, rootPath, scope String(path));

					// Check if folder exists
					{
						let dirPath = scope String();
						Path.GetDirectoryPath(fullPath, dirPath);
	
						if (!Core.System.DirectoryExists(dirPath))
						{
							Log.Warning(scope String("Skipped import path while building package at {0}. Failed to find containing directory if {1} at {2}")..Format(packagePath, path, dirPath));
							continue;
						}
					}

					// Determine if it is a wildcare or a file??, get all paths that match wildcare if it is one and add those

					// Is it a file or a folder? --- no wildcares
					//if (Core.System.FileExists(path) || Core.System.DirectoryExists(path)) importPaths.Add(StringView(path));
					//else Log.Warning(scope String("Failed to find file or directory at {0}"));

					delete fullPath; // TEMPORARY
				}
			}

			delete importPaths;

			return .Ok;
		}
	}
}
