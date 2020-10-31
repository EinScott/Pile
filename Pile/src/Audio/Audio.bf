using System;

namespace Pile
{
	public abstract class Audio
	{
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
		public abstract String ApiName { get; }
		public abstract String Info { get; }

		internal ~this() {}

		internal abstract Result<void> Initialize();

		// handle mixing?? - well.. central internal stuff, dont know if this is going to happen here yet

		// CreateSpeaker() - dunno about this naming, but i think its better than prepending 'audio' to some generic word
		// CreateSoundClip()

		// Generic class for filters that can work for all?

		// still need to do something that actually play sounds, so we avoid handing out handles
		// ---- no, clips are played on channels, channel is internal bus, busses can lead into other busses??
		// but so audiobus and audiochannel are the same. is that good?? idk
		// should probably be seperated somehow?? one one hand it would be good to have one play sounds, and the other bunde these sources, on the other hand this creates more voices (but that should probably matter less??)
	}
}
