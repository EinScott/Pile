using System;

using internal Pile;

namespace Pile
{
	public abstract class Audio
	{
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
		public abstract String ApiName { get; }
		public abstract String Info { get; }

		// insert main mixingBus here

		internal ~this() {}

		internal abstract Result<void> Initialize();

		internal abstract AudioSource.Platform CreateAudioSource();
		internal abstract AudioClip.Platform CreateAudioClip();
		internal abstract MixingBus.Platform CreateMixingBus();


		// handle mixing?? - well.. central internal stuff, dont know if this is going to happen here yet

		// Generic class for filters that can work for all? -- yeah should probably do something like that
		// question is, how does the implementation acutally hook filters up to that interface?

		// dont hand out handles
	}
}
