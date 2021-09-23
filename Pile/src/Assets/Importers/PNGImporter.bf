using System;
using System.Diagnostics;
using System.IO;
using System.Collections;

namespace Pile
{
	[RegisterImporter]
	class PNGImporter : Importer
	{
		public virtual String Name => "png";

		public virtual Result<void> Load(StringView name, Span<uint8> data)
		{
			let s = scope ArrayStream(data);
			let sr = scope Serializer(s);

			let bitmap = scope Bitmap(
				sr.Read<uint32>(),
				sr.Read<uint32>());
			sr.ReadInto!(Span<uint8>((uint8*)bitmap.Pixels.Ptr, bitmap.Pixels.Count * sizeof(Color)));

			Try!(Importers.SubmitTextureAsset(name, bitmap));

			return .Ok;
		}

		public virtual Result<uint8[]> Build(Stream data, Span<StringView> config, StringView dataFilePath)
		{
			if (!PNG.IsValid(data))
				LogErrorReturn!("PNGImporter: Data i not in PNG format");

			let bitmap = scope Bitmap();
			if (PNG.Read(data, bitmap) case .Err)
				return .Err;

			Debug.Assert(sizeof(uint32) == sizeof(Color));
			let s = scope ArrayStream((bitmap.Pixels.Count + 2) * sizeof(uint32));
			let sr = scope Serializer(s);
			
			sr.Write<uint32>(bitmap.Width);
			sr.Write<uint32>(bitmap.Height);
			sr.Write!(Span<uint8>((uint8*)&bitmap.Pixels[0], bitmap.Pixels.Count * sizeof(Color)));

			if (sr.HadError)
				LogErrorReturn!("PNGImporter: Error transfering bitmap data");

			return s.TakeOwnership();
		}
	}
}
