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
			case Message;
			case Warning;
			case Error;

			public ConsoleColor ToColor()
			{
				switch (this)
				{
				case .Message: return .White;
				case .Warning: return .Yellow;
				case .Error:   return .Red;
				}
			}

			public override void ToString(String strBuffer)
			{
				switch (this)
				{
				case .Message: strBuffer.Append("INFO");
				case .Warning: strBuffer.Append("WARN");
				case .Error:   strBuffer.Append("FAIL");
				}
			}
		}

		const String SEPERATOR = ": ";

		public delegate void LineCallback(Types type, String message);
		public static Event<LineCallback> OnLine;

#if DEBUG // Different defaults
		public static bool PrintToConsole = true;
		public static bool SaveOnError = false;
#else
		public static bool PrintToConsole = false;
		public static bool SaveOnError = true;
#endif

		static bool discontinued;
		static int writeIndex = 0;

		static readonly String buf = new String(32) ~ delete _;
		static readonly String logBuf = new String(64) ~ delete _;
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
		public static void Debug(String message) => Log(.Message, message);
#if !DEBUG
		[SkipCall]
#endif
		public static void Debug(Object message) => Log(.Message, message);
#if !DEBUG
		[SkipCall]
#endif
		public static void Debug(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Message, message);
		}

#if PILE_DISABLE_LOG_MESSAGES
		[SkipCall]
#endif
		public static void Message(String message) => Log(.Message, message);
#if PILE_DISABLE_LOG_MESSAGES
		[SkipCall]
#endif
		public static void Message(Object message) => Log(.Message, message);
#if PILE_DISABLE_LOG_MESSAGES
		[SkipCall]
#endif
		public static void Message(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Message, message);
		}

#if PILE_DISABLE_LOG_WARNINGS
		[SkipCall]
#endif
		public static void Warning(String message) => Log(.Warning, message);
#if PILE_DISABLE_LOG_WARNINGS
		[SkipCall]
#endif
		public static void Warning(Object message) => Log(.Warning, message);
#if PILE_DISABLE_LOG_WARNINGS
		[SkipCall]
#endif
		public static void Warning(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Warning, message);
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

		static void Log(Types type, String message)
		{
			// Write type
			type.ToString(buf);
			Append(buf, type.ToColor());
			buf.Clear();

			Append(SEPERATOR, ConsoleColor.DarkGray);

			// Write message
			Append(message);

			AppendLineBreak();

			OnLine(type, message);
		}

		static void Log(Types type, Object message)
		{
			// Write type
			type.ToString(buf);
			Append(buf, type.ToColor());
			buf.Clear();

			Append(SEPERATOR, ConsoleColor.DarkGray);

			// Write message
			message.ToString(buf);
			Append(buf);

			AppendLineBreak();

			OnLine(type, buf);
			buf.Clear();
		}

		static void Append(String text, ConsoleColor color = ConsoleColor.White)
		{
			if (PrintToConsole)
			{
				Console.ForegroundColor = color;
				Console.Write(text);
			}

			logBuf.Append(text);
		}

		static void AppendLineBreak()
		{
			if (PrintToConsole)
				Console.WriteLine();

			AppendRecord();
		}

		// Record stuff

		static void AppendRecord()
		{
			// Take logBuf and put its contents into record array
			record[writeIndex].Set(logBuf);
			logBuf.Clear();

			// Move writeIndex
			if (writeIndex + 1 < LOG_RECORD_COUNT)
				writeIndex++;
			else writeIndex = 0;
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
				Log.Warning("Couldn't append log to file, invalid path");
				return .Err;
			}

			if (!Directory.Exists(directory))
				if (Directory.CreateDirectory(directory) case .Err(let res))
				{
					Log.Warning(scope $"Couldn't append log to file, couldn't create missing directory: {res}");
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
					Log.Warning(scope $"Couldn't append log to file, couldn't read existing file: {res}");
					return .Err;
				}

				fileLog.Append(existingFile);
			}

			// Write
			if (File.WriteAllText(path, fileLog) case .Err)
			{
				Log.Warning("Couldn't append log to file, couldn't write file");
				return .Err;
			}

			return .Ok;
		}
	}
}
