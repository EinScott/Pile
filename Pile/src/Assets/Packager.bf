using System;
using System.IO;
using System.Collections;
using System.Threading.Tasks;

using internal Pile;

namespace Pile
{
	static
	{
#if !PILE_DISABLE_PACKAGER
		[Optimize]
		internal static Result<void> RunPackager()
		{
#if DEBUG
			const bool FORCE = false;
#else
			// Force it release (to have a fresh build and not carry over possible artifacts of patching)
			const bool FORCE = true;
#endif
			String inPath = scope .();
			String outPath = scope .();
			{
				let exePath = scope String();
				Environment.GetExecutableFilePath(exePath);

				let dirPath = scope String();
				if (Path.GetDirectoryPath(exePath, dirPath) case .Ok)
				{
					let markerPath = Path.GetAbsolutePath(@"..\Pile\output_dir.temp", dirPath, .. scope String());

					// If we are inside the build output directory
					// todo: this should probably be part of the build process itself... right now we're just doing a crappy test if we're in the build dir
					// so instead of just placing that .temp file maybe we can execute this in there at some point.. we just need it to be post-link
					if (File.Exists(markerPath))
					{
						inPath.Append(Path.GetAbsolutePath(@"..\..\..\assets", dirPath, .. scope String()));
						outPath.Append(Path.InternalCombine(.. scope String(dirPath), @"packages"));
					}
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
#endif
	}
}
