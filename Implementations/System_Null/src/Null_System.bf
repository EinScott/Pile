using System;

using internal Pile;

namespace Pile
{
	extension System
	{
		public static override String ApiName => "Null System";
		public static override String Info => String.Empty;

		static this()
		{
			MajorVersion = 1;
			MinorVersion = 0;
		}

		[SkipCall]
		protected internal static override void Initialize()
		{
			displays.Add(new Display());
		}	

		protected internal override static void Destroy()
		{

		}

		[SkipCall]
		protected internal static override void Step() {}
	}
}
