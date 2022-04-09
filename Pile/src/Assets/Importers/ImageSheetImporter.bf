using System;
using System.Diagnostics;
using System.IO;
using System.Collections;
using Bon;

using internal Pile;

namespace Pile
{
	[RegisterImporter]
	class ImageSheetImporter : ImageImporter
	{
		[BonTarget]
		protected enum SubmitOption
		{
			PackedTexture,
			PackedExactTexture
		}

		[BonTarget]
		struct Options
		{
			public UPoint2 sliceOriginOffset;
			public UPoint2 sliceImageSize;
			public Point2 slicePadding;

			public SubmitOption submit;
			public FilterOption filter;
		}

		Options options;

		public override String Name => "imageSheet";

		static StringView[?] ext = .("png");
		public override Span<StringView> TargetExtensions => ext;

		public override void ClearConfig()
		{
			options = default;
		}

		public override Result<void> SetConfig(StringView bonStr)
		{
			Try!(Bon.Deserialize(ref options, bonStr));
			return .Ok;
		}

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let s = scope ArrayStream(data);
			let sr = scope Serializer(s);

			let bitmap = scope Bitmap(
				sr.Read<uint32>(),
				sr.Read<uint32>());
			sr.ReadInto!(Span<uint8>((uint8*)bitmap.Pixels.Ptr, bitmap.Pixels.Count * sizeof(Color)));

			let slicemap = scope Bitmap((.)options.sliceImageSize.X, (.)options.sliceImageSize.Y);
			Rect clip = .(options.sliceOriginOffset, options.sliceImageSize);

			TextureFilter filter;
			switch (options.filter)
			{
			case .Default:
				filter = Core.Defaults.TextureFilter;
			case .Linear: filter = .Linear;
			case .Nearest: filter = .Nearest;
			}

			let strideX = (int)options.sliceImageSize.X + options.slicePadding.X;
			let strideY = (int)options.sliceImageSize.Y + options.slicePadding.Y;
			for (var i = 0; clip.Y + clip.Height + strideY < bitmap.Height; clip.Y += strideY, i++)
				for (; clip.X + clip.Width + strideX < bitmap.Width; clip.X += strideX, i++)
				{
					bitmap.GetSubBitmap(clip, slicemap, true);

					let nameStr = scope String(name.Length + 2)..Append(name);
					i.ToString(nameStr);
					switch (options.submit)
					{
					case .PackedTexture:
						Try!(SubmitLoadedTextureAsset(nameStr, slicemap, filter));
					case .PackedExactTexture:
						Try!(SubmitLoadedTextureAsset(nameStr, slicemap, filter, true));
					}
				}

			return .Ok;
		}
	}
}