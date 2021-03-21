using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class MixingBus : AudioBus
	{
		internal AudioBus output;

		float volume = 1;

		/// Returns Audio.MasterBus by default. Won't be null
		public AudioBus Output => output;

		public override float Volume
		{
			get => volume;
			set
			{
				if (value == volume) return;

				SetVolume(Math.Max(0, value));
				volume = value;
			}
		}

		public this(MixingBus output = null)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");

			Initialize();

			this.output = output == null ? output : Audio.MasterBus;
			Output.AddBus(this);
		}

		public ~this()
		{
			Output.RemoveBus(this);
			RedirectInputsToMaster();
		}

		// When this is deleted, things feeding into this bus need to be redirected
		protected internal extern void RedirectInputsToMaster();

		// TODO: Filterstuff -- create some abstraction... somewhat like material?
		// -> do here and in MasterBus. Public api should be enforced by IAudioBus
	}
}
