using System;
using System.IO;

namespace Pile
{
	public class System
	{
		public extern uint32 MajorVersion { get; }
		public extern uint32 MinorVersion { get; }
		public extern String ApiName { get; }
		public extern String Info { get; }

		internal this() {}

		internal ~this()
		{
			delete DataPath;
			delete UserPath;
		}

		protected internal virtual void DetermineDataPaths(StringView title)
		{
			String exePath = scope .();
			Environment.GetExecutableFilePath(exePath);
			String exeDir = new .();
			Path.GetDirectoryPath(exePath, exeDir);
			DataPath = exeDir;
			
			String lowerTitle = scope String(title)..Replace(Path.DirectorySeparatorChar, '_')..Replace(Path.AltDirectorySeparatorChar, '_')..Replace(Path.VolumeSeparatorChar, '_')..ToLower();
			String userPath = scope .();
			String userDir = new .();

#if BF_PLATFORM_WINDOWS
			Environment.GetEnvironmentVariable("APPDATA", userPath);
			if (!userPath.IsEmpty)
				Path.InternalCombine(userDir, userPath, lowerTitle);
#endif
#if BF_PLATFORM_LINUX
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
#endif
#if BF_PLATFORM_MACOS
			Environment.GetEnvironmentVariable("HOME", userPath);
			if (!userPath.IsEmpty)
				Path.InternalCombine(userDir, userPath, "Library", "Application Support", lowerTitle);
#endif

			if (userDir.IsEmpty)
			{
				Log.Error("Couldn't determine UserPath");
				userDir.Set(exeDir);
			}
			UserPath = userDir;

			if (!Directory.Exists(userDir))
				Directory.CreateDirectory(userDir);
		}

		protected internal extern Input CreateInput();
		protected internal extern Window CreateWindow(uint32 width, uint32 height);

		protected internal extern void Initialize();
		protected internal extern void Step();
		protected internal extern void* GetNativeWindowHandle();

		public String DataPath { get; private set; }
		public String UserPath { get; private set; }
	}
}
