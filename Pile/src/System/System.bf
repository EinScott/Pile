using System;
using System.IO;

namespace Pile
{
	public abstract class System
	{
		public abstract String ApiName { get; }

		internal ~this()
		{
			delete DataPath;
			delete UserPath;
		}

		internal virtual void DetermineDataPaths(StringView title)
		{
			String exePath = scope .();
			Environment.GetExecutableFilePath(exePath);
			String exeDir = new .();
			Path.GetDirectoryPath(exePath, exeDir);
			DataPath = exeDir;
			
			String lowerTitle = scope String(title)..Replace(Path.DirectorySeparatorChar, '_')..Replace(Path.AltDirectorySeparatorChar, '_')..Replace(Path.VolumeSeparatorChar, '_')..ToLower();
			String userPath = scope .();
			String userDir = new .();
			switch (Environment.OSVersion.Platform)
			{
			case .WinCE, .Win32Windows, .Win32S, .Win32NT, .Xbox:
				Environment.GetEnvironmentVariable("APPDATA", userPath);
				if (!userPath.IsEmpty)
					Path.InternalCombine(userDir, userPath, lowerTitle);
			case .Unix:
				Environment.GetEnvironmentVariable("XDG_DATA_HOME", userPath);
				if (!userPath.IsEmpty)
				{
					Path.InternalCombine(userDir, userPath, lowerTitle);
				}
				else
				{
					Environment.GetEnvironmentVariable("HOME", userPath);
					if (!userPath.IsEmpty)
						Path.InternalCombine(userDir, userPath, ".local", "share", lowerTitle);
				}
			case .MacOSX:
				Environment.GetEnvironmentVariable("HOME", userPath);
				if (!userPath.IsEmpty)
					Path.InternalCombine(userDir, userPath, "Library", "Application Support", lowerTitle);
			}

			if (userDir.IsEmpty)
			{
				Log.Warning("Couldn't determine UserPath");
				userDir.Set(exeDir);
			}
			UserPath = userDir;

			if (!Directory.Exists(userDir))
				Directory.CreateDirectory(userDir);
		}

		internal abstract Input CreateInput();
		internal abstract Window CreateWindow(int32 width, int32 height);

		internal abstract void Initialize();
		internal abstract void Step();

		public String DataPath { get; private set; }
		public String UserPath { get; private set; }
	}
}
