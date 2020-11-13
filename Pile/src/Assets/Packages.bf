using System;
using System.IO;
using System.Collections;
using System.Diagnostics;
using JSON_Beef.Types;
using JSON_Beef.Serialization;

using internal Pile;

namespace Pile
{
	public static class Packages
	{
		// Represents the json data in the package import file
		internal class PackageData
		{
			public List<ImportData> imports = new List<ImportData>() ~ DeleteContainerAndItems!(_);

			internal class ImportData
			{
				public readonly String Path ~ delete _;
				public readonly String Importer ~ delete _;
				public readonly String NamePrefix ~ DeleteNotNull!(_);
				public readonly JSONObject Config ~ DeleteNotNull!(_);

				internal this(StringView path, StringView importer, StringView? namePrefix, JSONObject config)
				{
					Path = new String(path);
					Importer = new String(importer);
					if (namePrefix != null) NamePrefix = new String(namePrefix.Value);
					Config = config;
				}
			}
		}
		
		// Node of data for one imported file
		internal class PackageNode
		{
			public readonly uint32 Importer;
			public readonly uint8[] Name ~ delete _;
			public readonly uint8[] Data ~ delete _;
			public readonly uint8[] DataNode ~ delete _;

			public this(uint32 importer, uint8[] name, uint8[] data, uint8[] dataNode)
			{
				Name = name;
				Importer = importer;
				Data = data;
				DataNode = dataNode;
			}
		}

		static Dictionary<String, Importer> importers = new Dictionary<String, Importer>() ~ DeleteDictionaryAndKeysAndItems!(_);
		static List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_);

		static String packagesPath ~ delete _;

		public delegate void PackageEvent(Package package);
		public static Event<PackageEvent> OnLoadPackage; // Called after a package was loaded
		public static Event<PackageEvent> OnUnloadPackage; // Called before a package was unloaded (assets not yet deleted)

		internal static void Initialize()
		{
			packagesPath = new String();
			Path.InternalCombine(packagesPath, Core.System.DataPath, "Packages");

			if (!Directory.Exists(packagesPath))
				Directory.CreateDirectory(packagesPath);
		}

		static ~this()
		{
			OnLoadPackage.Dispose();
			OnUnloadPackage.Dispose();
		}

		public static void RegisterImporter(StringView name, Importer importer)
		{
			for (let s in importers.Keys)
				if (s == name)
				{
					Log.Error(scope String()..AppendF("Couldn't register importer as {}, because another importer was already registered for under that name", name));
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

		public static Result<Package> LoadPackage(StringView packageName)
		{
			Debug.Assert(packagesPath != null, "Initialize Core first!");

			for (int i = 0; i < loadedPackages.Count; i++)
				if (loadedPackages[i].Name == packageName)
					LogErrorReturn!(scope String()..AppendF("Package {} is already loaded", packageName));

			List<PackageNode> nodes = scope List<PackageNode>();
			List<String> importerNames = scope List<String>();

			// Read file
			{
				let packagePath = scope String();
				Path.InternalCombineViews(packagePath, packagesPath, packageName);
				if (!packageName.EndsWith(".bin")) Path.ChangeExtension(scope String(packagePath), ".bin", packagePath);
				let res = File.ReadAllBytes(packagePath);
				if (res case .Err)
				  LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Error reading file from {}", packageName, packagePath));

				let file = res.Value;

				// HEADER (3 bytes + one reserved)
				// FILESIZE (4 bytes, uint32)

				// IMPORTERNAMECOUNT (uint32)
				// -IMPORTERNAME ARRAY
				// 		ELEMENT:
				// 		STRINGSIZE (uint32)
				// 		STRING

				// NODESCOUNT (uint32)

				// NODEDATAARRAY
				//		ELEMENT:
				//		ZLIB SIZE (uint32)
				//		ZLIB UNCOMPRESSED SIZE (uint32)
				//		ZLIBARRAY: (decompressed) =>
				// 			IMPORTERNAMEINDEX (uint32)
				// 			NAME (uint32)
				// 			NAMEDATA
				// 			DATAARRAYLENGTH (uint32)
				// 			DATAARRAY (of bytes)
				// 			DATANODEARRAYLENGTH (uint32)
				// 			DATANODEARRAY (of bytes)

				int32 readByte = 4; // Start after header

				if (file.Count < 16 // Check min file size
					|| file[0] != 0x50 || file[1] != 0x4C || file[2] != 0x50 // Check file header
					|| file[3] != 0x00 // Check version
					|| ReadUInt() != (uint32)file.Count) // Check file size
					LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Invalid file format", packageName));

				{
					let importerNameCount = ReadUInt();
					for (uint32 i = 0; i < importerNameCount; i++)
					{
						let importerNameLength = ReadUInt();
						importerNames.Add(new String((char8*)&file[readByte], (.)importerNameLength));
						readByte += (.)importerNameLength;
					}

					let nodeCount = ReadUInt();
					for (uint32 i = 0; i < nodeCount; i++)
					{
						// Decompress
						let zLibSize = ReadUInt();
						let uncompSize = ReadUInt();
						let node = scope uint8[uncompSize];
						int position = 0;
						if (Compression.Decompress(Span<uint8>(&file[readByte], (.)zLibSize), node) case .Err(let err))
							LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Error decompressing node data: {}", packageName, err));
						readByte += (.)zLibSize;

						uint32 ReadArrayUInt()
						{
							let startIndex = position;
							position += 4;
							return (((uint32)node[startIndex] << 24) | (((uint32)node[startIndex + 1]) << 16) | (((uint32)node[startIndex + 2]) << 8) | (uint32)node[startIndex + 3]);
						}

						// Read from decompressed array
						let importerIndex = ReadArrayUInt();

						let nameLength = ReadArrayUInt();
						let name = new uint8[nameLength];
						Span<uint8>(&node[position], (.)nameLength).CopyTo(name);
						position += (.)nameLength;

						let dataLength = ReadArrayUInt();
						let data = new uint8[dataLength];
						Span<uint8>(&node[position], (.)dataLength).CopyTo(data);
						position += (.)dataLength;

						let nodeDataLength = ReadArrayUInt();
						let nodeData = new uint8[nodeDataLength];

						if (nodeDataLength > 0) // This might be 0
							Span<uint8>(&node[position], (.)nodeDataLength).CopyTo(nodeData);

						position += (.)nodeDataLength;

						nodes.Add(new PackageNode(importerIndex, name, data, nodeData));
					}
				}

				if (readByte != file.Count)
					LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. The file contains {} bytes, but the end of data was at {}", packageName, file.Count, readByte));

				delete file;

				uint32 ReadUInt()
				{
					let startIndex = readByte;
					readByte += 4;
					return (((uint32)file[startIndex] << 24) | (((uint32)file[startIndex + 1]) << 16) | (((uint32)file[startIndex + 2]) << 8) | (uint32)file[startIndex + 3]);
				}
			}

			let package = new Package();
			if (packageName.EndsWith(".bin")) Path.ChangeExtension(packageName, String.Empty, package.name);
			else package.name.Set(packageName);

			// Import each package node
			for (let node in nodes)
			{
				Importer importer;

				if (node.Importer < (uint32)importers.Count && importers.ContainsKey(importerNames[(int)node.Importer]))
					importer = importers.GetValue(importerNames[(int)node.Importer]);
				else if (node.Importer < (uint32)importers.Count)
					LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Couldn't find importer {}", packageName, importerNames[(int)node.Importer]));
				else
					LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Couldn't find importer name at index {} of file's importer name array; index out of range", packageName, node.Importer));
				
				let name = StringView((char8*)node.Name.CArray(), node.Name.Count);

				let json = scope String((char8*)node.DataNode.CArray(), node.DataNode.Count);
				let res = JSONParser.ParseObject(json);
				if (res case .Err(let err))
					LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Error parsing json data for asset {}: {} ({})", packageName, name, err, json));

				let dataNode = res.Get();

				importer.package = package;
				if (importer.Load(name, node.Data, dataNode) case .Err(let err))
					LogErrorReturn!(scope String()..AppendF("Couldn't loat package {}. Error importing asset {} with {}: {}", name, importerNames[(int)node.Importer], err));
				importer.package = null;
				delete dataNode;

				delete node;
			}

			loadedPackages.Add(package);

			// Clear up
			for (let s in importerNames)
				delete s;

			Assets.PackAndUpdate();

			OnLoadPackage(package);
			return .Ok(package);
		}

		public static Result<void> UnloadPackage(StringView packageName)
		{
			Package package = null;
			for (int i = 0; i < loadedPackages.Count; i++)
				if (loadedPackages[i].Name == packageName)
				{
					package = loadedPackages[i];
					loadedPackages.RemoveAtFast(i);
				}

			if (package == null)
				LogErrorReturn!(scope String()..AppendF("Couldn't unload package {}: No package with that name exists", packageName));

			OnUnloadPackage(package);

			for (let assetType in package.ownedAssets.Keys)
				for (let assetName in package.ownedAssets.GetValue(assetType).Get())
					Assets.RemoveAsset(assetType, assetName);

			for (let textureName in package.ownedPackerTextures)
				Assets.RemovePackerTexture(textureName);

			Assets.PackAndUpdate();

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

		public static Result<void> BuildPackage(StringView packagePath, StringView outputPath = packagesPath)
		{
			let t = scope Stopwatch(true);
			PackageData packageData = scope PackageData();

			{
				// Read package file
				String jsonFile = scope String();
				if (File.ReadAllText(packagePath, jsonFile) case .Err(let err))
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {} because the file could not be opened", packagePath));

				if (!JSONParser.IsValidJson(jsonFile))
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Invalid json file", packagePath));

				JSONObject root = scope JSONObject();
				let res = JSONParser.ParseObject(jsonFile, ref root);
				if (res case .Err(let err))
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error parsing json: {}", packagePath, err));

				if (!root.ContainsKey("imports"))
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. The root json object must include a 'imports' json array of objects", packagePath));

				JSONArray array = null;
				var ress = root.Get("imports", ref array);
				if (ress case .Err(let err))
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting 'imports' array from root object: {}", packagePath, err));
				if (array == null)
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting 'imports' array from root object", packagePath));

				JSONObject entry = null;
				for (int i = 0; i < array.Count; i++)
				{
					ress = array.Get(i, ref entry);
					if (ress case .Err(let err))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting object at position {} of 'imports' array: {}", packagePath, i, err));
					if (entry == null) continue; // This can probably not happen anyways

					// Mandatory parameters
					if (!entry.ContainsKey("path") || !entry.ContainsKey("importer"))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error processing object at position {} of 'imports' array: Object must include a path and importer string", packagePath, i));
					if (entry.GetValueType("path") != .STRING || entry.GetValueType("importer") != .STRING)
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error processing object at position {} of 'imports' array: Object must include a path and importer entry, both of json type string", packagePath, i));

					String path = null;
					ress = entry.Get("path", ref path);
					if (ress case .Err(let err))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting object 'path' of object at position {} of 'imports' array: {}", packagePath, i, err));

					String importer = null;
					ress = entry.Get("importer", ref importer);
					if (ress case .Err(let err))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting object 'importer' of object at position {} of 'imports' array: {}", packagePath, i, err));

					// Option parameters
					String namePrefix = null;
					if (entry.ContainsKey("namePrefix") && entry.GetValueType("namePrefix") == .STRING)
					{
						ress = entry.Get("namePrefix", ref namePrefix);
						if (ress case .Err(let err))
 							LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting object 'namePrefix' of object at position {} of 'imports' array: {}", packagePath, i, err));
					}

					JSONObject config = null;
					if (entry.ContainsKey("config") && entry.GetValueType("config") == .OBJECT)
					{
						ress = entry.Get("config", ref config);
						if (ress case .Err(let err))
							LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error getting object 'config' of object at position {} of 'imports' array: {}", packagePath, i, err));
					}

					packageData.imports.Add(new PackageData.ImportData(path, importer, namePrefix == null ? null : StringView(namePrefix), config == null ? null : new JSONObject(config)));

					entry = null;
				}
			}

			// Resolve imports
			List<PackageNode> nodes = scope List<PackageNode>();
			List<String> importerNames = scope List<String>();

			List<StringView> duplicateNameLookup = scope List<StringView>();
			List<String> importPaths = scope List<String>(); // All of these paths exist
			let rootPath = scope String();
			Path.GetDirectoryPath(packagePath, rootPath);
			for (let import in packageData.imports)
			{
				Importer importer;

				// Try to find importer
				if (importers.ContainsKey(import.Importer)) importer = importers[import.Importer];
				else LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Couln't find importer '{}'", packagePath, import.Importer));

				bool importerUsed = false;

				// Interpret path string (put all final paths in importPaths)
				for (var path in import.Path.Split(';'))
				{
					path.Trim();

					let fullPath = scope String();
					Path.InternalCombineViews(fullPath, rootPath, path);

					// Check if containing folder exists
					let dirPath = scope String();
					Path.GetDirectoryPath(fullPath, dirPath);

					if (!Directory.Exists(dirPath))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Failed to find containing directory of {} at {}", packagePath, path, dirPath));

					// Import everything - recursively
					if (Path.SamePath(fullPath, dirPath))
					{
						let importDirs = scope List<String>();
						importDirs.Add(new String(dirPath));

						String currImportPath;
						repeat // For each entry in import dirs
						{
							currImportPath = importDirs[importDirs.Count - 1]; // Pick from the back, since we dont want to remove stuff in middle or front
							currImportPath..Append(Path.DirectorySeparatorChar)..Append('*');

							for (let entry in Directory.Enumerate(currImportPath, .Files | .Directories))
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
							importDirs.PopBack();
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
						let searchPath = scope String();
						let wildCardPath = scope String();
						repeat // For each entry in import dirs
						{
							let current = importDirs.Count - 1;
							currImportPath = importDirs[current]; // Pick from the back, since we dont want to remove stuff in middle or front

							searchPath..Set(currImportPath)..Append(Path.DirectorySeparatorChar)..Append('*');
							wildCardPath..Set(currImportPath)..Append(Path.DirectorySeparatorChar)..Append(wildCard);

							bool match = false;
							for (let entry in Directory.Enumerate(searchPath, .Files | .Directories))
							{
								let dirFilePath = new String();
								entry.GetFilePath(dirFilePath);

								if (searchPath == wildCardPath || Path.WildcareCompare(dirFilePath, wildCardPath))
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
								Log.Warning(scope String()..AppendF("Couldn't find any matches for {} in {}", wildCardPath, currImportPath));

							// Tidy up
							importDirs.RemoveAtFast(current);
							delete currImportPath;
						}
						while (importDirs.Count > 0);
					}
				}

				// Import all files found for this import statement with this importer
				for (var filePath in importPaths)
				{
					Log.Message(scope String()..AppendF("Importing {}", filePath));

					// Read file
					let res = File.ReadAllBytes(filePath);
					if (res case .Err(let err))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error reading file at {} with {}: {}", packagePath, filePath, import.Importer, err));
					uint8[] data = res;

					// Run through importer -- config may be null
					let ress = importer.Build(data, import.Config, let node);
					if (ress case .Err(let err))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error importing file at {} with {}: {}", packagePath, filePath, import.Importer, err));
					uint8[] builtData = ress;
					if (builtData.Count <= 0)
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error importing file at {} with {}: Length of returned data cannot be 0", packagePath, filePath, import.Importer));

					delete data;

					// Convert node string to bytes
					let s = scope String();
					if (node != null)
						node.ToString(s); // Node might be null

					let nodeData = new uint8[s.Length]; // Array might be empty, and that is valid
					
					if (node != null)
					{
						// Fill array
						Span<uint8>((uint8*)s.Ptr, s.Length).CopyTo(nodeData);
						delete node;
					}

					// Make name
					s.Clear();
					if (import.NamePrefix != null) s.Append(import.NamePrefix);
					Path.GetFileNameWithoutExtension(filePath, s);

					// Check if name exists
					if (duplicateNameLookup.Contains(s))
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error importing file at {}: Entry with name {} has already been imported", packagePath, filePath, s));

					// Add to node and duplicate lookup
					let name = new uint8[s.Length];
					Span<uint8>((uint8*)s.Ptr, s.Length).CopyTo(name);
					duplicateNameLookup.Add(StringView((char8*)name.CArray(), name.Count)); // Add name data interpreted as string back to duplicate lookup

					// Add data
					importerUsed = true;
					nodes.Add(new PackageNode((uint32)importerNames.Count, name, builtData, nodeData));

					delete filePath;
				}
				importPaths.Clear();

				if (importerUsed)
					importerNames.Add(new String(import.Importer));
			}
			duplicateNameLookup.Clear();

			// Put it all in a file
			{
				// HEADER (3 bytes + one reserved)
				// FILESIZE (4 bytes, uint32)

				// IMPORTERNAMECOUNT (uint32)
				// -IMPORTERNAME ARRAY
				// 		ELEMENT:
				// 		STRINGSIZE (uint32)
				// 		STRING

				// NODESCOUNT (uint32)

				// NODEDATAARRAY
				//		ELEMENT:
				//		ZLIB SIZE (uint32)
				//		ZLIB UNCOMPRESSED SIZE (uint32)
				//		ZLIBARRAY: (decompressed) =>
				// 			IMPORTERNAMEINDEX (uint32)
				// 			NAME (uint32)
				// 			NAMEDATA
				// 			DATAARRAYLENGTH (uint32)
				// 			DATAARRAY (of bytes)
				// 			DATANODEARRAYLENGTH (uint32)
				// 			DATANODEARRAY (of bytes)

				List<uint8> file = scope List<uint8>();
				file.Add(0x50); // Head
				file.Add(0x4C);
				file.Add(0x50);
				file.Add(0x00); // Empty
				WriteUInt(0); // Size placeholder

				// All importer strings
				WriteUInt((uint32)importerNames.Count);
				for (let s in importerNames)
				{
					WriteUInt((uint32)s.Length);
					let span = Span<uint8>((uint8*)s.Ptr, s.Length);
					file.AddRange(span);

					delete s;
				}

				// All data in order
				WriteUInt((uint32)nodes.Count);
				for (let node in nodes)
				{
					let sizeNumPos = file.Count;
					WriteUInt((uint32)0);
					let zLib = scope uint8[sizeof(uint32) * 4 + node.Name.Count + node.Data.Count + node.DataNode.Count];
					int position = 0;

					void WriteArrayUInt(uint32 uint)
					{
						zLib[position] = (uint8)((uint >> 24) & 0xFF);
						zLib[position + 1] = (uint8)((uint >> 16) & 0xFF);
						zLib[position + 2] = (uint8)((uint >> 8) & 0xFF);
						zLib[position + 3] = (uint8)(uint & 0xFF);
						position += 4;
					}

					void WriteArraySpan(Span<uint8> span)
					{
						var span;
						let dest = Span<uint8>((&zLib[position - 1]) + 1, Math.Min(zLib.Count, span.Length));
						if (span.Length != dest.Length)
						{
							Log.Warning(scope String()..AppendF("Span to write to zlib input array was longer ({}) than arrayLenght - currentArrayPosition ({})", span.Length, dest.Length));
							span.Length = dest.Length; // Trim input span to fit zlib mem. ~~This should never happen but yeah
						}
						span.CopyTo(dest);
						position += dest.Length;
					}

					// Write into zLib array
					WriteArrayUInt(node.Importer);
					WriteArrayUInt((uint32)node.Name.Count);
					WriteArraySpan(node.Name);
					WriteArrayUInt((uint32)node.Data.Count);
					WriteArraySpan(node.Data);
					WriteArrayUInt((uint32)node.DataNode.Count);
					WriteArraySpan(node.DataNode);

					// Write uncompressed size
					WriteUInt((uint32)zLib.Count);

					// Compress
					let zLibStart = file.Count;
					file.Count += zLib.Count; // Reserve original size of data
					var compSize = 0;
					let res = Compression.Compress(zLib, Span<uint8>(&file[zLibStart], file.Count));
					switch (res)
					{
					case .Err (let err):
						LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error compressing node data: {}", packagePath, err));
					case .Ok(let val):
						compSize = val;
					}
					file.Count -= zLib.Count - compSize; // Remove unneeded reserved space

					// Insert real size
					file[sizeNumPos] = (uint8)((compSize >> 24) & 0xFF);
					file[sizeNumPos + 1] = (uint8)((compSize >> 16) & 0xFF);
					file[sizeNumPos + 2] = (uint8)((compSize >> 8) & 0xFF);
					file[sizeNumPos + 3] = (uint8)(compSize & 0xFF);

					delete node;
				}
				nodes.Clear();

				void WriteUInt(uint32 uint)
				{
					file.Add((uint8)((uint >> 24) & 0xFF));
					file.Add((uint8)((uint >> 16) & 0xFF));
					file.Add((uint8)((uint >> 8) & 0xFF));
					file.Add((uint8)(uint & 0xFF));
				}

				// Fill in size
				file[4] = (uint8)((file.Count >> 24) & 0xFF);
				file[5] = (uint8)((file.Count >> 16) & 0xFF);
				file[6] = (uint8)((file.Count >> 8) & 0xFF);
				file[7] = (uint8)(file.Count & 0xFF);

				let outPath = scope String();
				let packageName = scope String();
				Path.GetFileNameWithoutExtension(scope String(packagePath), packageName);
				Path.InternalCombine(outPath, scope String(outputPath), packageName);
				Path.ChangeExtension(scope String(outPath), ".bin", outPath);
				let res = File.WriteAllBytes(outPath, file);
				if (res case .Err)
					LogErrorReturn!(scope String()..AppendF("Couldn't build package at {}. Error writing file to {}", packagePath, outPath));

				t.Stop();
				Log.Message(scope String()..AppendF("Built package {} in {}ms", packageName, t.ElapsedMilliseconds));
			}

			return .Ok;
		}
	}
}
