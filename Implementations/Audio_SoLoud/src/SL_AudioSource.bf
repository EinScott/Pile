using SoLoud;

namespace Pile
{
	extension AudioSource
	{
		// slightly confusingly, Pile.AudioSource doesnt correspond to a SoLoud AudioSource, but rather something like a Voice playing interface

		internal uint32 slBusHandle; // external only. Is set when this is played on SoLoud or another Bus, used again when removing
		internal Bus* slBus;
	}
}
