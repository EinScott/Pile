using System;
using System.Diagnostics;
using System.Collections;

using internal Pile;

namespace Pile
{
	static class DevConsole
	{
		struct Message : IDisposable
		{
			public Log.Types type;
			public String message = new .();

			public void Dispose()
			{
				if (message != null)
					delete message;
			}
		}

		static uint32 recordLength = 64;
		public static uint32 RecordLength
		{
			[Inline]
			get => recordLength;
			set
			{
				if (value != recordLength)
				{
					// Create new
					let newRec = new Message[value];
					for (int i < value)
						newRec[i] = Message();

					// Copy over all common content
					let common = Math.Min(value, recordLength);
					for (var i < common)
					{
						newRec[i].message.Set(record[i].message);
					}

					// Delete old
					for (int i < recordLength)
						record[i].Dispose();
					delete record;

					record = newRec;
					recordLength = value;
				}
			}
		}

		static int writeIndex = 0;

		static Message[] record;
		static int prevScale = -1;
		static int prevEdgeMargin;
		static Point2 prevLogPos;
		static Rect prevScreenRect;

		static bool logDirty = true;
		static int logHeight;
		static String logs;

		static String inputLine;
		static String diagnosticLine;
		static String autoComplete;
		static float backDelay;

		static this()
		{
#if DEBUG
			Log.OnLine.Add(new => Write);

			record = new Message[RecordLength];
			for (int i < recordLength)
				record[i] = .();

			logs = new .();
			inputLine = new .();
			diagnosticLine = new .();
			autoComplete = new .();
#endif
		}

		static ~this()
		{
#if DEBUG
			for (int i < recordLength)
				record[i].Dispose();
			delete record;

			delete logs;
			delete inputLine;
			delete diagnosticLine;
			delete autoComplete;
#endif
		}

		// TODO: input history via up and down
		// cursor movement via left and right, also drawing of it obviously

		[DebugOnly]
		public static void Update()
		{
			// Typed text
			inputLine.Append(Input.Keyboard.Text);

			// Paste
			if (Input.Keyboard.Ctrl && Input.Keyboard.Pressed(.V))
				inputLine.Append(Input.GetClipboardString(.. scope .()));

			// Delete
			if (inputLine.Length > 0)
			{
				if (Input.Keyboard.Pressed(.Backspace))
				{
					inputLine.RemoveFromEnd(1);
					backDelay = 0.4f;
				}
				else if (Input.Keyboard.Down(.Backspace))
				{
					if (backDelay > 0)
						backDelay -= Time.RawDelta;
					else
					{
						inputLine.RemoveFromEnd(1);
						backDelay = 0.02f;
					}
				}
			}

			if (Input.Keyboard.Pressed(.Delete))
				inputLine.Clear();

			// Enter
			if (Input.Keyboard.Pressed(.Enter) && inputLine.Length > 0)
			{
				Write(.Info, inputLine);
				Commands.Interpreter.Interpret(inputLine, => Write);

				inputLine.Clear();
				diagnosticLine.Clear();
				autoComplete.Clear();
			}

			// Diagnostics
			diagnosticLine.Clear();
			autoComplete..Clear();
			if (inputLine.Length > 0)
			{
				autoComplete.Append("> ");
				Commands.Interpreter.Interpret(inputLine, => Write, diagnosticLine, autoComplete);
			}

			if (inputLine.Length > 0 && Input.Keyboard.Pressed(.Tab) && autoComplete.Length > 2) // "> "
			{
				var replaceStart = inputLine.LastIndexOf(' ');
				if (replaceStart == -1)
					replaceStart = 0;

				inputLine.RemoveFromEnd(inputLine.Length - replaceStart);

				var replace = StringView(&autoComplete[2], autoComplete.Length - 2);
				let replaceEnd = replace.IndexOf(' ');
				if (replaceEnd != -1)
					replace.Length = replaceEnd;

				inputLine.Append(replace);
			}
		}

		[DebugOnly]
		public static void Render(Batch2D batch, SpriteFont font, Rect screenRect, int scale = 4, int edgeMargin = 4)
		{
			Debug.Assert(scale > 0);
			Debug.Assert(font != null);

			let textScale = 5 * (float)scale / font.Size;
			let rect = Rect(screenRect.Position + .(edgeMargin * scale), screenRect.Size - .(edgeMargin * scale * 2));

			// Dark background
			batch.Rect(rect, .Black * 0.6f);

			// Input box
			let textMargin = (edgeMargin / 4) * scale;
			let lineHeight = (int)(font.LineHeight * textScale);
			let inputBox = Rect(rect.Position + .(0, rect.Size.Y - (lineHeight + textMargin)), Point2(rect.Size.X, lineHeight  + (edgeMargin / 2) * scale));
			batch.Rect(inputBox, .Black * 0.8f);

			// Input line
			{
				let linePos = rect.Position + .(textMargin, rect.Size.Y - lineHeight);
				batch.Text(font, scope $"> {inputLine}", linePos, Vector2(textScale), .One, 0); // TODO: limit input text, or render only last part?
			}

			// TODO: cursor?

			var logPos = inputBox.Position + .(textMargin, -(edgeMargin));
			let logWidth = inputBox.Size.X - (textMargin * 2);

			do if (diagnosticLine.Length > 0 || autoComplete.Length > 0)
			{
				let wDiag = scope String(diagnosticLine);
				let wAuto = scope String(autoComplete); // TODO: since we're wrapping this, make . show suggestions for enums already! TEST THIS, also do the same for matching methods!

				if (wAuto.Length > 2) // "> "
				{
					logPos.Y -= (.)(font.WrapText(wAuto, logWidth) * textScale); // TODO: something is still wrong with wrapping. We either give  it a rubbish value or the function is wrong

					if (logPos.Y < rect.Y)
						break;

					batch.Text(font, wAuto, logPos, Vector2(textScale), .One, 0);
				}

				logPos.Y -= (.)(font.WrapText(wDiag, logWidth) * textScale);

				if (logPos.Y < rect.Y)
					break;

				batch.Text(font, wDiag, logPos, Vector2(textScale), .One, 0);
				
				logPos.Y -= lineHeight;
			}
			
			if (prevScale != scale || prevEdgeMargin != edgeMargin || prevScreenRect != screenRect || prevLogPos != logPos) // Force update based on different environment
			{
				prevScale = scale;
				prevEdgeMargin = edgeMargin;
				prevScreenRect = screenRect;
				prevLogPos = logPos;
				logDirty = true;
			}
			
			if (logDirty)
			{
				PrepareLogString(font, textScale, logWidth, logPos.Y - rect.Y - textMargin);
				logDirty = false;
			}

			logPos.Y -= logHeight;
			batch.Text(font, logs, logPos, Vector2(textScale), .One, 0);
		}

		static void PrepareLogString(SpriteFont font, float textScale, float logWidth, float maxHeight)
		{
			bool hasWrap = false;
			int iEnd;
			int i;
			float height = 0;
			// Look how many lines we can fit backwards
			for (int x = 0, iEnd = i = ((writeIndex - 1) < 0 ? RecordLength - 1 : writeIndex - 1); x < RecordLength; x++, i = (i - 1) >= 0 ? i - 1 : { hasWrap = true; RecordLength - 1 })
			{
				// Skip empty/cleared lines
				if (record[i].message.Length == 0)
					break;

				let line = scope String(record[i].type.ToString(.. scope .()));
				line.Append(": ");
				line.Append(record[i].message);

				let lineHeight = font.WrapText(line, logWidth) * textScale;

				// TODO: Decide to include or not include it based on the height here. Later we'll have a scroll start and end
				// or maybe just some lines from this! (for first or last line on screen)
				if (height + lineHeight > maxHeight)
					break;

				height += lineHeight;
			}
			logHeight = (.)height;
			logs.Clear();

			if (logHeight == 0)
				return;

			i = (i + 1) % RecordLength;
			if ((iEnd + 1) % RecordLength != i)
				iEnd = (iEnd + 1) % RecordLength;

			// Fill the lines we can fit into the log string
			for (var j = i; j != iEnd; j = (j + 1) % RecordLength)
			{
				let line = scope String(record[j].type.ToString(.. scope .()));
				line.Append(": ");
				line.Append(record[j].message);

				font.WrapText(line, logWidth);

				if (logs.Length > 0)
					logs.Append('\n');

				logs.Append(line);
			}
		}

		public static void Clear()
		{
			for (var rec in record)
				rec.message.Clear();
			writeIndex = 0;
			logDirty = true;
		}

		static void Write(Log.Types type, StringView message)
		{
#if DEBUG
			let thisIndex = writeIndex;

			// Move writeIndex
			if (writeIndex + 1 < RecordLength)
				writeIndex++;
			else writeIndex = 0;

			var msg = ref record[thisIndex];
			msg.message..Set(message)..Trim();
			msg.type = type;

			logDirty = true;
#endif
		}
	}
}
