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
			EntryPoint.Config.gameTitle = "ExamplePileGame";
			EntryPoint.Config.windowTitle = "Example Game Window";
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