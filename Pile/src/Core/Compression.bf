using MiniZ;
using System;

namespace Pile
{
	public static class Compression
	{
		public static Result<int> Compress(Span<uint8> source, Span<uint8> destination, MiniZ.CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			int64 destL = (int32)destination.Length;
			let s = MiniZ.Compress(&destination[0], ref destL, &source[0], (int)(int32)source.Length, level);

			switch (s)
			{
			case .OK: return .Ok((.)destL);
				// The errors that could realistically happen
			case .MEM_ERROR: LogErrorReturn!("[MINIZ::MEM_ERROR] Failed to allocate memory");
			case .ERRNO: LogErrorReturn!("[MINIZ::ERRNO] Error reading/writing data");
			case .BUF_ERROR: LogErrorReturn!("[MINIZ::BUF_ERR] Invalid buffer");
				// Default case
			default: LogErrorReturn!(scope String("MiniZ error: {0}")..Format(s));
			}
		}

		public static Result<void> Compress(Span<uint8> source, ref Span<uint8> destination,  MiniZ.CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			let res = Compress(source, destination, level);

			switch (res)
			{
			case .Ok(let val):
				destination.Length = val;
				return .Ok;
			case .Err(let err):
				return .Err(err);
			}
		}

		public static Result<void> Compress(Span<uint8> source, uint8[] destination,  MiniZ.CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let res = Compress(source, Span<uint8>(destination), level);

			switch (res)
			{
			case .Ok(let val):
				destination.Count = val;
				return .Ok;
			case .Err(let err):
				return .Err(err);
			}
		}

		public static Result<int> Decompress(Span<uint8> source, Span<uint8> destination)
		{
			int64 destL = (int32)destination.Length;
			let s = MiniZ.Uncompress(&destination[0], ref destL, &source[0], source.Length);

			switch (s)
			{
			case .OK: return .Ok((.)destL);
				// The errors that could realistically happen
			case .MEM_ERROR: LogErrorReturn!("[MINIZ::MEM_ERROR] Failed to allocate memory");
			case .ERRNO: LogErrorReturn!("[MINIZ::ERRNO] Error reading/writing data");
			case .DATA_ERROR: LogErrorReturn!("[MINIZ::DATA_ERROR] Data is invalid or incomplete");
				// Default case
			default: LogErrorReturn!(scope String("MiniZ error: {0}")..Format(s));
			}
		}

		public static Result<void> Decompress(Span<uint8> source, ref Span<uint8> destination)
		{
			let res = Decompress(source, destination);

			switch (res)
			{
			case .Ok(let val):
				destination.Length = val;
				return .Ok;
			case .Err(let err):
				return .Err(err);
			}
		}

		public static Result<void> Decompress(Span<uint8> source, uint8[] destination)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let res = Decompress(source, Span<uint8>(destination));

			switch (res)
			{
			case .Ok(let val):
				destination.Count = val;
				return .Ok;
			case .Err(let err):
				return .Err(err);
			}
		}
	}
}
