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

		/// Buffered will only reallocate if pixel buffer isnt long enough
		public void Reset(uint32 width, uint32 height, Span<Color> pixels, bool buffered = false)
		{
			Runtime.Assert(width > 0 && height > 0 && width * height <= pixels.Length, "Bitmap Width and Height need to be greater than 0; Number of Pixels in array needs to be at least Width * Height");

			Width = width;
			Height = height;

			if (!buffered || Width * Height > Pixels.Count)
			{
				if (Pixels != null) delete Pixels;
				Pixels = new Color[width * height];
			}

			pixels.CopyTo(Pixels);
		}

		/// Buffered will only reallocate if pixel buffer isnt long enough
		public void ResizeAndClear(uint32 width, uint32 height, bool buffered = false)
		{
			Runtime.Assert(width > 0 && height > 0, "Bitmap Width and Height need to be greater than 0");

			Width = width;
			Height = height;

			if (!buffered || Width * Height > Pixels.Count)
			{
				if (Pixels != null) delete Pixels;
				Pixels = new Color[width * height];
			}
			else Clear();
		}

		public void Clear()
		{
			Array.Clear(&Pixels[0], Pixels.Count);
		}

		public void SetPixels(Span<Color> pixels)
		{
			Runtime.Assert(Width * Height <= pixels.Length, "Number of Pixels in array needs to be at least Width * Height");

			pixels.CopyTo(Pixels);
		}

		public void SetPixels(Rect dest, Span<Color> pixels)
		{
			Runtime.Assert(dest.Width > 0 && dest.Height > 0 && dest.Width * dest.Height <= pixels.Length, "Destination Rect Width and Height need to be greater than 0; Number of Pixels in array needs to be at least Destination.Width * Destination.Height");

			let dst = Span<Color>(Pixels);

			for (int y = 0; y < dest.Height; y++)
			{
			    let from = pixels.Slice(y * dest.Width, dest.Width);
			    let to = dst.Slice(dest.X + (dest.Y + y) * Width, dest.Width);

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

		/// Buffered will only reallocate if pixel buffer isnt long enough
		public void GetSubBitmap(Rect source, Bitmap sub, bool buffered = false)
		{
			sub.ResizeAndClear((uint32)source.Width, (uint32)source.Height, buffered);
			GetPixels(sub.Pixels, Rect(0, 0, source.Width, source.Height), source);
		}

		/// Buffered will only reallocate if pixel buffer isnt long enough
		public void CopyTo(Bitmap bitmap, bool buffered = false)
		{
			bitmap.Reset(Width, Height, Pixels, buffered);
		}
	}
}
