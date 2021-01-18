using System;
using System.IO;

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
			bool cache = false;
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
				else if (arg.StartsWith("cache"))
				{
					cache = true;
				}
				else Log.Warning(scope $"Unknown packager argument: {arg}");
			}

			if (inPath.Length == 0 || outPath.Length == 0)
				LogErrorReturn!("Packager need both an 'in=' and 'out=' argument");

			if (!Directory.Exists(inPath))
				LogErrorReturn!(scope $"Packer inPath argument has to contain a valid path to an existing directory. {inPath} is invalid");

			if (!Directory.Exists(outPath))
				Directory.CreateDirectory(outPath);

			// Get last build date for caching
			DateTime lastBuild = ?;
			String buildFilePath = null;
			if (cache)
			{
				buildFilePath = Path.InternalCombine(.. scope:: String(), scope .(outPath), "packageBuild.dat");

				if (File.Exists(buildFilePath))
				{
					// Load build file and extract last build date
					let buildFile = scope String();
					if (File.ReadAllText(buildFilePath, buildFile) case .Err)
					{
						Log.Warning("Couldn't read packageBuild.dat; disabled caching");
						cache = false;
					}
					else
					{
						if (uint64.Parse(buildFile) case .Ok(let val))
							lastBuild.[Friend]dateData = val;
						else
						{
							Log.Warning("Couldn't parse packageBuild.dat; disabled caching");
							cache = false;
						}	
					}
				}
			}

			bool error = false;
			for (let file in Directory.EnumerateFiles(inPath))
			{
				// Identify file
				let path = file.GetFilePath(.. scope String());

				if (!path.EndsWith(".json")) continue;

				if (cache)
				{
					let packageName = Path.GetFileNameWithoutExtension(scope String(path), .. scope String());
					let packageOutPath = Path.InternalCombine(.. scope String(), scope .(outPath), packageName);
					Path.ChangeExtension(packageOutPath, ".bin", packageOutPath);

					if (File.Exists(packageOutPath) && !Packages.PackageSourceChanged(path, lastBuild))
						continue;
				}

				if (Packages.BuildPackage(path, outPath) case .Err)
				{
					Log.Warning(scope $"Failed building package {path}. Skipping");
					error = true;
					continue;
				}
			}

			if (cache && !error)
			{
				let newBuildDate = DateTime.UtcNow.Ticks.ToString(.. scope String());
				TrySilent!(File.WriteAllText(buildFilePath, newBuildDate));
			}

			return .Ok;
		}
#endif
	}
}
