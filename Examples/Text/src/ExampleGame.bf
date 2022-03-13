using Pile;
using System;

namespace Game
{
	[AlwaysInclude]
	class ExampleGame : Game<ExampleGame>
	{
		static this()
		{
			Core.Config.createGame = () => new ExampleGame();
			Core.Config.gameTitle = "example";
			Core.Config.windowTitle = "Example Game";
		}

		Batch2D batch = new .() ~ delete _;
		SpriteFont debugFont ~ delete _;

		// This is always a reference to the asset with that name if it's loaded
		Asset<Subtexture> button = Asset<Subtexture>("button");

		bool debugRender;

		protected override void Startup()
		{
			// This is automatically built for us. See BeefProj.toml and Pile/Assets/Packager.bf and Examples/Text/assets/
			Assets.LoadPackage("font");

			let font = Assets.Get<Font>("nunito_semibold");
			debugFont = new SpriteFont(font, 46, Charsets.ASCII);

			Assets.UnloadPackage("font");

			Assets.LoadPackage("content");

			Perf.Track = true;
		}

		protected override void Shutdown()
		{
			Assets.UnloadPackage("content");
		}

		protected override void Update()
		{
			if (Input.Keyboard.Pressed(.F1)) // Press F1 for performance info
				debugRender = !debugRender;
		}

		public static CharModifier WiggleCharModifier(Vector2 currPos, int index, char32 char)
		{
			const int MAGNITUDE = 4;
			const int FREQUENCY = 14;
			const int SPEED = 5;

			return .(.(0, Math.Sin((.)Time.Duration.TotalSeconds * SPEED + index * FREQUENCY) * MAGNITUDE), .One, 0, .White);
		}

		public static CharModifier RollCharModifier(Vector2 currPos, int index, char32 char)
		{
			const int SPEED = 5;

			return .(.Zero, .One, (.)Time.Duration.TotalSeconds * SPEED, .White);
		}

		public static CharModifier WobbleCharModifier(Vector2 currPos, int index, char32 char)
		{
			const float MAGNITUDE = 4; // Smaller is more extreme here
			const float FREQUENCY = 0.2f;
			const int SPEED = 4;

			return .(.Zero, .One * (1f - ((Math.Sin((float)Time.Duration.TotalSeconds * SPEED + index * FREQUENCY) + 1) / MAGNITUDE)), 0, .White);
		}

		public static CharModifier ColorfulCharModifier(Vector2 currPos, int index, char32 char)
		{
			const float FREQUENCY = 0.2f;
			const int SPEED = 4;

			return .(.Zero, .One, 0, .(
				0.5f + 0.5f * (Math.Sin((.)Time.Duration.TotalSeconds * SPEED + index * FREQUENCY)),
				0.5f + 0.5f * (Math.Sin((.)Time.Duration.TotalSeconds * SPEED + Math.PI_f / 3 + index * FREQUENCY)),
				0.5f + 0.5f * (Math.Sin((.)Time.Duration.TotalSeconds * SPEED + 2 * Math.PI_f / 3 + index * FREQUENCY)), 1f));
		}

		public static CharModifier SuperCharModifier(Vector2 currPos, int index, char32 char)
		{
			return WiggleCharModifier(currPos, index, char) + WobbleCharModifier(currPos, index, char) + ColorfulCharModifier(currPos, index, char);
		}

		const Rect textBox = .(600, 200, 300, 100);
		const Rect textBox2 = .(600, 400, 400, 200);

		protected override void Render()
		{
			// Clear screen and bacher buffer
			Graphics.Clear(System.Window, .Black);
			batch.Clear();

			if (debugRender)
				Perf.Render(batch, debugFont);

			// Sometimes we need to get the longer overloads here when we
			// have to specify that we want to treat the inserted texture
			// like the char glyphs themselves. This wouldn't matter if we
			// weren't rendering onto a blank cleared screen

			{
				PerfTrack("DrawTextSimple");
				batch.Text(debugFont, "Sample text... I guess?", .(120, 200), .White);
			}

			{
				PerfTrack("DrawTextModified");
				batch.Text(debugFont, "Hello! I am a text.\nNice to see you.", .(120, 300), .White, .Zero, => SuperCharModifier);
			}

			{
				PerfTrack("DrawTextMixed");
				batch.TextMixed(debugFont, "Press {0} to doubt. {0}", Vector2(120, 450), .White, .Zero, => WiggleCharModifier, true, true, button.Asset);
			}

			batch.HollowRect(textBox, 2, .DarkGray);
			{
				PerfTrack("DrawTextFramed");
				batch.TextFramed(debugFont, "Hello I am a text.\nI squeeze in here somehow.\nWeird...", textBox, .White);
			}

			batch.HollowRect(textBox2, 2, .DarkGray);
			{
				PerfTrack("DrawTextMixedFramed");
				batch.TextMixedFramed(debugFont, "I found this button today: {}\n it looked very {{interesting}}!\nDoesn't it?\nI think so at least.", textBox2, .Gray, .Gray, .Zero, 0, null, true, true, button.Asset);
			}

			{
				PerfTrack("DrawTextMixedFramedModified");
				batch.TextMixedFramed(debugFont, "I found this button today: {}\n it looked very {{interesting}}!\nDoesn't it?\nI think so at least.", textBox2, .White, .White, .Zero, 0, => SuperCharModifier, true, true, button.Asset);
			}

			// Render batch
			batch.Render(System.Window);
		}
	}
}