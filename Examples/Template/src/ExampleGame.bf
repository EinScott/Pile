using Pile;
using System;

namespace Game
{
	[AlwaysInclude]
	class ExampleGame : Game<ExampleGame>
	{
		static this()
		{
			EntryPoint.Preferences.createGame = () => new ExampleGame();
			EntryPoint.Preferences.gameTitle = "Example Game";
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