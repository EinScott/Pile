using System;
using System.Collections;
using System.IO;
using System.Diagnostics;
using System.Threading;

namespace Pile
{
	[Optimize]
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

		public static Event<delegate void(Types type, String message)> OnLine;

#if DEBUG // Different defaults
		public static bool PrintToConsole = true;
#else
		public static bool PrintToConsole = false;
#endif

		static int32 recordLength = 64;
		public static int32 RecordLength
		{
			[Inline]
			get => recordLength;
			set
			{
				if (value != recordLength)
				{
					// Create new
					let newRec = new String[value];
					for (int i < value)
						newRec[i] = new String(64);

					// Copy over all common content
					let common = Math.Min(value, recordLength);
					for (var i < common)
					{
						newRec[i].Set(record[i]);
					}

					// Delete old
					for (int i < recordLength)
						delete record[i];
					delete record;

					record = newRec;
					recordLength = value;
				}
			}
		}

		internal static bool discontinued;
		static int writeIndex = 0;

		static String[] record = new String[RecordLength];

		static String logPath = new String() ~ delete _;

		static this()
		{
			for (int i < RecordLength)
				record[i] = new String(64);
		}

		static ~this()
		{
			for (int i < RecordLength)
				delete record[i];
			delete record;
		}

		internal static void CreateDefaultPath()
		{
			Path.InternalCombine(logPath, System.UserPath, @"log.txt");
		}

		// Logging functions
		[DebugOnly]
		public static void Debug(String message) => Log(.Info, message);
		[DebugOnly]
		public static void Debug(Object message) => Log(.Info, message);
		[DebugOnly]
		public static void Debug(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Info, message);
		}

		public static void Info(String message) => Log(.Info, message);
		public static void Info(Object message) => Log(.Info, message);
		public static void Info(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Info, message);
		}

		public static void Warn(String message) => Log(.Warn, message);
		public static void Warn(Object message) => Log(.Warn, message);
		public static void Warn(StringView format, params Object[] inserts)
		{
			let message = scope String();
			message.AppendF(format, params inserts).IgnoreError();
			Log(.Warn, message);
		}

		public static void Error(String message)
		{
			Log(.Error, message);
		}
		public static void Error(Object message)
		{
			Log(.Error, message);
		}
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

#if DEBUG
				using (debugWriteMonitor.Enter())
				{
					if (debugNeedsWrite < 8)
						debugWriteBuffer[debugNeedsWrite++].Set(fullMessage);
					else debugWriteBuffer[7].Set(fullMessage); // rest in peace previous message...
				}
#endif
			}
		}

		[DebugOnly]
		static void FlushDebugWrite()
		{
			DoDebugWriteBuffer();
		}

		[DebugOnly,Inline]
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

#if DEBUG
		static Monitor debugWriteMonitor = new Monitor() ~ delete _;
		static Thread debugWriteThread = new Thread(new => DebugWriteThread)..SetName("Pile Log DebugWrite")..Start() ~ debugExit = true;
		static bool debugExit;

		static String[] debugWriteBuffer = {
			var s = new String[8]();
			for (let i < 8)
				s[i] = new String(128);
			s
		} ~ {
			using (debugWriteMonitor.Enter())
				DeleteContainerAndItems!(_);
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
			let thisIndex = writeIndex;

			// Move writeIndex
			if (writeIndex + 1 < RecordLength)
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

		public static new void ToString(String buffer)
		{
			DateTime.UtcNow.ToString(buffer, "yyyy-MM-dd\"T\"HH:mm:ss\" UTC (Local offset: \"");
			TimeZoneInfo.Local.GetUtcOffset(DateTime.Now).Hours.ToString(buffer);
			buffer..Append(")").Append(Environment.NewLine);

			// writeIndex is where we *would* write next, and since the newest output (index before this)
			// is printed last, we start here at the (if existent) oldest and go around once
			for (int x = 0, int i = writeIndex; x < RecordLength; x++, i = (i + 1) < RecordLength ? i + 1 : 0) // Since we start anywhere in the array, we will need to wrap i
			{
				// Skip empty/cleared lines
				if (record[i].Length == 0)
					continue;

				// Append string
				buffer.Append(record[i]);
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
