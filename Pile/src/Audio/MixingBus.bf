using System;

using internal Pile;

namespace Pile
{
	public class MixingBus
	{
		internal abstract class Platform
		{
			public abstract bool IsMasterBus { get; }

			public abstract void Initialize(MixingBus bus);
			public abstract void SetVolume(float volume);

			// Called from other MixingBusses
			public abstract void AddBus(MixingBus bus);
			public abstract void RemoveBus(MixingBus bus);

			// Called from AudioSource
			public abstract void AddSource(AudioSource source);
			public abstract void RemoveSource(AudioSource source);
		}

		internal readonly Platform platform ~ delete _;

		internal MixingBus output;
		internal float volume;

		/// Returns null only on Audio.MasterBus, otherwise any bus or Audio.MasterBus
		public MixingBus Output
		{
			get => output;
			set
			{
				if (value != null && value == output || platform.IsMasterBus) return;

				if (output != null) output.platform.RemoveBus(this);
				output = value;
				if (output != null) output.platform.AddBus(this);
				else Core.Audio.MasterBus.platform.AddBus(this);
			}
		}

		public float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				platform.SetVolume(Math.Max(0, value));
				volume = value;
			}
		}

		public this()
		{
			AssertInit();

			platform = Core.Audio.CreateMixingBus();
			platform.Initialize(this);
			Output = null; // Default output bus
		}

		// TODO: Filterstuff
	}
}
