using System.Collections;
using System;

using internal Pile;

namespace Pile
{
	public class InputState
	{
		public readonly Input input;

		public readonly Keyboard keyboard;
		public readonly Mouse mouse;
		internal readonly Controller[] controllers;
		public Controller GetController(int index) => controllers[index];

		internal this(Input input, int maxControllers)
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

		internal void Step()
		{
			for	(int i = 0; i < controllers.Count; i++)
			{
				if (controllers[i].Connected)
					controllers[i].Step();
			}

			keyboard.Step();
			mouse.Step();
		}

		internal void Copy(InputState from)
		{
			for	(int i = 0; i < controllers.Count; i++)
			{
				if (from.controllers[i].Connected || controllers[i].Connected != from.controllers[i].Connected)
					controllers[i].Copy(from.controllers[i]);
			}

			keyboard.Copy(from.keyboard);
			mouse.Copy(from.mouse);
		}
	}
}
