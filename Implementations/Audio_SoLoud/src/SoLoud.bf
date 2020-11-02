using System;

namespace SoLoud
{
	public class Soloud;
	public class WavStream;
	public class Bus;
	public class Queue;

	// Audio Sources (void* audiosource)
	public class Wav;
	public class Vizsn;
	public class Vic;
	public class TedSid;
	public class Speech;
	public class Sfxr;
	public class Openmpt;
	public class Noise;
	public class Monotone;
	public class Ay;

	// Filters (void* filter)
	public class WaveShaperFilter;
	public class RobotizeFilter;
	public class LofiFilter;
	public class FreeverbFilter;
	public class FlangerFilter;
	public class FFTFilter;
	public class EchoFilter;
	public class DCRemovalFilter;
	public class BiquadResonantFilter;
	public class BassboostFilter;

	public enum SoLoudResult : int32
	{
		OK = 0,

		INVALIDPARAMETER = 1,
		FILENOTFOUND = 2,
		FILELOADFAILED = 3,
		DLLNOTFOUND = 4,
		OUTOFMEMORY = 5,
		NOTIMPLEMENTED = 6,
		UNKNOWNERROR = 7
	}

	public enum FilterParameterTypes : uint32
	{
		FLOAT = 0,
		INT = 1,
		BOOL = 2
	}

	public enum Resampler : uint32
	{
		POINT = 0,
		LINEAR = 1,
		CATMULLROM = 2
	}
	
	public enum Waveform : int32
	{
		SQUARE = 0,
		SAW = 1,
		SIN = 2,
		TRIANGLE = 3,
		BOUNCE = 4,
		JAWS = 5,
		HUMPS = 6,
		FSQUARE = 7,
		FSAW = 8
	}

	static
	{
		public static bool ResultIsError(SoLoudResult check, out SoLoudResult res)
		{
			res = check;
			if (check == .OK) return false;

			return true;
		}

		public const int32 SL_TRUE = 1;
		public const int32 SL_FALSE = 0;
	}

	public static class SL_Soloud
	{
		public enum Backend : uint32
		{
			AUTO = 0,
			SDL1 = 1,
			SDL2 = 2,
			PORTAUDIO = 3,
			WINMM = 4,
			XAUDIO2 = 5,
			WASAPI = 6,
			ALSA = 7,
			JACK = 8,
			OSS = 9,
			OPENAL = 10,
			COREAUDIO = 11,
			OPENSLES = 12,
			VITA_HOMEBREW = 13,
			MINIAUDIO = 14,
			NOSOUND = 15,
			NULLDRIVER = 16
		}

		public enum Flags : uint32
		{
			CLIP_ROUNDOFF = 1,
			ENABLE_VISUALIZATION = 2,
			LEFT_HANDED_3D = 4,
			NO_FPU_REGISTER_CHANGE = 8
		}

		public enum Channels : uint32
		{
			ONE = 1,
			TWO = 2,
			FOUR = 4,
			SIX = 6,
			EIGHT = 8
		}

		
		public const uint32 BACKEND_MAX = 17;
		public const uint32 AUTO = 0;

		[LinkName("Soloud_destroy")]
		public static extern void Destroy(Soloud* soloud);

		[LinkName("Soloud_create")]
		public static extern Soloud* Create();

		[LinkName("Soloud_init")]
		public static extern SoLoudResult Init(Soloud* soloud);

		[LinkName("Soloud_initEx")]
		public static extern SoLoudResult Init(Soloud* soloud, Flags flags = .CLIP_ROUNDOFF, Backend backend = .AUTO, uint32 samplerate = AUTO, uint32 bufferSize = AUTO, Channels channels = .TWO);

		[LinkName("Soloud_deinit")]
		public static extern void Deinit(Soloud* soloud);

		[LinkName("Soloud_getVersion")]
		public static extern uint32 GetVersion(Soloud* soloud);

		[LinkName("Soloud_getErrorString")]
		public static extern char8* GetErrorString(Soloud* soloud, SoLoudResult errorCode);

		[LinkName("Soloud_getBackendId")]
		public static extern Backend GetBackendId(Soloud* soloud);

		[LinkName("Soloud_getBackendString")]
		public static extern char8* GetBackendString(Soloud* soloud);

		[LinkName("Soloud_getBackendChannels")]
		public static extern uint32 GetBackendChannels(Soloud* soloud);

		[LinkName("Soloud_getBackendSamplerate")]
		public static extern uint32 GetBackendSamplerate(Soloud* soloud);

		[LinkName("Soloud_getBackendBufferSize")]
		public static extern uint32 GetBackendBufferSize(Soloud* soloud);

		[LinkName("Soloud_setSpeakerPosition")]
		public static extern SoLoudResult SetSpeakerPosition(Soloud* soloud, uint32 channel, float x, float y, float z);

		[LinkName("Soloud_getSpeakerPosition")]
		public static extern SoLoudResult GetSpeakerPosition(Soloud* soloud, uint32 channel, float* x, float* y, float* z);

		[LinkName("Soloud_play")]
		public static extern uint32 Play(Soloud* soloud, void* sound);

		[LinkName("Soloud_playEx")]
		public static extern uint32 Play(Soloud* soloud, void* sound, float volume, float pan, int32 paused, uint32 bus);

		[LinkName("Soloud_playClocked")]
		public static extern uint32 PlayClocked(Soloud* soloud, double soundTime, void* sound);

		[LinkName("Soloud_playClockedEx")]
		public static extern uint32 PlayClocked(Soloud* soloud, double soundTime, void* sound, float volume, float pan, uint32 bus);

		[LinkName("Soloud_play3d")]
		public static extern uint32 Play3d(Soloud* soloud, void* sound, float posX, float posY, float posZ);

		[LinkName("Soloud_play3dEx")]
		public static extern uint32 Play3d(Soloud* soloud, void* sound, float posX, float posY, float posZ, float velX, float velY, float velZ, float volume, bool paused, uint32 bus);

		[LinkName("Soloud_play3dClocked")]
		public static extern uint32 Play3dClocked(Soloud* soloud, double soundTime, void* sound, float posX, float posY, float posZ);

		[LinkName("Soloud_play3dClockedEx")]
		public static extern uint32 Play3dClocked(Soloud* soloud, double soundTime, void* sound, float posX, float posY, float posZ, float velX, float velY, float velZ, float volume, uint32 bus);

		[LinkName("Soloud_playBackground")]
		public static extern uint32 PlayBackground(Soloud* soloud, void* sound);

		[LinkName("Soloud_playBackgroundEx")]
		public static extern uint32 PlayBackground(Soloud* soloud, void* sound, float volume, bool paused, uint32 bus);

		[LinkName("Soloud_seek")]
		public static extern SoLoudResult Seek(Soloud* soloud, uint32 voiceHandle, double seconds);

		[LinkName("Soloud_stop")]
		public static extern void Stop(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_stopAll")]
		public static extern void StopAll(Soloud* soloud);

		[LinkName("Soloud_stopAudioSource")]
		public static extern void StopAudioSource(Soloud* soloud, void* sound);

		[LinkName("Soloud_countAudioSource")]
		public static extern SoLoudResult CountAudioSource(Soloud* soloud, void* sound);

		[LinkName("Soloud_setFilterParameter")]
		public static extern void SetFilterParameter(Soloud* soloud, uint32 voiceHandle, uint32 filterId, uint32 attributeId, float value);

		[LinkName("Soloud_getFilterParameter")]
		public static extern float GetFilterParameter(Soloud* soloud, uint32 voiceHandle, uint32 filterId, uint32 attributeId);

		[LinkName("Soloud_fadeFilterParameter")]
		public static extern void FadeFilterParameter(Soloud* soloud, uint32 voiceHandle, uint32 filterId, uint32 attributeId, float to, double time);

		[LinkName("Soloud_oscillateFilterParameter")]
		public static extern void OscillateFilterParameter(Soloud* soloud, uint32 voiceHandle, uint32 filterId, uint32 attributeId, float from, float to, double time);

		[LinkName("Soloud_getStreamTime")]
		public static extern double GetStreamTime(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getStreamPosition")]
		public static extern double GetStreamPosition(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getPause")]
		public static extern SoLoudResult GetPause(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getVolume")]
		public static extern float GetVolume(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getOverallVolume")]
		public static extern float GetOverallVolume(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getPan")]
		public static extern float GetPan(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getSamplerate")]
		public static extern float GetSamplerate(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getProtectVoice")]
		public static extern int32 GetProtectVoice(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getActiveVoiceCount")]
		public static extern uint32 GetActiveVoiceCount(Soloud* soloud);

		[LinkName("Soloud_getVoiceCount")]
		public static extern uint32 GetVoiceCount(Soloud* soloud);

		[LinkName("Soloud_isValidVoiceHandle")]
		public static extern int32 IsValidVoiceHandle(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getRelativePlaySpeed")]
		public static extern float GetRelativePlaySpeed(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getPostClipScaler")]
		public static extern float GetPostClipScaler(Soloud* soloud);

		[LinkName("Soloud_getMainResampler")]
		public static extern Resampler GetMainResampler(Soloud* soloud);

		[LinkName("Soloud_getGlobalVolume")]
		public static extern float GetGlobalVolume(Soloud* soloud);

		[LinkName("Soloud_getMaxActiveVoiceCount")]
		public static extern uint32 GetMaxActiveVoiceCount(Soloud* soloud);

		[LinkName("Soloud_getLooping")]
		public static extern int32 GetLooping(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getAutoStop")]
		public static extern int32 GetAutoStop(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getLoopPoint")]
		public static extern double GetLoopPoint(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_setLoopPoint")]
		public static extern void SetLoopPoint(Soloud* soloud, uint32 voiceHandle, double loopPoint);

		[LinkName("Soloud_setLooping")]
		public static extern void SetLooping(Soloud* soloud, uint32 voiceHandle, int32 looping);

		[LinkName("Soloud_setAutoStop")]
		public static extern void SetAutoStop(Soloud* soloud, uint32 voiceHandle, int32 autoStop);

		[LinkName("Soloud_setMaxActiveVoiceCount")]
		public static extern SoLoudResult SetMaxActiveVoiceCount(Soloud* soloud, uint32 voiceCount);

		[LinkName("Soloud_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Soloud* soloud, uint32 voiceHandle, int32 mustTick, int32 kill);

		[LinkName("Soloud_setGlobalVolume")]
		public static extern void SetGlobalVolume(Soloud* soloud, float volume);

		[LinkName("Soloud_setPostClipScaler")]
		public static extern void SetPostClipScaler(Soloud* soloud, float scaler);

		[LinkName("Soloud_setMainResampler")]
		public static extern void SetMainResampler(Soloud* soloud, Resampler resampler);

		[LinkName("Soloud_setPause")]
		public static extern void SetPause(Soloud* soloud, uint32 voiceHandle, int32 pause);

		[LinkName("Soloud_setPauseAll")]
		public static extern void SetPauseAll(Soloud* soloud, int32 pause);

		[LinkName("Soloud_setRelativePlaySpeed")]
		public static extern SoLoudResult SetRelativePlaySpeed(Soloud* soloud, uint32 voiceHandle, float speed);

		[LinkName("Soloud_setProtectVoice")]
		public static extern void SetProtectVoice(Soloud* soloud, uint32 voiceHandle, int32 protect);

		[LinkName("Soloud_setSamplerate")]
		public static extern void SetSamplerate(Soloud* soloud, uint32 voiceHandle, float samplerate);

		[LinkName("Soloud_setPan")]
		public static extern void SetPan(Soloud* soloud, uint32 voiceHandle, float pan);

		[LinkName("Soloud_setPanAbsolute")]
		public static extern void SetPanAbsolute(Soloud* soloud, uint32 voiceHandle, float lVolume, float rVolume);

		[LinkName("Soloud_setChannelVolume")]
		public static extern void SetChannelVolume(Soloud* soloud, uint32 voiceHandle, uint32 channel, float volume);

		[LinkName("Soloud_setVolume")]
		public static extern void SetVolume(Soloud* soloud, uint32 voiceHandle, float volume);

		[LinkName("Soloud_setDelaySamples")]
		public static extern void SetDelaySamples(Soloud* soloud, uint32 voiceHandle, uint32 samples);

		[LinkName("Soloud_fadeVolume")]
		public static extern void FadeVolume(Soloud* soloud, uint32 voiceHandle, float to, double time);

		[LinkName("Soloud_fadePan")]
		public static extern void FadePan(Soloud* soloud, uint32 voiceHandle, float to, double time);

		[LinkName("Soloud_fadeRelativePlaySpeed")]
		public static extern void FadeRelativePlaySpeed(Soloud* soloud, uint32 voiceHandle, float to, double time);

		[LinkName("Soloud_fadeGlobalVolume")]
		public static extern void FadeGlobalVolume(Soloud* soloud, float to, double time);

		[LinkName("Soloud_schedulePause")]
		public static extern void SchedulePause(Soloud* soloud, uint32 voiceHandle, double time);

		[LinkName("Soloud_scheduleStop")]
		public static extern void ScheduleStop(Soloud* soloud, uint32 voiceHandle, double time);

		[LinkName("Soloud_oscillateVolume")]
		public static extern void OscillateVolume(Soloud* soloud, uint32 voiceHandle, float from, float to, double time);

		[LinkName("Soloud_oscillatePan")]
		public static extern void OscillatePan(Soloud* soloud, uint32 voiceHandle, float from, float to, double time);

		[LinkName("Soloud_oscillateRelativePlaySpeed")]
		public static extern void OscillateRelativePlaySpeed(Soloud* soloud, uint32 voiceHandle, float from, float to, double time);

		[LinkName("Soloud_oscillateGlobalVolume")]
		public static extern void OscillateGlobalVolume(Soloud* soloud, float from, float to, double time);

		[LinkName("Soloud_setGlobalFilter")]
		public static extern void SetGlobalFilter(Soloud* soloud, uint32 filterId, void* filter);

		[LinkName("Soloud_setVisualizationEnable")]
		public static extern void SetVisualizationEnable(Soloud* soloud, int32 enable);

		[LinkName("Soloud_calcFFT")]
		public static extern float* CalcFFT(Soloud* soloud);

		[LinkName("Soloud_getWave")]
		public static extern float* GetWave(Soloud* soloud);

		[LinkName("Soloud_getApproximateVolume")]
		public static extern float GetApproximateVolume(Soloud* soloud, uint32 channel);

		[LinkName("Soloud_getLoopCount")]
		public static extern uint32 GetLoopCount(Soloud* soloud, uint32 voiceHandle);

		[LinkName("Soloud_getInfo")]
		public static extern float GetInfo(Soloud* soloud, uint32 voiceHandle, uint32 infoKey);

		[LinkName("Soloud_createVoiceGroup")]
		public static extern uint32 CreateVoiceGroup(Soloud* soloud);

		[LinkName("Soloud_destroyVoiceGroup")]
		public static extern SoLoudResult DestroyVoiceGroup(Soloud* soloud, uint32 voiceGroupHandle);

		[LinkName("Soloud_addVoiceToGroup")]
		public static extern SoLoudResult AddVoiceToGroup(Soloud* soloud, uint32 voiceGroupHandle, uint32 voiceHandle);

		[LinkName("Soloud_isVoiceGroup")]
		public static extern SoLoudResult IsVoiceGroup(Soloud* soloud, uint32 voiceGroupHandle);

		[LinkName("Soloud_isVoiceGroupEmpty")]
		public static extern bool IsVoiceGroupEmpty(Soloud* soloud, uint32 voiceGroupHandle);

		[LinkName("Soloud_update3dAudio")]
		public static extern void Update3dAudio(Soloud* soloud);

		[LinkName("Soloud_set3dSoundSpeed")]
		public static extern SoLoudResult Set3dSoundSpeed(Soloud* soloud, float speed);

		[LinkName("Soloud_get3dSoundSpeed")]
		public static extern float Get3dSoundSpeed(Soloud* soloud);

		[LinkName("Soloud_set3dListenerParameters")]
		public static extern void Set3dListenerParameters(Soloud* soloud, float posX, float posY, float posZ, float atX, float atY, float atZ, float upX, float upY, float upZ);

		[LinkName("Soloud_set3dListenerParametersEx")]
		public static extern void Set3dListenerParameters(Soloud* soloud, float posX, float posY, float posZ, float atX, float atY, float atZ, float upX, float upY, float upZ, float velocityX, float velocityY, float velocityZ);

		[LinkName("Soloud_set3dListenerPosition")]
		public static extern void Set3dListenerPosition(Soloud* soloud, float posX, float posY, float posZ);

		[LinkName("Soloud_set3dListenerAt")]
		public static extern void Set3dListenerAt(Soloud* soloud, float atX, float atY, float atZ);

		[LinkName("Soloud_set3dListenerUp")]
		public static extern void Set3dListenerUp(Soloud* soloud, float upX, float upY, float upZ);

		[LinkName("Soloud_set3dListenerVelocity")]
		public static extern void Set3dListenerVelocity(Soloud* soloud, float velocityX, float velocityY, float velocityZ);

		[LinkName("Soloud_set3dSourceParameters")]
		public static extern void Set3dSourceParameters(Soloud* soloud, uint32 voiceHandle, float posX, float posY, float posZ);

		[LinkName("Soloud_set3dSourceParametersEx")]
		public static extern void Set3dSourceParameters(Soloud* soloud, uint32 voiceHandle, float posX, float posY, float posZ, float velocityX, float velocityY, float velocityZ);

		[LinkName("Soloud_set3dSourcePosition")]
		public static extern void Set3dSourcePosition(Soloud* soloud, uint32 voiceHandle, float posX, float posY, float posZ);

		[LinkName("Soloud_set3dSourceVelocity")]
		public static extern void Set3dSourceVelocity(Soloud* soloud, uint32 voiceHandle, float velocityX, float velocityY, float velocityZ);

		[LinkName("Soloud_set3dSourceMinMaxDistance")]
		public static extern void Set3dSourceMinMaxDistance(Soloud* soloud, uint32 voiceHandle, float minDistance, float maxDistance);

		[LinkName("Soloud_set3dSourceAttenuation")]
		public static extern void Set3dSourceAttenuation(Soloud* soloud, uint32 voiceHandle, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Soloud_set3dSourceDopplerFactor")]
		public static extern void Set3dSourceDopplerFactor(Soloud* soloud, uint32 voiceHandle, float dopplerFactor);

		[LinkName("Soloud_mix")]
		public static extern void Mix(Soloud* soloud, float* buffer, uint32 samples);

		[LinkName("Soloud_mixSigned16")]
		public static extern void MixSigned16(Soloud* soloud, int16* buffer, uint32 samples);

	}

	public static class SL_Ay
	{
		[LinkName("Ay_destroy")]
		public static extern void Destroy(Ay* ay);

		[LinkName("Ay_create")]
		public static extern Ay* Create();

		[LinkName("Ay_setVolume")]
		public static extern void SetVolume(Ay* ay, float volume);

		[LinkName("Ay_setLooping")]
		public static extern void SetLooping(Ay* ay, int32 loop);

		[LinkName("Ay_setAutoStop")]
		public static extern void SetAutoStop(Ay* ay, int32 autoStop);

		[LinkName("Ay_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Ay* ay, float minDistance, float maxDistance);

		[LinkName("Ay_set3dAttenuation")]
		public static extern void Set3dAttenuation(Ay* ay, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Ay_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Ay* ay, float dopplerFactor);

		[LinkName("Ay_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Ay* ay, int32 listenerRelative);

		[LinkName("Ay_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Ay* ay, int32 distanceDelay);

		[LinkName("Ay_set3dCollider")]
		public static extern void Set3dCollider(Ay* ay, void* collider);

		[LinkName("Ay_set3dColliderEx")]
		public static extern void Set3dCollider(Ay* ay, void* collider, int32 userData);

		[LinkName("Ay_set3dAttenuator")]
		public static extern void Set3dAttenuator(Ay* ay, void* attenuator);

		[LinkName("Ay_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Ay* ay, int32 mustTick, int32 kill);

		[LinkName("Ay_setLoopPoint")]
		public static extern void SetLoopPoint(Ay* ay, double loopPoint);

		[LinkName("Ay_getLoopPoint")]
		public static extern double GetLoopPoint(Ay* ay);

		[LinkName("Ay_setFilter")]
		public static extern void SetFilter(Ay* ay, uint32 filterId, void* filter);

		[LinkName("Ay_stop")]
		public static extern void Stop(Ay* ay);

	}

	public static class SL_BassboostFilter
	{
		public enum BassboostFilterParameters : uint32 { WET = 0, BOOST = 1 }

		[LinkName("BassboostFilter_destroy")]
		public static extern void Destroy(BassboostFilter* bassboostfilter);

		[LinkName("BassboostFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(BassboostFilter* bassboostfilter);

		[LinkName("BassboostFilter_getParamName")]
		public static extern char8* GetParamName(BassboostFilter* bassboostfilter, BassboostFilterParameters param);

		[LinkName("BassboostFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(BassboostFilter* bassboostfilter, BassboostFilterParameters param);

		[LinkName("BassboostFilter_getParamMax")]
		public static extern float GetParamMax(BassboostFilter* bassboostfilter, BassboostFilterParameters param);

		[LinkName("BassboostFilter_getParamMin")]
		public static extern float GetParamMin(BassboostFilter* bassboostfilter, BassboostFilterParameters param);

		[LinkName("BassboostFilter_setParams")]
		public static extern SoLoudResult SetParams(BassboostFilter* bassboostfilter, float boost);

		[LinkName("BassboostFilter_create")]
		public static extern BassboostFilter* Create();

	}

	public static class SL_BiquadResonantFilter
	{
		public enum BiquadResonantFilterTypes : uint32 { LOWPASS = 0, HIGHPASS = 1, BANDPASS = 2 }
		public enum BiquadResonantFilterParameters : uint32 { WET = 0, TYPE = 2, FREQUENCY = 3, RESONANCE = 4 }

		[LinkName("BiquadResonantFilter_destroy")]
		public static extern void Destroy(BiquadResonantFilter* biquadresonantfilter);

		[LinkName("BiquadResonantFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(BiquadResonantFilter* biquadresonantfilter);

		[LinkName("BiquadResonantFilter_getParamName")]
		public static extern char8* GetParamName(BiquadResonantFilter* biquadresonantfilter, BiquadResonantFilterParameters param);

		[LinkName("BiquadResonantFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(BiquadResonantFilter* biquadresonantfilter, BiquadResonantFilterParameters param);

		[LinkName("BiquadResonantFilter_getParamMax")]
		public static extern float GetParamMax(BiquadResonantFilter* biquadresonantfilter, BiquadResonantFilterParameters param);

		[LinkName("BiquadResonantFilter_getParamMin")]
		public static extern float GetParamMin(BiquadResonantFilter* biquadresonantfilter, BiquadResonantFilterParameters param);

		[LinkName("BiquadResonantFilter_create")]
		public static extern BiquadResonantFilter* Create();

		[LinkName("BiquadResonantFilter_setParams")]
		public static extern SoLoudResult SetParams(BiquadResonantFilter* biquadresonantfilter, BiquadResonantFilterTypes type, float frequency, float resonance);

	}

	public static class SL_Bus
	{
		[LinkName("Bus_destroy")]
		public static extern void Destroy(Bus* bus);

		[LinkName("Bus_create")]
		public static extern Bus* Create();

		[LinkName("Bus_setFilter")]
		public static extern void SetFilter(Bus* bus, uint32 filterId, void* filter);

		[LinkName("Bus_play")]
		public static extern uint32 Play(Bus* bus, void* sound);

		[LinkName("Bus_playEx")]
		public static extern uint32 Play(Bus* bus, void* sound, float volume, float pan, int32 paused);

		[LinkName("Bus_playClocked")]
		public static extern uint32 PlayClocked(Bus* bus, double soundTime, void* sound);

		[LinkName("Bus_playClockedEx")]
		public static extern uint32 PlayClocked(Bus* bus, double soundTime, void* sound, float volume, float pan);

		[LinkName("Bus_play3d")]
		public static extern uint32 Play3d(Bus* bus, void* sound, float posX, float posY, float posZ);

		[LinkName("Bus_play3dEx")]
		public static extern uint32 Play3d(Bus* bus, void* sound, float posX, float posY, float posZ, float velX, float velY, float velZ, float volume, int32 paused);

		[LinkName("Bus_play3dClocked")]
		public static extern uint32 Play3dClocked(Bus* bus, double soundTime, void* sound, float posX, float posY, float posZ);

		[LinkName("Bus_play3dClockedEx")]
		public static extern uint32 Play3dClocked(Bus* bus, double soundTime, void* sound, float posX, float posY, float posZ, float velX, float velY, float velZ, float volume);

		[LinkName("Bus_setChannels")]
		public static extern SoLoudResult SetChannels(Bus* bus, uint32 channels);

		[LinkName("Bus_setVisualizationEnable")]
		public static extern void SetVisualizationEnable(Bus* bus, int32 enable);

		[LinkName("Bus_annexSound")]
		public static extern void AnnexSound(Bus* bus, uint32 voiceHandle);

		[LinkName("Bus_calcFFT")]
		public static extern float* CalcFFT(Bus* bus);

		[LinkName("Bus_getWave")]
		public static extern float* GetWave(Bus* bus);

		[LinkName("Bus_getApproximateVolume")]
		public static extern float GetApproximateVolume(Bus* bus, uint32 channel);

		[LinkName("Bus_getActiveVoiceCount")]
		public static extern uint32 GetActiveVoiceCount(Bus* bus);

		[LinkName("Bus_getResampler")]
		public static extern Resampler GetResampler(Bus* bus);

		[LinkName("Bus_setResampler")]
		public static extern void SetResampler(Bus* bus, Resampler resampler);

		[LinkName("Bus_setVolume")]
		public static extern void SetVolume(Bus* bus, float volume);

		[LinkName("Bus_setLooping")]
		public static extern void SetLooping(Bus* bus, int32 loop);

		[LinkName("Bus_setAutoStop")]
		public static extern void SetAutoStop(Bus* bus, int32 autoStop);

		[LinkName("Bus_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Bus* bus, float minDistance, float maxDistance);

		[LinkName("Bus_set3dAttenuation")]
		public static extern void Set3dAttenuation(Bus* bus, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Bus_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Bus* bus, float dopplerFactor);

		[LinkName("Bus_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Bus* bus, int32 listenerRelative);

		[LinkName("Bus_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Bus* bus, int32 distanceDelay);

		[LinkName("Bus_set3dCollider")]
		public static extern void Set3dCollider(Bus* bus, void* collider);

		[LinkName("Bus_set3dColliderEx")]
		public static extern void Set3dCollider(Bus* bus, void* collider, int32 userData);

		[LinkName("Bus_set3dAttenuator")]
		public static extern void Set3dAttenuator(Bus* bus, void* attenuator);

		[LinkName("Bus_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Bus* bus, int32 mustTick, int32 kill);

		[LinkName("Bus_setLoopPoint")]
		public static extern void SetLoopPoint(Bus* bus, double loopPoint);

		[LinkName("Bus_getLoopPoint")]
		public static extern double GetLoopPoint(Bus* bus);

		[LinkName("Bus_stop")]
		public static extern void Stop(Bus* bus);

	}

	public static class SL_DCRemovalFilter
	{
		[LinkName("DCRemovalFilter_destroy")]
		public static extern void Destroy(DCRemovalFilter* dcremovalfilter);

		[LinkName("DCRemovalFilter_create")]
		public static extern DCRemovalFilter* Create();

		[LinkName("DCRemovalFilter_setParams")]
		public static extern SoLoudResult SetParams(DCRemovalFilter* dcremovalfilter);

		[LinkName("DCRemovalFilter_setParamsEx")]
		public static extern SoLoudResult SetParams(DCRemovalFilter* dcremovalfilter, float length);

		[LinkName("DCRemovalFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(DCRemovalFilter* dcremovalfilter);

		[LinkName("DCRemovalFilter_getParamName")]
		public static extern char8* GetParamName(DCRemovalFilter* dcremovalfilter, uint32 paramIndex);

		[LinkName("DCRemovalFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(DCRemovalFilter* dcremovalfilter, uint32 paramIndex);

		[LinkName("DCRemovalFilter_getParamMax")]
		public static extern float GetParamMax(DCRemovalFilter* dcremovalfilter, uint32 paramIndex);

		[LinkName("DCRemovalFilter_getParamMin")]
		public static extern float GetParamMin(DCRemovalFilter* dcremovalfilter, uint32 paramIndex);

	}

	public static class SL_EchoFilter
	{
		public enum EchoFilterParameters : uint32 { WET = 0, DELAY = 1, DECAY = 2, FILTER = 3 }

		[LinkName("EchoFilter_destroy")]
		public static extern void Destroy(EchoFilter* echofilter);

		[LinkName("EchoFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(EchoFilter* echofilter);

		[LinkName("EchoFilter_getParamName")]
		public static extern char8* GetParamName(EchoFilter* echofilter, EchoFilterParameters param);

		[LinkName("EchoFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(EchoFilter* echofilter, EchoFilterParameters param);

		[LinkName("EchoFilter_getParamMax")]
		public static extern float GetParamMax(EchoFilter* echofilter, EchoFilterParameters param);

		[LinkName("EchoFilter_getParamMin")]
		public static extern float GetParamMin(EchoFilter* echofilter, EchoFilterParameters param);

		[LinkName("EchoFilter_create")]
		public static extern EchoFilter* Create();

		[LinkName("EchoFilter_setParams")]
		public static extern SoLoudResult SetParams(EchoFilter* echofilter, float delay);

		[LinkName("EchoFilter_setParamsEx")]
		public static extern SoLoudResult SetParams(EchoFilter* echofilter, float delay, float decay, float filter);

	}

	public static class SL_FFTFilter
	{
		[LinkName("FFTFilter_destroy")]
		public static extern void Destroy(FFTFilter* fftfilter);

		[LinkName("FFTFilter_create")]
		public static extern FFTFilter* Create();

		[LinkName("FFTFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(FFTFilter* fftfilter);

		[LinkName("FFTFilter_getParamName")]
		public static extern char8* GetParamName(FFTFilter* fftfilter, uint32 paramIndex);

		[LinkName("FFTFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(FFTFilter* fftfilter, uint32 paramIndex);

		[LinkName("FFTFilter_getParamMax")]
		public static extern float GetParamMax(FFTFilter* fftfilter, uint32 paramIndex);

		[LinkName("FFTFilter_getParamMin")]
		public static extern float GetParamMin(FFTFilter* fftfilter, uint32 paramIndex);

	}

	public static class SL_FlangerFilter
	{
		public enum FlangerFilterParameters : uint32 { WET = 0, DELAY = 1, FREQ = 2 }

		[LinkName("FlangerFilter_destroy")]
		public static extern void Destroy(FlangerFilter* flangerfilter);

		[LinkName("FlangerFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(FlangerFilter* flangerfilter);

		[LinkName("FlangerFilter_getParamName")]
		public static extern char8* GetParamName(FlangerFilter* flangerfilter, FlangerFilterParameters param);

		[LinkName("FlangerFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(FlangerFilter* flangerfilter, FlangerFilterParameters param);

		[LinkName("FlangerFilter_getParamMax")]
		public static extern float GetParamMax(FlangerFilter* flangerfilter, FlangerFilterParameters param);

		[LinkName("FlangerFilter_getParamMin")]
		public static extern float GetParamMin(FlangerFilter* flangerfilter, FlangerFilterParameters param);

		[LinkName("FlangerFilter_create")]
		public static extern FlangerFilter* Create();

		[LinkName("FlangerFilter_setParams")]
		public static extern SoLoudResult SetParams(FlangerFilter* flangerfilter, float delay, float freq);

	}

	public static class SL_FreeverbFilter
	{
		public enum FreeverbFilterParameters : uint32 { WET = 0, FREEZE = 1, ROOMSIZE = 2, DAMP = 3, WIDTH = 4 }

		[LinkName("FreeverbFilter_destroy")]
		public static extern void Destroy(FreeverbFilter* freeverbfilter);

		[LinkName("FreeverbFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(FreeverbFilter* freeverbfilter);

		[LinkName("FreeverbFilter_getParamName")]
		public static extern char8* GetParamName(FreeverbFilter* freeverbfilter, FreeverbFilterParameters param);

		[LinkName("FreeverbFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(FreeverbFilter* freeverbfilter, FreeverbFilterParameters param);

		[LinkName("FreeverbFilter_getParamMax")]
		public static extern float GetParamMax(FreeverbFilter* freeverbfilter, FreeverbFilterParameters param);

		[LinkName("FreeverbFilter_getParamMin")]
		public static extern float GetParamMin(FreeverbFilter* freeverbfilter, FreeverbFilterParameters param);

		[LinkName("FreeverbFilter_create")]
		public static extern FreeverbFilter* Create();

		[LinkName("FreeverbFilter_setParams")]
		public static extern SoLoudResult SetParams(FreeverbFilter* freeverbfilter, float mode, float roomSize, float damp, float width);

	}

	public static class SL_LofiFilter
	{
		public enum LofiFilterParameters : uint32 { WET = 0, SAMPLERATE = 1, BITDEPTH = 2 }

		[LinkName("LofiFilter_destroy")]
		public static extern void Destroy(LofiFilter* lofifilter);

		[LinkName("LofiFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(LofiFilter* lofifilter);

		[LinkName("LofiFilter_getParamName")]
		public static extern char8* GetParamName(LofiFilter* lofifilter, LofiFilterParameters param);

		[LinkName("LofiFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(LofiFilter* lofifilter, LofiFilterParameters param);

		[LinkName("LofiFilter_getParamMax")]
		public static extern float GetParamMax(LofiFilter* lofifilter, LofiFilterParameters param);

		[LinkName("LofiFilter_getParamMin")]
		public static extern float GetParamMin(LofiFilter* lofifilter, LofiFilterParameters param);

		[LinkName("LofiFilter_create")]
		public static extern LofiFilter* Create();

		[LinkName("LofiFilter_setParams")]
		public static extern SoLoudResult SetParams(LofiFilter* lofifilter, float sampleRate, float bitdepth);

	}

	public static class SL_Monotone
	{
		[LinkName("Monotone_destroy")]
		public static extern void Destroy(Monotone* monotone);

		[LinkName("Monotone_create")]
		public static extern Monotone* Create();

		[LinkName("Monotone_setParams")]
		public static extern SoLoudResult SetParams(Monotone* monotone, int32 hardwareChannels);

		[LinkName("Monotone_setParamsEx")]
		public static extern SoLoudResult SetParams(Monotone* monotone, int32 hardwareChannels, Waveform waveform);

		[LinkName("Monotone_load")]
		public static extern SoLoudResult Load(Monotone* monotone, char8* filename);

		[LinkName("Monotone_loadMem")]
		public static extern SoLoudResult LoadMem(Monotone* monotone, uint8* mem, uint32 length);

		[LinkName("Monotone_loadMemEx")]
		public static extern SoLoudResult LoadMem(Monotone* monotone, uint8* mem, uint32 length, int32 copy, int32 takeOwnership);

		//[LinkName("Monotone_loadFile")]
		//public static extern SoLoudResult LoadFile(Monotone* monotone, void* file);

		[LinkName("Monotone_setVolume")]
		public static extern void SetVolume(Monotone* monotone, float volume);

		[LinkName("Monotone_setLooping")]
		public static extern void SetLooping(Monotone* monotone, int32 loop);

		[LinkName("Monotone_setAutoStop")]
		public static extern void SetAutoStop(Monotone* monotone, int32 autoStop);

		[LinkName("Monotone_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Monotone* monotone, float minDistance, float maxDistance);

		[LinkName("Monotone_set3dAttenuation")]
		public static extern void Set3dAttenuation(Monotone* monotone, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Monotone_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Monotone* monotone, float dopplerFactor);

		[LinkName("Monotone_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Monotone* monotone, int32 listenerRelative);

		[LinkName("Monotone_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Monotone* monotone, int32 distanceDelay);

		[LinkName("Monotone_set3dCollider")]
		public static extern void Set3dCollider(Monotone* monotone, void* collider);

		[LinkName("Monotone_set3dColliderEx")]
		public static extern void Set3dCollider(Monotone* monotone, void* collider, int32 userData);

		[LinkName("Monotone_set3dAttenuator")]
		public static extern void Set3dAttenuator(Monotone* monotone, void* attenuator);

		[LinkName("Monotone_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Monotone* monotone, int32 mustTick, int32 kill);

		[LinkName("Monotone_setLoopPoint")]
		public static extern void SetLoopPoint(Monotone* monotone, double loopPoint);

		[LinkName("Monotone_getLoopPoint")]
		public static extern double GetLoopPoint(Monotone* monotone);

		[LinkName("Monotone_setFilter")]
		public static extern void SetFilter(Monotone* monotone, uint32 filterId, void* filter);

		[LinkName("Monotone_stop")]
		public static extern void Stop(Monotone* monotone);

	}

	public static class SL_Noise
	{
		[LinkName("Noise_destroy")]
		public static extern void Destroy(Noise* noise);

		[LinkName("Noise_create")]
		public static extern Noise* Create();

		[LinkName("Noise_setOctaveScale")]
		public static extern void SetOctaveScale(Noise* noise, float oct0, float oct1, float oct2, float oct3, float oct4, float oct5, float oct6, float oct7, float oct8, float oct9);

		[LinkName("Noise_setType")]
		public static extern void SetType(Noise* noise, int32 type);

		[LinkName("Noise_setVolume")]
		public static extern void SetVolume(Noise* noise, float volume);

		[LinkName("Noise_setLooping")]
		public static extern void SetLooping(Noise* noise, int32 loop);

		[LinkName("Noise_setAutoStop")]
		public static extern void SetAutoStop(Noise* noise, int32 autoStop);

		[LinkName("Noise_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Noise* noise, float minDistance, float maxDistance);

		[LinkName("Noise_set3dAttenuation")]
		public static extern void Set3dAttenuation(Noise* noise, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Noise_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Noise* noise, float dopplerFactor);

		[LinkName("Noise_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Noise* noise, int32 listenerRelative);

		[LinkName("Noise_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Noise* noise, int32 distanceDelay);

		[LinkName("Noise_set3dCollider")]
		public static extern void Set3dCollider(Noise* noise, void* collider);

		[LinkName("Noise_set3dColliderEx")]
		public static extern void Set3dCollider(Noise* noise, void* collider, int32 userData);

		[LinkName("Noise_set3dAttenuator")]
		public static extern void Set3dAttenuator(Noise* noise, void* attenuator);

		[LinkName("Noise_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Noise* noise, int32 mustTick, int32 kill);

		[LinkName("Noise_setLoopPoint")]
		public static extern void SetLoopPoint(Noise* noise, double loopPoint);

		[LinkName("Noise_getLoopPoint")]
		public static extern double GetLoopPoint(Noise* noise);

		[LinkName("Noise_setFilter")]
		public static extern void SetFilter(Noise* noise, uint32 filterId, void* filter);

		[LinkName("Noise_stop")]
		public static extern void Stop(Noise* noise);

	}

	public static class SL_Openmpt
	{
		[LinkName("Openmpt_destroy")]
		public static extern void Destroy(Openmpt* openmpt);

		[LinkName("Openmpt_create")]
		public static extern Openmpt* Create();

		[LinkName("Openmpt_load")]
		public static extern SoLoudResult Load(Openmpt* openmpt, char8* filename);

		[LinkName("Openmpt_loadMem")]
		public static extern SoLoudResult LoadMem(Openmpt* openmpt, uint8* mem, uint32 length);

		[LinkName("Openmpt_loadMemEx")]
		public static extern SoLoudResult LoadMem(Openmpt* openmpt, uint8* mem, uint32 length, int32 copy, int32 takeOwnership);

		//[LinkName("Openmpt_loadFile")]
		//public static extern SoLoudResult LoadFile(Openmpt* openmpt, void* file);

		[LinkName("Openmpt_setVolume")]
		public static extern void SetVolume(Openmpt* openmpt, float volume);

		[LinkName("Openmpt_setLooping")]
		public static extern void SetLooping(Openmpt* openmpt, int32 loop);

		[LinkName("Openmpt_setAutoStop")]
		public static extern void SetAutoStop(Openmpt* openmpt, int32 autoStop);

		[LinkName("Openmpt_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Openmpt* openmpt, float minDistance, float maxDistance);

		[LinkName("Openmpt_set3dAttenuation")]
		public static extern void Set3dAttenuation(Openmpt* openmpt, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Openmpt_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Openmpt* openmpt, float dopplerFactor);

		[LinkName("Openmpt_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Openmpt* openmpt, int32 listenerRelative);

		[LinkName("Openmpt_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Openmpt* openmpt, int32 distanceDelay);

		[LinkName("Openmpt_set3dCollider")]
		public static extern void Set3dCollider(Openmpt* openmpt, void* collider);

		[LinkName("Openmpt_set3dColliderEx")]
		public static extern void Set3dCollider(Openmpt* openmpt, void* collider, int32 userData);

		[LinkName("Openmpt_set3dAttenuator")]
		public static extern void Set3dAttenuator(Openmpt* openmpt, void* attenuator);

		[LinkName("Openmpt_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Openmpt* openmpt, int32 mustTick, int32 kill);

		[LinkName("Openmpt_setLoopPoint")]
		public static extern void SetLoopPoint(Openmpt* openmpt, double loopPoint);

		[LinkName("Openmpt_getLoopPoint")]
		public static extern double GetLoopPoint(Openmpt* openmpt);

		[LinkName("Openmpt_setFilter")]
		public static extern void SetFilter(Openmpt* openmpt, uint32 filterId, void* filter);

		[LinkName("Openmpt_stop")]
		public static extern void Stop(Openmpt* openmpt);

	}

	public static class SL_Queue
	{
		[LinkName("Queue_destroy")]
		public static extern void Destroy(Queue* queue);

		[LinkName("Queue_create")]
		public static extern Queue* Create();

		[LinkName("Queue_play")]
		public static extern SoLoudResult Play(Queue* queue, void* sound);

		[LinkName("Queue_getQueueCount")]
		public static extern uint32 GetQueueCount(Queue* queue);

		[LinkName("Queue_isCurrentlyPlaying")]
		public static extern SoLoudResult IsCurrentlyPlaying(Queue* queue, void* sound);

		[LinkName("Queue_setParamsFromAudioSource")]
		public static extern SoLoudResult SetParamsFromAudioSource(Queue* queue, void* sound);

		[LinkName("Queue_setParams")]
		public static extern SoLoudResult SetParams(Queue* queue, float samplerate);

		[LinkName("Queue_setParamsEx")]
		public static extern SoLoudResult SetParams(Queue* queue, float samplerate, uint32 channels);

		[LinkName("Queue_setVolume")]
		public static extern void SetVolume(Queue* queue, float volume);

		[LinkName("Queue_setLooping")]
		public static extern void SetLooping(Queue* queue, int32 loop);

		[LinkName("Queue_setAutoStop")]
		public static extern void SetAutoStop(Queue* queue, int32 autoStop);

		[LinkName("Queue_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Queue* queue, float minDistance, float maxDistance);

		[LinkName("Queue_set3dAttenuation")]
		public static extern void Set3dAttenuation(Queue* queue, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Queue_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Queue* queue, float dopplerFactor);

		[LinkName("Queue_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Queue* queue, int32 listenerRelative);

		[LinkName("Queue_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Queue* queue, int32 distanceDelay);

		[LinkName("Queue_set3dCollider")]
		public static extern void Set3dCollider(Queue* queue, void* collider);

		[LinkName("Queue_set3dColliderEx")]
		public static extern void Set3dCollider(Queue* queue, void* collider, int32 userData);

		[LinkName("Queue_set3dAttenuator")]
		public static extern void Set3dAttenuator(Queue* queue, void* attenuator);

		[LinkName("Queue_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Queue* queue, int32 mustTick, int32 kill);

		[LinkName("Queue_setLoopPoint")]
		public static extern void SetLoopPoint(Queue* queue, double loopPoint);

		[LinkName("Queue_getLoopPoint")]
		public static extern double GetLoopPoint(Queue* queue);

		[LinkName("Queue_setFilter")]
		public static extern void SetFilter(Queue* queue, uint32 filterId, void* filter);

		[LinkName("Queue_stop")]
		public static extern void Stop(Queue* queue);

	}

	public static class SL_RobotizeFilter
	{
		public enum RobotizeFilterParameters : uint32 { WET = 0, FREQ = 1, WAVE = 2 }

		[LinkName("RobotizeFilter_destroy")]
		public static extern void Destroy(RobotizeFilter* robotizefilter);

		[LinkName("RobotizeFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(RobotizeFilter* robotizefilter);

		[LinkName("RobotizeFilter_getParamName")]
		public static extern char8* GetParamName(RobotizeFilter* robotizefilter, RobotizeFilterParameters param);

		[LinkName("RobotizeFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(RobotizeFilter* robotizefilter, RobotizeFilterParameters param);

		[LinkName("RobotizeFilter_getParamMax")]
		public static extern float GetParamMax(RobotizeFilter* robotizefilter, RobotizeFilterParameters param);

		[LinkName("RobotizeFilter_getParamMin")]
		public static extern float GetParamMin(RobotizeFilter* robotizefilter, RobotizeFilterParameters param);

		[LinkName("RobotizeFilter_setParams")]
		public static extern void SetParams(RobotizeFilter* robotizefilter, float freq, Waveform waveform);

		[LinkName("RobotizeFilter_create")]
		public static extern RobotizeFilter* Create();

	}

	public static class SL_Sfxr
	{
		[LinkName("Sfxr_destroy")]
		public static extern void Destroy(Sfxr* sfxr);

		[LinkName("Sfxr_create")]
		public static extern Sfxr* Create();

		[LinkName("Sfxr_resetParams")]
		public static extern void ResetParams(Sfxr* sfxr);

		[LinkName("Sfxr_loadParams")]
		public static extern SoLoudResult LoadParams(Sfxr* sfxr, char8* filename);

		[LinkName("Sfxr_loadParamsMem")]
		public static extern SoLoudResult LoadParamsMem(Sfxr* sfxr, uint8* mem, uint32 length);

		[LinkName("Sfxr_loadParamsMemEx")]
		public static extern SoLoudResult LoadParamsMem(Sfxr* sfxr, uint8* mem, uint32 length, int32 copy, int32 takeOwnership);

		//[LinkName("Sfxr_loadParamsFile")]
		//public static extern SoLoudResult LoadParamsFile(Sfxr* sfxr, void* file);

		[LinkName("Sfxr_loadPreset")]
		public static extern SoLoudResult LoadPreset(Sfxr* sfxr, int32 presetNo, int32 randSeed);

		[LinkName("Sfxr_setVolume")]
		public static extern void SetVolume(Sfxr* sfxr, float volume);

		[LinkName("Sfxr_setLooping")]
		public static extern void SetLooping(Sfxr* sfxr, int32 loop);

		[LinkName("Sfxr_setAutoStop")]
		public static extern void SetAutoStop(Sfxr* sfxr, int32 autoStop);

		[LinkName("Sfxr_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Sfxr* sfxr, float minDistance, float maxDistance);

		[LinkName("Sfxr_set3dAttenuation")]
		public static extern void Set3dAttenuation(Sfxr* sfxr, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Sfxr_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Sfxr* sfxr, float dopplerFactor);

		[LinkName("Sfxr_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Sfxr* sfxr, int32 listenerRelative);

		[LinkName("Sfxr_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Sfxr* sfxr, int32 distanceDelay);

		[LinkName("Sfxr_set3dCollider")]
		public static extern void Set3dCollider(Sfxr* sfxr, void* collider);

		[LinkName("Sfxr_set3dColliderEx")]
		public static extern void Set3dCollider(Sfxr* sfxr, void* collider, int32 userData);

		[LinkName("Sfxr_set3dAttenuator")]
		public static extern void Set3dAttenuator(Sfxr* sfxr, void* attenuator);

		[LinkName("Sfxr_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Sfxr* sfxr, int32 mustTick, int32 kill);

		[LinkName("Sfxr_setLoopPoint")]
		public static extern void SetLoopPoint(Sfxr* sfxr, double loopPoint);

		[LinkName("Sfxr_getLoopPoint")]
		public static extern double GetLoopPoint(Sfxr* sfxr);

		[LinkName("Sfxr_setFilter")]
		public static extern void SetFilter(Sfxr* sfxr, uint32 filterId, void* filter);

		[LinkName("Sfxr_stop")]
		public static extern void Stop(Sfxr* sfxr);

	}

	public static class SL_Speech
	{
		[LinkName("Speech_destroy")]
		public static extern void Destroy(Speech* speech);

		[LinkName("Speech_create")]
		public static extern Speech* Create();

		[LinkName("Speech_setText")]
		public static extern SoLoudResult SetText(Speech* speech, char8* text);

		[LinkName("Speech_setParams")]
		public static extern SoLoudResult SetParams(Speech* speech);

		[LinkName("Speech_setParamsEx")]
		public static extern SoLoudResult SetParams(Speech* speech, uint32 baseFrequency, float baseSpeed, float baseDeclination, Waveform baseWaveform);

		[LinkName("Speech_setVolume")]
		public static extern void SetVolume(Speech* speech, float volume);

		[LinkName("Speech_setLooping")]
		public static extern void SetLooping(Speech* speech, int32 loop);

		[LinkName("Speech_setAutoStop")]
		public static extern void SetAutoStop(Speech* speech, int32 autoStop);

		[LinkName("Speech_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Speech* speech, float minDistance, float maxDistance);

		[LinkName("Speech_set3dAttenuation")]
		public static extern void Set3dAttenuation(Speech* speech, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Speech_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Speech* speech, float dopplerFactor);

		[LinkName("Speech_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Speech* speech, int32 listenerRelative);

		[LinkName("Speech_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Speech* speech, int32 distanceDelay);

		[LinkName("Speech_set3dCollider")]
		public static extern void Set3dCollider(Speech* speech, void* collider);

		[LinkName("Speech_set3dColliderEx")]
		public static extern void Set3dCollider(Speech* speech, void* collider, int32 userData);

		[LinkName("Speech_set3dAttenuator")]
		public static extern void Set3dAttenuator(Speech* speech, void* attenuator);

		[LinkName("Speech_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Speech* speech, int32 mustTick, int32 kill);

		[LinkName("Speech_setLoopPoint")]
		public static extern void SetLoopPoint(Speech* speech, double loopPoint);

		[LinkName("Speech_getLoopPoint")]
		public static extern double GetLoopPoint(Speech* speech);

		[LinkName("Speech_setFilter")]
		public static extern void SetFilter(Speech* speech, uint32 filterId, void* filter);

		[LinkName("Speech_stop")]
		public static extern void Stop(Speech* speech);

	}

	public static class SL_TedSid
	{
		[LinkName("TedSid_destroy")]
		public static extern void Destroy(TedSid* tedsid);

		[LinkName("TedSid_create")]
		public static extern TedSid* Create();

		[LinkName("TedSid_load")]
		public static extern SoLoudResult Load(TedSid* tedsid, char8* filename);

		[LinkName("TedSid_loadMem")]
		public static extern SoLoudResult LoadMem(TedSid* tedsid, uint8* mem, uint32 length);

		[LinkName("TedSid_loadMemEx")]
		public static extern SoLoudResult LoadMem(TedSid* tedsid, uint8* mem, uint32 length, int32 copy, int32 takeOwnership);

		//[LinkName("TedSid_loadFile")]
		//public static extern SoLoudResult LoadFile(TedSid* tedsid, void* file);

		[LinkName("TedSid_setVolume")]
		public static extern void SetVolume(TedSid* tedsid, float volume);

		[LinkName("TedSid_setLooping")]
		public static extern void SetLooping(TedSid* tedsid, int32 loop);

		[LinkName("TedSid_setAutoStop")]
		public static extern void SetAutoStop(TedSid* tedsid, int32 autoStop);

		[LinkName("TedSid_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(TedSid* tedsid, float minDistance, float maxDistance);

		[LinkName("TedSid_set3dAttenuation")]
		public static extern void Set3dAttenuation(TedSid* tedsid, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("TedSid_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(TedSid* tedsid, float dopplerFactor);

		[LinkName("TedSid_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(TedSid* tedsid, int32 listenerRelative);

		[LinkName("TedSid_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(TedSid* tedsid, int32 distanceDelay);

		[LinkName("TedSid_set3dCollider")]
		public static extern void Set3dCollider(TedSid* tedsid, void* collider);

		[LinkName("TedSid_set3dColliderEx")]
		public static extern void Set3dCollider(TedSid* tedsid, void* collider, int32 userData);

		[LinkName("TedSid_set3dAttenuator")]
		public static extern void Set3dAttenuator(TedSid* tedsid, void* attenuator);

		[LinkName("TedSid_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(TedSid* tedsid, int32 mustTick, int32 kill);

		[LinkName("TedSid_setLoopPoint")]
		public static extern void SetLoopPoint(TedSid* tedsid, double loopPoint);

		[LinkName("TedSid_getLoopPoint")]
		public static extern double GetLoopPoint(TedSid* tedsid);

		[LinkName("TedSid_setFilter")]
		public static extern void SetFilter(TedSid* tedsid, uint32 filterId, void* filter);

		[LinkName("TedSid_stop")]
		public static extern void Stop(TedSid* tedsid);

	}

	public static class SL_Vic
	{
		[LinkName("Vic_destroy")]
		public static extern void Destroy(Vic* vic);

		[LinkName("Vic_create")]
		public static extern Vic* Create();

		[LinkName("Vic_setModel")]
		public static extern void SetModel(Vic* vic, int32 odel);

		[LinkName("Vic_getModel")]
		public static extern SoLoudResult GetModel(Vic* vic);

		[LinkName("Vic_setRegister")]
		public static extern void SetRegister(Vic* vic, int32 eg, uint8 alue);

		[LinkName("Vic_getRegister")]
		public static extern uint8 GetRegister(Vic* vic, int32 eg);

		[LinkName("Vic_setVolume")]
		public static extern void SetVolume(Vic* vic, float volume);

		[LinkName("Vic_setLooping")]
		public static extern void SetLooping(Vic* vic, int32 loop);

		[LinkName("Vic_setAutoStop")]
		public static extern void SetAutoStop(Vic* vic, int32 autoStop);

		[LinkName("Vic_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Vic* vic, float minDistance, float maxDistance);

		[LinkName("Vic_set3dAttenuation")]
		public static extern void Set3dAttenuation(Vic* vic, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Vic_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Vic* vic, float dopplerFactor);

		[LinkName("Vic_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Vic* vic, int32 listenerRelative);

		[LinkName("Vic_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Vic* vic, int32 distanceDelay);

		[LinkName("Vic_set3dCollider")]
		public static extern void Set3dCollider(Vic* vic, void* collider);

		[LinkName("Vic_set3dColliderEx")]
		public static extern void Set3dCollider(Vic* vic, void* collider, int32 userData);

		[LinkName("Vic_set3dAttenuator")]
		public static extern void Set3dAttenuator(Vic* vic, void* attenuator);

		[LinkName("Vic_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Vic* vic, int32 mustTick, int32 kill);

		[LinkName("Vic_setLoopPoint")]
		public static extern void SetLoopPoint(Vic* vic, double loopPoint);

		[LinkName("Vic_getLoopPoint")]
		public static extern double GetLoopPoint(Vic* vic);

		[LinkName("Vic_setFilter")]
		public static extern void SetFilter(Vic* vic, uint32 filterId, void* filter);

		[LinkName("Vic_stop")]
		public static extern void Stop(Vic* vic);

	}

	public static class SL_Vizsn
	{
		[LinkName("Vizsn_destroy")]
		public static extern void Destroy(Vizsn* vizsn);

		[LinkName("Vizsn_create")]
		public static extern Vizsn* Create();

		[LinkName("Vizsn_setText")]
		public static extern void SetText(Vizsn* vizsn, char8* text);

		[LinkName("Vizsn_setVolume")]
		public static extern void SetVolume(Vizsn* vizsn, float volume);

		[LinkName("Vizsn_setLooping")]
		public static extern void SetLooping(Vizsn* vizsn, int32 loop);

		[LinkName("Vizsn_setAutoStop")]
		public static extern void SetAutoStop(Vizsn* vizsn, int32 autoStop);

		[LinkName("Vizsn_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Vizsn* vizsn, float minDistance, float maxDistance);

		[LinkName("Vizsn_set3dAttenuation")]
		public static extern void Set3dAttenuation(Vizsn* vizsn, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Vizsn_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Vizsn* vizsn, float dopplerFactor);

		[LinkName("Vizsn_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Vizsn* vizsn, int32 listenerRelative);

		[LinkName("Vizsn_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Vizsn* vizsn, int32 distanceDelay);

		[LinkName("Vizsn_set3dCollider")]
		public static extern void Set3dCollider(Vizsn* vizsn, void* collider);

		[LinkName("Vizsn_set3dColliderEx")]
		public static extern void Set3dCollider(Vizsn* vizsn, void* collider, int32 userData);

		[LinkName("Vizsn_set3dAttenuator")]
		public static extern void Set3dAttenuator(Vizsn* vizsn, void* attenuator);

		[LinkName("Vizsn_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Vizsn* vizsn, int32 mustTick, int32 kill);

		[LinkName("Vizsn_setLoopPoint")]
		public static extern void SetLoopPoint(Vizsn* vizsn, double loopPoint);

		[LinkName("Vizsn_getLoopPoint")]
		public static extern double GetLoopPoint(Vizsn* vizsn);

		[LinkName("Vizsn_setFilter")]
		public static extern void SetFilter(Vizsn* vizsn, uint32 filterId, void* filter);

		[LinkName("Vizsn_stop")]
		public static extern void Stop(Vizsn* vizsn);

	}

	public static class SL_Wav
	{
		[LinkName("Wav_destroy")]
		public static extern void Destroy(Wav* wav);

		[LinkName("Wav_create")]
		public static extern Wav* Create();

		//[LinkName("Wav_load")]
		//public static extern SoLoudResult Load(Wav* wav, char8* filename);

		[LinkName("Wav_loadMem")]
		public static extern SoLoudResult LoadMem(Wav* wav, uint8* mem, uint32 length);

		[LinkName("Wav_loadMemEx")]
		public static extern SoLoudResult LoadMem(Wav* wav, uint8* mem, uint32 length, int32 copy, int32 takeOwnership);

		//[LinkName("Wav_loadFile")]
		//public static extern SoLoudResult LoadFile(Wav* wav, void* file);

		[LinkName("Wav_loadRawWave8")]
		public static extern SoLoudResult LoadRawWave8(Wav* wav, uint8* mem, uint32 length);

		[LinkName("Wav_loadRawWave8Ex")]
		public static extern SoLoudResult LoadRawWave8(Wav* wav, uint8* mem, uint32 length, float samplerate, uint32 channels);

		[LinkName("Wav_loadRawWave16")]
		public static extern SoLoudResult LoadRawWave16(Wav* wav, int16* mem, uint32 length);

		[LinkName("Wav_loadRawWave16Ex")]
		public static extern SoLoudResult LoadRawWave16(Wav* wav, int16* mem, uint32 length, float samplerate, uint32 channels);

		[LinkName("Wav_loadRawWave")]
		public static extern SoLoudResult LoadRawWave(Wav* wav, float* mem, uint32 length);

		[LinkName("Wav_loadRawWaveEx")]
		public static extern SoLoudResult LoadRawWave(Wav* wav, float* mem, uint32 length, float samplerate, uint32 channels, int32 copy, int32 takeOwnership);

		[LinkName("Wav_getLength")]
		public static extern double GetLength(Wav* wav);

		[LinkName("Wav_setVolume")]
		public static extern void SetVolume(Wav* wav, float volume);

		[LinkName("Wav_setLooping")]
		public static extern void SetLooping(Wav* wav, int32 loop);

		[LinkName("Wav_setAutoStop")]
		public static extern void SetAutoStop(Wav* wav, int32 autoStop);
		[LinkName("Wav_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(Wav* wav, float minDistance, float maxDistance);

		[LinkName("Wav_set3dAttenuation")]
		public static extern void Set3dAttenuation(Wav* wav, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("Wav_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(Wav* wav, float dopplerFactor);

		[LinkName("Wav_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(Wav* wav, int32 listenerRelative);

		[LinkName("Wav_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(Wav* wav, int32 distanceDelay);

		[LinkName("Wav_set3dCollider")]
		public static extern void Set3dCollider(Wav* wav, void* collider);

		[LinkName("Wav_set3dColliderEx")]
		public static extern void Set3dCollider(Wav* wav, void* collider, int32 userData);

		[LinkName("Wav_set3dAttenuator")]
		public static extern void Set3dAttenuator(Wav* wav, void* attenuator);

		[LinkName("Wav_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(Wav* wav, bool mustTick, bool kill); // @edit set to bool instead of int32

		[LinkName("Wav_setLoopPoint")]
		public static extern void SetLoopPoint(Wav* wav, double loopPoint);

		[LinkName("Wav_getLoopPoint")]
		public static extern double GetLoopPoint(Wav* wav);

		[LinkName("Wav_setFilter")]
		public static extern void SetFilter(Wav* wav, uint32 filterId, void* filter);

		[LinkName("Wav_stop")]
		public static extern void Stop(Wav* wav);

	}

	public static class SL_WaveShaperFilter
	{
		public enum WaveShaperFilterParameters : uint32 { WET = 0, AMOUNT = 1 }

		[LinkName("WaveShaperFilter_destroy")]
		public static extern void Destroy(WaveShaperFilter* waveshaperfilter);

		[LinkName("WaveShaperFilter_setParams")]
		public static extern SoLoudResult SetParams(WaveShaperFilter* waveshaperfilter, float amount);

		[LinkName("WaveShaperFilter_create")]
		public static extern WaveShaperFilter* Create();

		[LinkName("WaveShaperFilter_getParamCount")]
		public static extern SoLoudResult GetParamCount(WaveShaperFilter* waveshaperfilter);

		[LinkName("WaveShaperFilter_getParamName")]
		public static extern char8* GetParamName(WaveShaperFilter* waveshaperfilter, WaveShaperFilterParameters param);

		[LinkName("WaveShaperFilter_getParamType")]
		public static extern FilterParameterTypes GetParamType(WaveShaperFilter* waveshaperfilter, WaveShaperFilterParameters param);

		[LinkName("WaveShaperFilter_getParamMax")]
		public static extern float GetParamMax(WaveShaperFilter* waveshaperfilter, WaveShaperFilterParameters param);

		[LinkName("WaveShaperFilter_getParamMin")]
		public static extern float GetParamMin(WaveShaperFilter* waveshaperfilter, WaveShaperFilterParameters param);

	}

	public static class SL_WavStream
	{
		[LinkName("WavStream_destroy")]
		public static extern void Destroy(WavStream* wavstream);

		[LinkName("WavStream_create")]
		public static extern WavStream* Create();

		[LinkName("WavStream_load")]
		public static extern SoLoudResult Load(WavStream* wavstream, char8* filename);

		[LinkName("WavStream_loadMem")]
		public static extern SoLoudResult LoadMem(WavStream* wavstream, uint8* data, uint32 dataLen);

		[LinkName("WavStream_loadMemEx")]
		public static extern SoLoudResult LoadMem(WavStream* wavstream, uint8* data, uint32 dataLen, int32 copy, int32 takeOwnership);

		[LinkName("WavStream_loadToMem")]
		public static extern SoLoudResult LoadToMem(WavStream* wavstream, char8* filename);

		//[LinkName("WavStream_loadFile")]
		//public static extern SoLoudResult LoadFile(WavStream* wavstream, void* file);

		//[LinkName("WavStream_loadFileToMem")]
		//public static extern SoLoudResult LoadFileToMem(WavStream* wavstream, void* file);

		[LinkName("WavStream_getLength")]
		public static extern double GetLength(WavStream* wavstream);

		[LinkName("WavStream_setVolume")]
		public static extern void SetVolume(WavStream* wavstream, float volume);

		[LinkName("WavStream_setLooping")]
		public static extern void SetLooping(WavStream* wavstream, int32 loop);

		[LinkName("WavStream_setAutoStop")]
		public static extern void SetAutoStop(WavStream* wavstream, int32 autoStop);

		[LinkName("WavStream_set3dMinMaxDistance")]
		public static extern void Set3dMinMaxDistance(WavStream* wavstream, float minDistance, float maxDistance);

		[LinkName("WavStream_set3dAttenuation")]
		public static extern void Set3dAttenuation(WavStream* wavstream, uint32 attenuationModel, float attenuationRolloffFactor);

		[LinkName("WavStream_set3dDopplerFactor")]
		public static extern void Set3dDopplerFactor(WavStream* wavstream, float dopplerFactor);

		[LinkName("WavStream_set3dListenerRelative")]
		public static extern void Set3dListenerRelative(WavStream* wavstream, int32 listenerRelative);

		[LinkName("WavStream_set3dDistanceDelay")]
		public static extern void Set3dDistanceDelay(WavStream* wavstream, int32 distanceDelay);

		[LinkName("WavStream_set3dCollider")]
		public static extern void Set3dCollider(WavStream* wavstream, void* collider);

		[LinkName("WavStream_set3dColliderEx")]
		public static extern void Set3dCollider(WavStream* wavstream, void* collider, int32 userData);

		[LinkName("WavStream_set3dAttenuator")]
		public static extern void Set3dAttenuator(WavStream* wavstream, void* attenuator);

		[LinkName("WavStream_setInaudibleBehavior")]
		public static extern void SetInaudibleBehavior(WavStream* wavstream, int32 mustTick, int32 kill);

		[LinkName("WavStream_setLoopPoint")]
		public static extern void SetLoopPoint(WavStream* wavstream, double loopPoint);

		[LinkName("WavStream_getLoopPoint")]
		public static extern double GetLoopPoint(WavStream* wavstream);

		[LinkName("WavStream_setFilter")]
		public static extern void SetFilter(WavStream* wavstream, uint32 filterId, void* filter);

		[LinkName("WavStream_stop")]
		public static extern void Stop(WavStream* wavstream);

	}
}
