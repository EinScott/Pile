using System;
using System.IO;
using System.Text;
using System.Collections;

using internal Pile;

namespace Pile
{
	[StaticInitPriority(PILE_SINIT_IMPL)]
	static class System
	{
		public static readonly uint32 MajorVersion;
		public static readonly uint32 MinorVersion;
		public static extern String ApiName { get; }
		public static extern String Info { get; }

		internal static List<Monitor> monitors = new .() ~ DeleteContainerAndItems!(_); // Fill in Initialize()
		public static readonly ReadOnlyList<Monitor> Monitors = ReadOnlyList<Monitor>(monitors);
		
		public static String DataPath { get; private set; }
		public static String UserPath { get; private set; }

		/// Based on Graphics.Renderer, the System implementation is expected to set this up in Initialize()
		/// So that Graphics.Initialize() may use it. If this doesn't cater towards Graphics.Renderer, it
		/// will assume that the System implementation doesn't support the Renderer (and error/crash probably).
		internal static RendererSupport RendererSupport = .None;

		public static Window Window { get; internal set; }

		static ~this()
		{
			delete Window;

			delete DataPath;
			delete UserPath;
		}

		internal static void DetermineDataPaths(StringView title)
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
				Path.Clean(Path.InternalCombine(.. scope .(), userPath, fsTitle), userDir);
			}
			else
			{
				Environment.GetEnvironmentVariable("HOME", userPath);
				if (!userPath.IsEmpty)
					Path.Clean(Path.InternalCombine(.. scope .(), userPath, ".local", "share", fsTitle), userDir);
			}
#endif
#if BF_PLATFORM_MACOS
			Environment.GetEnvironmentVariable("HOME", userPath);
			if (!userPath.IsEmpty)
				Path.Clean(Path.InternalCombine(.. scope .(), userPath, "Library", "Application Support", fsTitle), userDir);
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
					Runtime.FatalError(scope $"Couldn't create directory for UserPath: {err}");
			}
		}

		protected internal static extern void Initialize();
		protected internal static extern void Step();
	}
}
