using System.Collections;
using System;

using internal Pile;

namespace Pile
{
	enum ButtonState : uint8
	{
		Up = 0,
		Released = 1,
		Pressed = 1 << 1,
		Down = 1 << 2,
	}

	struct InputState
	{
		public Keyboard keyboard;
		public Mouse mouse;
		internal Controller[Input.MaxControllers] controllers = .();
		[Inline]
		public ref Controller GetController(Controllers index) mut => ref controllers[(int)index];

		internal this()
		{
			for (int i = 0; i < controllers.Count; i++)
				controllers[i] = Controller();

			keyboard = Keyboard();
			mouse = Mouse();
		}

		[Inline]
		internal void Dispose()
		{
			keyboard.Dispose();
		}

		internal void Step() mut
		{
			for	(int i = 0; i < controllers.Count; i++)
			{
				if (controllers[i].Connected)
					controllers[i].Step();
			}

			keyboard.Step();
			mouse.Step();
		}

		internal void Copy(InputState from) mut
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
