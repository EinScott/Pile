using System;
using System.IO;
using System.Collections;
using System.Diagnostics;
using JSON_Beef.Types;
using JSON_Beef.Serialization;

namespace Pile
{
	public static class Packages
	{
		public class Package
		{
			private this() {}

			Dictionary<Type,List<String>> ownedAssets = new Dictionary<Type,List<String>>() ~ delete _;
			
			readonly String name = new String() ~ delete _;
			public StringView Name => name;
		}

		public abstract class Importer
		{
			public abstract void Load(Package package, uint8[] data, JSONObject dataNode);
			public abstract Result<uint8[], String> Build(uint8[] data, out JSONObject dataNode);

			protected void SubmitObject(Package package, Object add)
			{
				// Add object in package...

				// Add object in assets...
			}

			protected void SubmitPackerBitmap(Package package, Bitmap bitmap)
			{
				// Add bitmap in package...

				// Add bitmap in assets...
			}
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
			// Node of data for one imported file
			public readonly uint32 Importer;
			public readonly uint8[] Data ~ delete _;
			public readonly uint8[] DataNode ~ delete _;

			public this(uint32 importer, uint8[] data, uint8[] dataNode)
			{
				Importer = importer;
				Data = data;
				DataNode = dataNode;
			}
		}

		static Dictionary<String, Importer> importers = new Dictionary<String, Importer>() ~ DeleteDictionaryAndKeysAndItems!(_);
		static List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_);

		static String packagesPath ~ delete _;

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

		public static Result<Package, String> LoadPackage(StringView packageName)
		{
			List<PackageNode> nodes = scope List<PackageNode>();
			List<String> importerNames = scope List<String>();

			// Read file
			{
				let packagePath = scope String();
				Path.InternalCombineViews(packagePath, packagesPath, packageName);
				if (!packageName.EndsWith(".bin")) Path.ChangeExtension(scope String(packagePath), ".bin", packagePath);
				let res = Core.System.FileReadAllBytes(packagePath);
				if (res case .Err)
				  return .Err(new String("Couldn't loat package {0}. Error reading file from {1}")..Format(packageName, packagePath));

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
				// 		IMPORTERNAMEINDEX (uint32)
				// 		DATAARRAYLENGTH (uint32)
				// 		DATAARRAY (of bytes)
				// 		DATANODEARRAYLENGTH (uint32)
				// 		DATANODEARRAY (of bytes)

				int readByte = 4; // Start at header

				if (file.Count < 16 // Check min file size
					|| file[0] != 0x50 || file[1] != 0x4C || file[2] != 0x50 // Check file header
					|| file[3] != 0x00 // Check version
					|| UInt() != (uint32)file.Count) // Check file size
					return .Err(new String("Couldn't loat package {0}. Invalid file format")..Format(packageName));

				{
					let importerNameCount = UInt();
					for (int i = 0; i < importerNameCount; i++)
					{
						let importerNameLength = UInt();
						importerNames.Add(new String((char8*)&file[readByte], importerNameLength));
						readByte += importerNameLength;
					}

					let nodeCount = UInt();
					for (int i = 0; i < nodeCount; i++)
					{
						let importerIndex = UInt();

						let dataLength = UInt();
						let data = new uint8[dataLength];
						Span<uint8>(&file[readByte], dataLength).CopyTo(data);
						readByte += dataLength;

						let nodeDataLength = UInt();
						let nodeData = new uint8[nodeDataLength];
						Span<uint8>(&file[readByte], nodeDataLength).CopyTo(nodeData);
						readByte += nodeDataLength;

						nodes.Add(new PackageNode(importerIndex, data, nodeData));
					}
				}

				if (readByte != file.Count)
					return .Err(new String("Couldn't loat package {0}. The file contains {1} bytes, but the end of data was at {2}")..Format(packageName, file.Count, readByte));

				uint32 UInt()
				{
					let startIndex = readByte;
					readByte += 4;
					return (((uint32)file[startIndex] << 24) | (((uint32)file[startIndex + 1]) << 16) | (((uint32)file[startIndex + 2]) << 8) | (uint32)file[startIndex + 3]);
				}
			}

			let package = new [Friend]Package();
			if (packageName.EndsWith(".bin")) Path.ChangeExtension(packageName, "", package.[Friend]name);
			else package.[Friend]name.Set(packageName);

			// Import each package node
			for (let node in nodes)
			{
				Importer importer;

				if (node.Importer < importers.Count && importers.ContainsKey(importerNames[(int)node.Importer]))
					importer = importers.GetValue(importerNames[(int)node.Importer]);
				else if (node.Importer >= importers.Count) return .Err(new String("Couldn't loat package {0}. Couldn't find importer {1}")..Format(packageName, importerNames[(int)node.Importer]));
				else return .Err(new String("Couldn't loat package {0}. Couldn't find importer at index {1} of file's importer name array")..Format(packageName, node.Importer));

				let json = scope String((char8*)node.DataNode.CArray(), node.DataNode.Count);
				let doc = scope JSONDocument().ParseObject(json);
				if (doc case .Err(let err)) return .Err(new String("Couldn't loat package {0}. Couldn't find importer at index {1} of file's importer name array")..Format(packageName, node.Importer));
				let dataNode = doc.Get();

				importer.Load(package, node.Data, dataNode);
				delete dataNode;
			}

			// Clear up
			for (let s in importerNames)
				delete s;

			return .Ok(null);
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
			let t = scope Stopwatch(true);
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
			List<String> importerNames = scope List<String>();

			List<String> importPaths = scope List<String>(); // All of these paths exist
			let rootPath = scope String();
			Path.GetDirectoryPath(packagePath, rootPath);
			for (let import in packageData.imports)
			{
				Importer importer;

				// Try to find importer
				if (importers.ContainsKey(import.importer)) importer = importers[import.importer];
				else return .Err(new String("Couldn't build package at {0}. Couln't find importer '{1}'")..Format(packagePath, import.importer));

				bool importerUsed = false;

				// Interpret path string (put all final paths in importPaths)
				for (var path in import.path.Split(';'))
				{
					path.Trim();

					let fullPath = scope String();
					Path.InternalCombineViews(fullPath, rootPath, path);

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

					// Read file
					let res = Core.System.FileReadAllBytes(filePath);
					if (res case .Err(let err))
						return .Err(new String("Couldn't build package at {0}. Error reading file at {1}: {2}")..Format(packagePath, filePath, err));
					uint8[] data = res;

					// Run through importer
					let ress = importer.Build(data, let node);
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
					importerUsed = true;
					nodes.Add(new PackageNode((uint32)importerNames.Count, importedData, nodeData));

					delete filePath;
				}
				importPaths.Clear();

				if (importerUsed)
					importerNames.Add(new String(import.importer));
			}

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
				// 		IMPORTERNAMEINDEX (uint32)
				// 		DATAARRAYLENGTH (uint32)
				// 		DATAARRAY (of bytes)
				// 		DATANODEARRAYLENGTH (uint32)
				// 		DATANODEARRAY (of bytes)

				List<uint8> file = scope List<uint8>();
				file.Add(0x50); // Head
				file.Add(0x4C);
				file.Add(0x50);
				file.Add(0x00); // Empty
				UInt(0); // Size placeholder

				// All importer strings
				UInt((uint32)importerNames.Count);
				for (let s in importerNames)
				{
					UInt((uint32)s.Length);
					let span = Span<uint8>((uint8*)s.Ptr, s.Length);
					file.AddRange(span);

					delete s;
				}

				// All data in order
				for (let node in nodes)
				{
					UInt(node.Importer);
					UInt((uint32)node.Data.Count);
					file.AddRange(node.Data);
					UInt((uint32)node.DataNode.Count);
					file.AddRange(node.DataNode);

					delete node;
				}
				nodes.Clear();

				void UInt(uint32 uint)
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
				Path.InternalCombine(outPath, packagesPath, packageName);
				Path.ChangeExtension(scope String(outPath), ".bin", outPath);
				let res = Core.System.FileWriteAllBytes(outPath, file);
				if (res case .Err)
					return .Err(new String("Couldn't build package at {0}. Error writing file to {1}")..Format(packagePath, outPath));

				t.Stop();
				Log.Message(scope String("Built package {0} in {1}ms")..Format(packageName, t.ElapsedMilliseconds));
			}

			return .Ok;
		}
	}
}
