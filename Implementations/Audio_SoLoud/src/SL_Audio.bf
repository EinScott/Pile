using System;
using SoLoud;
using static SoLoud.SL_Soloud;

using internal Pile;

namespace Pile
{
	extension Audio
	{
		// TODO: maybe some debug mode (SL_Bus.SetVisualizationEnable(bus, true);) like graphics

		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SoLoud";

		String info = new String() ~ delete _;
		public override String Info => info;

		MasterBus master ~ delete _;
		public override MasterBus MasterBus => master;

		Backend Backend;
		uint32 MaxVoiceCount;

		internal Soloud* slPtr;
		internal bool spacialDirty;

		Vector3 up = .(0, 1, 0);
		public override Vector3 SpacialListenerUp
		{
			get => up;
			set
			{
				if (up != value)
				{
					up = value;
					Set3dListenerUp(slPtr, value.X, value.Y, value.Z);
					spacialDirty = true;
				}
			}
		}

		Vector3 listener;
		public override Vector3 SpacialListenerPosition
		{
			get => listener;
			set
			{
				if (listener != value)
				{
					listener = value;
					Set3dListenerPosition(slPtr, value.X, value.Y, value.Z);
					spacialDirty = true;
				}
			}
		}

		Vector3 facing;
		public override Vector3 SpacialListenerFacing
		{
			get => facing;
			set
			{
				if (facing != value)
				{
					facing = value;
					Set3dListenerAt(slPtr, value.X, value.Y, value.Z);
					spacialDirty = true;
				}
			}
		}

		Vector3 velocity;
		public override Vector3 SpacialListenerVelocity
		{
			get => velocity;
			set
			{
				if (velocity != value)
				{
					velocity = value;
					Set3dListenerVelocity(slPtr, value.X, value.Y, value.Z);
					spacialDirty = true;
				}
			}
		}

		float soundSpeed = 343; // SoLoud default - assumes 1 using is 1 meter
		public override float SpacialSoundSpeed
		{
			get => soundSpeed;
			set
			{
				if (soundSpeed != value)
				{
					soundSpeed = value;
					Set3dSoundSpeed(slPtr, value);
					spacialDirty = true;
				}
			}
		}

		// When changed, wont apply to sounds that are already played/scheduled
		public override bool SimulateSpacialDelay { get; set; }

		public override uint AudibleSoundCount => (.)GetActiveVoiceCount(slPtr);
		public override uint SoundCount => (.)GetVoiceCount(slPtr);

		this
		{
			Backend = .AUTO;
			MaxVoiceCount = 24;
		}

		internal ~this()
		{
			Deinit(slPtr);
			Destroy(slPtr);
		}

		protected internal override void Initialize()
		{
			// Create master bus (cant do earlier since we need to have Core.Auio assigned)
			master = new MasterBus();

			slPtr = Create();
			Init(slPtr, .CLIP_ROUNDOFF, Backend, AUTO, AUTO, .TWO);
			SetMaxActiveVoiceCount(slPtr, MaxVoiceCount);

			// Version
			let ver = GetVersion(slPtr);
			majVer = (uint32)Math.Floor((float)ver / 100);
			minVer = ver - (majVer * 100);

			// Info
			info.AppendF("backend: {}, buffer size: {}", GetBackendId(slPtr), GetBackendBufferSize(slPtr));
		}

		protected internal override void AfterUpdate()
		{
			if (spacialDirty)
			{
				Update3dAudio(slPtr);
				spacialDirty = false;
			}
		}
	}
}
