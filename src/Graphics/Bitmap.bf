using System;
using System.IO;

namespace Pile
{
	public class Bitmap
	{
		public readonly Color[] pixels;
		public readonly int32 width;
		public readonly int32 height;

		public this(int32 width, int32 height, Color[] colors)
		{
			Runtime.Assert(width <= 0 || height <= 0 || width * height > colors.Count);

			this.pixels = pixels;
			this.width = width;
			this.height = height;
		}

		public this(int32 width, int32 height) : this(width, height, new Color[width * height]) {}

		public void Premultiply()
		{
			uint8* rgba = (uint8*)&(void)pixels;

			let len = pixels.Count * 4;
			for (int32 i = 0; i < len; i++)
			{
				rgba[i + 0] = rgba[i + 0] * rgba[i + 3] / 255;
				rgba[i + 1] = rgba[i + 1] * rgba[i + 3] / 255;
				rgba[i + 2] = rgba[i + 2] * rgba[i + 3] / 255;
			}
		}

		public void SetPixels(Span<Color> source)
		{
			source.CopyTo(pixels);
		}

		public void GetPixels(Span<Color> dest, Rect destRect, Rect sourceRect)
		{
			Span<Color> src = Span<Color>(pixels);
			var sr = sourceRect;

			// can't be outside of the source image
			if (sourceRect.Left < 0) sr.Left = 0;
			if (sourceRect.Top < 0) sr.Top = 0;
			if (sourceRect.Right > width) sr.Right = width;
			if (sourceRect.Bottom > height) sr.Bottom = height;

			// can't be larger than our destination
			if (sourceRect.Width > destRect.Width - destRect.X)
			    sr.Width = destRect.Width - destRect.X;
			if (sourceRect.Height > destRect.Height - destRect.Y)
			    sr.Height = destRect.Height - destRect.Y;

			for (int y = 0; y < sr.Height; y++)
			{
			    var from = src.Slice(sr.X + (sr.Y + y) * width, sr.Width);
			    var to = dest.Slice(destRect.X + (destRect.Y + y) * destRect.Width, sr.Width);

			    from.CopyTo(to);
			}
		}

		public Bitmap GetSubBitmap(Rect source)
		{
			var bmp = new Bitmap((int32)source.Width, (int32)source.Height);
			GetPixels(bmp.pixels, Rect(0, 0, source.Width, source.Height), source);
			return bmp;
		}

		public Bitmap Clone()
		{
			let pix = new Color[pixels.Count];
			pixels.CopyTo(pix);
			return new Bitmap(width, height, pixels);
		}
	}
}
