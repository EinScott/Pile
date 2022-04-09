using System;

namespace Pile
{
	class Subtexture
	{
		public readonly Vector2[4] TexCoords { [Inline]get; private set; }
 		public readonly Point2[4] DrawCoords { [Inline]get; private set; }

		public Texture Texture
		{
			[Inline]
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
			[Inline]
			get => source;
			set
			{
				source = value;
				UpdateCoords();
			}
		}

		public Rect Frame
		{
			[Inline]
		    get => frame;
		    set
		    {
		        frame = value;
		        UpdateCoords();
		    }
		}

		[Inline]
		public int Width => frame.Width;
		[Inline]
		public int Height => frame.Height;

		Texture texture;
		Rect frame;
		Rect source;

		public this() {}
		public this(Texture texture) : this(texture, Rect(0, 0, texture.Width, texture.Height), Rect(0, 0, texture.Width, texture.Height)) {}

		public this(TextureView view)
		{
			this.texture = view.texture;
			this.source = view.source;
			this.frame = view.frame;

			TexCoords = view.TexCoords;
			DrawCoords = view.DrawCoords;
		}

		public this(Texture texture, Rect source)
		{
			Reset(texture, source);
		}

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

		public void Reset(Texture texture, Rect source)
		{
			this.texture = texture;
			this.source = source;
			this.frame = source;

			UpdateCoords();
		}

		public (Rect Source, Rect Frame) GetClip(Rect clip)
		{
			(Rect Source, Rect Frame) result = ?;

			result.Source = (clip + Point2(source.Left, source.Top) + Point2(frame.Left, frame.Top)).OverlapRect(source);

			result.Frame.X = Math.Min(0, frame.X + clip.X);
			result.Frame.Y = Math.Min(0, frame.Y + clip.Y);
			result.Frame.Width = clip.Width;
			result.Frame.Height = clip.Height;

			return result;
		}

		public (Rect Source, Rect Frame) GetClip(int x, int y, int w, int h)
		{
		    return GetClip(Rect(x, y, w, h));
		}

		public void GetClipSubtexture(Subtexture into, Rect clip)
		{
		    let (source, frame) = GetClip(clip);
		    into.Reset(texture, source, frame);
		}

		void UpdateCoords()
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
		        let tx0 = source.X / (float)texture.Width;
				let ty0 = source.Y / (float)texture.Height;
				let tx1 = source.Right / (float)texture.Width;
				let ty1 = source.Bottom / (float)texture.Height;

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

		public static operator TextureView(Subtexture t) => .(t);
	}
}
