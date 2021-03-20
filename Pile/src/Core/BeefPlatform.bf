using System;

using internal Pile;

namespace Pile
{
	static class BeefPlatform
	{
		/// Only has an effect when set before Core.Run() (i. e. during static initialization or OnStart)
		public static bool OfferCrashRelaunch = true;

		[CallingConvention(.Stdcall), CLink]
		static extern void BfpSystem_AddCrashInfo(char8* str);

		internal static void Initialize()
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
			let logStr = new String(256);
			logStr.Append(Environment.NewLine);
			logStr.Append("PILE LOG RECORD");
			if (Log.discontinued) logStr.Append(" - only newest part (by default, see log.txt at the game's save location)");
			logStr.Append(Environment.NewLine);
			BfpSystem_AddCrashInfo(Log.ToString(.. logStr).CStr());
		}
	}
}
