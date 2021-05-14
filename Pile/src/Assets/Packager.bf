using System;
using System.IO;
using System.Collections;
using System.Threading.Tasks;

using internal Pile;

namespace Pile
{
	static
	{
		// Used for package hot reload
		internal static mixin MakeScopedAssetsSourcePath()
		{
			String assetsPath = scope:mixin .();

			let dirPath = scope String();
			if (Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope String()), dirPath) case .Ok)
			{
				assetsPath.Append(Path.GetAbsolutePath(@"../../../assets", dirPath, .. scope String()));
			}

			assetsPath
		}

		[Optimize]
		internal static Result<void> RunPackager()
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
					let assetsPath = Path.GetAbsolutePath(@"../../../assets", dirPath, .. scope String());

					// If the usual dir doesnt exist... try args
					if (!Directory.Exists(assetsPath))
					{
						if (EntryPoint.CommandLine.Count > 1)
						{
							if (Path.IsPathRooted(EntryPoint.CommandLine[1]))
								assetsPath.Set(EntryPoint.CommandLine[1]);
							else
							{
								assetsPath.Clear();
								Path.GetAbsolutePath(EntryPoint.CommandLine[1], dirPath, assetsPath);
							}
						}

						if (!Directory.Exists(assetsPath))
							LogErrorReturn!("Assets folder couldn't be found in workspace.");
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

			let tasks = scope List<Packages.PackageBuildTask>();

			// Start tasks
			for (let file in Directory.EnumerateFiles(inPath))
			{
				// Identify file
				let path = file.GetFilePath(.. scope String());

				if (!path.EndsWith(".json")) continue;

				// Add these as PackageBuildTask, because we need the details passed in to log errors later on
				tasks.Add(Packages.BuildPackageAsync(path, outPath, FORCE) as Packages.PackageBuildTask);
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
	}
}
