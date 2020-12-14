using System.Collections;

namespace System.IO
{
	public extension File
	{
		// This is kind of ugly, find a nicer solution? Still, I kind of don't want to pass in a List<uint8>
		[NoDiscard("Possibly leaving new data array unreferenced")]
		public static Result<uint8[], FileError> ReadAllBytes(StringView path)
		{
			FileStream s = scope FileStream();
			if (s.Open(path) case .Err(let err))
				return .Err(.FileOpenError(err));
			let outData = new uint8[(.)s.Length];
			if (s.TryRead(outData) case .Err)
				return .Err(.FileReadError(.Unknown));

			return .Ok(outData);
		}

		public static Result<void, FileError> ReadAllBytes(StringView path, List<uint8> outData)
		{
			FileStream s = scope FileStream();
			if (s.Open(path) case .Err(let err))
				return .Err(.FileOpenError(err));
			let start = outData.Count;
			outData.Count += s.Length;
			if (s.TryRead(Span<uint8>(&outData[start], s.Length)) case .Err)
				return .Err(.FileReadError(.Unknown));

			return .Ok;
		}

		public static Result<void> WriteAllBytes(StringView path, Span<uint8> data)
		{
			FileStream fs = scope FileStream();
			Try!(fs.Open(path, .Create, .Write));
			fs.TryWrite(data);
			return .Ok;
		}
	}
}
