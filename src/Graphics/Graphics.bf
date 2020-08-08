using System;

namespace Pile
{
	public abstract class Graphics
	{
		public abstract int32 MajorVersion { get; }
		public abstract int32 MinorVersion { get; }

		public abstract int32 MaxTextureSize { get; }

		protected abstract Result<void, String> Initialize();
		protected abstract void Update();
		protected abstract void AfterRender();
	}
}