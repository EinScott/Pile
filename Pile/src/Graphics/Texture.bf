using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class Texture
	{
		internal abstract class Platform
		{
			internal abstract void Initialize(Texture texture);
			internal abstract void ResizeAndClear(uint32 width, uint32 height);
			internal abstract void SetFilter(TextureFilter filter);
			internal abstract void SetWrap(TextureWrap x, TextureWrap y);
			internal abstract void SetData(void* buffer);
			internal abstract void GetData(void* buffer);
			internal abstract bool IsFrameBuffer();
		}

		public static TextureFilter DefaultTextureFilter = TextureFilter.Nearest;

		internal readonly Platform platform ~ delete _;
		public readonly TextureFormat format;

		public uint32 Width { get; private set; }
		public uint32 Height { get; private set; }

		public uint32 Size => Width * Height * format.Size();

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

		public this(uint32 width, uint32 height, TextureFormat format = .Color)
		{
			Debug.Assert(Core.Graphics != null, "Core needs to be initialized before creating platform dependant objects");

			Debug.Assert(width > 0 || height > 0, "Texture size must be larger than 0");

			Width = width;
			Height = height;
			this.format = format;

			platform = Core.Graphics.CreateTexture(width, height, format);
			platform.Initialize(this);

			filter = DefaultTextureFilter;
		}

		public this(Bitmap bitmap)
			: this(bitmap.Width, bitmap.Height, .Color)
		{
			platform.SetData(&bitmap.Pixels[0]);
		}

		public void CopyTo(Bitmap bitmap)
		{
			bitmap.ResizeAndClear(Width, Height);

			var span = scope Span<Color>(bitmap.Pixels);
			platform.GetData(span);
		}

		public Result<void> Set(Bitmap bitmap)
		{
			if ((bitmap.Width != Width || bitmap.Height != Height) && (ResizeAndClear(bitmap.Width, bitmap.Height) case .Err)) return .Err; // Resize this if needed
			platform.SetData(scope Span<Color>(bitmap.Pixels));

			return .Ok;
		}

		public Result<void> ResizeAndClear(uint32 width, uint32 height)
		{
			if (width <= 0 || height <= 0)
				LogErrorReturn!("Texture size must be larger than 0");

			if (Width != width || Height != height)
			{
				Width = width;
				Height = height;

				platform.ResizeAndClear(width, height);
			}
			return .Ok;
		}

		public Result<void> SetColor(ref Span<Color> buffer) => SetData<Color>(ref buffer);
		public Result<void> SetData<T>(ref Span<T> buffer)
		{
			if (sizeof(T) * buffer.Length * sizeof(T) < (.)Size)
				LogErrorReturn!("Buffer is smaller than the Size of the Texture");

			platform.SetData(&buffer[0]);
			return .Ok;
		}

		public Result<void> GetColor(ref Span<Color> buffer) => GetData<Color>(ref buffer);
		public Result<void> GetData<T>(ref Span<T> buffer)
		{
			if (sizeof(T) * buffer.Length * sizeof(T) < (.)Size)
				LogErrorReturn!("Buffer is smaller than the Size of the Texture");

			platform.GetData(&buffer[0]);
			return .Ok;
		}
	}
}
