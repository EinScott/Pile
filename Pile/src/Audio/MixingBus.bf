using System;
using System.Diagnostics;

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

			// When this is deleted, things feeding into this bus need to be redirected
			public abstract void RedirectInputsToMaster();

			// TODO: Filterstuff
		}

		internal readonly Platform platform ~ delete _;
		internal MixingBus output;

		float volume = 1;

		/// Returns Audio.MasterBus by default. Won't be null
		public MixingBus Output => output;

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

		public this(MixingBus output = null)
		{
			Debug.Assert(Core.Audio != null, "Core needs to be initialized before creating platform dependant objects");

			platform = Core.Audio.CreateMixingBus();
			platform.Initialize(this);

			if (!platform.IsMasterBus)
			{
				this.output = output??Core.Audio.MasterBus;
				Output.platform.AddBus(this);
			}
		}

		public ~this()
		{
			if (!platform.IsMasterBus)
			{
				Output.platform.RemoveBus(this);
				platform.RedirectInputsToMaster();
			}
		}
	}
}
