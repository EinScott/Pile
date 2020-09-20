using System;
using System.IO;
using System.Collections;
using JSON_Beef.Serialization;
using JSON_Beef.Types;

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

		public abstract class Importer
		{
			public abstract Object Load(uint8[] data, JSONObject dataNode);
			public abstract Result<uint8[], String> Import(uint8[] data, out JSONObject dataNode);
		}

		public class Package
		{
			List<String> ownedAssets = new List<String>() ~ delete _;

			readonly String name = new String() ~ delete _;
			public StringView Name => name;
		}

		[AlwaysInclude(AssumeInstantiated = true, IncludeAllMethods = true)]
		[Reflect]
		class PackageData
		{
			public List<ImportData> imports = new List<ImportData>() ~ DeleteContainerAndItems!(_);

			[AlwaysInclude(AssumeInstantiated = true, IncludeAllMethods = true)]
			[Reflect]
			public class ImportData
			{
				public String path ~ delete _;
				public String importer ~ delete _;
			}
		}

		class PackageNode
		{
			// Node of data for one file
			public readonly uint8[] Data ~ delete _;
			public readonly uint8[] DataNode ~ delete _;

			public this(uint8[] data, uint8[] dataNode)
			{
				Data = data;
				DataNode = dataNode;
			}
		}

		static Packer texturePacker = new Packer() ~ delete _;
		static Dictionary<Type, Dictionary<String, Object>> assets = new Dictionary<Type, Dictionary<String, Object>>();

		static Dictionary<String, Importer> importers = new Dictionary<String, Importer>() ~ DeleteDictionaryAndKeysAndItems!(_);
		static List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_);

		static String packagesPath ~ delete _;

		static ~this()
		{
			for (let dic in assets.Values)
				DeleteDictionaryAndKeysAndItems!(dic);

			DeleteDictionaryAndKeys!(assets);
		}

		static void Initialize()
		{
			packagesPath = new String();
			Path.InternalCombine(packagesPath, Core.System.DataPath, "Packages");

			if (!Core.System.DirectoryExists(packagesPath))
				Core.System.DirectoryCreate(packagesPath);
		}

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
			// load from packages subfolder with this name, no lookup file
			// (.../Game/Packages/packageFile)

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
			// BREAK THIS DOWN INTO SMALLER PIECES AND MAKE TESTS FOR THEM (if possible, at least, cant really make tests for file access easily??, wait you can)

			PackageData packageData = scope PackageData();

			{
				// Read package file
				String jsonFile = scope String();
				if (Core.System.FileReadAllText(packagePath, jsonFile) case .Err(let err))
					return .Err(new String("Couldn't build package at {0} because the file could not be opened")..Format(packagePath));

				if (JSONDeserializer.Deserialize(jsonFile, packageData) case .Err(let err))
					return .Err(new String("Couldn't build package at {0}. Error while deserializing json: {1}")..Format(packagePath, err));
			}

			// Resolve imports
			List<PackageNode> nodes = scope List<PackageNode>();
			List<String> importPaths = scope List<String>(); // All of these paths exist
			let rootPath = scope String();
			Path.GetDirectoryPath(packagePath, rootPath);
			for (let import in packageData.imports)
			{
				Importer importer;

				// Try to find importer
				if (importers.ContainsKey(import.importer)) importer = importers[import.importer];
				else return .Err(new String("Couldn't build package at {0}. Couln't find importer '{1}'")..Format(packagePath, import.importer));

				// Interpret path string (put all final paths in importPaths)
				for (var path in import.path.Split(';'))
				{
					path.Trim();

					let fullPath = scope String();
					Path.InternalCombine(fullPath, rootPath, scope String(path));

					// Check if containing folder exists
					let dirPath = scope String();
					Path.GetDirectoryPath(fullPath, dirPath);

					if (!Core.System.DirectoryExists(dirPath))
						return .Err(new String("Couldn't build package at {0}. Failed to find containing directory of {1} at {2}")..Format(packagePath, path, dirPath));

					// Import everything - recursively
					if (Path.SamePath(fullPath, dirPath)) // Are dd/ddd/ and dd/ddd the same?? currently not, but should they?
					{
						let importDirs = scope List<String>();
						importDirs.Add(new String(dirPath));

						String currImportPath;
						repeat // For each entry in import dirs
						{
							currImportPath = importDirs[importDirs.Count - 1]; // Pick from the back, since we dont want to remove stuff in middle or front
							currImportPath..Append(Path.DirectorySeparatorChar)..Append('*');

							for (let entry in Core.System.DirectoryEnumerate(currImportPath, .Files | .Directories))
							{
								let path = new String();
								entry.GetFilePath(path);

								// Add matching files in this directory to import list
								if (!entry.IsDirectory)
									importPaths.Add(path);
								// Look for matching sub dirs and add to importDirs list
								else
									importDirs.Add(path);
							}

							// Tidy up
							importDirs.RemoveAt(importDirs.Count - 1);
							delete currImportPath;
						}
						while (importDirs.Count > 0);
					}
					// Import everything that matches - recursively
					else
					{
						let wildCard = scope String();
						Path.GetFileName(fullPath, wildCard);

						let importDirs = scope List<String>();
						importDirs.Add(new String(dirPath));

						String currImportPath;
						let currSearchStr = scope String();
						let wildCardPath = scope String();
						repeat // For each entry in import dirs
						{
							currImportPath = importDirs[importDirs.Count - 1]; // Pick from the back, since we dont want to remove stuff in middle or front
							currSearchStr..Append(currImportPath)..Append(Path.DirectorySeparatorChar)..Append('*');

							wildCardPath..Append(currImportPath)..Append(Path.DirectorySeparatorChar)..Append(wildCard);

							bool match = false;
							for (let entry in Core.System.DirectoryEnumerate(currSearchStr, .Files | .Directories))
							{
								let dirFilePath = new String();
								entry.GetFilePath(dirFilePath);

								if (Path.WildcareCompare(dirFilePath, wildCardPath))
								{
									match = true;

									// Add matching files in this directory to import list
									if (!entry.IsDirectory)
										importPaths.Add(dirFilePath);
									// Look for matching sub dirs and add to importDirs list
									else
										importDirs.Add(dirFilePath);

									continue; // Dont delete the string if we keep using it
								}
								delete dirFilePath;
							}

							if (!match)
								Log.Warning(scope String("Couldn't find any matches for {1} in {2}")..Format(packagePath, wildCardPath, currImportPath));

							// Tidy up
							importDirs.RemoveAt(importDirs.Count - 1);
							delete currImportPath;
							
							wildCardPath.Clear();
						}
						while (importDirs.Count > 0);
					}
				}

				// Import all files
				for (var filePath in importPaths)
				{
					Log.Message(scope String("Importing {0}")..Format(filePath));

					// we give it files data, it outputs data and a data node
					// so textures are just kept as seperate data blobs?

					// Read file
					let res = Core.System.FileReadAllBytes(filePath);
					if (res case .Err(let err))
						return .Err(new String("Couldn't build package at {0}. Error reading file at {1}: {2}")..Format(packagePath, filePath, err));
					uint8[] data = res;

					// Run through importer
					let ress = importer.Import(data, let node);
					if (ress case .Err(let err))
						return .Err(new String("Couldn't build package at {0}. Error importing file at {1}: {2}")..Format(packagePath, filePath, err));
					uint8[] importedData = ress;

					delete data;

					// Convert node string to bytes
					let s = scope String();
					node.ToString(s);
					let nodeData = new uint8[s.Length];
					Span<uint8>((uint8*)s.Ptr, s.Length).CopyTo(nodeData);

					delete node;

					// Add data
					nodes.Add(new PackageNode(importedData, nodeData));

					delete filePath;
				}
				importPaths.Clear();
			}
			
			// Put it all in a file
			{
				List<uint8> file = scope List<uint8>();
				file.Add(0x50); // Head
				file.Add(0x4C);
				file.Add(0x50);
				file.Add(0x00); // Empty
	
				for (let node in nodes)
				{
					// Put length
					UInt((uint)node.Data.Count);
					UInt((uint)node.DataNode.Count);
				}
	
				void UInt(uint uint)
				{
					file.Add((uint8)((uint >> 24) & 0xFF));
					file.Add((uint8)((uint >> 16) & 0xFF));
					file.Add((uint8)((uint >> 8) & 0xFF));
					file.Add((uint8)(uint & 0xFF));
				}
	
				for (var node in nodes)
				{
					file.AddRange(node.Data);
					file.AddRange(node.DataNode);
	
					delete node;
				}
				nodes.Clear();

				let outPath = scope String();
				let packageName = scope String();
				Path.GetFileNameWithoutExtension(scope String(packagePath), packageName);
				Path.InternalCombine(outPath, packagesPath, packageName);
				let res = Core.System.FileWriteAllBytes(outPath, file);
				if (res case .Err)
					return .Err(new String("Couldn't build package at {0}. Error writing file to {1}")..Format(packagePath, outPath));
			}
			
			return .Ok;
		}
	}
}
