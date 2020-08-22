using System;

namespace Pile
{
	public class Texture
	{
		public abstract class Platform
		{
			public abstract void Initialize(Texture texture);
			public abstract void Resize(int32 width, int32 height);
			public abstract void SetFilter(TextureFilter filter);
			public abstract void SetWrap(TextureWrap x, TextureWrap y);
			public abstract void SetData(void* buffer);
			public abstract void GetData(void* buffer);
			public abstract bool IsFrameBuffer();
		}

		public static TextureFilter DefaultTextureFilter = TextureFilter.Nearest;

		readonly Platform platform;
		public readonly TextureFormat format;

		public int32 Width { get; private set; }
		public int32 Height { get; private set; }

		public int32 Size => Width * Height * format.Size();

		TextureFilter filter;
		public TextureFilter Filter
		{
			get => filter;
			set => platform.SetFilter(filter = value);
		}

		TextureWrap wrapX;
		public TextureWrap WrapX
		{
			get => wrapX;
			set => platform.SetWrap(wrapX = value, wrapY);
		}
		
		TextureWrap wrapY;
		public TextureWrap WrapY
		{
			get => wrapY;
			set => platform.SetWrap(wrapX, wrapY = value);
		}

		public this(int32 width, int32 height, TextureFormat format = .Color)
		{
			Runtime.Assert(width > 0 || height > 0);

			Width = width;
			Height = height;
			this.format = format;

			platform = Core.Graphics.[Friend]CreateTexture(width, height, format);
			platform.Initialize(this);

			filter = DefaultTextureFilter;
		}

		public this(Bitmap bitmap)
			: this(bitmap.height, bitmap.width, .Color)
		{
			platform.SetData(scope Span<Color>(bitmap.pixels));
		}

		public ~this()
		{
			delete platform;
		}

		public Bitmap AsNewBitmap()
		{
			var bmp = new Bitmap(Width, Height);

			var span = scope Span<Color>(bmp.pixels);
			platform.GetData(span);
			span.CopyTo(bmp.pixels);

			return bmp;
		}

		public Result<void, String> SetColor(ref Span<Color> buffer) => SetData<Color>(ref buffer);
		public Result<void, String> SetData<T>(ref Span<T> buffer)
		{
			if (sizeof(T) * buffer.Length * sizeof(T) < Size)
				return .Err("Buffer is smaller than the Size of the Texture");

			platform.SetData(&buffer);
			return .Ok;
		}

		public Result<void, String> GetColor(ref Span<Color> buffer) => GetData<Color>(ref buffer);
		public Result<void, String> GetData<T>(ref Span<T> buffer)
		{
			if (sizeof(T) * buffer.Length * sizeof(T) < Size)
				return .Err("Buffer is smaller than the Size of the Texture");

			platform.GetData(&buffer);
			return .Ok;
		}
	}
}
