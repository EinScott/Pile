using System;
using System.Diagnostics;

namespace Pile
{
	public abstract class Game<T> : Game where T : Game
	{
		public static T Instance;

		public this()
		{
			Debug.Assert(typeof(T).IsSubtypeOf(typeof(Game)), "T should be the type of the class that inherits from Game<T>");
			Debug.Assert(Instance == null, scope $"{typeof(T)}.Instance already set");

			Instance = (T)this;
		}

		public ~this()
		{
			Instance = null;
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
