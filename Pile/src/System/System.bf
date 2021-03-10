using System;
using System.IO;
using System.Text;
using System.Collections;

using internal Pile;

namespace Pile
{
	public class System
	{
		public extern uint32 MajorVersion { get; }
		public extern uint32 MinorVersion { get; }
		public extern String ApiName { get; }
		public extern String Info { get; }

		internal List<Monitor> monitors ~ DeleteContainerAndItems!(_); // Fill in Initialize()
		public readonly ReadOnlyList<Monitor> Monitors;

		internal this()
		{
			monitors = new List<Pile.Monitor>();
			Monitors = ReadOnlyList<Monitor>(monitors);
		}

		internal ~this()
		{
			delete DataPath;
			delete UserPath;
		}

		protected internal void DetermineDataPaths(StringView title)
		{
			String exePath = Environment.GetExecutableFilePath(.. scope .());
			String exeDir = Path.GetDirectoryPath(exePath, .. scope .());
			DataPath = Path.Clean(exeDir, .. new .());
			
			String fsTitle = scope String(title)..Replace(Path.DirectorySeparatorChar, ' ')..Replace(Path.AltDirectorySeparatorChar, ' ')..Replace(Path.VolumeSeparatorChar, ' ');
			// we could test for all the ungodly things windows doesn't allow in file names. ATM that responsibility is on the developer naming the program...

			String userPath = scope .();
			String userDir = new .();

#if BF_PLATFORM_WINDOWS
			{
				// We want "<documents folder>/My Games/<game name>"
				bool dSuccess = false;

				// Get documents folder path
				char16* pathPtr = ?;
				let res = Windows.SHGetKnownFolderPath(Windows.FOLDERID_Documents, 0, .NullHandle, &pathPtr);
				if (res == .OK)
				{
					// Get length
					int len = 0;
					for (int_strsize i = 0; true; i++)
						if (pathPtr[i] == (char16)0)
						{
							len = i;
							break;
						}

					if (Encoding.UTF16.DecodeToUTF8(Span<uint8>((uint8*)pathPtr, len * sizeof(char16)), userPath) case .Ok)
					{
						Path.Clean(Path.InternalCombine(.. scope .(), userPath, "My Games", fsTitle), userDir);
						dSuccess = true;
					}
				}
				Windows.COM_IUnknown.CoTaskMemFree(pathPtr);

				// Alternative
				if (!dSuccess)
				{
					userPath.Clear();
					Environment.GetEnvironmentVariable("APPDATA", userPath);
					if (!userPath.IsEmpty)
						Path.Clean(Path.InternalCombine(.. scope .(), userPath, fsTitle), userDir);
				}	 
			}
#endif
#if BF_PLATFORM_LINUX
			Environment.GetEnvironmentVariable("XDG_DATA_HOME", userPath);
			if (!userPath.IsEmpty)
			{
				Path.Clean(Path.InternalCombine(.. scope .(), userPath, lowerTitle), userDir);
			}
			else
			{
				Environment.GetEnvironmentVariable("HOME", userPath);
				if (!userPath.IsEmpty)
					Path.Clean(Path.InternalCombine(.. scope .(), userPath, ".local", "share", lowerTitle), userDir);
			}
#endif
#if BF_PLATFORM_MACOS
			Environment.GetEnvironmentVariable("HOME", userPath);
			if (!userPath.IsEmpty)
				Path.Clean(Path.InternalCombine(.. scope .(), userPath, "Library", "Application Support", lowerTitle), userDir);
#endif

			if (userDir.IsEmpty)
			{
				Log.Error("Couldn't determine UserPath");
				userDir.Set(DataPath);
			}
			UserPath = userDir;

			if (!Directory.Exists(userDir))
			{
				if (Directory.CreateDirectory(userDir) case .Err(let err))
					Core.FatalError(scope $"Couldn't create directory for UserPath: {err}");
			}
		}

		protected internal extern void Initialize();
		protected internal extern void Step();

		public String DataPath { get; private set; }
		public String UserPath { get; private set; }
	}
}
