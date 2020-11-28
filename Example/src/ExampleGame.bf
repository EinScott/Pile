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
			// Register builtin importer. See assets/shaders.json or documentation on Packages
			Packages.RegisterImporter("raw", new RawImporter());

			// Register our function to be called on main
			EntryPoint.GameMain = => Run;
		}

		static Result<void> Run()
		{
			// Start pile with an instance of our game
			Core.Initialize("Example Game Window",
				new Pile.Implementations.SDL_System(),
				new Pile.Implementations.GL_Graphics(),
				new Pile.Implementations.SL_Audio(),
				1280, 720);

			Core.Start(new ExampleGame());
		
			return .Ok;
		}

		const float rectSpeed = 140;

		Shader batchShader ~ delete _;
		Material batchMat ~ delete _;
		Batch2D batch ~ delete _;

		// Virtual input of WASD and controller 0
		VirtualStick input = new VirtualStick()..Add(.A, .D, .W, .S)..AddLeftJoystick(0) ~ delete _;

		// Middle of the screen (origin is top left, since we're not using Camera2D or another matrix to translate)
		Vector2 rectPos = .(1280 / 2, 720 / 2);
		Rect relativeRect = Rect(-40, -40, 80, 80);

		protected override void Startup()
		{
			Log.Message("Hello!");

			// This is automatically built for us. See BeefProj.toml and Pile/Core/EntryPoint.bf @ RunPackager
			Packages.LoadPackage("shaders");

			// Setup default shader for drawing with Batch2D
			let source = scope ShaderData(Assets.Get<RawAsset>("s_batch2dVert").text, Assets.Get<RawAsset>("s_batch2dFrag").text); 
			batchShader = new Shader(source);
			batchMat = new Material(batchShader);

			batch = new Batch2D(batchMat);

			Packages.UnloadPackage("shaders"); // No need to have shader source code loaded anymore
		}

		protected override void Update()
		{
			// Move rect by input
			rectPos += input.Value.Normalized() * rectSpeed * Time.Delta;
		}

		protected override void Render()
		{
			// Clear screen and bacher buffer
			Core.Graphics.Clear(Core.Window, .Black);
			batch.Clear();

			// Raw rect at position
			batch.Rect(Rect(rectPos.Round() - relativeRect.Position, relativeRect.Size), .Red);

			// Render batch buffer
			batch.Render(Core.Window);
		}
	}
}
