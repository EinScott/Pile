using System;
using System.Collections;
using System.IO;

namespace Pile
{
	public static class Log
	{
		// this is slightly dumb, because we cant really save the log when we crash
		// maybe save to file 'per line' even though that sounds really dumb?

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
		public static bool PrintToConsole = true;
		public static bool SaveOnError = false;
		static bool discontinued;

		static readonly String buf = new String() ~ delete _;
		static readonly String log = new String() ~ delete _;

		public static void Message(String message) => Line(Types.Message, message);
		public static void Message(Object message) => Line(Types.Message, message);
		public static void Warning(String message) => Line(Types.Warning, message);
		public static void Warning(Object message) => Line(Types.Warning, message);
		public static void Error(String message)
		{
			Line(Types.Error, message);
			
			if (SaveOnError)
			{
				var s = scope String();
				Path.InternalCombine(s, Core.System.DataPath, @"log.txt");
				AppendToFile(s);
			}
		}
		public static void Error(Object message)
		{
			Line(Types.Error, message);

			if (SaveOnError)
			{
				var s = scope String();
				Path.InternalCombine(s, Core.System.DataPath, @"log.txt");
				AppendToFile(s);
			}
		}

		public static void AppendToFile(String filePath)
		{
			var directory = scope String();
			Runtime.Assert(Path.GetDirectoryPath(filePath, directory) == .Ok, "Couldn't append log to file, invalid path");

			if (directory.Length != 0 && !Directory.Exists(directory))
			{
				var res = Platform.BfpFileResult.Ok;
				Runtime.Assert(Directory.CreateDirectory(directory) != .Err(res), "Couldn't append log to file, couldn't create missing directory: {0}".Format(res));
			}

			let fileLog = scope String();
			if (discontinued) fileLog.Append("CONTINUES LOG FROM BELOW");
			else fileLog.Append("START OF LOG OUTPUT");

			fileLog.Append(Environment.NewLine);
			DateTime.Now.ToString(fileLog);
			fileLog.Append(Environment.NewLine);

			// Save and empty log
			fileLog.Append(log);
			log.Clear();
			discontinued = true;

			fileLog.Append(Environment.NewLine);

			if (File.Exists(filePath))
			{
				var existingFile = scope String();
				var res = FileError.FileOpenError(FileOpenError.Unknown);
				Runtime.Assert(File.ReadAllText(filePath, existingFile, true) != .Err(res), "Couldn't append log to file, couldn't read existing file: {0}".Format(res));

				fileLog.Append(existingFile);
			}

			Runtime.Assert(File.WriteAllText(filePath, fileLog) == .Ok, "Couldn't append log to file, couldn't write file");
		}

		static void Line(Types type, String message)
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

		static void Line(Types type, Object message)
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

			log.Append(text);
		}

		static void AppendLineBreak()
		{
			if (PrintToConsole)
				Console.WriteLine();

			log.Append(Environment.NewLine);
		}
	}
}
