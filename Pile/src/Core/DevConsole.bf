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

		static CircularBuffer<Message> record;

		static CircularBuffer<String> history;
		static String histOrigInput;
		static int currHistLook = -1;

		static String inputLine;
		static String diagnosticLine;
		static String autoComplete;
		static float backDelay;

		static this()
		{
#if DEBUG
			Log.OnLine.Add(new => Write);

			record = new .(64);
			for (int i < record.Capacity)
				record.Add(.());

			history = new .(8);

			histOrigInput = new .();
			inputLine = new .();
			diagnosticLine = new .();
			autoComplete = new .();
#endif
		}

		static ~this()
		{
#if DEBUG
			DeleteContainerAndDisposeItems!(record);
			DeleteContainerAndItems!(history);

			delete histOrigInput;
			delete inputLine;
			delete diagnosticLine;
			delete autoComplete;
#endif
		}

#if !DEBUG
		[SkipCall]
#endif
		public static void Update()
		{
#if DEBUG
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
			{
				inputLine.Clear();
				histOrigInput.Clear();
			}

			// Enter
			if (Input.Keyboard.Pressed(.Enter) && inputLine.Length > 0)
			{
				// Commit to history
				currHistLook = -1;
				var hist = ref history.AddByRef();
				if (hist == null)
					hist = new String(inputLine);
				else hist.Set(inputLine);

				Write(.Info, inputLine);
				Commands.Interpreter.Interpret(inputLine, => Write);

				inputLine.Clear();
				histOrigInput.Clear();
				diagnosticLine.Clear();
				autoComplete.Clear();
			}

			// History
			if (Input.Keyboard.Pressed(.Up))
			{
				let prevLook = currHistLook;
				currHistLook = Math.Min(currHistLook + 1, history.Count - 1);
				if (prevLook == -1 && currHistLook >= 0)
					histOrigInput.Set(inputLine);
				inputLine.Set(history[(history.Count - 1) - currHistLook]);
			}
			else if (Input.Keyboard.Pressed(.Down))
			{
				let prevLook = currHistLook;
				currHistLook = Math.Max(currHistLook - 1, -1);
				if (prevLook != currHistLook)
				{
					if (currHistLook < 0)
						inputLine.Set(histOrigInput);
					else inputLine.Set(history[(history.Count - 1) - currHistLook]);
				}
			}

			// Diagnostics
			diagnosticLine.Clear();
			autoComplete..Clear();
			if (inputLine.Length > 0)
				Commands.Interpreter.Interpret(inputLine, => Write, diagnosticLine, autoComplete);

			if (inputLine.Length > 0 && Input.Keyboard.Pressed(.Tab) && autoComplete.Length > 0)
			{
				var replaceStart = inputLine.LastIndexOf(' ');
				if (replaceStart == -1)
					replaceStart = 0;
				else replaceStart++; // Keep space

				var replace = StringView(autoComplete);
				let replaceEnd = replace.IndexOf(' ');
				if (replaceEnd != -1)
					replace.Length = replaceEnd;

				// If there are multiple options, first complete until they derive
				// If we're already on the point of derivation, pick first one as per default
				var check = StringView(autoComplete);
				var lastSpace = replaceEnd;
				var nextSpace = replaceEnd;
				String common = scope String(replace); // This HAS to include exactly or more than the common chars
				while (nextSpace + 1 < check.Length)
				{
					nextSpace = check.IndexOf(' ', nextSpace + 1);
					bool last = false;
					if (nextSpace == -1)
					{
						nextSpace = check.Length;
						last = true;
					}

					let part = StringView(&check[lastSpace + 1], nextSpace - lastSpace - 1); // Only include between spaces

					if (part.StartsWith('('))
						continue; // Ignore overload indicators

					if (common.Length > part.Length)
						common.RemoveToEnd(part.Length);

					for (let i < part.Length)
					{
						if (i >= common.Length)
							break;

						if (common[i].ToLower != part[i].ToLower)
						{
							common.RemoveToEnd(i);
							break;
						}
					}

					if (last)
						break;
					lastSpace = nextSpace;
				}
				
				bool completeFull = common.Length == inputLine.Length - replaceStart;
				inputLine.RemoveToEnd(replaceStart);
				inputLine.Append(completeFull ? replace : common);
			}
#endif
		}

#if !DEBUG
		[SkipCall]
#endif
		[PerfTrack]
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

			var logPos = inputBox.Position + .(textMargin, -(edgeMargin));
			let logWidth = inputBox.Size.X - (textMargin * 2);

			do if (diagnosticLine.Length > 0 || autoComplete.Length > 0)
			{
				let wDiag = scope String(diagnosticLine);
				let wAuto = scope String(scope $"> {autoComplete}");

				if (wAuto.Length > 2) // "> "
				{
					logPos.Y -= (.)(font.WrapText(wAuto, logWidth / textScale) * textScale);

					if (logPos.Y < rect.Y)
						break;

					batch.Text(font, wAuto, logPos, Vector2(textScale), .Zero, 0);
				}

				logPos.Y -= (.)(font.WrapText(wDiag, logWidth / textScale) * textScale);

				if (logPos.Y < rect.Y)
					break;

				batch.Text(font, wDiag, logPos, Vector2(textScale), .Zero, 0);
				
				logPos.Y -= lineHeight;
			}

			// Render logs
			float y = logPos.Y;
			float maxHeight = logPos.Y - rect.Y - textMargin;
			float height = 0;
			for (var j = record.Count - 1; j >= 0; j--)
			{
				let rec = record[[Unchecked]j];

				// Skip empty/cleared lines
				if (rec.message.Length == 0)
					break;

				let line = scope String(rec.type.GetLogString());
				let typeEnd = line.Length;
				line.Append(rec.message);

				let textHeight = font.WrapText(line, logWidth / textScale) * textScale;

				// TODO: Decide to include or not include it based on the height here. Later we'll have a scroll start and end
				// or maybe just some lines from this! (for first or last line on screen)
				if (height + textHeight > maxHeight)
					break;

				height += textHeight;
				y -= (.)textHeight;
				logPos.Y = (.)Math.Round(y);

				let typeStr = line.Substring(0, typeEnd);
				let logStr = line.Substring(typeEnd);

				Color color;
				switch (rec.type)
				{
				case .Info:
					color = .White;
				case .Warn:
					color = .Yellow;
				case .Error:
					color = .Red;
				}

				let typeDrawEnd = batch.Text(font, typeStr, logPos, Vector2(textScale), 0, color);
				batch.Text(font, logStr, .((.)typeDrawEnd.X, logPos.Y), Vector2(textScale), .Zero, 0);
			}
		}

		public static void Clear()
		{
			for (var rec in record)
				rec.message.Clear();
		}
		
#if DEBUG
		static void Write(Log.Types type, StringView message)
		{
			var msg = ref record.AddByRef();
			msg.message..Set(message)..Trim();
			msg.type = type;
		}
#endif
	}
}
