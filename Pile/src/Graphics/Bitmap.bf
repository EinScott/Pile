using System;
using System.IO;
using System.Diagnostics;

namespace Pile
{
	public class Bitmap
	{
		public Color[] Pixels { get; private set; }
		public uint32 Width { get; private set; }
		public uint32 Height { get; private set; }

		public this(uint32 width, uint32 height, Span<Color> pixels)
		{
			Runtime.Assert(width > 0 && height > 0 && width * height <= pixels.Length, "Bitmap Width and Height need to be greater than 0; Number of Pixels in array needs to be at least Width * Height");

			Width = width;
			Height = height;

			Pixels = new Color[width * height];
			pixels.CopyTo(Pixels);
		}

		public this(uint32 width, uint32 height)
		{
			Runtime.Assert(width > 0 && height > 0, "Bitmap Width and Height need to be greater than 0");

			Width = width;
			Height = height;

			Pixels = new Color[width * height];
		}

		public this() : this(1, 1, Span<Color>(&Color(0, 0, 0, 0), 1)) {}

		public ~this()
		{
			if (Pixels != null) delete Pixels;
		}

		public void Premultiply()
		{
			uint8* rgba = (uint8*)&Pixels[0];

			let len = Pixels.Count * 4;
			for (int32 i = 0; i < len; i++)
			{
				rgba[i + 0] = rgba[i + 0] * rgba[i + 3] / 255;
				rgba[i + 1] = rgba[i + 1] * rgba[i + 3] / 255;
				rgba[i + 2] = rgba[i + 2] * rgba[i + 3] / 255;
			}
		}

		public void Reset(uint32 width, uint32 height, Span<Color> pixels)
		{
			Runtime.Assert(width > 0 && height > 0 && width * height <= pixels.Length, "Bitmap Width and Height need to be greater than 0; Number of Pixels in array needs to be at least Width * Height");

			Width = width;
			Height = height;

			if (Pixels != null) delete Pixels;
			Pixels = new Color[width * height];
			pixels.CopyTo(Pixels);
		}

		public void ResizeAndClear(uint32 width, uint32 height)
		{
			Runtime.Assert(width > 0 && height > 0, "Bitmap Width and Height need to be greater than 0");

			Width = width;
			Height = height;

			if (Pixels != null) delete Pixels;
			Pixels = new Color[width * height];
		}

		public void Clear()
		{
			Array.Clear(&Pixels[0], Pixels.Count);
		}

		public void SetPixels(Span<Color> source)
		{
			source.CopyTo(Pixels);
		}

		public void SetPixels(Rect destination, Span<Color> source)
		{
			let dst = Span<Color>(Pixels);

			for (int y = 0; y < destination.Height; y++)
			{
			    let from = source.Slice(y * destination.Width, destination.Width);
			    let to = dst.Slice(destination.X + (destination.Y + y) * Width, destination.Width);

			    from.CopyTo(to);
			}
		}

		public void GetPixels(Span<Color> dest, Rect destRect, Rect sourceRect)
		{
			Span<Color> src = Span<Color>(Pixels);
			var sr = sourceRect;

			// can't be outside of the source image
			if (sourceRect.Left < 0) sr.Left = 0;
			if (sourceRect.Top < 0) sr.Top = 0;
			if (sourceRect.Right > Width) sr.Right = Width;
			if (sourceRect.Bottom > Height) sr.Bottom = Height;

			// can't be larger than our destination
			if (sourceRect.Width > destRect.Width - destRect.X)
			    sr.Width = destRect.Width - destRect.X;
			if (sourceRect.Height > destRect.Height - destRect.Y)
			    sr.Height = destRect.Height - destRect.Y;

			for (int y = 0; y < sr.Height; y++)
			{
			    var from = src.Slice(sr.X + (sr.Y + y) * Width, sr.Width);
			    var to = dest.Slice(destRect.X + (destRect.Y + y) * destRect.Width, sr.Width);

			    from.CopyTo(to);
			}
		}

		public void GetSubBitmap(Rect source, Bitmap sub)
		{
			sub.ResizeAndClear((.)source.Width, (.)source.Height);
			GetPixels(sub.Pixels, Rect(0, 0, source.Width, source.Height), source);
		}

		public void CopyTo(Bitmap bitmap)
		{
			bitmap.ResizeAndClear(Width, Height);
			bitmap.SetPixels(Pixels);
		}
	}
}
