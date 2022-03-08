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
	internal static class Packager
	{
		// TODO: it would be nice if libraries could declare packages of their own!
		// --> multiple asset source dirs? -- but how

		// make it easier to interface with Assets, make it usable for SpriteFont -- make textureFilter settable from importers actually
		// separate package load & hot reload stuff from resource management? -- maybe packageManager/packager all together?
		// -> packager packageBuilder & the other will be PackageLoader

		// TODO: package compression

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
		internal static Result<void> BuildAndPackageAssets()
		{
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
				tasks.Add(BuildPackageAsync(path, outPath) as PackageBuildTask);
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
							Log.Warn(scope $"Failed building package {task.[Friend]configPath}. Skipping");

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

				switch (fileExt)
				{
				case ".bon", "", ".":
					Log.Warn(scope $"Importer wants file extension '{fileExt}' - which we ignore! This will likely cause problems, choose a more specific file ending!");
					continue;
				}

				exts.Add(fileExt);
			}
			exts
		}

		static Result<void> ForFilesInDirRecursive(StringView path, Span<String> fileExtensions, delegate void(FileFindEntry e, StringView path) onFile)
		{
			let importDirs = scope List<String>(8);
			importDirs.Add(scope String(path));

			let searchPath = scope String(260);
			let enumeratePath = scope String(260);
			bool foundOne = false;
			repeat
			{
				let current = importDirs.Count - 1;
				String currImportDir = importDirs.Back;

				searchPath..Set(currImportDir).Append("/*");

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

				importDirs.RemoveAtFast(current);
			}
			while (importDirs.Count != 0);
			
			if (!foundOne)
				Log.Warn(scope $"No matching files found in '{path}'");

			return .Ok;
		}

		public static Result<void> BuildPackage(StringView configFilePath, StringView outputFolderPath)
		{
			let t = scope Stopwatch(true);
			
			PackageConfig config = scope PackageConfig();
			Try!(ReadPackageConfigFile(configFilePath, config));

			let packageName = Path.GetFileNameWithoutExtension(configFilePath, .. scope .(64));
			Debug.Assert(packageName.EndsWith(".package"));
			packageName.RemoveFromEnd(8);

			let outputPath = Path.InternalCombine(.. scope .(outputFolderPath.Length + packageName.Length + 16), outputFolderPath, packageName);
			Path.ChangeExtension(outputPath, ".bin", outputPath);
			String inputPath = scope .(configFilePath.Length);
			Try!(Path.GetDirectoryPath(configFilePath, inputPath));

			// Does the package already exist?
			DateTime oldPackageBuildDate = default;
			SHA256Hash oldSourceHash = default;
			FileStream oldPackageStream = null;
			uint64 oldPackageStartPos = 0, oldPackageIndexPos = 0, oldPackageFileSize = 0;
			PackageFormat.PackageFlags oldPackageFlags = default;

			// Patch from older package when it exists and was build with
			// the same config. Later we check to only use the entries that
			// didn't change...
			// If the source didn't change, we can just leave this package as-is!
			if (File.Exists(outputPath)
				&& (File.GetLastWriteTimeUtc(outputPath) case .Ok(out oldPackageBuildDate))
				&& (File.GetLastWriteTimeUtc(configFilePath) case .Ok(let oldConfigFileChange))
				&& oldConfigFileChange < oldPackageBuildDate) // We already built with this config!
			{
				// Salvage data from the existing package (don't need to recompute what didn't change)
				if ((PackageFormat.OpenPackage(outputPath, oldPackageStream = scope:: .()) case .Err)
					|| PackageFormat.ReadPackageHeader(oldPackageStream, out oldPackageFlags, out oldSourceHash, out oldPackageStartPos, out oldPackageFileSize, out oldPackageIndexPos) case .Err)
				{
					oldPackageStream.Close(); // We're just reading.. this should never return .Err!
					oldPackageStream = null;
				}
			}
			
			List<(Importer importer, String importerConfig, bool dependModified, List<(String path, bool modified)> targets)> passSets = scope .(8);
			defer
			{
				for (let passSet in passSets)
				{
					for (let target in passSet.targets)
						delete target.path;
					delete passSet.targets;
				}
			}

			// Hash every file that can affect the importers
			SHA256 hashBuilder = scope .();
			{
				HashSet<String> duplicateNameLookup = scope .(32);
				defer
				{
					for (let name in duplicateNameLookup)
						delete name;
				}

				for (let pass in config.importPasses) PASS:
				{
					if (pass.targetDir.Length == 0)
						continue;

					// Try to find importer
					Importer importer;
					if (!Importer.importers.TryGetValue(pass.importer, out importer))
						LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Couldn't find importer '{pass.importer}'");

					List<(String path, bool modified)> targets = new .(16);
					bool targetsStored = false;
					defer
					{
						// In case we return before putting this in passSets
						if (!targetsStored)
						{
							for (let target in targets)
								delete target.path;
							delete targets;
						}	
					}

					let targetPath = Path.Clean(.. Path.GetAbsolutePath(pass.targetDir..Trim(), inputPath, .. scope .(Math.Min(260, inputPath.Length + pass.targetDir.Length))));
					let dependPath = pass.dependDir == null ? targetPath : Path.Clean(.. Path.GetAbsolutePath(pass.dependDir..Trim(), inputPath, .. scope .(Math.Min(260, inputPath.Length + pass.dependDir.Length))));

					let targetExts = FixExtensionsScoped!(importer.TargetExtensions);

					Try!(ForFilesInDirRecursive(targetPath, targetExts, scope (entry, path) =>
						{
							let relativePath = GetScopedAssetName!(path, inputPath, false);
							hashBuilder.Update(.((.)&relativePath[0], relativePath.Length));

							// Remove extension (because now we add it to the lookup)
							Path.ChangeExtension(relativePath, default, relativePath);

							if (relativePath.EndsWith('/'))
							{
								Log.Warn(scope $"Skipping file at '{path}'. Cannot target files with empty names");
								return;
							}

							if (duplicateNameLookup.Contains(relativePath))
							{
								Log.Warn(scope $"Skipping file at '{path}'. File with asset name '{relativePath}' already exists");
								return;
							}

							duplicateNameLookup.Add(new .(relativePath));

							bool wasModifiedSinceLastBuild = false;
							if (oldPackageStream == null
								|| entry.GetLastWriteTimeUtc() >= oldPackageBuildDate)
								wasModifiedSinceLastBuild = true;

							if (!wasModifiedSinceLastBuild)
							{
								let metaFilePath = Importer.[Friend]ToScopedMetaFilePath!(path);
								if (metaFilePath != path && File.Exists(metaFilePath)
									&& (oldPackageStream == null
									|| File.GetLastWriteTimeUtc(metaFilePath) >= oldPackageBuildDate))
									wasModifiedSinceLastBuild = true;
							}

							targets.Add((new .(path), wasModifiedSinceLastBuild));
						}));

					// Pass has no effect
					if (targets.Count == 0)
						continue;

					bool dependModified = false;
					if (dependPath != targetPath
						&& importer.DependantExtensions.Length > 0)
					{
						let dependExts = FixExtensionsScoped!(importer.DependantExtensions);

						Try!(ForFilesInDirRecursive(targetPath, dependExts, scope [&dependModified,&hashBuilder,&inputPath,&oldPackageStream,&oldPackageBuildDate](entry, path) =>
							{
								// Also hash these since they potentially affect importer behavior
								let relativePath = GetScopedAssetName!(path, inputPath, false);
								hashBuilder.Update(.((.)&relativePath[0], relativePath.Length));

								if (!dependModified)
								{
									if (oldPackageStream == null
										|| entry.GetLastWriteTimeUtc() >= oldPackageBuildDate)
										dependModified = true;

									let metaFilePath = Importer.[Friend]ToScopedMetaFilePath!(path);
									if (metaFilePath != path && File.Exists(metaFilePath)
										&& (oldPackageStream == null
										|| File.GetLastWriteTimeUtc(metaFilePath) >= oldPackageBuildDate))
										dependModified = true;
								}
							}));
					}

					passSets.Add((importer, pass.config, dependModified, targets));
					targetsStored = true; // Don't delete the list contents we just submitted
				}

				if (passSets.Count == 0)
					LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Package has no content");
			}

			let sourceHash = hashBuilder.Finish();
			bool sourceChanged = false;
			CHANGE_CHECK:
			for (let passSet in passSets)
			{
				if (passSet.dependModified)
				{
					sourceChanged = true;
					break;
				}

				for (let target in passSet.targets)
					if (target.modified)
					{
						sourceChanged = true;
						break CHANGE_CHECK;
					}
			}

			if (!sourceChanged
				&& oldPackageStream != null
				&& sourceHash == oldSourceHash)
			{
				t.Stop();
				Log.Info(scope $"Package '{packageName}' didn't change; took {t.ElapsedMilliseconds}ms");
				return .Ok;
			}

			PackageFormat.Index oldPackageFileIndex = null;
			if (oldPackageStream != null)
			{
				oldPackageFileIndex = scope:: .();

				if (PackageFormat.ReadPackageIndex(oldPackageStream, oldPackageIndexPos, oldPackageStartPos, oldPackageFileSize, oldPackageFlags, oldPackageFileIndex) case .Err)
					oldPackageFileIndex = null; // Then... don't
			}

			let newPackagePath = scope String(outputPath.Length + 5)..Append(outputPath)..Append(".build");
			FileStream packageStream = scope .();
			Try!(PackageFormat.CreatePackage(newPackagePath, packageStream));
			Try!(PackageFormat.WritePackageHeaderProvisional(packageStream, .None, sourceHash, let packageStartPos));

			PackageFormat.Index fileIndex = scope .();

			for (let passSet in passSets)
			{
				Debug.Assert(passSet.targets.Count > 0);

				let importer = passSet.importer;
				int importerIndex = fileIndex.importerNames.IndexOf(importer.Name);
				if (importerIndex == -1)
				{
					importerIndex = fileIndex.importerNames.Count;
					fileIndex.importerNames.Add(new .(importer.Name));
				}

				importer.ClearConfig();
				if (passSet.importerConfig != null
					&& passSet.importer.SetConfig(passSet.importerConfig) case .Err)
					LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Failed to set config of importer '{importer.Name}'");

				if (importerIndex > uint8.MaxValue)
					LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Too many importers used! (max 256)");

				PackageFormat.IndexPass indexPass = .(passSet.targets.Count);
				indexPass.importerIndex = (.)importerIndex;
				indexPass.importerConfig = passSet.importerConfig == null ? null : new .(passSet.importerConfig);
				fileIndex.passes.Add(indexPass);

				PackageFormat.IndexPass oldIndexPass;
				if (oldPackageFileIndex != null)
				{
					// These don't change when we're able to load the old package! (same config)
					Debug.Assert(oldPackageFileIndex.passes.Count == passSets.Count);
					oldIndexPass = oldPackageFileIndex.passes[@passSet.Index];
				}
				else oldIndexPass = default;

				for (let target in passSet.targets)
				{
					let entryName = GetScopedAssetName!(target.path, inputPath);
					Debug.Assert(entryName.Length > 0);

					uint8[] entryData = null;
					defer
					{
						DeleteNotNull!(entryData);
					}

					bool needToBuildData = true;
					if (oldPackageFileIndex != null && passSet.dependModified && !target.modified)
					{
						for (let entry in oldIndexPass.entries)
						{
							if (entry.name == entryName)
							{
								entryData = new .[entry.length];
								if (PackageFormat.ReadPackageData(oldPackageStream, oldPackageStartPos, entry, entryData) case .Err)
								{
									// Just try to build then...
									DeleteAndNullify!(entryData);
									break;
								}

								needToBuildData = false;
								break;
							}
						}
					}

					if (needToBuildData)
					{
						switch (passSet.importer.Build(target.path))
						{
						case .Err:
							LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Failed to build file '{target.path}' with importer {passSet.importer.Name}");
						case .Ok(out entryData):
						}

						if (entryData == null)
							LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Importer {passSet.importer.Name} returned no data for '{target.path}'");
					}

					Debug.Assert(entryData != null);

					Try!(PackageFormat.WritePackageData(packageStream, entryName, entryData, packageStartPos, let passEntry));
					indexPass.entries.Add(passEntry);
				}
			}

			uint64 packageIndexOffset = (.)packageStream.Position - packageStartPos;
			Try!(PackageFormat.WritePackageIndex(packageStream, fileIndex));
			Try!(PackageFormat.WritePackageHeaderComplete(packageStream, packageIndexOffset, packageStartPos));

			if (packageStream.Close() case .Err)
				LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Couldn't finish writing");

			if (oldPackageStream != null)
			{
				oldPackageStream.Close(); // We only read... this should never error!
				File.Delete(outputPath).IgnoreError();
			}

			if (File.Move(newPackagePath, outputPath) case .Err)
				LogErrorReturn!(scope $"Couldn't build package '{packageName}'. Couldn't rename build file to '{outputPath}'");

			t.Stop();
			Log.Info(scope $"Built package '{packageName}'; took {t.ElapsedMilliseconds}ms");

			return .Ok;
		}

		public static Task<bool> BuildPackageAsync(StringView configPath, StringView outputFolderPath)
		{
			return new PackageBuildTask(configPath, outputFolderPath);
		}

		// adapted from StreamReader
		internal class PackageBuildTask : Task<bool> // bool indicates success
		{
			WaitEvent mDoneEvent = new WaitEvent() ~ delete _;

			String configPath = new String() ~ delete _;
			String outputFolderPath = new String() ~ delete _;

			public this(StringView packageBuildFilePath, StringView outputFolderPath)
			{
				this.configPath.Set(packageBuildFilePath);
				this.outputFolderPath.Set(outputFolderPath);

				ThreadPool.QueueUserWorkItem(new => Proc);
			}

			public ~this()
			{
				mDoneEvent.WaitFor();
			}

			void Proc()
			{
				m_result = BuildPackage(configPath, outputFolderPath) case .Ok;
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
