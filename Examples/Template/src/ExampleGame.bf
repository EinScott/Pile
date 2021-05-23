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
			Core.Config.gameTitle = "ExamplePileGame";
			Core.Config.windowTitle = "Example Game Window";
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
			Graphics.Clear(System.Window, .Black);
		}
	}
}