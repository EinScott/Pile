using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class Texture
	{
		public readonly TextureFormat format;

		public uint32 Width { get; private set; }
		public uint32 Height { get; private set; }

		public uint32 Size => Width * Height * format.Size();
		bool genMipmaps;

		TextureFilter filter;
		public TextureFilter Filter
		{
			get => filter;
			set => SetFilter(filter = value);
		}

		TextureWrap wrapX;
		public TextureWrap WrapX
		{
			get => wrapX;
			set => SetWrap(wrapX = value, wrapY);
		}
		
		TextureWrap wrapY;
		public TextureWrap WrapY
		{
			get => wrapY;
			set => SetWrap(wrapX, wrapY = value);
		}

		public extern bool IsFrameBuffer { get; }

		public this(uint32 width, uint32 height, TextureFormat format = .Color, TextureFilter filter = Core.Defaults.TextureFilter, bool genMipmaps = Core.Defaults.TexturesGenMipmaps)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");
			Runtime.Assert(width > 0 && height > 0, "Texture size must be larger than 0");

			Width = width;
			Height = height;
			this.format = format;
			this.filter = filter;
			this.genMipmaps = genMipmaps;

			Initialize();
		}

		public this(Bitmap bitmap, TextureFilter filter = Core.Defaults.TextureFilter, bool genMipmaps = Core.Defaults.TexturesGenMipmaps)
			: this(bitmap.Width, bitmap.Height, .Color, filter, genMipmaps)
		{
			SetData(bitmap.Pixels.Ptr);
		}

		public void CopyTo(Bitmap bitmap)
		{
			bitmap.ResizeAndClear(Width, Height);

			var span = Span<Color>(bitmap.Pixels);
			GetData(span.Ptr);
		}

		public void Set(Bitmap bitmap)
		{
			if (bitmap.Width != Width || bitmap.Height != Height)
				ResizeAndClear(bitmap.Width, bitmap.Height); // Resize this if needed

			SetData(bitmap.Pixels.Ptr);
		}

		public void ResizeAndClear(uint32 newWidth, uint32 newHeight)
		{
			Runtime.Assert(newWidth > 0 && newHeight > 0, "FrameBuffer size must be larger than 0");

			if (Width != newWidth || Height != newHeight)
			{
				Width = newWidth;
				Height = newHeight;

				ResizeAndClearInternal(newWidth, newHeight);
			}
		}

		[Inline]
		public void SetColor(Span<Color> buffer) => SetData<Color>(buffer);
		public void SetData<T>(Span<T> buffer)
		{
			Runtime.Assert(sizeof(T) * buffer.Length * sizeof(T) >= (.)Size, "Buffer size must be at least equal to the size of the texture");

			SetData(buffer.Ptr);
		}

		[Inline]
		public void GetColor(Span<Color> buffer) => GetData<Color>(buffer);
		public void GetData<T>(Span<T> buffer)
		{
			Runtime.Assert(sizeof(T) * buffer.Length * sizeof(T) >= (.)Size, "Buffer size must be at least equal to the size of the texture");

			GetData(buffer.Ptr);
		}

		protected extern void Initialize();
		protected extern void ResizeAndClearInternal(uint32 width, uint32 height);
		protected extern void SetFilter(TextureFilter filter);
		protected extern void SetWrap(TextureWrap x, TextureWrap y);
		protected extern void SetData(void* buffer);
		protected extern void GetData(void* buffer);

		public static operator TextureView(Texture t) => .(t);
	}
}
