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
		internal static Result<void> RunPackager(Span<String> args)
		{
			StringView inPath = StringView();
			StringView outPath = StringView();
			for(let arg in args)
			{
				if (arg.StartsWith("in="))
				{
					inPath = arg;
					inPath.RemoveFromStart(3);
				}
				else if (arg.StartsWith("out="))
				{
					outPath = arg;
					outPath.RemoveFromStart(4);
				}
				else Log.Warn(scope $"Unknown packager argument: {arg}");
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
				tasks.Add(Packages.BuildPackageAsync(path, outPath) as Packages.PackageBuildTask);
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
						task.Dispose();
					}
				}
			}

			return .Ok;
		}
#endif
	}
}
