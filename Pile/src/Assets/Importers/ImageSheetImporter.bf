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
		struct MetaOptions
		{
			public UPoint2 sliceOriginOffset;
			public UPoint2 sliceImageSize;
			public Point2 slicePadding;
		}

		public override String Name => "imageSheet";

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let s = scope ArrayStream(data);
			let sr = scope Serializer(s);

			let bitmap = scope Bitmap(
				sr.Read<uint32>(),
				sr.Read<uint32>());

			MetaOptions metaOpt = .{
				sliceOriginOffset = .(sr.Read<uint32>(), sr.Read<uint32>()),
				sliceImageSize = .(sr.Read<uint32>(), sr.Read<uint32>()),
				slicePadding = .(sr.Read<uint32>(), sr.Read<uint32>())
			};

			sr.ReadInto!(Span<uint8>((uint8*)bitmap.Pixels.Ptr, bitmap.Pixels.Count * sizeof(Color)));

			let slicemap = scope Bitmap((.)metaOpt.sliceImageSize.X, (.)metaOpt.sliceImageSize.Y);
			Rect clip = .(metaOpt.sliceOriginOffset, metaOpt.sliceImageSize);

			TextureFilter filter;
			switch (options.filter)
			{
			case .Default:
				filter = Core.Defaults.TextureFilter;
			case .Linear: filter = .Linear;
			case .Nearest: filter = .Nearest;
			}

			let strideX = (int)metaOpt.sliceImageSize.X + metaOpt.slicePadding.X;
			let strideY = (int)metaOpt.sliceImageSize.Y + metaOpt.slicePadding.Y;
			for (var i = 0; clip.Y + clip.Height + strideY < bitmap.Height; clip.Y += strideY, i++)
				for (; clip.X + clip.Width + strideX < bitmap.Width; clip.X += strideX, i++)
				{
					bitmap.GetSubBitmap(clip, slicemap, true);

					let nameStr = scope String(name.Length + 2)..Append(name);
					i.ToString(nameStr);

					switch (options.submit)
					{
					case .PackedTexture:
						Try!(SubmitLoadedTextureAsset(nameStr, bitmap, filter));
					case .PackedExactTexture:
						Try!(SubmitLoadedTextureAsset(nameStr, bitmap, filter, true));
					case .SingleTexture:
						Try!(SubmitLoadedAsset(nameStr, new Texture(bitmap, filter)));
					case .SingleBitmap:
						Try!(SubmitLoadedAsset(nameStr, bitmap.CopyTo(.. new .(bitmap.Width, bitmap.Height))));
					}
				}

			return .Ok;
		}

		public override Result<uint8[]> Build(StringView filePath)
		{
			Debug.Assert(File.Exists(filePath));

			FileStream fs = scope FileStream();
			Try!(fs.Open(filePath, .Open, .Read));

			if (!PNG.IsValid(fs))
				LogErrorReturn!("ImageSheetImporter: Data in not in PNG format (only option right now)");

			let bitmap = scope Bitmap();
			Try!(PNG.Read(fs, bitmap));

			// TODO: try to just write back our png? - use qui internally?
			// does this work again; try after we use compression again!

			let metaFilePath = ToScopedMetaFilePath!(filePath);

			if (!File.Exists(metaFilePath))
				LogErrorReturn!("ImageSheetImporter: No tile .bon file of the same name found");

			String bonMetaFile = scope .();
			if (File.ReadAllText(metaFilePath, bonMetaFile) case .Err)
				LogErrorReturn!("ImageSheetImporter: Error reading meta file");
			MetaOptions metaOpt = default;
			if (Bon.Deserialize(ref metaOpt, bonMetaFile) case .Err)
				LogErrorReturn!("ImageSheetImporter: Error reading bon in meta file");

			Debug.Assert(sizeof(uint32) == sizeof(Color));
			let s = scope ArrayStream((bitmap.Pixels.Count + 2) * sizeof(uint32));
			let sr = scope Serializer(s);

			sr.Write<uint32>(bitmap.Width);
			sr.Write<uint32>(bitmap.Height);
			sr.Write<uint32>((.)metaOpt.sliceOriginOffset.X);
			sr.Write<uint32>((.)metaOpt.sliceOriginOffset.Y);
			sr.Write<uint32>((.)metaOpt.sliceImageSize.X);
			sr.Write<uint32>((.)metaOpt.sliceImageSize.Y);
			sr.Write<uint32>((.)metaOpt.slicePadding.X);
			sr.Write<uint32>((.)metaOpt.slicePadding.Y);
			sr.Write!(Span<uint8>((uint8*)&bitmap.Pixels[0], bitmap.Pixels.Count * sizeof(Color)));

			if (sr.HadError)
				LogErrorReturn!("ImageSheetImporter: Error transfering bitmap data");

			return s.TakeOwnership();
		}
	}
}