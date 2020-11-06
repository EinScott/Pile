using FreeType;

namespace Pile
{
	public class Font
	{
		static Library* lib;

		// ---

		static bool init;
		static void EnsureInit()
		{
			if (!init)
			{
				FreeType.Init(out lib);
				init = true;
			}	
		}

		// remove above when sure its not needed

		static this()
		{
			FreeType.Init(out lib); // handle errors
		}

		static ~this()
		{
			if (lib != null)
				FreeType.Done(lib); // handle errors
		}

		public this()
		{
			Log.Message(lib);
		}
	}
}
