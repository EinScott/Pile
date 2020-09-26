using System;
using System.IO;

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
		public override Result<void, FileResult> DirectoryCreate(StringView path) => .Ok;

		[SkipCall]
		public override Result<void, FileResult> DirectoryDelete(StringView path) => .Ok;

		public override FileEnumerator DirectoryEnumerate(StringView searchPath, EnumerateFlags flags)
		{
			return base.DirectoryEnumerate("", flags); // TODO: I'm not sure if this returns no or all entries
		}

		public override bool DirectoryExists(StringView path) => true;

		[SkipCall]
		public override Result<void, FileResult> DirectoryMove(StringView fromPath, StringView toPath) => .Ok;

		[SkipCall]
		public override Result<void, FileResult> FileCopy(StringView fromPath, StringView toPath, bool overwrite = true) => .Ok;

		[SkipCall]
		public override Result<void, FileResult> FileDelete(StringView path) => .Ok;

		public override bool FileExists(StringView path) => true;

		public override Result<DateTime> FileGetWriteTime(StringView path, bool utc = false) => .Ok(.MinValue);

		[SkipCall]
		public override Result<void, FileResult> FileMove(StringView fromPath, StringView toPath) => .Ok;

		public override Result<uint8[], FileError> FileReadAllBytes(StringView path) => .Ok(new uint8[1](0));

		[SkipCall]
		public override Result<void, FileError> FileReadAllText(StringView path, String outText, bool preserveLineEnding = false) => .Ok;

		[SkipCall]
		public override Result<void> FileWriteAllBytes(StringView path, Span<uint8> data) => .Ok;

		[SkipCall]
		public override Result<void> FileWriteAllText(StringView path, StringView text, bool doAppend = false) => .Ok;

		[SkipCall]
		public override Result<void> FileWriteAllText(StringView path, StringView text, System.Text.Encoding encoding) => .Ok;
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples)
		{

		}

		public void* GetGLProcAddress(StringView procName)
		{
			return null;
		}

		Null_Context context = new Null_Context() ~ delete _;

		public ISystemOpenGL.Context GetGLContext()
		{
			return context;
		}
	}
}
