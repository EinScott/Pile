using System;
using System.IO;

namespace Pile
{
	[RegisterImporter]
	class AudioClipImporter : RawImporter
	{
		// todo: at the moment, we blindly believe that the buffer we received is in fact a valid format

		public override String Name => "audio_clip";

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let asset = new AudioClip(data);

			if (Importers.SubmitAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}
	}
}
