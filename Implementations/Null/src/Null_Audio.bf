using System;

using internal Pile;

namespace Pile
{
	extension Audio
	{
		public override uint32 MajorVersion => 1;
		public override uint32 MinorVersion => 0;

		public override String ApiName => "Null Audio";

		public override String Info => String.Empty;

		MasterBus masterBus ~ delete _;
		public override MasterBus MasterBus => masterBus;

		public override uint SoundCount => 0;

		public override uint AudibleSoundCount => 0;

		protected internal override void Initialize()
		{
			masterBus = new MasterBus();
		}
	}
}
