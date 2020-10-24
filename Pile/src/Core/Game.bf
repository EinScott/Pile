using System;

namespace Pile
{
	public abstract class Game<T> : Game where T : Game
	{
		public static T Instance;

		public this()
		{
			Instance = (T)this;
		}
	}

	public abstract class Game
	{
		protected virtual void Startup() {}
		protected virtual void Shutdown() {}

		protected virtual void Update() {}
		protected virtual void Render() {}

		protected virtual void Step() {}
	}
}
