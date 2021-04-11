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
#if !DEBUG
	[Optimize]
#endif
	static class Packages
	{
		// Represents the json data in the package import file
		[Serializable]
		internal class PackageData
		{
			public bool use_path_names;
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

		const int32 MAXCHUNK = int16.MaxValue - 1;

		public static Result<void> ReadPackage(StringView packagePath, List<Packages.Node> nodes, List<String> importerNames, out SHA256Hash contentHash)
		{
			contentHash = .();
			let inPath = Path.Clean(packagePath, .. scope .());

			if (!inPath.EndsWith(".bin"))
				Path.ChangeExtension(inPath, ".bin", inPath);
			
			// Get file
			let fs = scope BufferedFileStream();
			if (fs.Open(inPath, .Open, .Read, .None, 65536) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Error reading file: {err}");

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
			//			ZLIB CHUNK (compressed) => (contains part of the following)
			// 				IMPORTERNAMEINDEX (uint32)
			// 				NAMELENGTH (uint32)
			// 				NAMEDATA[]
			// 				DATALENGTH (uint32)
			// 				DATAARRAY[]

			mixin ReadInto(var thing)
			{
				switch (fs.TryRead((Span<uint8>)thing))
				{
				case .Err:
					LogErrorReturn!(scope $"Couldn't read package. Error reading data from {inPath}");
				case .Ok(let val):
					if (val != ((Span<uint8>)thing).Length)
						LogErrorReturn!(scope $"Couldn't read package. Error reading data from {inPath} (unexpected partial read)");
				}

				thing
			}

			mixin ReadUInt()
			{
				uint8[4] data = .();
				switch (fs.TryRead(data))
				{
				case .Err:
					LogErrorReturn!(scope $"Couldn't read package. Error reading data from {inPath}");
				case .Ok(let val):
					if (val != data.Count)
						LogErrorReturn!(scope $"Couldn't read package. Error reading data from {inPath} (unexpected partial read)");
				}
				(((uint32)data[0] << 24) | (((uint32)data[1]) << 16) | (((uint32)data[2]) << 8) | (uint32)data[3]) // big endian
			}

			let header = ReadInto!(scope uint8[4]());
			if (header[0] != 0x50 || header[1] != 0x4C || header[2] != 0x50) // Check file header
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Invalid file format");

			let size = ReadUInt!(); // File size

			// Read file body
			{
				// Read content hash
				ReadInto!(contentHash.mHash);

				// Read importer names
				let importerNameCount = ReadUInt!();
				for (uint32 i = 0; i < importerNameCount; i++)
				{
					let importerNameLength = ReadUInt!();

					let nameString = new String(importerNameLength);
					nameString.Length = importerNameLength;
					ReadInto!(Span<uint8>((uint8*)&nameString[0], importerNameLength));

					importerNames.Add(nameString);
				}

				// Read nodes
				{
					let nodeCount = ReadUInt!();

					DynMemStream uncompressed = scope .();
					List<uint8> uncompData = uncompressed.TakeOwnership();
					defer delete uncompData;

					List<uint8> compData = new .();
					defer delete compData;

					mixin ReadUncompInto(var thing)
					{
						if (uncompressed.TryRead(thing) case .Err)
							LogErrorReturn!("Couldn't read package. Error reading from uncompressed buffer");
						thing
					}

					mixin ReadUncompUInt()
					{
						uint8[4] data = .();
						if (uncompressed.TryRead(data) case .Err)
							LogErrorReturn!("Couldn't read package. Error reading from uncompressed buffer");
						(((uint32)data[0] << 24) | (((uint32)data[1]) << 16) | (((uint32)data[2]) << 8) | (uint32)data[3]) // big endian
					}

					for (uint32 i = 0; i < nodeCount; i++)
					{
						// Decompress
						let uncompSize = ReadUInt!();
						let numChunks = ReadUInt!();
						
						uncompData.Count = uncompSize;
						uint32 uncompWriteStart = 0;

						for (int j = 0; j < numChunks; j++)
						{
							// Read compressed chunk
							let compSize = (int32)ReadUInt!();
							compData.Count = compSize;
							ReadInto!(compData);

							// Decompress
							/*switch (Compression.Decompress(compData, Span<uint8>(&uncompData[uncompWriteStart], uncompSize - uncompWriteStart)))
							{
							case .Ok(let val):
								uncompWriteStart += (.)val;
							case .Err:
								LogErrorReturn!(scope $"Couldn't load package at {inPath}. Error decompressing node chunk");
							}*/

							// @do temp
							Internal.MemCpy(&uncompData[uncompWriteStart], &compData[0], compSize);
							uncompWriteStart += (.)compSize;
						}

						if (uncompSize != uncompWriteStart)
							LogErrorReturn!(scope $"Couldn't load package at {inPath}. Uncompressed node data wasn't of expected size");

						// Read from decompressed data
						let importerIndex = ReadUncompUInt!();

						let nameLength = ReadUncompUInt!();
						let name = ReadUncompInto!(new uint8[nameLength]);

						let dataLength = ReadUncompUInt!();
						let data = ReadUncompInto!(new uint8[dataLength]);

						nodes.Add(Node(importerIndex, name, data));
						
						compData.Clear();
						uncompressed.Position = 0;
						uncompData.Clear();
					}
				}
			}

			// Confirm we read what we put in
			if (size != fs.Position)
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Invalid file format: The file contains {size} bytes, but the file content ended at {fs.Position}");	

			fs.Close(); // We did only read, this should never error.

			return .Ok;
		}

		static Result<void> WritePackage(StringView cPackagePath, List<Packages.Node> nodes, List<String> importerNames, SHA256Hash contentHash)
		{
			let outPath = Path.ChangeExtension(cPackagePath, ".bin", .. scope String(cPackagePath));
			let dir = scope String();
			if (Path.GetDirectoryPath(outPath, dir) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error getting directory of path {outPath}");

			if (!Directory.Exists(dir) && (Directory.CreateDirectory(dir) case .Err(let err)))
				LogErrorReturn!(scope $"Couldn't write package. Error creating directory {dir} ({err})");

			let fs = scope BufferedFileStream();
			if (fs.Open(outPath, .Create, .Write, .None, 65536) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error opening stream to {outPath}");

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
			//			ZLIB CHUNK (compressed) => (contains part of the following)
			// 				IMPORTERNAMEINDEX (uint32)
			// 				NAMELENGTH (uint32)
			// 				NAMEDATA[]
			// 				DATALENGTH (uint32)
			// 				DATAARRAY[]

			mixin Put(Span<uint8> data)
			{
				if (fs.Write(data) case .Err)
					LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath}");
			}

			mixin PutUInt(int num)
			{
				let uint = (uint32)num;
				uint8[4] data; // big endian
				data[0] = (uint8)((uint >> 24) & 0xFF);
				data[1] = (uint8)((uint >> 16) & 0xFF);
				data[2] = (uint8)((uint >> 8) & 0xFF);
				data[3] = (uint8)(uint & 0xFF);

				if (fs.Write(data) case .Err)
					LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath}");
			}

			PackageMode mode = .None;
			Put!(uint8[?](0x50, 0x4C, 0x50, mode.Underlying)); // Header & Mode
			PutUInt!(0); // Size placeholder

			// Write content hash
			var contentHash;
			let hashSpan = Span<uint8>(&contentHash.mHash[0], contentHash.mHash.Count);
			Put!(hashSpan);

			// Write importer strings
			PutUInt!(importerNames.Count);
			for (let s in importerNames)
			{
				PutUInt!(s.Length);
				let span = Span<uint8>((uint8*)s.Ptr, s.Length);
				Put!(span);
			}

			// Write nodes
			PutUInt!(nodes.Count);
			{
				DynMemStream uncompressed = scope .();
				List<uint8> uncompData = uncompressed.TakeOwnership();
				defer delete uncompData;

				List<uint8> compData = new .();
				defer delete compData;

				mixin PutUncomp(Span<uint8> data)
				{
					if (uncompressed.Write(data) case .Err)
						LogErrorReturn!("Couldn't write package. Error writing into uncompressed buffer");
				}

				mixin PutUncompUInt(int data)
				{
					let uint = (uint32)data;
					uint8[4] num; // big endian
					num[0] = (uint8)((uint >> 24) & 0xFF);
					num[1] = (uint8)((uint >> 16) & 0xFF);
					num[2] = (uint8)((uint >> 8) & 0xFF);
					num[3] = (uint8)(uint & 0xFF);

					if (uncompressed.Write(num) case .Err)
						LogErrorReturn!("Couldn't write package. Error writing into uncompressed buffer");
				}

				for (let node in nodes)
				{
					// Write things to compress
					let uncompSize = sizeof(uint32) * 3 + node.Name.Count + node.Data.Count;
					uncompData.Reserve(uncompSize);

					PutUncompUInt!(node.Importer);
					PutUncompUInt!(node.Name.Count);
					PutUncomp!(node.Name);
					PutUncompUInt!(node.Data.Count);
					PutUncomp!(node.Data);

					Debug.Assert(uncompData.Count == uncompSize);

					// Write uncompressed size & numChunks into file
					PutUInt!(uncompSize);
					let chunks = (int)Math.Ceiling((double)uncompSize / MAXCHUNK);
					PutUInt!(chunks);

					uint32 uncompReadStart = 0; // Reset position for reading
					uint32 compWriteStart = 0;
					let compReservedSize = uncompSize + sizeof(uint32) * chunks; // (maximum plausible size) Reserve original size of data + space for chunk size ints
					compData.Count += compReservedSize; // Grow uninitialized size so we can compress into it

					// Compress node in chunks
					var compSize = sizeof(uint32) * chunks; // (actual size we continue to compute) Also include size of chunk size ints, since this is the size of the whole array
					for (uint32 i = 0; i < chunks; i++)
					{
						uint32 compSizeIndex = compWriteStart; // Reserve space for chunk size
						compWriteStart += sizeof(uint32);

						uint32 chunkReadSize = (.)Math.Min(MAXCHUNK, uncompSize - uncompReadStart);

						/*let res = Compression.Compress(Span<uint8>(&uncompData[uncompReadStart], chunkReadSize), Span<uint8>(&compData[compWriteStart], compData.Count - compWriteStart));
						uint32 chunkWriteSize;
						switch (res)
						{
						case .Ok(let val):
							chunkWriteSize = (.)val;
							compSize += val;
						case .Err:
							LogErrorReturn!(scope $"Couldn't write package. Error compressing node data");
						}*/

						// @do temp
						Internal.MemCpy(&compData[compWriteStart], &uncompData[uncompReadStart], chunkReadSize);
						uint32 chunkWriteSize = chunkReadSize;
						compSize += chunkReadSize;

						// Increment read and write start for next chunk
						uncompReadStart += chunkReadSize;
						compWriteStart += chunkWriteSize;

						// Replace size placeholder (it's probably not worth it having a MemStream just for this)
						{
							let num = chunkWriteSize;
							compData[compSizeIndex] = (uint8)((num >> 24) & 0xFF);
							compData[compSizeIndex + 1] = (uint8)((num >> 16) & 0xFF);
							compData[compSizeIndex + 2] = (uint8)((num >> 8) & 0xFF);
							compData[compSizeIndex + 3] = (uint8)(num & 0xFF);
						}
					}

					compData.Count -= compReservedSize - compSize; // Remove unneeded reserved space

					Put!(compData);

					compData.Clear();
					uncompressed.Position = 0;
					uncompData.Clear();
				}
			}

			// Fill in size
			let size = fs.Position;
			fs.Seek(4);
			PutUInt!(size);

			if (fs.Close() case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath} when closing stream");

			return .Ok;
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

		static mixin GetScopedAssetName(StringView filePath, StringView assetsFolderPath, PackageData config, PackageData.ImportData import)
		{
			let s = scope:mixin String();
			if (import.name_prefix != null) s.Append(import.name_prefix);

			if (config.use_path_names) // Make it use the relative path with uniform forward slashes
				s.Append(Path.Unify(.. Path.GetRelativePath(filePath, assetsFolderPath, .. scope .())));
			else Path.GetFileNameWithoutExtension(filePath, s);
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

			String assetsFolderPath = null;
			if (packageData.use_path_names) // If we use relative path names as names, we need the path to make it relative to
			{
				Path.GetDirectoryPath(cPackageBuildFilePath, assetsFolderPath = new .());
				defer:: delete assetsFolderPath;
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

						if (Path.IsPathRooted(path))
							LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Path {path} must be a relative and direct path to items contained inside the asset folder");

						let fullPath = Path.Clean(.. Path.InternalCombineViews(.. scope String(), rootPath, path));

						if (fullPath.Contains("../") || fullPath.EndsWith("/..") || fullPath == "..")
							LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Path {path} must be a direct path to items contained inside the asset folder (without \"../)\"");

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
											let s = GetScopedAssetName!(enumeratePath, assetsFolderPath, packageData, import);
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
						let name = GetScopedAssetName!(filePath, assetsFolderPath, packageData, import);

						if (name.Length == 0)
						{
							Log.Warn($"Skipping asset at {filePath}. Files with empty file names will be ignored");
							continue;
						}

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

							// Add data
							if (patchIndex == -1)
							{
								// Add to node and duplicate lookup
								let nameData = new uint8[name.Length];
								Span<uint8>((uint8*)name.Ptr, name.Length).CopyTo(nameData);

								nodes.Add(Node((uint32)currentImporter, nameData, buildData));
							}
							else
							{
								delete nodes[patchIndex].Data; // Swap out

								// reuse Name (to not confuse our previousNames list)
								nodes[patchIndex] = Node((uint32)currentImporter, nodes[patchIndex].Name, buildData);
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
									node.Dispose();
									nodes.RemoveAtFast(i);
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
