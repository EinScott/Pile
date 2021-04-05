using System;
using System.IO;
using System.Collections;
using System.Threading.Tasks;

using internal Pile;

namespace Pile
{
	static
	{
		internal static mixin GetScopedAssetsSourcePath()
		{
			String assetsPath = scope:mixin .();
			let exePath = Environment.GetExecutableFilePath(.. scope String());

			let dirPath = scope String();
			if (Path.GetDirectoryPath(exePath, dirPath) case .Ok)
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
				let exePath = Environment.GetExecutableFilePath(.. scope String());

				let dirPath = scope String();
				if (Path.GetDirectoryPath(exePath, dirPath) case .Ok)
				{
					// this test is weird... maybe make cleaner at some point?
#if BF_PLATFORM_WINDOWS
					let markerPath = Path.GetAbsolutePath(@"../Pile/Pile__.lib", dirPath, .. scope String());
#else
					let markerPath = Path.GetAbsolutePath(@"../Pile/Pile_Core.o", dirPath, .. scope String());
#endif

					// If we are inside the build output directory
					if (File.Exists(markerPath))
					{
						inPath.Append(Path.GetAbsolutePath(@"../../../assets", dirPath, .. scope String()));
						outPath.Append(Path.InternalCombine(.. scope String(dirPath), @"packages"));
					}
					else LogErrorReturn!("Packager should only be called for development purposes when the application is inside the project build directory");
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
