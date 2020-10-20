using System;

namespace Pile
{
	public abstract class Audio
	{
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
		public abstract String ApiName { get; }

		internal ~this() {}

		internal abstract Result<void> Initialize();

		// handle mixing?? - well.. central internal stuff, dont know if this is going to happen here yet

		// CreateSpeaker() - dunno about this naming, but i think its better than prepending 'audio' to some generic word
		// CreateSoundClip()
	}
}
