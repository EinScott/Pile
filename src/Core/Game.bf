using System;

namespace Pile
{
	public abstract class Game<T> : Game
	{

	}

	public abstract class Game
	{
		protected virtual void Startup()
		{
			Core.Window.Transparent = true;
			Core.Window.Resizable = true;
			Core.Window.Visible = false;
			Core.Window.OnFocusChanged.Add(new => Do);
			Core.Window.OnMoved.Add(new => Do);
			Core.Window.OnResized.Add(new => Do);
		}
		protected virtual void Shutdown() {}

		protected virtual void Update() {if(!Core.Window.Visible) Console.WriteLine("dd");}
		//public virtual void Render() {} -- implementation details to be done

	 	void Do()
		{
			Console.WriteLine(Core.Window.Focus);
			Console.WriteLine(Core.Window.Visible);
			Console.WriteLine(Core.Window.Size);
			Console.WriteLine(Core.Window.Position);
		}
	}
}
