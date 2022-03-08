using System;
using System.Diagnostics;
using System.IO;
using System.Collections;

namespace Pile
{
	// TODO: more than just PNG
	// TODO: options
	// -> submit to packer or not
	// -> texture format
	// -> keep as bitmap?

	[RegisterImporter]
	class ImageImporter : Importer
	{
		public override String Name => "image";

		static StringView[?] ext = .("png");
		public override Span<StringView> TargetExtensions => ext;

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let s = scope ArrayStream(data);
			let sr = scope Serializer(s);

			let bitmap = scope Bitmap(
				sr.Read<uint32>(),
				sr.Read<uint32>());
			sr.ReadInto!(Span<uint8>((uint8*)bitmap.Pixels.Ptr, bitmap.Pixels.Count * sizeof(Color)));

			Try!(SubmitLoadedTextureAsset(name, bitmap));

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

			// TODO: try to just write back our png?
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
