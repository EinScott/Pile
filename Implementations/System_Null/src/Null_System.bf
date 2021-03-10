using System;

using internal Pile;

namespace Pile
{
	public extension System : ISystemOpenGL
	{
		public override uint32 MajorVersion => 1;
		public override uint32 MinorVersion => 0;
		public override String ApiName => "Null System";
		public override String Info => String.Empty;

		[SkipCall]
		protected internal override void Initialize()
		{
			monitors.Add(new Monitor());
		}	

		[SkipCall]
		protected internal override void Step() {}

		[SkipCall]
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples) {}

		public void* GetGLProcAddress(StringView procName) => null;

		Null_Context context = new Null_Context() ~ delete _;

		public ISystemOpenGL.Context GetGLContext() => context;
	}
}
