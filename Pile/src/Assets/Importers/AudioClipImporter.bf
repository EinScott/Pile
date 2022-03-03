using System;
using System.IO;

namespace Pile
{
	[RegisterImporter]
	class AudioClipImporter : Importer
	{
		// todo: at the moment, we blindly believe that the buffer we received is in fact a valid format

		// TODO: make audioData or something... so that we can better swap it with IpersistentAsset?

		public override String Name => "audioClip";

		const StringView[?] ext = .("ogg", "mp3", "wav");
		public override Span<StringView> TargetExtensions => ext;

		public override Result<void> Load(StringView name, Span<uint8> data)
		{
			let asset = new AudioClip(data);

			if (SubmitLoadedAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}
	}
}
