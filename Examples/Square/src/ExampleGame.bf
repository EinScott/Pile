using Pile;
using System;

namespace Game
{
	// TODO examples for... using audio, fonts, packages

	[AlwaysInclude]
	class ExampleGame : Game<ExampleGame>
	{
		static this()
		{
			Core.Config.gameInstance = new ExampleGame();
			Core.Config.gameTitle = "example";
			Core.Config.windowTitle = "Example Game";
		}

		const float rectSpeed = 140;
		Batch2D batch = new .() ~ delete _;

		// Virtual input of WASD and controller 0
		VirtualStick input = new VirtualStick()..Add(.A, .D, .W, .S)..AddLeftJoystick(0) ~ delete _;

		// Middle of the screen (origin is top left, since we're not using Camera2D or another matrix to translate)
		Vector2 rectPos = .(1280 / 2, 720 / 2);
		Rect relativeRect = Rect(-40, -40, 80, 80);

		protected override void Startup()
		{
			Log.Info("Hello!");

			// todo: no need to load default stuff anymore, but this is kind of a good example... load some png here?

			// This is automatically built for us. See BeefProj.toml and Pile/Core/EntryPoint.bf @ RunPackager
			//Assets.LoadPackage("shaders");
		}

		protected override void Update()
		{
			// Move rect by input
			rectPos += input.Value.Normalize() * rectSpeed * Time.Delta;
		}

		protected override void Render()
		{
			// Clear screen and bacher buffer
			Graphics.Clear(System.Window, .Black);
			batch.Clear();

			// Raw rect at position
			batch.Rect(Rect(rectPos.Round() + relativeRect.Position, relativeRect.Size), .Red);

			// Render batch buffer
			batch.Render(System.Window);
		}
	}
}