using Pile;

namespace Dimtoo
{
	public struct Frame
	{
		public readonly Subtexture Texture;
		public readonly int Duration;

		public this(Subtexture texture, int duration)
		{
			Texture = texture;
			Duration = duration;
		}

		public static operator Subtexture(Frame frame) => frame.Texture;
	}
}
