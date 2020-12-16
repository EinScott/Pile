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
		public class Node
		{
			public readonly uint32 Importer;
			public readonly uint8[] Name ~ delete _;
			public readonly uint8[] Data ~ delete _;
			public readonly uint8[] DataNode ~ delete _;

			internal this(uint32 importer, uint8[] name, uint8[] data, uint8[] dataNode)
			{
				Name = name;
				Importer = importer;
				Data = data;
				DataNode = dataNode;
			}
		}
		
		const int32 MAXCHUNK = 32767;

		[Optimize]
		public static Result<void> ReadPackage(StringView packagePath, List<Packages.Node> nodes, List<String> importerNames)
		{
			let inPath = scope String(packagePath);

			if (!inPath.EndsWith(".bin"))
				Path.ChangeExtension(scope String(inPath), ".bin", inPath);

			// Get file
			let file = LogErrorTry!(File.ReadAllBytes(inPath), scope $"Couldn't loat package at {inPath}. Error reading file");
			defer delete file;

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
			//		ZLIB UNCOMPRESSED SIZE (uint32)
			//		NUM ZLIB CHUNKS (uint32)
			//		ZLIB ARRAY:
			//			ELEMENT:
			//			ZLIB CHUNK SIZE (uint32)
			//			ZLIB CHUNK (compressed) =>
			// 				IMPORTERNAMEINDEX (uint32)
			// 				NAME (uint32)
			// 				NAMEDATA
			// 				DATAARRAYLENGTH (uint32)
			// 				DATAARRAY (of bytes)
			// 				DATANODEARRAYLENGTH (uint32)
			// 				DATANODEARRAY (of bytes)

			int32 readByte = 4; // Start after header

			if (file.Count < 16 // Check min file size
				|| file[0] != 0x50 || file[1] != 0x4C || file[2] != 0x50 // Check file header
				|| file[3] != 0x00 // Check version
				|| ReadUInt() != (uint32)file.Count) // Check file size
				LogErrorReturn!(scope $"Couldn't loat package at {inPath}. Invalid file format");

			{
				let importerNameCount = ReadUInt();
				for (uint32 i = 0; i < importerNameCount; i++)
				{
					let importerNameLength = ReadUInt();
					importerNames.Add(new String((char8*)&file[readByte], importerNameLength));
					readByte += (.)importerNameLength;
				}

				let nodeCount = ReadUInt();
				for (uint32 i = 0; i < nodeCount; i++)
				{
					// Decompress
					let uncompSize = ReadUInt();
					let numChunks = ReadUInt();

					let nodeRaw = new uint8[uncompSize];
					defer delete nodeRaw;
					var writeStart = 0;

					// Decompress every chunk
					for (int j = 0; j < numChunks; j++)
					{
						var chunkSize = (int32)ReadUInt();
						let uncompChunkSize = LogErrorTry!(Compression.Decompress(Span<uint8>(&file[readByte], chunkSize), Span<uint8>(&nodeRaw[writeStart], nodeRaw.Count - writeStart)), scope $"Couldn't loat package at {inPath}. Error decompressing node data");
						readByte += chunkSize;

						writeStart += uncompChunkSize;
					}

					if (uncompSize != writeStart)
						LogErrorReturn!(scope $"Couldn't load package at {inPath}. Uncompressed node data wasn't of expected size");

					int position = 0;

					uint32 ReadArrayUInt()
					{
						let startIndex = position;
						position += 4;
						return (((uint32)nodeRaw[startIndex] << 24) | (((uint32)nodeRaw[startIndex + 1]) << 16) | (((uint32)nodeRaw[startIndex + 2]) << 8) | (uint32)nodeRaw[startIndex + 3]);
					}

					// Read from decompressed array
					let importerIndex = ReadArrayUInt();

					let nameLength = ReadArrayUInt();
					let name = new uint8[nameLength];
					Span<uint8>(&nodeRaw[position], nameLength).CopyTo(name);
					position += nameLength;

					let dataLength = ReadArrayUInt();
					let data = new uint8[dataLength];
					Span<uint8>(&nodeRaw[position], dataLength).CopyTo(data);
					position += dataLength;

					let nodeDataLength = ReadArrayUInt();
					let nodeData = new uint8[nodeDataLength];

					if (nodeDataLength > 0) // This might be 0
						Span<uint8>(&nodeRaw[position], nodeDataLength).CopyTo(nodeData);

					position += nodeDataLength;

					nodes.Add(new Node(importerIndex, name, data, nodeData));
				}
			}

			if (readByte != file.Count)
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. The file contains {file.Count} bytes, but the end of data was at {readByte}");	

			return .Ok;

			uint32 ReadUInt()
			{
				let startIndex = readByte;
				readByte += 4;
				return (((uint32)file[startIndex] << 24) | (((uint32)file[startIndex + 1]) << 16) | (((uint32)file[startIndex + 2]) << 8) | (uint32)file[startIndex + 3]);
			}
		}

		[Optimize]
		static Result<void> WritePackage(StringView packagePath, List<Packages.Node> nodes, List<String> importerNames)
		{
			let file = new List<uint8>();
			defer delete file;

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
			//		ZLIB UNCOMPRESSED SIZE (uint32)
			//		NUM ZLIB CHUNKS (uint32)
			//		ZLIB ARRAY:
			//			ELEMENT:
			//			ZLIB CHUNK SIZE (uint32)
			//			ZLIB CHUNK (compressed) =>
			// 				IMPORTERNAMEINDEX (uint32)
			// 				NAME (uint32)
			// 				NAMEDATA
			// 				DATAARRAYLENGTH (uint32)
			// 				DATAARRAY (of bytes)
			// 				DATANODEARRAYLENGTH (uint32)
			// 				DATANODEARRAY (of bytes)

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
			}

			// All data in order
			WriteUInt((uint32)nodes.Count);
			for (let node in nodes)
			{
				let zLibInput = new uint8[sizeof(uint32) * 4 + node.Name.Count + node.Data.Count + node.DataNode.Count];
				defer delete zLibInput;
				int position = 0;

				void WriteArrayUInt(uint32 uint)
				{
					zLibInput[position] = (uint8)((uint >> 24) & 0xFF);
					zLibInput[position + 1] = (uint8)((uint >> 16) & 0xFF);
					zLibInput[position + 2] = (uint8)((uint >> 8) & 0xFF);
					zLibInput[position + 3] = (uint8)(uint & 0xFF);
					position += 4;
				}

				void WriteArraySpan(Span<uint8> span)
				{
					var span;
					let dest = Span<uint8>((&zLibInput[position - 1]) + 1, Math.Min(zLibInput.Count, span.Length));
					if (span.Length != dest.Length)
					{
						Log.Warning(scope $"Span to write to zlib input array was longer ({span.Length}) than arrayLenght - currentArrayPosition ({dest.Length})");
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

				// Write uncompressed size & numChunks into file
				WriteUInt((uint32)zLibInput.Count);
				let chunks = (uint32)Math.Ceiling((double)zLibInput.Count / MAXCHUNK);
				WriteUInt(chunks);

				var readStart = 0;
				int compSize = sizeof(uint32) * chunks; // Also include size of chunk size ints, since this is the size of the whole array

				var writeStart = file.Count;
				let zLibFileSize = zLibInput.Count + sizeof(uint32) * chunks;
				file.Count += zLibFileSize; // Reserve original size of data + space for chunk size ints

				// Compress node in chunks
				for (uint32 i = 0; i < chunks; i++)
				{
					let writeSizeIndex = writeStart; // Reserve space for chunk size
					writeStart += sizeof(uint32);

					let chunkReadSize = Math.Min(MAXCHUNK, zLibInput.Count - readStart);
					
					let res = Compression.Compress(Span<uint8>(&zLibInput[readStart], chunkReadSize), Span<uint8>(&file[writeStart], file.Count - writeStart));
					var chunkWriteSize = 0;
					switch (res)
					{
					case .Err (let err):
						LogErrorReturn!(scope $"Couldn't write package. Error compressing node data: {err}");
					case .Ok(let val):
						chunkWriteSize = val;
						compSize += val;
					}

					readStart += chunkReadSize;
					writeStart += chunkWriteSize;
					ReplaceUInt(writeSizeIndex, (uint32)chunkWriteSize);
				}

				file.Count -= zLibFileSize - compSize; // Remove unneeded reserved space
			}

			void WriteUInt(uint32 uint)
			{
				file.Add((uint8)((uint >> 24) & 0xFF));
				file.Add((uint8)((uint >> 16) & 0xFF));
				file.Add((uint8)((uint >> 8) & 0xFF));
				file.Add((uint8)(uint & 0xFF));
			}

			void ReplaceUInt(int at, uint32 uint)
			{
				file[at] = (uint8)((uint >> 24) & 0xFF);
				file[at + 1] = (uint8)((uint >> 16) & 0xFF);
				file[at + 2] = (uint8)((uint >> 8) & 0xFF);
				file[at + 3] = (uint8)(uint & 0xFF);
			}

			// Fill in size
			ReplaceUInt(4, (uint32)file.Count);

			let outPath = scope String(packagePath);
			Path.ChangeExtension(scope String(outPath), ".bin", outPath);

			if (!Directory.Exists(outPath))
				LogErrorTry!(Directory.CreateDirectory(outPath), scope $"Couldn't write package. Error creating directory {outPath}");

			LogErrorTry!(File.WriteAllBytes(outPath, file), scope $"Couldn't write package. Error writing file to {outPath}");

			return .Ok;
		}

		[Optimize]
		static Result<void> ReadPackageBuildFile(StringView packageBuildFilePath, PackageData packageData)
		{
			// Read package file
			String jsonFile = scope String();
			if (File.ReadAllText(packageBuildFilePath, jsonFile) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath} because the file could not be opened");

			if (!JSONParser.IsValidJson(jsonFile))
				LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Invalid json file");

			JSONObject root = scope JSONObject();
			let res = JSONParser.ParseObject(jsonFile, ref root);
			if (res case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error parsing json: {err}");

			if (!root.ContainsKey("imports"))
				LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. The root json object must include a 'imports' json array of objects");

			JSONArray array = null;
			var ress = root.Get("imports", ref array);
			if (ress case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting 'imports' array from root object: {err}");
			if (array == null)
				LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting 'imports' array from root object");

			JSONObject entry = null;
			for (int i = 0; i < array.Count; i++)
			{
				ress = array.Get(i, ref entry);
				if (ress case .Err(let err))
					LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting object at position {i} of 'imports' array: {err}");
				if (entry == null) continue; // This can probably not happen anyways

				// Mandatory parameters
				if (!entry.ContainsKey("path") || !entry.ContainsKey("importer"))
					LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error processing object at position {i} of 'imports' array: Object must include a path and importer string");
				if (entry.GetValueType("path") != .STRING || entry.GetValueType("importer") != .STRING)
					LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error processing object at position {i} of 'imports' array: Object must include a path and importer entry, both of json type string");

				String path = null;
				ress = entry.Get("path", ref path);
				if (ress case .Err(let err))
					LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting object 'path' of object at position {i} of 'imports' array: {err}");

				String importer = null;
				ress = entry.Get("importer", ref importer);
				if (ress case .Err(let err))
					LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting object 'importer' of object at position {i} of 'imports' array: {err}");

				// Option parameters
				String namePrefix = null;
				if (entry.ContainsKey("name_prefix") && entry.GetValueType("name_prefix") == .STRING)
				{
					ress = entry.Get("name_prefix", ref namePrefix);
					if (ress case .Err(let err))
						LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting object 'name_prefix' of object at position {i} of 'imports' array: {err}");
				}

				JSONObject config = null;
				if (entry.ContainsKey("config") && entry.GetValueType("config") == .OBJECT)
				{
					ress = entry.Get("config", ref config);
					if (ress case .Err(let err))
						LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error getting object 'config' of object at position {i} of 'imports' array: {err}");
				}

				packageData.imports.Add(new PackageData.ImportData(path, importer, namePrefix == null ? null : StringView(namePrefix), config == null ? null : new JSONObject(config)));

				entry = null;
			}

			return .Ok;
		}

		[Optimize]
		public static Result<void> BuildPackage(StringView packageBuildFilePath, StringView outputPath)
		{
			let t = scope Stopwatch(true);
			PackageData packageData = new PackageData();

			if (ReadPackageBuildFile(packageBuildFilePath, packageData) case .Err)
			{
				delete packageData;
				return .Err;
			}

			// Resolve imports
			List<Node> nodes = new List<Node>();
			List<String> importerNames = new List<String>();

			defer
			{
				DeleteContainerAndItems!(importerNames);
				DeleteContainerAndItems!(nodes);
			}

			{
				// Delete on scope exit
				defer delete packageData;

				List<StringView> duplicateNameLookup = scope List<StringView>();
				List<String> importPaths = new List<String>(); // All of these paths exist
				defer
				{
					DeleteContainerAndItems!(importPaths);
				}

				let rootPath = scope String();
				Path.GetDirectoryPath(packageBuildFilePath, rootPath);
				for (let import in packageData.imports)
				{
					Importer importer;
	
					// Try to find importer
					if (Assets.Importers.ContainsKey(import.Importer)) importer = Assets.Importers[import.Importer];
					else LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Couln't find importer '{import.Importer}'");
	
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
							LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Failed to find containing directory of {path} at {dirPath}");
	
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
									Log.Warning(scope $"Couldn't find any matches for {wildCardPath} in {currImportPath}");
	
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
						Log.Message(scope $"Importing {filePath}");
	
						// Read file
						let res = File.ReadAllBytes(filePath);
						if (res case .Err(let err))
							LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error reading file at {filePath} with {import.Importer}: {err}");
						uint8[] data = res;
	
						// Run through importer -- config may be null
						let ress = importer.Build(data, import.Config, let node);
						if (ress case .Err(let err))
							LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error importing file at {filePath} with {import.Importer}: {err}");
						uint8[] builtData = ress.Get();
						if (builtData.Count <= 0)
							LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error importing file at {filePath} with {import.Importer}: Length of returned data cannot be 0");
	
						delete data;

						// Make name
						let s = scope String();
						if (import.NamePrefix != null) s.Append(import.NamePrefix);
						Path.GetFileNameWithoutExtension(filePath, s);

						// Check if name exists
						if (duplicateNameLookup.Contains(s))
							LogErrorReturn!(scope $"Couldn't build package at {packageBuildFilePath}. Error importing file at {filePath}: Entry with name {s} has already been imported");

						// Add to node and duplicate lookup
						let name = new uint8[s.Length];
						Span<uint8>((uint8*)s.Ptr, s.Length).CopyTo(name);
						duplicateNameLookup.Add(StringView((char8*)name.CArray(), name.Count)); // Add name data interpreted as string back to duplicate lookup

						// Convert node string to bytes
						s.Clear();
						if (node != null)
							node.ToString(s); // Node might be null
	
						let nodeData = new uint8[s.Length]; // Array might be empty, and that is valid
						
						if (node != null)
						{
							// Fill array
							Span<uint8>((uint8*)s.Ptr, s.Length).CopyTo(nodeData);
							delete node;
						}
	
						// Add data
						importerUsed = true;
						nodes.Add(new Node((uint32)importerNames.Count, name, builtData, nodeData));
					}
					ClearAndDeleteItems(importPaths);
	
					if (importerUsed)
						importerNames.Add(new String(import.Importer));
				}
			}

			// Put it all in a file
			{
				let outPath = scope String();
				let packageName = scope String();
				Path.GetFileNameWithoutExtension(scope String(packageBuildFilePath), packageName);
				Path.InternalCombine(outPath, scope String(outputPath), packageName);

				Try!(WritePackage(outPath, nodes, importerNames));

				t.Stop();
				Log.Message(scope $"Built package {outPath} in {t.ElapsedMilliseconds}ms");
			}

			return .Ok;
		}
	}
}
