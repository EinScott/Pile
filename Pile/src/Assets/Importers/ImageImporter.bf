using System;
using System.Diagnostics;
using System.IO;
using System.Collections;
using Bon;

namespace Pile
{
	[RegisterImporter]
	class ImageImporter : Importer
	{
		[BonTarget]
		enum SubmitOption
		{
			PackedTexture,
			SingleTexture,
			SingleBitmap
		}

		[BonTarget]
		enum FilterOption
		{
			Default,
			Linear,
			Nearest
		}

		[BonTarget]
		struct Options
		{
			public SubmitOption submit; // TODO!
			public FilterOption filter;
		}

		public override String Name => "image";

		static StringView[?] ext = .("png");
		public override Span<StringView> TargetExtensions => ext;

		Options options;

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

			TextureFilter filter;
			switch (options.filter)
			{
			case .Default:
				filter = Core.Defaults.TextureFilter;
			case .Linear: filter = .Linear;
			case .Nearest: filter = .Nearest;
			}

			Try!(SubmitLoadedTextureAsset(name, bitmap, filter));

			return .Ok;
		}

		public override Result<uint8[]> Build(StringView filePath)
		{
			Debug.Assert(File.Exists(filePath));

			FileStream fs = scope FileStream();
			Try!(fs.Open(filePath, .Open, .Read));

			if (!PNG.IsValid(fs))
				LogErrorReturn!("ImageImporter: Data in not in PNG format (only option right now)");

			let bitmap = scope Bitmap();
			Try!(PNG.Read(fs, bitmap));

			// TODO: try to just write back our png? - use qui internally?
			// does this work again; try after we use compression again!

			Debug.Assert(sizeof(uint32) == sizeof(Color));
			let s = scope ArrayStream((bitmap.Pixels.Count + 2) * sizeof(uint32));
			let sr = scope Serializer(s);

			sr.Write<uint32>(bitmap.Width);
			sr.Write<uint32>(bitmap.Height);
			sr.Write!(Span<uint8>((uint8*)&bitmap.Pixels[0], bitmap.Pixels.Count * sizeof(Color)));

			if (sr.HadError)
				LogErrorReturn!("ImageImporter: Error transfering bitmap data");

			return s.TakeOwnership();
		}
	}
}
