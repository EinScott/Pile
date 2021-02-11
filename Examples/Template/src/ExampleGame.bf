using Pile;
using System;

namespace Game
{
	[AlwaysInclude]
	class ExampleGame : Game<ExampleGame>
	{
		static this()
		{
			EntryPoint.GameMain = => Run;
		}

		static Result<void> Run()
		{
			// Start pile with an instance of our game
			Try!(Core.Run(1280, 720, new ExampleGame(), "Example Game"));
		
			return .Ok;
		}

		protected override void Startup()
		{
			Log.Info("Hello!");
		}

		protected override void Update()
		{
			
		}

		protected override void Render()
		{
			Core.Graphics.Clear(Core.Window, .Black);
		}
	}
}