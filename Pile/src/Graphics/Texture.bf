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

		readonly Platform platform ~ delete _;
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

		public bool IsFrameBuffer => platform.IsFrameBuffer();

		public this(int32 width, int32 height, TextureFormat format = .Color)
		{
			Runtime.Assert(width > 0 || height > 0, "Texture size must be larger than 0");

			Width = width;
			Height = height;
			this.format = format;

			platform = Core.Graphics.[Friend]CreateTexture(width, height, format);
			platform.Initialize(this);

			filter = DefaultTextureFilter;
		}

		public this(Bitmap bitmap)
			: this(bitmap.Height, bitmap.Width, .Color)
		{
			platform.SetData(&bitmap.Pixels[0]);
		}

		public void CopyTo(Bitmap bitmap)
		{
			bitmap.Resize(Width, Height);

			var span = scope Span<Color>(bitmap.Pixels);
			platform.GetData(span);
		}

		public Result<void, String> Set(Bitmap bitmap)
		{
			if (!bitmap.[Friend]initialized) return .Err("Bitmap is empty");

			if (Resize(bitmap.Width, bitmap.Height) case .Err(let err)) return .Err(err);
			platform.SetData(scope Span<Color>(bitmap.Pixels));

			return .Ok;
		}

		/** Resize also clears the texture! TextureFormat is preserved.*/
		public Result<void, String> Resize(int32 width, int32 height)
		{
			if (width <= 0 || height <= 0)
				return .Err("Texture size must be larger than 0");

			if (Width != width || Height != height)
			{
				Width = width;
				Height = height;

				platform.Resize(width, height);
			}
			return .Ok;
		}

		public Result<void, String> SetColor(ref Span<Color> buffer) => SetData<Color>(ref buffer);
		public Result<void, String> SetData<T>(ref Span<T> buffer)
		{
			if (sizeof(T) * buffer.Length * sizeof(T) < Size)
				return .Err("Buffer is smaller than the Size of the Texture");

			platform.SetData(&buffer[0]);
			return .Ok;
		}

		public Result<void, String> GetColor(ref Span<Color> buffer) => GetData<Color>(ref buffer);
		public Result<void, String> GetData<T>(ref Span<T> buffer)
		{
			if (sizeof(T) * buffer.Length * sizeof(T) < Size)
				return .Err("Buffer is smaller than the Size of the Texture");

			platform.GetData(&buffer[0]);
			return .Ok;
		}
	}
}
