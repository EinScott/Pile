using System;
using System.IO;

namespace Pile
{
	static
	{
#if !PILE_DISABLE_PACKAGER
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
				else Log.Warning(scope $"Unknown packager argument: {arg}");
			}

			if (inPath.Length == 0 || outPath.Length == 0)
				LogErrorReturn!("Packager need both an 'in=' and 'out=' argument");

			if (!Directory.Exists(inPath))
				LogErrorReturn!("Packer inPath argument has to contain a valid path to an existing directory");

			if (!Directory.Exists(outPath))
				Directory.CreateDirectory(outPath);

			for (let file in Directory.EnumerateFiles(inPath))
			{
				// Identify file
				let path = scope String();
				file.GetFilePath(path);

				if (!path.EndsWith(".json")) continue;

				if (Packages.BuildPackage(path, outPath) case .Err)
				{
					Log.Warning(scope $"Failed building package {path}. Skipping");
					continue;
				}
			}

			return .Ok;
		}
#endif
	}
}
