using System;
using System.Collections;
using System.IO;
using System.Diagnostics;
using System.Threading;

using internal Pile;

namespace Pile
{
	[Optimize,StaticInitAfter(typeof(Console)),StaticInitPriority(PILE_SINIT_ENTRY + 10)] // Before everything else
	static class Log
	{
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

		public static Event<delegate void(Types type, StringView message)> OnLine ~ _.Dispose();

#if DEBUG // Different defaults
		public static bool PrintToConsole = true;
#else
		public static bool PrintToConsole = false;
#endif

		public static Types Verbosity = .Info;

		internal static bool discontinued;

		static CircularBuffer<String> record = new .(64) ~ DeleteContainerAndItems!(_);

		static String logPath = new String() ~ delete _;

		static this()
		{
			for (int i < record.Capacity) // Fill buffer
				record.Add(new String(64));
		}

		internal static void CreateDefaultPath()
		{
			Path.InternalCombine(logPath, System.UserPath, @"log.txt");
		}

		// Logging functions
#if !DEBUG
		[SkipCall]
#endif
		[Inline]
		public static void Debug(StringView message) => Log(.Info, message);
#if !DEBUG
		[SkipCall]
#endif
		[Inline]
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

		[Inline]
		public static void Info(StringView message) => Log(.Info, message);
		[Inline]
		public static void Info(Object message) => Log(.Info, message);
		public static void Info(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Info, message);
		}

		[Inline]
		public static void Warn(StringView message) => Log(.Warn, message);
		[Inline]
		public static void Warn(Object message) => Log(.Warn, message);
		public static void Warn(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Warn, message);
		}

		[Inline]
		public static void Error(StringView message) => Log(.Error, message);
		[Inline]
		public static void Error(Object message) => Log(.Error, message);
		public static void Error(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Error, message);
		}

		// Actually log lines
		[Inline]
		static void Log(Types type, Object message)
		{
			// Write message
			let msgStr = message.ToString(.. scope String());

			Log(type, msgStr);
		}

		static void Log(Types type, StringView message)
		{
			let fullMessage = scope String(6 + message.Length)..Append(type.GetLogString())..Append(message);

			using (writeMonitor.Enter())
			{
				if (Verbosity <= type)
					AppendRecord(fullMessage);

				if (OnLine.HasListeners)
					OnLine(type, message);

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

#if DEBUG
					using (debugWriteMonitor.Enter())
					{
						if (debugNeedsWrite < DEBUGWRITEBUFSIZE)
							debugWriteBuffer[debugNeedsWrite++].Set(fullMessage);
						else debugWriteBuffer[DEBUGWRITEBUFSIZE - 1].Set(fullMessage); // rest in peace previous message...
					}
#endif
				}
			}
		}

#if !DEBUG
		[SkipCall]
#endif
		static void FlushDebugWrite()
		{
#if DEBUG
			DoDebugWriteBuffer();
#endif
		}

		static Monitor writeMonitor = new Monitor() ~ delete _;
		const int DEBUGWRITEBUFSIZE = 8;
#if DEBUG
		[Inline]
		static void DoDebugWriteBuffer()
		{
			using (debugWriteMonitor.Enter())
			{
				for (uint8 i < debugNeedsWrite)
				{
					Debug.WriteLine(debugWriteBuffer[i]);
				}
				debugNeedsWrite = 0;
			}
		}

		static Monitor debugWriteMonitor = new Monitor() ~ delete _;
		static Thread debugWriteThread = new Thread(new => DebugWriteThread)..SetName("Pile Log DebugWrite")..Start() ~ debugExit = true;
		static bool debugExit;

		static String[] debugWriteBuffer = {
			var s = new String[DEBUGWRITEBUFSIZE]();
			for (let i < DEBUGWRITEBUFSIZE)
				s[i] = new String(128);
			s
		} ~ {
			using (debugWriteMonitor.Enter())
			{
				DeleteContainerAndItems!(_);
				debugNeedsWrite = 0;
			}
		};
		static uint8 debugNeedsWrite;

		static void DebugWriteThread()
		{
			while (true)
			{
				while (debugNeedsWrite == 0)
				{
					Thread.Sleep(1);

					if (debugExit)
						return;
				}

				DoDebugWriteBuffer();
			}
		}
#endif

		// Record stuff
		[Inline]
		static void AppendRecord(String logBuf)
		{
			record.AddByRef().Set(logBuf);
		}

		static void ClearRecord()
		{
			// Indicate that is is not the full log record
			discontinued = true;

			// Clear
			for (var string in record)
				string.Clear();
		}
		
		// Save log record (and clear record)

		public static new void ToString(String buffer)
		{
			DateTime.UtcNow.ToString(buffer, "yyyy-MM-dd\" \"HH:mm:ss\" UTC (Local offset: \"");
			TimeZoneInfo.Local.GetUtcOffset(DateTime.Now).Hours.ToString(buffer);
			buffer..Append(")").Append(Environment.NewLine);

			for (let rec in record.GetBackwardsEnumerator())
			{
				// Skip empty/cleared lines
				if (rec.Length == 0)
					continue;

				// Append string
				buffer.Append(rec);
				buffer.Append(Environment.NewLine);
			}
		}

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

			// Get log contents and clear
			fileLog.Append(Environment.NewLine);
			ToString(fileLog);
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
