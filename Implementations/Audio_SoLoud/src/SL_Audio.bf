using System;
using SoLoud;
using static SoLoud.SL_Soloud;

using internal Pile;

namespace Pile
{
	extension Audio
	{
		public static override String ApiName => "SoLoud";

		static String info = new String() ~ delete _;
		public static override String Info => info;

		static MasterBus master;
		[Inline]
		public static override MasterBus MasterBus => master;

		static Backend Backend;
		static uint32 MaxVoiceCount;

		internal static Soloud* slPtr;
		internal static bool spacialDirty;

		static Vector3 up = .(0, 1, 0);
		public static override Vector3 SpacialListenerUp
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

		static Vector3 listener;
		public static override Vector3 SpacialListenerPosition
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

		static Vector3 facing;
		public static override Vector3 SpacialListenerFacing
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

		static Vector3 velocity;
		public static override Vector3 SpacialListenerVelocity
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

		static float soundSpeed = 343; // SoLoud default - assumes 1 using is 1 meter
		public static override float SpacialSoundSpeed
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
		public static override bool SimulateSpacialDelay { get; set; }

		public static override uint AudibleSoundCount => (.)GetActiveVoiceCount(slPtr);
		public static override uint SoundCount => (.)GetVoiceCount(slPtr);

		static this()
		{
			// Version
			let ver = GetVersion(slPtr);
			MajorVersion = (uint32)Math.Floor((float)ver / 100);
			MinorVersion = ver - (MajorVersion * 100);

			Backend = .AUTO;
			MaxVoiceCount = 24;
		}

		protected internal static override void Destroy()
		{
			delete master;

			SL_Soloud.Deinit(slPtr);
			SL_Soloud.Destroy(slPtr);
		}

		protected internal static override void Initialize()
		{
			// Create master bus (cant do earlier since we need to have Core.Auio assigned)
			master = new MasterBus();

			slPtr = Create();
			Init(slPtr, .CLIP_ROUNDOFF, Backend, AUTO, AUTO, .TWO);
			SetMaxActiveVoiceCount(slPtr, MaxVoiceCount);

			// Info
			info.AppendF("backend: {}, buffer size: {}", GetBackendId(slPtr), GetBackendBufferSize(slPtr));
		}

		protected internal static override void AfterUpdate()
		{
			if (spacialDirty)
			{
				Update3dAudio(slPtr);
				spacialDirty = false;
			}
		}
	}
}
