using System;
using System.Collections;
using System.IO;

namespace Pile
{
	public static class Log
	{
#if PILE_LONG_LOG_RECORD
		public const int32 LOG_RECORD_COUNT = 512;
#else
		public const int32 LOG_RECORD_COUNT = 64;
#endif
		
		public enum Types
		{
			case Info;
			case Warn;
			case Error;

			public ConsoleColor GetLogColor()
			{
				switch (this)
				{
				case .Info: 	return .White;
				case .Warn: 	return .Yellow;
				case .Error:	return .Red;
				}
			}

			public String GetLogString()
			{
				switch (this)
				{
				case .Info: 	return "INFO: ";
				case .Warn: 	return "WARN: ";
				case .Error:	return "FAIL: ";
				}
			}
		}

		public static Event<delegate void(Types type, String message)> OnLine;

#if DEBUG // Different defaults
		public static bool PrintToConsole = true;
		public static bool SaveOnError = false;
#else
		public static bool PrintToConsole = false;
		public static bool SaveOnError = true;
#endif

		static bool discontinued;
		static int writeIndex = 0;

		static readonly String[] record = new String[LOG_RECORD_COUNT];

		static String logPath = new String() ~ delete _;

		static this()
		{
			for (int i = 0; i < LOG_RECORD_COUNT; i++)
				record[i] = new String(64);
		}

		static ~this()
		{
			for (int i = 0; i < LOG_RECORD_COUNT; i++)
				delete record[i];
			delete record;
		}

		internal static void Initialize()
		{
			Path.InternalCombine(logPath, Core.System.UserPath, @"log.txt");

			// Make sure init output is saved at least once
			if (!File.Exists(logPath))
				SaveToFile().IgnoreError();
		}

		// Logging shorthands
#if !DEBUG
		[SkipCall]
#endif
		public static void Debug(String message) => Log(.Info, message);
#if !DEBUG
		[SkipCall]
#endif
		public static void Debug(Object message) => Log(.Info, message);
#if !DEBUG
		[SkipCall]
#endif
		public static void Debug(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Info, message);
		}

#if PILE_DISABLE_LOG_MESSAGES
		[SkipCall]
#endif
		public static void Info(String message) => Log(.Info, message);
#if PILE_DISABLE_LOG_MESSAGES
		[SkipCall]
#endif
		public static void Info(Object message) => Log(.Info, message);
#if PILE_DISABLE_LOG_MESSAGES
		[SkipCall]
#endif
		public static void Info(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Info, message);
		}

#if PILE_DISABLE_LOG_WARNINGS
		[SkipCall]
#endif
		public static void Warn(String message) => Log(.Warn, message);
#if PILE_DISABLE_LOG_WARNINGS
		[SkipCall]
#endif
		public static void Warn(Object message) => Log(.Warn, message);
#if PILE_DISABLE_LOG_WARNINGS
		[SkipCall]
#endif
		public static void Warn(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Warn, message);
		}

		public static void Error(String message)
		{
			Log(.Error, message);
			
			if (SaveOnError)
				SaveToFile().IgnoreError();
		}
		public static void Error(Object message)
		{
			Log(.Error, message);

			if (SaveOnError)
				SaveToFile().IgnoreError();
		}
		public static void Error(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Error, message);

			if (SaveOnError)
				SaveToFile().IgnoreError();
		}

		// Actually log lines
		[Inline]
		static void Log(Types type, Object message)
		{
			// Write message
			let msgStr = message.ToString(.. scope String());

			Log(type, msgStr);
		}

		[Inline]
		static void Log(Types type, String message)
		{
			let fullMessage = scope String(type.GetLogString())..Append(message);
			AppendRecord(fullMessage);

			if (PrintToConsole)
			{
				if (type == .Info)
					Console.WriteLine(fullMessage);
				else
				{
					Console.ForegroundColor = type.GetLogColor();
					Console.Write(type.GetLogString());
					Console.ForegroundColor = .Gray;
					Console.WriteLine(message);
				}
			}
		}

		// Record stuff
		[Inline]
		static void AppendRecord(String logBuf)
		{
			let thisIndex = writeIndex;

			// Move writeIndex
			if (writeIndex + 1 < LOG_RECORD_COUNT)
				writeIndex++;
			else writeIndex = 0;

			// Take logBuf and put its contents into record array
			record[thisIndex].Set(logBuf);
		}

		static void ClearRecord()
		{
			// Indicate that is is not the full log record
			discontinued = true;

			// Clear
			for (var string in record)
				string.Clear();
			writeIndex = 0;
		}
		
		// Save log record (and clear record)

		public static Result<void> SaveToFile(String path = logPath)
		{
			var directory = scope String();
			if (Path.GetDirectoryPath(path, directory) case .Err)
			{
				Log.Warn("Couldn't append log to file, invalid path");
				return .Err;
			}

			if (!Directory.Exists(directory))
				if (Directory.CreateDirectory(directory) case .Err(let res))
				{
					Log.Warn(scope $"Couldn't append log to file, couldn't create missing directory: {res}");
					return .Err;
				}
			
			let fileLog = scope String();
			if (discontinued) fileLog.Append("CONTINUES LOG FROM BELOW");
			else fileLog.Append("START OF LOG OUTPUT");

			fileLog.Append(Environment.NewLine);
			DateTime.UtcNow.ToString(fileLog, "yyyy-MM-dd\"T\"HH:mm:ss\" UTC (Local offset: \"");
			TimeZoneInfo.Local.GetUtcOffset(DateTime.Now).Hours.ToString(fileLog);
			fileLog..Append(")").Append(Environment.NewLine);

			// Save and empty log

			// writeIndex is where we *would* write next, and since the newest output (index before this)
			// is printed last, we start here at the (if existant) oldest and go around once
			for (int x = 0, int i = writeIndex; x < LOG_RECORD_COUNT; x++, i = (i + 1) < LOG_RECORD_COUNT ? i + 1 : 0) // Since we start anywhere in the array, we will need to wrap i
			{
				// Skip empty/cleared lines
				if (record[i].Length == 0)
					continue;

				// Append string
				fileLog.Append(record[i]);
				fileLog.Append(Environment.NewLine);
			}
			ClearRecord();

			// Append possibly existing file
			if (File.Exists(path))
			{
				fileLog.Append(Environment.NewLine);

				var existingFile = scope String();
				if (File.ReadAllText(path, existingFile, true) case .Err(let res))
				{
					Log.Warn(scope $"Couldn't append log to file, couldn't read existing file: {res}");
					return .Err;
				}

				fileLog.Append(existingFile);
			}

			// Write
			if (File.WriteAllText(path, fileLog) case .Err)
			{
				Log.Warn("Couldn't append log to file, couldn't write file");
				return .Err;
			}

			return .Ok;
		}
	}
}
