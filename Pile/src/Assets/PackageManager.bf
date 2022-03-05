using System;
using System.IO;
using System.Collections;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Security.Cryptography;
using Bon;

using internal Pile;

namespace Pile
{
	static class PackageManager
	{
		// TODO: it would be nice if libraries could declare packages of their own!
		// --> multiple asset source dirs? -- but how
		// --> alternatively with.. either comptime included packages... no OR a manual reg. setup (...)?

		// make it easier to interface with Assets, make it usable for SpriteFont -- make textureFilter settable from importers actually
		// separate package load & hot reload stuff from resource management? -- maybe packageManager/packager all together?
		// -> packager packageBuilder & the other will be PackageLoader

		/// Set in static init!
		internal static String relativeAssetsPath = @"../../../assets";

		// Used for package hot reload
		internal static mixin MakeScopedAssetsSourcePath()
		{
			String assetsPath = scope:mixin .();

			let dirPath = scope String();
			if (Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope String()), dirPath) case .Ok)
			{
				assetsPath.Append(Path.GetAbsolutePath(relativeAssetsPath, dirPath, .. scope String()));
			}

			assetsPath
		}

		[Optimize]
		internal static Result<void> BuildAndPackageAssets() // TODO: update mentions of Packager!
		{
#if DEBUG
			const bool FORCE = false;
#else
			// Force full package build in release (to have a fresh build and not carry over possible artifacts of patching)
			const bool FORCE = true;
#endif
			String inPath = scope .();
			String outPath = scope .();
			{
				let dirPath = scope String();
				if (Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope String()), dirPath) case .Ok)
				{
					let assetsPath = Path.GetAbsolutePath(relativeAssetsPath, dirPath, .. scope String());

					// If the usual dir doesnt exist... try args
					if (!Directory.Exists(assetsPath))
					{
						if (Core.CommandLine.Count > 1)
						{
							if (Path.IsPathRooted(Core.CommandLine[1]))
								assetsPath.Set(Core.CommandLine[1]);
							else
							{
								assetsPath.Clear();
								Path.GetAbsolutePath(Core.CommandLine[1], dirPath, assetsPath);
							}
						}

						if (!Directory.Exists(assetsPath))
						{
							Log.Warn("Assets folder couldn't be found in workspace.");
							return .Ok;
						}
					}

					inPath.Append(assetsPath);
					outPath.Append(Path.InternalCombine(.. scope String(dirPath), @"packages"));
				}
			}

			if (!Directory.Exists(inPath))
			{
				Log.Info(scope $"No packages to build. {inPath} doesn't exist");
				return .Ok;
			}

			if (!Directory.Exists(outPath) && (Directory.CreateDirectory(outPath) case .Err(let err)))
				LogErrorReturn!(scope $"Failed to create package output path {outPath}");

			let tasks = scope List<PackageBuildTask>();

			// Start tasks
			for (let file in Directory.EnumerateFiles(inPath))
			{
				// Identify file
				let path = file.GetFilePath(.. scope String());

				if (!path.EndsWith(".package.bon")) continue;

				// Add these as PackageBuildTask, because we need the details passed in to log errors later on
				tasks.Add(BuildPackageAsync(path, outPath, FORCE) as PackageBuildTask);
			}

			if (tasks.Count == 0)
			{
				Log.Info(scope $"No packages to build");
				return .Ok;
			}

			// Wait for tasks to end
			while (tasks.Count > 0)
			{
				for (int i < tasks.Count)
				{
					let task = tasks[i];
					if(task.IsCompleted)
					{
						if (!task.GetAwaiter().GetResult())
							Log.Warn(scope $"Failed building package {task.[Friend]packageBuildFilePath}. Skipping");

						// Remove task
						tasks.RemoveAtFast(i--);
						delete task;
					}
				}
			}

			return .Ok;
		}

		// Represents the bon data in the package import file
		[BonTarget]
		internal class PackageConfig
		{
			public List<ImportPass> importPasses ~ if (_ != null) DeleteContainerAndDisposeItems!(_);

			[BonTarget]
			internal struct ImportPass : IDisposable
			{
				public String targetDir;
				public String dependDir;
				public String importer;
				public String config;

				public void Dispose()
				{
					DeleteNotNull!(targetDir);
					DeleteNotNull!(dependDir);
					DeleteNotNull!(importer);
					DeleteNotNull!(config);
				}
			}
		}

		static Result<void> ReadPackageConfigFile(StringView checkConfigPath, PackageConfig packageData)
		{
			// Read package file
			String jsonFile = scope String();
			if (File.ReadAllText(checkConfigPath, jsonFile) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {checkConfigPath}. Couldn't open file");

			var packageData;
			if (Bon.Deserialize(ref packageData, jsonFile) case .Err)
				LogErrorReturn!(scope $"Couldn't build package at {checkConfigPath}. Error reading bon");

			// Check file structure
			if (packageData.importPasses == null)
				LogErrorReturn!(scope $"Couldn't build package at {checkConfigPath}. \"importPasses\" array has to be specified in root object");

			for (let imp in packageData.importPasses)
			{
				if (imp.targetDir == null || imp.importer == null)
					LogErrorReturn!(scope $"Couldn't build package at {checkConfigPath}. \"targetDir\" and \"importer\" has to be specified for every import pass");
			}

			return .Ok;
		}

		static mixin GetScopedAssetName(StringView filePath, StringView assetsFolderPath)
		{
			Path.Unify(.. Path.GetRelativePath(filePath, assetsFolderPath, .. scope:mixin .()))
		}

		static Result<void> GetFilesInDirRecursive(StringView rootPath, StringView checkedConfigPath, StringView paths, delegate void(FileFindEntry e, StringView path) onFile)
		{
			for (var path in paths.Split(';'))
			{
				path.Trim();

				if (Path.IsPathRooted(path))
					LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Path {path} must be a relative and direct path to items contained inside the asset folder");

				let fullPath = Path.Clean(.. Path.InternalCombine(.. scope String(rootPath.Length + path.Length), rootPath, path));

				if (fullPath.Contains("../") || fullPath.EndsWith("/..") || fullPath == "..")
					LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Path {path} must be a direct path to items contained inside the asset folder (without \"../)\"");

				// Check if containing folder exists
				let dirPath = scope String();
				if ((Path.GetDirectoryPath(fullPath, dirPath) case .Err) || !Directory.Exists(dirPath))
					LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Failed to find containing directory of {path}");

				// Import everything that matches
				SEARCH:
				{
					let wildCard = Path.GetFileName(fullPath, .. scope String(fullPath.Length / 2));

					let importDirs = scope List<String>(8);
					importDirs.Add(scope:SEARCH String(dirPath));

					String currImportPath;
					let enumeratePath = scope String(260);
					let searchPath = scope String(260);
					let wildCardPath = scope String(260);
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
		public static Result<void> BuildPackage(StringView configFilePath, StringView outputFolderPath, bool force = false)
		{
			let t = scope Stopwatch(true);
			PackageConfig packageData = scope PackageConfig();

			let checkedConfigPath = Path.Clean(configFilePath, .. scope .(configFilePath.Length));

			Try!(ReadPackageConfigFile(checkedConfigPath, packageData));

			// For making paths relative to asset forlder root
			String assetsFolderPath = Path.GetDirectoryPath(checkedConfigPath, .. scope .(checkedConfigPath.Length));

			// Package data
			List<Entry> nodes = new List<Entry>(32);
			List<String> importerNames = new List<String>(8);

			defer
			{
				DeleteContainerAndItems!(importerNames);
				for (let n in nodes)
					n.Dispose();
				delete nodes;
			}

			// Prepare paths
			let packageName = Path.GetFileNameWithoutExtension(checkedConfigPath, .. scope String());
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
					&& (File.GetLastWriteTimeUtc(checkedConfigPath) case .Ok(let lastBuildFileChange)) // Get last build file change time
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
				Try!(Path.GetDirectoryPath(checkedConfigPath, rootPath));

				// Build hash from all names
				SHA256 hashBuilder = scope .();

				// Check additional files
				bool additionalChanged = false; // If we are doing a full build, this will not matter (only forces imports on change, but we do that anyway here)
				if (packageData.additionals != null)
				{
					for (let incl in packageData.additionals)
					{
						Try!(GetFilesInDirRecursive(rootPath, checkedConfigPath, incl, scope [&](entry, path) =>
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
					else LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Couldn't find importer '{import.importer}'");

					// Get index in importerNames array
					int currentImporter = importerNames.Count; // Default for when it will be added later
					{
						let foundImporter = importerNames.IndexOf(import.importer);
						if (foundImporter != -1)
							currentImporter = foundImporter;
					}

					// Interpret path string (put all final paths in importPaths)
					Try!(GetFilesInDirRecursive(rootPath, checkedConfigPath, import.targetDir, scope [&](entry, path) =>
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
							LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Error importing file at {filePath}: Entry with name {name} has already been imported.\n\tConsider using \"name_prefix\". Note that names are compared with OrdinalIgnoreCase. Alternatively consider changing the package's \"path\" to exclude that file");

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
								LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Error reading file at {filePath} with {import.importer}: {err}");

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
								LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Importer error importing file at {filePath} with {import.importer}");
							uint8[] buildData = ress.Get();
							if (buildData == null)
								LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Error importing file at {filePath} with {import.importer}: Data returned is null");
							else if (buildData.Count <= 0)
							{
								delete buildData;
								LogErrorReturn!(scope $"Couldn't build package at {checkedConfigPath}. Error importing file at {filePath} with {import.importer}: Length of returned data cannot be 0");
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
				m_result = BuildPackage(packageBuildFilePath, outputFolderPath, force) case .Ok;
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
