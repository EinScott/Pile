using System;
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
			let bitmap = new Bitmap(
				(((uint32)data[0]) << 24) | (((uint32)data[1]) << 16) | (((uint32)data[2]) << 8) | ((uint32)data[3]),
				(((uint32)data[4]) << 24) | (((uint32)data[5]) << 16) | (((uint32)data[6]) << 8) | ((uint32)data[7]),
				Span<Color>((Color*)&data[2 * sizeof(uint32)], data.Length / sizeof(uint32) - 2)); // sizeof(Color) == sizeof(uint32));

			if (Importers.SubmitTextureAsset(name, bitmap) case .Err)
			{
				delete bitmap;
				return .Err;
			}
			else return .Ok;
		}

		public virtual Result<uint8[]> Build(Span<uint8> data, Span<StringView> config, StringView dataFilePath)
		{
			if (!PNG.IsValid(data))
				LogErrorReturn!("Data i not in PNG format");

			// todo: Trying to compress raw png data errors MINIZ (BUF_ERROR). Why?
			let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let bitmap = new Bitmap();
			defer delete bitmap;
			if (PNG.Read(mem, bitmap) case .Err)
				return .Err;

			let outData = new uint8[(bitmap.Pixels.Count + 2) * sizeof(uint32)];
			Span<uint8>((uint8*)&bitmap.Pixels[0], bitmap.Pixels.Count * sizeof(Color)).CopyTo(
				Span<uint8>(&outData[2 * sizeof(uint32)], bitmap.Pixels.Count * sizeof(Color /* == uint32 */)));

			outData[0] = (uint8)((bitmap.Width >> 24) & 0xFF);
			outData[1] = (uint8)((bitmap.Width >> 16) & 0xFF);
			outData[2] = (uint8)((bitmap.Width >> 8) & 0xFF);
			outData[3] = (uint8)(bitmap.Width & 0xFF);

			outData[4] = (uint8)((bitmap.Height >> 24) & 0xFF);
			outData[5] = (uint8)((bitmap.Height >> 16) & 0xFF);
			outData[6] = (uint8)((bitmap.Height >> 8) & 0xFF);
			outData[7] = (uint8)(bitmap.Height & 0xFF);

			return outData;
		}
	}
}
