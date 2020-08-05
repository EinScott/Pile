using System.Collections;
using System;

namespace Pile
{
	public class InputState
	{
		public readonly Input input;

		public readonly Keyboard keyboard;
		public readonly Mouse mouse;
		readonly Controller[] controllers;
		public Controller GetController(int index) => controllers[index];

		public this(Input input, int maxControllers)
		{
			this.input = input;

			controllers = new Controller[maxControllers];
			for (int i = 0; i < controllers.Count; i++)
				controllers[i] = new Controller(input);

			keyboard = new Keyboard(input);
			mouse = new Mouse();
		}

		public ~this()
		{
			delete keyboard;
			delete mouse;

			for	(int i = 0; i < controllers.Count; i++)
				delete controllers[i];
			delete controllers;
		}

		void Step()
		{
			for	(int i = 0; i < controllers.Count; i++)
			{
				if (controllers[i].Connected)
					controllers[i].[Friend]Step();
			}

			keyboard.[Friend]Step();
			mouse.[Friend]Step();
		}

		void Copy(InputState from)
		{
			for	(int i = 0; i < controllers.Count; i++)
			{
				if (from.controllers[i].Connected || controllers[i].Connected != from.controllers[i].Connected)
					controllers[i].[Friend]Copy(from.controllers[i]);
			}

			keyboard.[Friend]Copy(from.keyboard);
			mouse.[Friend]Copy(from.mouse);
		}
	}
}
