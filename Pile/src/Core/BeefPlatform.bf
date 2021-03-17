using System;

using internal Pile;

namespace Pile
{
	[AlwaysInclude, StaticInitPriority(-10)]
	static class BeefPlatform
	{
		public static bool OfferCrashRelaunch = true;

		[CallingConvention(.Stdcall), CLink]
		private static extern void BfpSystem_AddCrashInfo(char8* str);

		static this()
		{
			Runtime.[Friend]AddCrashInfoFunc((void*)((function void()) => OnCrash));
			if (OfferCrashRelaunch)
				Platform.BfpSystem_SetCrashRelaunchCmd(MakeRelaunchCmd(.. scope .()));
		}

		static void MakeRelaunchCmd(String buffer)
		{
			buffer.Append("\"");
			Environment.GetExecutableFilePath(buffer);
			buffer.Append("\"");
		}

		static void OnCrash()
		{
			if (!Core.run) // Don't do this on static init or when Pile wasn't used
				return;

			let logStr = new String("\nPILE LOG RECORD");
			if (Log.discontinued) logStr.Append(" - only newest part (by default, see log.txt at the game's save location)");
			BfpSystem_AddCrashInfo(Log.ToString(.. logStr).CStr());
		}
	}
}
