using System;
using System.IO;
using JSON_Beef.Types;

namespace Pile
{
	public class AudioClipImporter : RawImporter
	{
		// at the moment, we blindly believe that the buffer we received is in fact a valid format

		public override Result<void> Load(StringView name, Span<uint8> data, JSONObject dataNode)
		{
			let mem = scope MemoryStream();
			Try!(mem.TryWrite(data));
			mem.Position = 0;

			let asset = new AudioClip(data);

			return SubmitAsset(name, asset);
		}
	}
}
