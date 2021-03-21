using System;

namespace Pile
{
	enum RendererSupport
	{
		// TODO: no info on most APIs
		case None;
		case OpenGLCore(GetProcAddressFunc getProcAddr, SetGLAttributes setAttributes);
		case OpenGLES;
		case Vulkan;
		case Direct3D;
		case Metal;

		internal function void* GetProcAddressFunc(StringView procName);
		internal function void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples);

	}
}
