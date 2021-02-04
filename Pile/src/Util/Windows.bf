namespace System
{
	extension Windows
	{
		// https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid
		public const Guid FOLDERID_Documents = .(0xFDD39AD0, 0x238F, 0x46AF, 0xAD, 0xB4, 0x6C, 0x85, 0x48, 0x03, 0x69, 0xC7); // {FDD39AD0-238F-46AF-ADB4-6C85480369C7}

		// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
		// The non-deprecated way of getting common file system path locations (newer version of SHGetSpecialFolderLocation)
		[Import("shell32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern COM_IUnknown.HResult SHGetKnownFolderPath(Guid rfid, uint32 dwFlags, Handle hToken, char16** ppszPath);
	}
}
