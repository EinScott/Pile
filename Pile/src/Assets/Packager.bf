using System;
using System.IO;
using System.Collections;
using System.Threading.Tasks;

using internal Pile;

namespace Pile
{
	static
	{
		internal static mixin GetAssetsPath()
		{
			String assetsPath = scope:mixin .();
			let exePath = Environment.GetExecutableFilePath(.. scope String());

			let dirPath = scope String();
			if (Path.GetDirectoryPath(exePath, dirPath) case .Ok)
			{
				assetsPath.Append(Path.GetAbsolutePath(@"..\..\..\assets", dirPath, .. scope String()));
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
					let markerPath = Path.GetAbsolutePath(@"..\Pile\Pile__.lib", dirPath, .. scope String());

					// If we are inside the build output directory
					if (File.Exists(markerPath))
					{
						inPath.Append(Path.GetAbsolutePath(@"..\..\..\assets", dirPath, .. scope String()));
						outPath.Append(Path.InternalCombine(.. scope String(dirPath), @"packages"));
					}
					else LogErrorReturn!("Packager should only be called for development purposes when the application is inside the project build directory");
				}
			}

			if (inPath.Length == 0 || outPath.Length == 0)
				LogErrorReturn!("Packager need both an 'in=' and 'out=' argument");

			if (!Directory.Exists(inPath))
				LogErrorReturn!(scope $"Packer inPath argument has to contain a valid path to an existing directory. {inPath} is invalid");

			if (!Directory.Exists(outPath))
				Try!(Directory.CreateDirectory(outPath));

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
