using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class MixingBus
	{
		internal abstract class Platform
		{
			internal abstract bool IsMasterBus { get; }

			internal abstract void Initialize(MixingBus bus);
			internal abstract void SetVolume(float volume);

			// Called from other MixingBusses
			internal abstract void AddBus(MixingBus bus);
			internal abstract void RemoveBus(MixingBus bus);

			// Called from AudioSource
			internal abstract void AddSource(AudioSource source);
			internal abstract void RemoveSource(AudioSource source);

			// When this is deleted, things feeding into this bus need to be redirected
			internal abstract void RedirectInputsToMaster();

			// TODO: Filterstuff -- create some abstraction... somewhat like material?
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