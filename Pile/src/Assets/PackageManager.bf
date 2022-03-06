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

		static Result<void> ReadPackageConfigFile(StringView configPath, PackageConfig config)
		{
			// Read package file
			String jsonFile = scope String(512);
			if (File.ReadAllText(configPath, jsonFile) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't build package at {configPath}. Couldn't open file");

			Debug.Assert(config != null);
			var config; // We know that bon won't realloc anything here. Config is set and of the right type!
			if (Bon.Deserialize(ref config, jsonFile) case .Err)
				LogErrorReturn!(scope $"Couldn't build package at {configPath}. Error reading bon");

			// Check file structure
			if (config.importPasses == null)
				LogErrorReturn!(scope $"Couldn't build package at {configPath}. \"importPasses\" array has to be specified in root object");

			for (let imp in config.importPasses)
			{
				if (imp.targetDir == null || imp.importer == null)
					LogErrorReturn!(scope $"Couldn't build package at {configPath}. \"targetDir\" and \"importer\" has to be specified for every import pass");
			}

			return .Ok;
		}

		static mixin GetScopedAssetName(StringView filePath, StringView assetsFolderPath, bool noExtension = true)
		{
			let path = Path.GetRelativePath(filePath, assetsFolderPath, .. scope:mixin .(filePath.Length - assetsFolderPath.Length + 16));
			if (noExtension)
				Path.ChangeExtension(path, default, path);
			Path.Unify(path);
			path
		}

		static mixin FixExtensionsScoped(Span<StringView> extensions)
		{
			List<String> exts = scope:mixin .(extensions.Length);
			for (let ext in extensions)
			{
				String fileExt = scope:PASS .(ext.Length + 1);
				if (!ext.StartsWith('.'))
					fileExt.Append('.');
				fileExt.Append(ext);

				exts.Add(fileExt);
			}
			exts
		}

		static Result<void> ForFilesInDirRecursive(StringView path, Span<String> fileExtensions, StringView configFilePath, delegate void(FileFindEntry e, StringView path) onFile)
		{
			let importDirs = scope List<String>(8);
			importDirs.Add(scope String(path));

			let searchPath = scope String(260);
			let enumeratePath = scope String(260);
			repeat
			{
				let current = importDirs.Count - 1;
				String currImportDir = importDirs.Back;

				searchPath..Set(currImportDir).Append("/*");

				bool foundOne = false;
				for (let entry in Directory.Enumerate(searchPath, .Files | .Directories))
				{
					enumeratePath.Clear();
					entry.GetFilePath(enumeratePath);

					if (!entry.IsDirectory)
					{
						bool matchesExt = false;
						for (let ext in fileExtensions)
							if (enumeratePath.EndsWith(ext, .OrdinalIgnoreCase))
							{
								matchesExt = true;
								break;
							}

						if (matchesExt)
						{
							foundOne = true;
							onFile(entry, enumeratePath);
						}
					}
					else
						importDirs.Add(scope:: String(enumeratePath));
				}

				if (!foundOne)
					Log.Warn(scope $"No matching files found in '{searchPath}'");

				importDirs.RemoveAtFast(current);
			}
			while (importDirs.Count != 0);

			return .Ok;
		}

		public static Result<void> BuildPackage(StringView configFilePath, StringView outputFolderPath)
		{
			let t = scope Stopwatch(true);
			
			PackageConfig config = scope PackageConfig();
			Try!(ReadPackageConfigFile(configFilePath, config));

			let packageName = Path.GetFileNameWithoutExtension(configFilePath, .. scope .(64));
			let outputPath = Path.InternalCombine(.. scope .(outputFolderPath.Length + packageName.Length + 16), outputFolderPath, packageName);
			Path.ChangeExtension(outputPath, ".bin", outputPath);
			String inputPath = scope .(configFilePath.Length);
			Try!(Path.GetDirectoryPath(configFilePath, inputPath));

			// Does the package already exist?
			DateTime lastPackageBuildDate;
			SHA256Hash lastSourceHash;
			Stream packageStream = null;

			if (File.Exists(outputPath)
				&& (File.GetLastWriteTimeUtc(outputPath) case .Ok(out lastPackageBuildDate))
				&& (File.GetLastWriteTimeUtc(configFilePath) case .Ok(let lastConfigFileChange))
				&& lastConfigFileChange < lastPackageBuildDate) // We already built with this config!
			{
				// Salvage data from the existing package (don't need to recompute what didn't change)
				packageStream = PackageFormat.OpenPackageScoped!::(outputPath);

				lastSourceHash = default;

				// TODO:
				// load index
				// put names of things contained in a hashSet
				// -> if the file didn't change after lastBuildDate and we have data from it here... it's fine
				// also worry about when to check what the importer wants... some passes need to be redone when some
				// dependant files changed!
				// set lastSourceHash
			}
			else
			{
				lastSourceHash = .();
				lastPackageBuildDate = default;
			}

			List<(Importer impoter, List<(String path, bool modified)> targets)> passSets = scope .(8);
			defer
			{
				for (let passSet in passSets)
					for (let target in passSet.targets)
						delete target.path;
			}

			// Hash every file that can affect the importers
			SHA256 hashBuilder = scope .();
			bool sourceWasModified = false;
			for (let pass in config.importPasses) PASS:
			{
				if (pass.targetDir.Length == 0)
					continue;

				// Try to find importer
				Importer importer;
				if (!Importer.importers.TryGetValue(pass.importer, out importer))
					LogErrorReturn!(scope $"Couldn't build package at {configFilePath}. Couldn't find importer '{pass.importer}'");

				List<(String path, bool modified)> targets = scope:: .(16);
				bool targetsStored = false;
				defer
				{
					// In case we return before puttin this in passSets
					if (!targetsStored)
					{
						for (let target in targets)
							delete target.path;
					}	
				}

				let targetPath = Path.Clean(.. Path.GetAbsolutePath(inputPath, pass.targetDir..Trim(), .. scope .(inputPath.Length + pass.targetDir.Length)));
				let dependPath = pass.dependDir == null ? targetPath : Path.Clean(.. Path.GetAbsolutePath(inputPath, pass.dependDir..Trim(), .. scope .(inputPath.Length + pass.dependDir.Length)));

				let targetExts = FixExtensionsScoped!(importer.TargetExtensions);

				Try!(ForFilesInDirRecursive(targetPath, targetExts, configFilePath, scope (entry, path) =>
					{
						let relativePath = GetScopedAssetName!(path, inputPath, false);
						hashBuilder.Update(.((.)&relativePath[0], relativePath.Length));

						// TODO: only add when
						// 1) prev build doesnt exist
						// 2) ... doesnt have it
						// 3) it was modified since -> sourceWasModified !! (also set the current true thing below)
						// also (if prev build exists and has it) remove this from
						// that lookup! --> rest has since been REMOVED

						targets.Add((new .(path), true));
					}));

				// Pass has no effect
				if (targets.Count == 0)
					continue;

				if (dependPath != targetPath)
				{
					let dependExts = FixExtensionsScoped!(importer.DependantExtensions);

					Try!(ForFilesInDirRecursive(targetPath, dependExts, configFilePath, scope (entry, path) =>
						{
							// Also hash these since they potentially affect importer behavior
							let relativePath = GetScopedAssetName!(path, inputPath, false);
							hashBuilder.Update(.((.)&relativePath[0], relativePath.Length));

							// TODO: if this was since modified
							// -> sourceWasModified = true;
						}));
				}

				passSets.Add((importer, targets));
				targetsStored = true; // Don't delete the list contents we just submitted
			}

			if (passSets.Count == 0)
				LogErrorReturn!(scope $"Couldn't build package at {configFilePath}. Package has no content");

			let sourceHash = hashBuilder.Finish();
			if (!sourceWasModified
				&& lastSourceHash != default // on older package exists!
				&& sourceHash == lastSourceHash)
			{
				return .Ok;
			}

			// gather all info List<PackageFormat.BuildPass>
			// -> load what we can from old file if possible
			// -> build the rest with importers
			// -> remove old files / passes / importers!
			// ---- actually- we will automatically remove them because
			//      when they're not in the pass's importTargetPaths, they
			//      won't even get looked at again!
			// TODO: duplicate name lookup-- things might be in the same folder and have the same extension
			// for some reason- which we remove in the asset name! (maybe do this earlier?)
			// -> already during iteration! -> should be a package-global lookup anyway!

			for (let passSet in passSets)
			{

				for (let target in passSet.targets)
				{
					if (!target.modified)
					{
						// Look in last package if possible
					}

					// build stuff!

					// submit data to buildIndex structure list thing!
				}
			}

			// write full new file

			t.Stop();
			Log.Info(scope $"Built package {packageName}; took {t.ElapsedMilliseconds}ms");

			return .Ok;
		}

		// String assetsFolderPath = Path.GetDirectoryPath(configFilePath, .. scope .(configFilePath.Length));

		/// If force is false, the package will only be built if there is no file at outPath or the package source changed and patched otherwise
		/*public static Result<void> BuildPackage(StringView configFilePath, StringView outputFolderPath)
		{
			let t = scope Stopwatch(true);

			let checkedConfigPath = Path.Clean(configFilePath, .. scope .(configFilePath.Length));
			
			PackageConfig packageData = scope PackageConfig();
			Try!(ReadPackageConfigFile(checkedConfigPath, packageData));








			// Package data
			List<PackageFormat.BuildPass> passes = scope .(8);
			List<String> importerNames = scope .(8);

			// Prepare paths
			String assetsFolderPath = Path.GetDirectoryPath(checkedConfigPath, .. scope .(checkedConfigPath.Length));
			let packageName = Path.GetFileNameWithoutExtension(checkedConfigPath, .. scope .(64));
			let outputPath = Path.Clean(.. Path.InternalCombine(.. scope .(outputFolderPath.Length + packageName.Length + 32), outputFolderPath, packageName));
			Path.ChangeExtension(outputPath, ".bin", outputPath);

			SHA256Hash contentHash;
			SHA256Hash lastContentHash;
			bool somethingChanged = false;

			

			// Resolve imports and build
			BUILD:
			{
				HashSet<String> duplicateNameLookup = scope HashSet<String>(32);

				HashSet<StringView> previousNames = scope HashSet<StringView>(32); // All names of the last package content (only used in rebuild)
				List<String> includePaths = scope List<String>(32); // All of these paths exist
				List<StringView> importPaths = scope List<StringView>(32); // All of these paths exist AND need to be imported again because of changes or additions

				// Check if we need to do a full build or can do a patch
				/*DateTime lastPackageBuildDate;
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
				}*/

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
		}*/

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
