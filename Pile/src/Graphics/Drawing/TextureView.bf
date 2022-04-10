using System;

namespace Pile
{
	/// Simple structure which both Textures and Subtextures easily convert to
	struct TextureView
	{
		public readonly Vector2[4] TexCoords;
		public readonly Point2[4] DrawCoords;

		public int Width => frame.Width;
		public int Height => frame.Height;

		public readonly Texture texture;
		public readonly Rect frame;
		public readonly Rect source;

		public this(Texture texture)
		{
			this.texture = texture;
			this.source = this.frame = .(0, 0, texture.Width, texture.Height);

			DrawCoords = .(.Zero, .(source.Width, 0), .(source.Width, source.Height), .(0, source.Height));
			TexCoords = .(.Zero, .UnitX, .One, .UnitY);
		}

		public this(Subtexture subTex)
		{
			this.texture = subTex.Texture;
			this.source = subTex.Source;
			this.frame = subTex.Frame;

			TexCoords = subTex.TexCoords;
			DrawCoords = subTex.DrawCoords;
		}

		public this(Texture texture, Rect source) : this(texture, source, Rect(0, 0, source.Width, source.Height)) {}
		public this(Texture texture, Rect source, Rect frame)
		{
			this.texture = texture;
			this.source = source;
			this.frame = frame;

			DrawCoords = ?;

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
				TexCoords = ?;

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
			else TexCoords = .();
		}

		public (Rect Source, Rect Frame) GetClip(Rect clip)
		{
			(Rect Source, Rect Frame) result = default;

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

		public TextureView GetClipTextureView(Rect clip)
		{
		    let (source, frame) = GetClip(clip);
		    return TextureView(texture, source, frame);
		}
	}
}
