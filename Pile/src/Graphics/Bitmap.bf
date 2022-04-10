using System;
using System.IO;
using System.Diagnostics;

namespace Pile
{
	class Bitmap
	{
		public Color[] Pixels { [Inline] get; [Inline] private set; }
		public uint32 Width { [Inline] get; [Inline] private set; }
		public uint32 Height { [Inline] get; [Inline] private set; }

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

		public ref Color this[int x, int y]
		{
			[Checked, Inline]
			get
			{
				Runtime.Assert(x < Width && y < Height, "Trying to access pixel outside of bitmap");
				return ref Pixels[x + y * Width];
			}
			[Checked]
			set
			{
				Runtime.Assert(x < Width && y < Height, "Trying to access pixel outside of bitmap");
				Pixels[x + y * Width] = value;
			}

			[Unchecked, Inline]
			get
			{
				return ref Pixels[x + y * Width];
			}

			[Unchecked]
			set
			{
				Pixels[x + y * Width] = value;
			}
		}

		public ref Color this[uint x, uint y]
		{
			[Checked, Inline]
			get
			{
				Runtime.Assert(x < Width && y < Height, "Trying to access pixel outside of bitmap");
				return ref Pixels[(.)(x + y * Width)];
			}

			[Checked]
			set
			{
				Runtime.Assert(x < Width && y < Height, "Trying to access pixel outside of bitmap");
				Pixels[(.)(x + y * Width)] = value;
			}

			[Unchecked, Inline]
			get
			{
				return ref Pixels[(.)(x + y * Width)];
			}

			[Unchecked]
			set
			{
				Pixels[(.)(x + y * Width)] = value;
			}
		}

		public void Premultiply()
		{
			let rgba = (uint8*)Pixels.Ptr;

			let len = (int)Width * Height * 4;
			for (int32 i = 0; i < len; i++)
			{
				rgba[i + 0] = rgba[i + 0] * rgba[i + 3] / 255;
				rgba[i + 1] = rgba[i + 1] * rgba[i + 3] / 255;
				rgba[i + 2] = rgba[i + 2] * rgba[i + 3] / 255;
			}
		}

		/// Buffered will only reallocate if pixel buffer isnt long enough
		public void Reset(uint32 width, uint32 height, Span<Color> pixels, bool buffered = true)
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
		public void ResizeAndClear(uint32 width, uint32 height, bool buffered = true)
		{
			Runtime.Assert(width > 0 && height > 0, "Bitmap Width and Height need to be greater than 0");

			if (!buffered || ((Width != width || Height != height || Pixels == null) || Width * Height > Pixels.Count))
			{
				if (Pixels != null) delete Pixels;
				Pixels = new Color[width * height];
			}
			else Clear();

			Width = width;
			Height = height;
		}

		public void Clear()
		{
			Array.Clear(Pixels.Ptr, Pixels.Count);
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

		public void VerticalFlip()
		{
			for (let row < Height / 2)
			{
				const int BUF_SIZE = 8192;
				for (int rowSize = Width; rowSize > 0; rowSize -= BUF_SIZE / sizeof(Color))
				{
					uint8[BUF_SIZE] buf = ?;
					let top = Pixels.Ptr + row * Width + Width - rowSize;
					let bottom = Pixels.Ptr + (Height - 1 - row) * Width + Width - rowSize; // == bitmap.Pixels.Ptr + bitmap.Pixels.Count - bitmap.Width * (1 + row)

					let rowByteSize = rowSize * sizeof(Color);
					let length = (rowByteSize >= BUF_SIZE ? BUF_SIZE : rowByteSize);

					Internal.MemCpy(&buf[0], top, length);
					Internal.MemCpy(top, bottom, length);
					Internal.MemCpy(bottom, &buf[0], length);
				}
			}
		}
	}
}
