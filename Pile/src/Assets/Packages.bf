using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Collections;
using System.Diagnostics;
using System.Security.Cryptography;
using Bon;

using internal Pile;

namespace Pile
{
#if !DEBUG
	[Optimize]
#endif
	static class Packages
	{
		// TODO:
		// -> so... methods to read the index, do things with it, methods to load some collection of entries
		// patched by either fitting the new data into the old slot (keep it in there as long as possible) or just
		// appending it to the end and updating the index! -- both set the patched flag on file
		// -> hot reload is fast, next full run will clean it up and do a full rebuild (probably nicer for workflow)

		// HEADER (3 bytes)
		// VERSION (1 byte)
		// FLAGS (1 byte) (like patched: which says that this includes dead data and should be rebuild on next proper launch)
		// SOURCE_HASH (32 bytes)
		// INDEX_OFFSET (8 bytes, uint64)

		// CONTENT (?)

		// PASS_ENTRY_COUNT (2 bytes, uint16)
		// PASS_ENTRY[]
		//   ENTRY:
		//     IMPORTER_NAME_LENGTH (2 bytes, uint16)
		//     IMPORTER_NAME[]
		//     IMPORTER_CONFIG_LENGTH (2 bytes, uint16)
		//     IMPORTER_CONFIG[]
		//     CONTENT_ENTRY_COUNT (4 bytes, uint32)
		//     CONTENT_ENTRY[]
		//       ENTRY:
		//       NAME_LENGTH (2 bytes, uint16 - most significant bit signals "data_patched")
		//       NAME[]
		//       OFFSET (8 bytes, uint64)
		//       LENGTH (8 bytes, uint64)
		//       SLOT_SIZE (8 bytes, uint64) -- only if "data_patched"

		// FILE_SIZE (8 bytes, uint64)

		// Represents the json data in the package import file
		[BonTarget]
		internal class PackageSpec
		{
			public List<ImportPass> importPasses ~ if (_ != null) DeleteContainerAndDisposeItems!(_);

			[BonTarget]
			internal struct ImportPass : IDisposable
			{
				public String targetDir;
				public String importer;
				public String config;

				public void Dispose()
				{
					DeleteNotNull!(targetDir);
					DeleteNotNull!(importer);
					DeleteNotNull!(config);
				}
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
			//		IMPORTERNAMEINDEX (uint32)
			// 		NAMELENGTH (uint32)
			// 		NAMEDATA[]
			// 		DATALENGTH (uint32)
			// 		DATAARRAY[]

			Serializer sr = scope .(fs);

			let header = sr.ReadInto!(scope uint8[4]());
			if (header[0] != 0x50 || header[1] != 0x4C || header[2] != 0x50) // Check file header (currently we ignore "mode" at header[3])
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Invalid file format");

			let size = sr.Read<uint32>(); // File size

			// Read content hash
			sr.ReadInto!(contentHash.mHash);

			// Read file body
			{
				let ds = scope CompressionStream(fs, .Decompress);
				sr.underlyingStream = ds;

				// Read importer names
				let importerNameCount = sr.Read<uint32>();
				for (uint32 i = 0; i < importerNameCount; i++)
				{
					let importerNameLength = sr.Read<uint32>();

					let nameString = new String(importerNameLength)..PrepareBuffer(importerNameLength);
					sr.ReadInto!(Span<uint8>((uint8*)nameString.Ptr, importerNameLength));

					importerNames.Add(nameString);
				}

				// Read nodes
				let nodeCount = sr.Read<uint32>();
				for (uint32 i = 0; i < nodeCount; i++)
				{
					let importerIndex = sr.Read<uint32>();

					let nameLength = sr.Read<uint32>();
					let name = sr.ReadInto!(new uint8[nameLength]);

					let dataLength = sr.Read<uint32>();
					let data = sr.ReadInto!(new uint8[dataLength]);

					nodes.Add(Node(importerIndex, name, data));
				}
			}

			if (sr.HadError)
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Error reading from file");

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
			//		IMPORTERNAMEINDEX (uint32)
			// 		NAMELENGTH (uint32)
			// 		NAMEDATA[]
			// 		DATALENGTH (uint32)
			// 		DATAARRAY[]

			Serializer sr = scope .(fs);

			PackageMode mode = .None;
			sr.Write!(uint8[?](0x50, 0x4C, 0x50, mode.Underlying)); // Header & Mode
			sr.Write<uint32>(0); // Size placeholder

			// Write content hash
			var contentHash;
			let hashSpan = Span<uint8>(&contentHash.mHash[0], contentHash.mHash.Count);
			sr.Write!(hashSpan);

			// Compress this block (main file content)
			{
				let cs = scope CompressionStream(fs, .BEST_SPEED);
				sr.underlyingStream = cs;
	
				// Write importer strings
				sr.Write<uint32>((.)importerNames.Count);
				for (let s in importerNames)
				{
					sr.Write<uint32>((.)s.Length);
					let span = Span<uint8>((uint8*)s.Ptr, s.Length);
					sr.Write!(span);
				}
	
				// Write nodes
				sr.Write<uint32>((.)nodes.Count);
				for (let node in nodes)
				{
					sr.Write<uint32>(node.Importer);
					sr.Write<uint32>((.)node.Name.Count);
					sr.Write!(node.Name);
					sr.Write<uint32>((.)node.Data.Count);
					sr.Write!(node.Data);
				}

				if (cs.Close() case .Err)
					LogErrorReturn!(scope $"Couldn't write package. Error flushing compressionStream into file");
			}

			// Fill in size
			let size = fs.Position;
			fs.Seek(4);

			sr.underlyingStream = fs;
			sr.Write<uint32>((.)size);

			if (sr.HadError)
				LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath}");

			if (fs.Close() case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath} when closing stream");

			return .Ok;
		}

		static Result<void> ReadPackageBuildFile(StringView cPackageBuildFilePath, PackageSpec packageData)
		{
			// Read package file
			String jsonFile = scope String();
			if (File.ReadAllText(cPackageBuildFilePath, jsonFile) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath} because the file could not be opened");

			var packageData;
			if (Bon.Deserialize(ref packageData, jsonFile) case .Err)
				LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error reading json");

			if (packageData.importPasses == null)
				LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. \"imports\" array has to be specified in root object");

			for (let imp in packageData.importPasses)
			{
				if (imp.targetDir == null || imp.importer == null)
					LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. \"path\" and \"importer\" has to be specified for every import statement");
			}

			return .Ok;
		}

		static mixin GetScopedAssetName(StringView filePath, StringView assetsFolderPath, PackageSpec config, PackageSpec.ImportPass import)
		{
			let s = scope:mixin String();
			if (import.name_prefix != null) s.Append(import.name_prefix);

			if (config.use_path_names) // Make it use the relative path with uniform forward slashes
				s.Append(Path.Unify(.. Path.GetRelativePath(filePath, assetsFolderPath, .. scope .())));
			else Path.GetFileNameWithoutExtension(filePath, s);
			s
		}

		static Result<void> GetFilesFromPathsRec(StringView rootPath, StringView cPackageBuildFilePath, StringView paths, delegate void(FileFindEntry e, StringView path) onFile)
		{
			for (var path in paths.Split(';'))
			{
				path.Trim();

				if (Path.IsPathRooted(path))
					LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Path {path} must be a relative and direct path to items contained inside the asset folder");

				let fullPath = Path.Clean(.. Path.InternalCombine(.. scope String(), rootPath, path));

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
									onFile(entry, enumeratePath);
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

			return .Ok;
		}

		/// If force is false, the package will only be built if there is no file at outPath or the package source changed and patched otherwise
		public static Result<void> BuildPackage(StringView packageBuildFilePath, StringView outputFolderPath, bool force = false)
		{
			let t = scope Stopwatch(true);
			PackageSpec packageData = scope PackageSpec();

			let cPackageBuildFilePath = Path.Clean(packageBuildFilePath, .. scope .());
			if (ReadPackageBuildFile(cPackageBuildFilePath, packageData) case .Err)
				return .Err;

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
			let outputPath = Path.Clean(.. Path.InternalCombine(.. scope String(), outputFolderPath, packageName));
			Path.ChangeExtension(outputPath, ".bin", outputPath);

			// Resolve imports and build
			SHA256Hash contentHash;
			SHA256Hash lastContentHash;
			bool somethingChanged = false;
			BUILD:
			{
				HashSet<String> duplicateNameLookup = scope HashSet<String>();

				HashSet<StringView> previousNames = scope HashSet<StringView>(); // All names of the last package content (only used in rebuild)
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

				let rootPath = scope String();
				Try!(Path.GetDirectoryPath(cPackageBuildFilePath, rootPath));

				// Build hash from all names
				SHA256 hashBuilder = scope .();

				// Check additional files
				bool additionalChanged = false; // If we are doing a full build, this will not matter (only forces imports on change, but we do that anyway here)
				if (packageData.additionals != null)
				{
					for (let incl in packageData.additionals)
					{
						Try!(GetFilesFromPathsRec(rootPath, cPackageBuildFilePath, incl, scope [&](entry, path) =>
							{
								// Hash name always
								let s = scope String();
								Path.GetFileNameWithoutExtension(path, s);
								hashBuilder.Update(Span<uint8>((uint8*)s.Ptr, s.Length));

								// If we are patching and an additional file has changed, some importers
								// may want to rebuild in response
								if (patchBuild && entry.GetLastWriteTimeUtc() > lastPackageBuildDate)
									additionalChanged = true;
							}));
					}
				}

				for (let import in packageData.importPasses)
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
					Try!(GetFilesFromPathsRec(rootPath, cPackageBuildFilePath, import.targetDir, scope [&](entry, path) =>
						{
							// Hash name
							let s = GetScopedAssetName!(path, assetsFolderPath, packageData, import);
							hashBuilder.Update(Span<uint8>((uint8*)s.Ptr, s.Length));

							let includeFilePath = new String(path);
							includePaths.Add(includeFilePath);

							// If we need to import this file (if this is a full build, the file was changed, or its new)
							if (!patchBuild || entry.GetLastWriteTimeUtc() > lastPackageBuildDate || !previousNames.Contains(s)
								|| additionalChanged && importer.RebuildOnAdditionalChanged)
								importPaths.Add(includeFilePath);
						}));

					// If anything changed this import statement, we know that we WILL build
					// somethingChanged is already true if !patchBuild
					if (!somethingChanged && importPaths.Count > 0)
						somethingChanged = true;

					// The following loop might return, do defer this here so it really deletes the strings in any case!
					defer
					{
						ClearAndDeleteItems!(includePaths);
					}

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
						if (duplicateNameLookup.Contains(scope String(name)..ToLower()))
							LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error importing file at {filePath}: Entry with name {name} has already been imported.\n\tConsider using \"name_prefix\". Note that names are compared with OrdinalIgnoreCase. Alternatively consider changing the package's \"path\" to exclude that file");

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
									if (StringView((char8*)node.Name.Ptr, node.Name.Count) == name)
									{
										patchIndex = i;
										break;
									}
								}
							}

							Log.Debug($"Importing {filePath}");

							// Read file
							let fs = scope FileStream();
							if (fs.Open(filePath, .Read) case .Err(let err))
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
							let ress = importer.Build(fs, config, filePath);
							if (ress case .Err)
								LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Importer error importing file at {filePath} with {import.importer}");
							uint8[] buildData = ress.Get();
							if (buildData == null)
								LogErrorReturn!(scope $"Couldn't build package at {cPackageBuildFilePath}. Error importing file at {filePath} with {import.importer}: Data returned is null");
							else if (buildData.Count <= 0)
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
						duplicateNameLookup.Add(scope:BUILD String(name)..ToLower());
					}
					importPaths.Clear();

					if (importerUsed && currentImporter == importerNames.Count) // The importer doesnt already have an index
						importerNames.Add(new String(import.importer));
				}

				// Remove nodes
				if (patchBuild)
				{
					for (let prevName in previousNames)
						if (!duplicateNameLookup.Contains(scope String(prevName)..ToLower()))
						{
							Log.Debug($"Removing {prevName}");

							for (var i < nodes.Count)
							{
								let node = ref nodes[i];
								if (StringView((char8*)node.Name.Ptr, node.Name.Count) == prevName)
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
