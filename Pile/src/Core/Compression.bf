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
			case .OK: return .Ok(destL);
				// The errors that could realistically happen
			case .MEM_ERROR: LogErrorReturn!("[MINIZ::MEM_ERROR] Failed to allocate memory");
			case .ERRNO: LogErrorReturn!("[MINIZ::ERRNO] Error reading/writing data");
			case .BUF_ERROR: LogErrorReturn!("[MINIZ::BUF_ERR] Invalid buffer");
				// Default case
			default: LogErrorReturn!(scope $"MiniZ error: {s}");
			}
		}

		public static Result<void> Compress(Span<uint8> source, ref Span<uint8> destination,  MiniZ.CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			let length = Try!(Compress(source, destination, level));
			destination.Length = length;
			return .Ok;
		}

		public static Result<void> Compress(Span<uint8> source, uint8[] destination,  MiniZ.CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let length = Try!(Compress(source, Span<uint8>(destination), level));
			destination.Count = length;
			return .Ok;
		}

		public static Result<int> Decompress(Span<uint8> source, Span<uint8> destination)
		{
			int64 destL = (int32)destination.Length;
			let s = MiniZ.Uncompress(&destination[0], ref destL, &source[0], source.Length);

			switch (s)
			{
			case .OK: return .Ok(destL);
				// The errors that could realistically happen
			case .MEM_ERROR: LogErrorReturn!("[MINIZ::MEM_ERROR] Failed to allocate memory");
			case .ERRNO: LogErrorReturn!("[MINIZ::ERRNO] Error reading/writing data");
			case .DATA_ERROR: LogErrorReturn!("[MINIZ::DATA_ERROR] Data is invalid or incomplete");
				// Default case
			default: LogErrorReturn!(scope $"MiniZ error: {s}");
			}
		}

		public static Result<void> Decompress(Span<uint8> source, ref Span<uint8> destination)
		{
			let length = Try!(Decompress(source, destination));
			destination.Length = length;
			return .Ok;
		}

		public static Result<void> Decompress(Span<uint8> source, uint8[] destination)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let length = Try!(Decompress(source, Span<uint8>(destination)));
			destination.Count = length;
			return .Ok;
		}
	}
}
