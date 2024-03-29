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
			Core.Config.createGame = () => new ExampleGame();
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
		}

		protected override void Update()
		{
			// Move rect by input
			rectPos += .Normalize(input.Value) * rectSpeed * Time.Delta;
		}

		protected override void Render()
		{
			// Clear screen and bacher buffer
			Graphics.Clear(System.Window, .Black);
			batch.Clear();

			// Raw rect at position
			batch.Rect(Rect(Vector2.Round(rectPos) + relativeRect.Position, relativeRect.Size), .Red);

			// Render batch buffer
			batch.Render(System.Window);
		}
	}
}