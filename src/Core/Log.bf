using System;
using System.Collections;
using System.IO;

namespace Pile
{
	public static class Log
	{
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

		static readonly String buf = new String() ~ delete _;
		static readonly String log = new String() ~ delete _;

		public static void Message(String message) => Line(Types.Message, message);
		public static void Message(Object message) => Line(Types.Message, message);
		public static void Warning(String message) => Line(Types.Warning, message);
		public static void Warning(Object message) => Line(Types.Warning, message);
		public static void Error(String message) => Line(Types.Error, message);
		public static void Error(Object message) => Line(Types.Error, message);

		public static void AppendToFile(String filePath)
		{
			var directory = scope String();
			if (Path.GetDirectoryPath(filePath, directory) == .Err)
 			{
				 Log.Error("Couldn't append log to file, invalid path");
				 return;
			}

			if (directory.Length != 0 && !Directory.Exists(directory))
			{
				var res = Platform.BfpFileResult.Ok;
				if(Directory.CreateDirectory(directory) == .Err(res))
				{
					Log.Error("Couldn't append log to file, couldn't create missing directory:");
					Log.Error(res);
					return;
				}
			}

			let fileLog = scope String();
			fileLog.Append("START OF LOG OUTPUT");
			fileLog.Append(Environment.NewLine);
			DateTime.Now.ToString(fileLog);
			fileLog.Append(Environment.NewLine);

			fileLog.Append(log);

			fileLog.Append(Environment.NewLine);

			if (File.Exists(filePath))
			{
				var existingFile = scope String();
				var res = FileError.FileOpenError(FileOpenError.Unknown);
				if (File.ReadAllText(filePath, existingFile, true) == .Err(res))
				{
					Log.Error("Couldn't append log to file, couldn't read existing file:");
					Log.Error(res);
					return;
				}

				fileLog.Append(existingFile);
			}

			if(File.WriteAllText(filePath, fileLog) == .Err)
			{
				Log.Error("Couldn't append log to file, couldn't write file");
				return;
			}
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
