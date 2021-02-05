using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Collections;
using System.Diagnostics;
using System.Security.Cryptography;
using Atma;

using internal Pile;

namespace Pile
{
	[Optimize]
	public static class Packages
	{
		// Represents the json data in the package import file
		[Serializable]
		internal class PackageData
		{
			public List<ImportData> imports ~ DeleteContainerAndItems!(_);

			[Serializable]
			internal class ImportData
			{
				public String path ~ DeleteNotNull!(_);
				public String importer ~ DeleteNotNull!(_);
				public String name_prefix ~ DeleteNotNull!(_);
				public String config ~ DeleteNotNull!(_);
			}
		}
		
		// Node of data for one imported file
		public struct Node : IDisposable
		{
			public readonly uint32 Importer;
			public readonly uint8[] Name;
			public readonly uint8[] Data;

			internal this(uint32 importer, uint8[] name, uint8[] data)
			{
				Name = name;
				Importer = importer;
				Data = data;
			}

			public void Dispose()
			{
				delete Name;
				delete Data;
			}
		}

		enum PackageMode : uint8
		{
			None = 0,
		}

		const int32 MAXCHUNK = int16.MaxValue;

		// @do: both read and write are old. Redo them with just literal file and memory streams!
		public static Result<void> ReadPackage(StringView packagePath, List<Packages.Node> nodes, List<String> importerNames, out SHA256Hash contentHash)
		{
			contentHash = .();
			let inPath = Path.Clean(packagePath, .. scope .());

			if (!inPath.EndsWith(".bin"))
				Path.ChangeExtension(inPath, ".bin", inPath);

			// Get file
			let file = new List<uint8>();
			LogErrorTry!(File.ReadAll(inPath, file), scope $"Couldn't load package at {inPath}. Error reading file");
			defer delete file;

			// HEADER (3 bytes)
			// MODE (1 byte)
			// FILESIZE (4 bytes, uint32)
			// CONTENTHASH (32 bytes)

			// IMPORTERNAMECOUNT (uint32)
			// IMPORTERNAMEARRAY[]
			// 		ELEMENT:
			// 		STRINGSIZE (uint32)
			// 		STRING[]

			// NODECOUNT (uint32)
			// NODEDATAARRAY[]
			//		ELEMENT:
			//		ZLIB UNCOMPRESSED SIZE (uint32)
			//		NUM ZLIB CHUNKS (uint32)
			//		ZLIBARRAY[]
			//			ELEMENT:
			//			ZLIB CHUNK SIZE (uint32)
			//			ZLIB CHUNK (compressed) =>
			// 				IMPORTERNAMEINDEX (uint32)
			// 				NAMELENGTH (uint32)
			// 				NAMEDATA[]
			// 				DATALENGTH (uint32)
			// 				DATAARRAY[]

			int32 readByte = 4; // Start after header

			if (file.Count < 16 // Check min file size
				|| file[0] != 0x50 || file[1] != 0x4C || file[2] != 0x50 // Check file header
				|| ReadUInt() != (uint32)file.Count) // Check file size
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Invalid file format");

			//let mode = (PackageMode)file[3];

			// Read file
			{
				// Read hash
				{
					Span<uint8>(&file[readByte], 32).CopyTo(contentHash.mHash);
					readByte += 32;
				}

				// Importer names
				let importerNameCount = ReadUInt();
				for (uint32 i = 0; i < importerNameCount; i++)
				{
					let importerNameLength = ReadUInt();
					importerNames.Add(new String((char8*)&file[readByte], importerNameLength));
					readByte += (.)importerNameLength;
				}

				// Nodes
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
						let chunkSize = (int32)ReadUInt();
						let uncompChunkSize = LogErrorTry!(Compression.Decompress(Span<uint8>(&file[readByte], chunkSize), Span<uint8>(&nodeRaw[writeStart], nodeRaw.Count - writeStart)), scope $"Couldn't loat package at {inPath}. Error decompressing node data");
						readByte += chunkSize;

						writeStart += uncompChunkSize;
					}

					if (uncompSize != writeStart)
						LogErrorReturn!(scope $"Couldn't load package at {inPath}. Uncompressed node data wasn't of expected size");

					int position = 0;

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

					nodes.Add(Node(importerIndex, name, data));

					uint32 ReadArrayUInt()
					{
						let startIndex = position;
						position += 4;
						return (((uint32)nodeRaw[startIndex] << 24) | (((uint32)nodeRaw[startIndex + 1]) << 16) | (((uint32)nodeRaw[startIndex + 2]) << 8) | (uint32)nodeRaw[startIndex + 3]);
					}
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

		static Result<void> WritePackage(StringView cPackagePath, List<Packages.Node> nodes, List<String> importerNames, SHA256Hash contentHash)
		{
			let file = new List<uint8>();
			defer delete file;

			// HEADER (3 bytes)
			// MODE (1 byte)
			// FILESIZE (4 bytes, uint32)
			// CONTENTHASH (32 bytes)

			// IMPORTERNAMECOUNT (uint32)
			// IMPORTERNAMEARRAY[]
			// 		ELEMENT:
			// 		STRINGSIZE (uint32)
			// 		STRING[]

			// NODECOUNT (uint32)
			// NODEDATAARRAY[]
			//		ELEMENT:
			//		ZLIB UNCOMPRESSED SIZE (uint32)
			//		NUM ZLIB CHUNKS (uint32)
			//		ZLIBARRAY[]
			//			ELEMENT:
			//			ZLIB CHUNK SIZE (uint32)
			//			ZLIB CHUNK (compressed) =>
			// 				IMPORTERNAMEINDEX (uint32)
			// 				NAMELENGTH (uint32)
			// 				NAMEDATA[]
			// 				DATALENGTH (uint32)
			// 				DATAARRAY[]

			file.Add(0x50); // Head
			file.Add(0x4C);
			file.Add(0x50);

			PackageMode mode = .None;
			file.Add(mode.Underlying); // Mode

			WriteUInt(0); // Size placeholder

			// Content Hash
			var contentHash;
			let hashSpan = Span<uint8>(&contentHash.mHash[0], contentHash.mHash.Count);
			file.AddRange(hashSpan); // Write hash

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
				let zLibInput = new uint8[sizeof(uint32) * 3 + node.Name.Count + node.Data.Count];
				defer delete zLibInput;
				int position = 0;

				// Write into zLib array
				WriteArrayUInt(node.Importer);
				WriteArrayUInt((uint32)node.Name.Count);
				WriteArraySpan(node.Name);
				WriteArrayUInt((uint32)node.Data.Count);
				WriteArraySpan(node.Data);

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
					case .Err:
						LogErrorReturn!(scope $"Couldn't write package. Error compressing node data");
					case .Ok(let val):
						chunkWriteSize = val;
						compSize += val;
					}

					readStart += chunkReadSize;
					writeStart += chunkWriteSize;
					ReplaceUInt(writeSizeIndex, (uint32)chunkWriteSize);
				}

				file.Count -= zLibFileSize - compSize; // Remove unneeded reserved space

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
						Log.Warn(scope $"Span to write to zlib input array was longer ({span.Length}) than arrayLenght - currentArrayPosition ({dest.Length})");
						span.Length = dest.Length; // Trim input span to fit zlib mem. ~~This should never happen but yeah
					}
					span.CopyTo(dest);
					position += dest.Length;
				}
			}

			// Fill in size
			ReplaceUInt(4, (uint32)file.Count);

			let outPath = Path.ChangeExtension(cPackagePath, ".bin", .. scope String(cPackagePath));
			let dir = scope String();
			if (Path.GetDirectoryPath(outPath, dir) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error getting directory of path {outPath}");

			if (!Directory.Exists(dir))
			{
				if (Directory.CreateDirectory(dir) case .Err(let err))
					LogErrorReturn!(scope $"Couldn't write package. Error creating directory {dir} ({err})");
			}

			if (File.WriteAll(outPath, file) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error writing file to {outPath}");

			return .Ok;

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
		}

		static Result<void> ReadPackageBuildFile(StringView cPackageBuildFilePath, PackageData packageData)
		{
			// Read package file
			String jsonFile = scope String();
			if (File.ReadAllText(cPackageBuildFilePath, jsonFile) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath} because the file could not be opened");

			if (JsonConvert.Deserialize(packageData, jsonFile) case .Err)
				LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error reading json");

			for (let imp in packageData.imports)
			{
				if (imp.path == null || imp.importer == null)
					LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. \"path\" and \"importer\" has to be specified for every import statement");
			}

			return .Ok;
		}

		static mixin GetScopedAssetName(StringView filePath, PackageData.ImportData import)
		{
			let s = scope:mixin String();
			if (import.name_prefix != null) s.Append(import.name_prefix);
			Path.GetFileNameWithoutExtension(filePath, s);
			s
		}

		/// If force is false, the package will only be built if there is no file at outPath or the package source changed and patched otherwise
		public static Result<void> BuildPackage(StringView packageBuildFilePath, StringView outputFolderPath, bool force = false)
		{
			let t = scope Stopwatch(true);
			PackageData packageData = new PackageData();

			let cPackageBuildFilePath = Path.Clean(packageBuildFilePath, .. scope .());
			if (ReadPackageBuildFile(cPackageBuildFilePath, packageData) case .Err)
			{
				delete packageData;
				return .Err;
			}

			// Package data
			List<Node> nodes = new List<Node>(32);
			List<String> importerNames = new List<String>(8);

			defer
			{
				DeleteContainerAndItems!(importerNames);
				for (let n in nodes)
					n.Dispose();
				delete nodes;
			}

			// Prepare paths
			let packageName = Path.GetFileNameWithoutExtension(cPackageBuildFilePath, .. scope String());
			let outputPath = Path.Clean(.. Path.InternalCombineViews(.. scope String(), outputFolderPath, packageName));
			Path.ChangeExtension(outputPath, ".bin", outputPath);

			// Resolve imports and build
			SHA256Hash contentHash;
			SHA256Hash lastContentHash;
			bool somethingChanged = false;
			BUILD:
			{
				// Delete on scope exit
				defer delete packageData;

				List<String> duplicateNameLookup = scope List<String>();

				List<StringView> previousNames = scope List<StringView>(); // All names of the last package content (only used in rebuild)
				List<String> includePaths = scope List<String>(); // All of these paths exist
				List<StringView> importPaths = scope List<StringView>(); // All of these paths exist AND need to be imported again because of changes or additions

				// Check if we need to do a full build or can do a patch
				DateTime lastPackageBuildDate;
				bool patchBuild = false;
				if (!force && File.Exists(outputPath) && (File.GetLastWriteTimeUtc(outputPath) case .Ok(out lastPackageBuildDate)) // Get last package build time if file exists
					&& (File.GetLastWriteTimeUtc(cPackageBuildFilePath) case .Ok(let lastBuildFileChange)) // Get last build file change time
					&& lastBuildFileChange < lastPackageBuildDate) // Check if BuildFile was changed between builds (in that case we would need full build)
				{
					// Try to read the previous package contents
					if ((ReadPackage(outputPath, nodes, importerNames, out lastContentHash) case .Err))
					{
						// Clean up possible trash, we need to full build now
						for (let n in nodes)
							n.Dispose();
						nodes.Clear();
						ClearAndDeleteItems!(importerNames);

						lastPackageBuildDate = .();
						lastContentHash = .();
						somethingChanged = true;
					}
					// ReadPackage was successful. We can rebuild
					else patchBuild = true;
				}
				else
				{
					// We will full build
					lastPackageBuildDate = .();
					lastContentHash = .();
					somethingChanged = true;
				}

				// Add existing nodes (from existing package) into previous lookup
				// So we can detect changes in content
				if (patchBuild)
				{
					for (let node in nodes)
						previousNames.Add(StringView((char8*)node.Name.CArray(), node.Name.Count));
				}

				let importerData = new List<uint8>();
				defer delete importerData;

				let rootPath = scope String();
				Try!(Path.GetDirectoryPath(cPackageBuildFilePath, rootPath));

				// Build hash from all names
				SHA256 hashBuilder = .();

				for (let import in packageData.imports)
				IMPORT:
				{
					Importer importer;

					// Try to find importer
					if (Importers.importers.ContainsKey(import.importer)) importer = Importers.importers[import.importer];
					else LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Couldn't find importer '{import.importer}'");

					// Get index in importerNames array
					int currentImporter = importerNames.Count; // Default for when it will be added later
					{
						let foundImporter = importerNames.IndexOf(import.importer);
						if (foundImporter != -1)
							currentImporter = foundImporter;
					}

					// Interpret path string (put all final paths in importPaths)
					for (var path in import.path.Split(';'))
					{
						path.Trim();

						let fullPath = Path.Clean(.. (Path.IsPathRooted(path)
							? scope String(path)
							: Path.InternalCombineViews(.. scope String(), rootPath, path)));

						// Check if containing folder exists
						let dirPath = scope String();
						if ((Path.GetDirectoryPath(fullPath, dirPath) case .Err) || !Directory.Exists(dirPath))
							LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Failed to find containing directory of {path}");

						// Import everything that matches
						SEARCH:
						{
							let wildCard = Path.GetFileName(fullPath, .. scope String());

							let importDirs = scope List<String>(8);
							importDirs.Add(scope:SEARCH String(dirPath));

							String currImportPath;
							let enumeratePath = scope String(128);
							let searchPath = scope String(128);
							let wildCardPath = scope String(128);
							repeat // For each entry in import dirs
							{
								let current = importDirs.Count - 1;
								currImportPath = importDirs[current]; // Pick from the back, since we dont want to remove stuff in middle or front

								searchPath..Set(currImportPath)..Append(Path.DirectorySeparatorChar).Append('*');
								wildCardPath..Set(currImportPath)..Append(Path.DirectorySeparatorChar).Append(wildCard);

								bool match = false;
								for (let entry in Directory.Enumerate(searchPath, .Files | .Directories))
								{
									enumeratePath.Clear();
									entry.GetFilePath(enumeratePath);

									if (searchPath == wildCardPath || Path.WildcareCompare(enumeratePath, wildCardPath))
									{
										match = true;

										// Add matching files in this directory to import list
										if (!entry.IsDirectory)
										{
											// Hash name
											let s = GetScopedAssetName!(enumeratePath, import);
											hashBuilder.Update(Span<uint8>((uint8*)s.Ptr, s.Length));

											let includeFilePath = scope:IMPORT String(enumeratePath);
											includePaths.Add(includeFilePath);

											// If we need to import this file (if this is a full build, the file was changed, or its new)
											if (!patchBuild || entry.GetLastWriteTimeUtc() > lastPackageBuildDate || !previousNames.Contains(s))
												importPaths.Add(includeFilePath);
										}
										// Look for matching sub dirs and add to importDirs list
										else
											importDirs.Add(scope:SEARCH String(enumeratePath));
									}
								}

								if (!match)
									Log.Warn(scope $"Couldn't find any matches for {wildCardPath} in {currImportPath}");

								// Tidy up
								importDirs.RemoveAtFast(current);
							}
							while (importDirs.Count > 0);
						}
					}

					// If anything changed this import statement, we know that we WILL build
					// somethingChanged is already true if !patchBuild
					if (!somethingChanged && importPaths.Count > 0)
						somethingChanged = true;

					// Import all files found for this import statement with this importer
					bool importerUsed = false;
					let config = scope List<StringView>();
					for (var filePath in includePaths) // For each INCLUDED file (which might already be in last build)
					{
						// Make name
						let name = GetScopedAssetName!(filePath, import);

						// Check if name already exists
						if (duplicateNameLookup.Contains(name))
							LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error importing file at {filePath}: Entry with name {name} has already been imported. Consider using \"name_prefix\"");

						// If some file changed AND (we do a full build OR this file is in the to import list) => we need to import this (again)
						if (somethingChanged && (!patchBuild || importPaths.Contains(filePath)))
						{
							// Override old node if we're patching changes in
							int patchIndex = -1;
							if (patchBuild)
							{
								for (var i < nodes.Count)
								{
									let node = ref nodes[i];
									if (StringView((char8*)&node.Name[0], node.Name.Count) == name)
									{
										patchIndex = i;
										break;
									}
								}
							}

							Log.Debug($"Importing {filePath}");
							importerData.Clear();

							// Read file
							let res = File.ReadAll(filePath, importerData);
							if (res case .Err(let err))
								LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error reading file at {filePath} with {import.importer}: {err}");

							// Compose config
							config.Clear();
							if (import.config != null && import.config.Length > 0)
							{
								for (var part in import.config.Split(';'))
								{
									part.Trim();
									config.Add(part);
								}
							}

							// Run through importer
							let ress = importer.Build(importerData, config, filePath);
							if (ress case .Err)
								LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Importer error importing file at {filePath} with {import.importer}");
							uint8[] buildData = ress.Get();
							if (buildData.Count <= 0)
							{
								delete buildData;
								LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error importing file at {filePath} with {import.importer}: Length of returned data cannot be 0");
							}

							// Add to node and duplicate lookup
							let nameData = new uint8[name.Length];
							Span<uint8>((uint8*)name.Ptr, name.Length).CopyTo(nameData);

							// Add data
							if (patchIndex == -1)
								nodes.Add(Node((uint32)currentImporter, nameData, buildData));
							else
							{
								nodes[patchIndex].Dispose(); // Swap out
								nodes[patchIndex] = Node((uint32)currentImporter, nameData, buildData);
							}

							importerUsed = true;
						}

						// Add name data interpreted as string back to duplicate lookup in any case
						duplicateNameLookup.Add(scope:BUILD String(name));
					}
					includePaths.Clear();
					importPaths.Clear();

					if (importerUsed && currentImporter == importerNames.Count) // The importer doesnt already have an index
						importerNames.Add(new String(import.importer));
				}

				// Remove nodes
				if (patchBuild)
				{
					for (let prevName in previousNames)
						if (!duplicateNameLookup.Contains(scope .(prevName)))
						{
							Log.Debug($"Removing {prevName}");

							for (var i < nodes.Count)
							{
								let node = ref nodes[i];
								if (StringView((char8*)&node.Name[0], node.Name.Count) == prevName)
								{
									nodes.RemoveAtFast(i);
									node.Dispose();
									somethingChanged = true; // Even though hash shouldn't match either...
									break;
								}
							}
						}
				}

				contentHash = hashBuilder.Finish();
			}

			// If nothing changed, do nothing
			if (!somethingChanged && contentHash == lastContentHash)
			{
				t.Stop();
				Log.Info(scope $"Package {packageName} didn't change; took {t.ElapsedMilliseconds}ms");
				return .Ok;
			}

			// Put it all in a file
			{
				Try!(WritePackage(outputPath, nodes, importerNames, contentHash));

				t.Stop();
				Log.Info(scope $"Built package {packageName}; took {t.ElapsedMilliseconds}ms");
				return .Ok;
			}
		}

		public static Task<bool> BuildPackageAsync(StringView packageBuildFilePath, StringView outputFolderPath, bool force = false)
		{
			return new PackageBuildTask(packageBuildFilePath, outputFolderPath, force);
		}

		// adapted from StreamReader
		internal class PackageBuildTask : Task<bool> // bool indicates success
		{
			WaitEvent mDoneEvent = new WaitEvent() ~ delete _;

			String packageBuildFilePath = new String() ~ delete _;
			String outputFolderPath = new String() ~ delete _;
			bool force;

			public this(StringView packageBuildFilePath, StringView outputFolderPath, bool force = false)
			{
				this.packageBuildFilePath.Set(packageBuildFilePath);
				this.outputFolderPath.Set(outputFolderPath);
				this.force = force;

				ThreadPool.QueueUserWorkItem(new => Proc);
			}

			public ~this()
			{
				mDoneEvent.WaitFor();
			}

			void Proc()
			{
				m_result = Packages.BuildPackage(packageBuildFilePath, outputFolderPath, force) case .Ok;
				Finish(false);
				Ref();
				if (m_result)
					Notify(false);
				Deref();
				mDoneEvent.Set();
			}
		}
	}
}
