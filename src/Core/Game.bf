using System;

namespace Pile
{
	public abstract class Game<T> : Game where T : class
	{
		public static T Instance;
	}

	public abstract class Game
	{
		protected virtual void Startup() {}
		protected virtual void Shutdown() {}

		protected virtual void Update() {}
		//public virtual void Render() {} -- implementation details to be done
	}
}
