using System;

namespace Pile
{
	public class Subtexture
	{
		public Point2[4] TexCoords { get; private set; }
 		public Point2[4] DrawCoords { get; private set; }

		public Texture Texture
		{
			get => texture;
			set
			{
				if (texture != value)
				{
					texture = value;
					UpdateCoords();
				}
			}
		}

		public Rect Source
		{
			get => source;
			set
			{
				source = value;
				UpdateCoords();
			}
		}

		public Rect Frame
		{
		    get => frame;
		    set
		    {
		        frame = value;
		        UpdateCoords();
		    }
		}


		public int Width => frame.Width;
		public int Height => frame.Height;

		Texture texture;
		Rect frame;
		Rect source;

		public this() {}
		public this(Texture texture) : this(texture, Rect(0, 0, texture.Width, texture.Height), Rect(0, 0, texture.Width, texture.Height)) {}
		public this(Texture texture, Rect source) : this(texture, Rect(0, 0, source.Width, source.Height)) {}

		public this(Texture texture, Rect source, Rect frame)
		{
			Reset(texture, source, frame);
		}

		public void Reset(Texture texture, Rect source, Rect frame)
		{
			this.texture = texture;
			this.source = source;
			this.frame = frame;

			UpdateCoords();
		}

		public (Rect Source, Rect Frame) GetClip(Rect clip)
		{
			(Rect Source, Rect Frame) result;

			result.Source = (clip + Point2(Source.Left, Source.Top) + Point2(Frame.Left, Frame.Top)).OverlapRect(Source);

			result.Frame.X = Math.Min(0, Frame.X + clip.X);
			result.Frame.Y = Math.Min(0, Frame.Y + clip.Y);
			result.Frame.Width = clip.Width;
			result.Frame.Height = clip.Height;

			return result;
		}

		public (Rect Source, Rect Frame) GetClip(int x, int y, int w, int h)
		{
		    return GetClip(Rect(x, y, w, h));
		}

		public Subtexture GetClipSubtexture(Rect clip)
		{
		    var (source, frame) = GetClip(clip);
		    return new Subtexture(Texture, source, frame);
		}

		private void UpdateCoords()
		{
		    DrawCoords[0].X = -frame.X;
		    DrawCoords[0].Y = -frame.Y;
		    DrawCoords[1].X = -frame.X + source.Width;
		    DrawCoords[1].Y = -frame.Y;
		    DrawCoords[2].X = -frame.X + source.Width;
		    DrawCoords[2].Y = -frame.Y + source.Height;
		    DrawCoords[3].X = -frame.X;
		    DrawCoords[3].Y = -frame.Y + source.Height;

		    if (texture != null)
		    {
		        let tx0 = source.X / texture.Width;
				let ty0 = source.Y / texture.Height;
				let tx1 = source.Right / texture.Width;
				let ty1 = source.Bottom / texture.Height;

		        TexCoords[0].X = tx0;
		        TexCoords[0].Y = ty0;
		        TexCoords[1].X = tx1;
		        TexCoords[1].Y = ty0;
		        TexCoords[2].X = tx1;
		        TexCoords[2].Y = ty1;
		        TexCoords[3].X = tx0;
		        TexCoords[3].Y = ty1;
		    }
		}
	}
}