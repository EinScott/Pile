using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_System : System, ISystemOpenGL
	{
		public override uint32 MajorVersion => 1;
		public override uint32 MinorVersion => 0;
		public override String ApiName => "Null System";
		public override String Info => "";

		internal override Input CreateInput()
		{
			return new Null_Input();
		}

		internal override Window CreateWindow(int32 width, int32 height)
		{
			return new Null_Window(width, height);
		}

		[SkipCall]
		internal override void Initialize() {}

		[SkipCall]
		internal override void Step() {}

		internal override void DetermineDataPaths(StringView title)
		{
			base.DetermineDataPaths(title); // It's probably best to leave this as is
		}

		[SkipCall]
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples) {}

		public void* GetGLProcAddress(StringView procName) => null;

		Null_Context context = new Null_Context() ~ delete _;

		public ISystemOpenGL.Context GetGLContext() => context;
	}
}
