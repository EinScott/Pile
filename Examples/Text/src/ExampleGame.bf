using Pile;
using System;

namespace Game
{
	[AlwaysInclude]
	class ExampleGame : Game<ExampleGame>
	{
		static this()
		{
			EntryPoint.Config.createGame = () => new ExampleGame();
			EntryPoint.Config.gameTitle = "example";
			EntryPoint.Config.windowTitle = "Example Game";
		}

		Batch2D batch = new .() ~ delete _;
		SpriteFont sf ~ delete _;

		Asset<Subtexture> button = new Asset<Subtexture>("button") ~ delete _;

		bool debugRender;

		protected override void Startup()
		{
			// This is automatically built for us. See BeefProj.toml and Pile/Assets/Packager.bf and Examples/Text/assets/
			Assets.LoadPackage("font");

			let font = Assets.Get<Font>("nunito_semibold");
			sf = new SpriteFont(font, 46, Charsets.ASCII);

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

		protected override void Render()
		{
			// Clear screen and bacher buffer
			Graphics.Clear(System.Window, .Black);
			batch.Clear();

			if (debugRender)
				Perf.Render(batch, sf);

			{
				PerfTrack!("DrawTextSimple");
				// Raw rect at position
				batch.Text(sf, "Sample text... I guess?", .(120, 200), .White);
			}

			{
				PerfTrack!("DrawTextModified");
				// Raw rect at position
				batch.Text(sf, "Hello! I am a text.\nNice to see you.", .(120, 300), .White, .Zero, => SuperCharModifier);
			}

			{
				PerfTrack!("DrawTextMixed");
				// Raw rect at position
				batch.TextMixed(sf, "Press {} to doubt.", Vector2(120, 450), .White, .Zero, => WiggleCharModifier, true, true, button.Asset);
			}

			// Render batch buffer
			batch.Render(System.Window);
		}
	}
}