namespace Pile
{
	public interface IGraphicsOpenGL
	{
		public enum GLProfile : uint32
		{
			// Maps to SDL.SDL_GLProfile enum
			Core = 0x0001,
			Compatability = 0x0002,
			ES = 0x0004
		}

		public GLProfile Profile { get; }
	}
}
