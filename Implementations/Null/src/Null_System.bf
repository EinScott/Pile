using System;

namespace Pile.Implementations
{
	public class Null_System : System, ISystemOpenGL
	{
		public override String ApiName => "Null System";

		protected override Input CreateInput()
		{
			return new Null_Input();
		}

		protected override Window CreateWindow(int32 width, int32 height)
		{
			return new Null_Window(width, height);
		}

		[SkipCall]
		protected override void Initialize() {}

		[SkipCall]
		protected override void Update() {}

		protected override void DetermineDataPath()
		{
			base.DetermineDataPath(); // It's probably best to leave this as is
		}

		[SkipCall]
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples) {}

		public void* GetGLProcAddress(StringView procName) => null;

		Null_Context context = new Null_Context() ~ delete _;

		public ISystemOpenGL.Context GetGLContext() => context;
	}
}
