//using MiniZ;
//using static MiniZ.MiniZ;
using static Pile.MiniZ;
using System;
using System.IO;

namespace Pile
{
	static class Compression
	{
		const int CHUNK_SIZE = uint16.MaxValue;

		// TODO: use way more streams in the packages pipeline!
		// TODO: compressionStream/zlibstream
		public static Result<void /*?*/> Compress(Stream source, Stream destination, CompressionLevel level = .DEFAULT_COMPRESSION, bool writeZlibHeader = true)
		{
			return .Ok;
		}

		public static Result<uint> Compress(Span<uint8> source, Span<uint8> destination, CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			/*mz_stream s = default;
			s.next_in = source.Ptr;
			s.avail_in = 0;
			s.next_out = destination.Ptr;
			s.avail_out = (.)Math.Min(CHUNK_SIZE, destination.Length);

			// We write directly from span to span, maybe we need some other tracking vars?

			if (mz_deflateInit(&s, level) != .OK)
				LogErrorReturn!("Failed to init deflate");

			int inRemaining = source.Length;
			int outRemaining = destination.Length;
			while (true)
			{
				if (s.avail_in == 0)
				{
					let chunk = Math.Min(CHUNK_SIZE, inRemaining);

					s.next_in = &source[source.Length - inRemaining];
					s.avail_in = (.)chunk;

					inRemaining -= chunk;
				}

				let status = mz_deflate(&s, (inRemaining > 0) ? .NO_FLUSH : .FINISH);

				if (s.avail_out == 0)
				{
					outRemaining -= CHUNK_SIZE;

					if (outRemaining <= 0 && status != .STREAM_END)
						LogErrorReturn!("Insufficient deflate destination buffer");

					s.next_out = &destination[destination.Length - outRemaining];
					s.avail_out = (.)Math.Min(CHUNK_SIZE, outRemaining);
				}

				if (status == .STREAM_END)
					break;
				else if (status != .OK)
					LogErrorReturn!(scope $"Failed to deflate: {status}");
			}

			if (mz_deflateEnd(&s) != .OK)
				LogErrorReturn!("Failed to end deflate");

			return .Ok;*/

			uint destL = (.)destination.Length;
			uint srcL = (.)source.Length;
			let s = mz_compress(destination.Ptr, &destL, source.Ptr, srcL, level);

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

		public static Result<void> Compress(Span<uint8> source, ref Span<uint8> destination,  CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			let length = Try!(Compress(source, destination, level));
			destination.Length = (.)length;
			return .Ok;
		}

		public static Result<void> Compress(Span<uint8> source, uint8[] destination,  CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let length = Try!(Compress(source, Span<uint8>(destination), level));
			destination.Count = (.)length;
			return .Ok;
		}

		public static Result<uint> Decompress(Span<uint8> source, Span<uint8> destination)
		{
			/*mz_stream s = default;
			s.next_in = source.Ptr;
			s.avail_in = 0;
			s.next_out = destination.Ptr;
			s.avail_out = (.)Math.Min(CHUNK_SIZE, destination.Length);

			// We write directly from span to span, maybe we need some other tracking vars?
			// ACTUALLY THIS COULD STILL JUST BE ONE CALL?
			// I mean, we have the whole thing in mem anyways!

			if (mz_inflateInit(&s) != .OK)
				LogErrorReturn!("Failed to init inflate");

			int inRemaining = source.Length;
			int outRemaining = destination.Length;
			while (true)
			{
				if (s.avail_in == 0)
				{
					let chunk = Math.Min(CHUNK_SIZE, inRemaining);

					s.next_in = &source[source.Length - inRemaining];
					s.avail_in = (.)chunk;

					inRemaining -= chunk;
				}

				let status = mz_inflate(&s, .SYNC_FLUSH);

				if (s.avail_out == 0)
				{
					outRemaining -= CHUNK_SIZE;

					if (outRemaining <= 0 && status != .STREAM_END)
						LogErrorReturn!("Insufficient inflate destination buffer");

					s.next_out = &destination[destination.Length - outRemaining];
					s.avail_out = (.)Math.Min(CHUNK_SIZE, outRemaining);
				}

				if (status == .STREAM_END)
					break;
				else if (status != .OK)
					LogErrorReturn!(scope $"Failed to inflate: {status}");
			}

			if (mz_inflateEnd(&s) != .OK)
				LogErrorReturn!("Failed to end inflate");

			return .Ok(0); // TODO return what we actually read?? maybe do this differently -> comments above*/

			int destL = (.)destination.Length;
			//let s = Uncompress(destination.Ptr, ref destL, source.Ptr, source.Length);
			uint srcL = (.)source.Length;
			uint destL2 = (.)destL;
			let s = MiniZ.mz_uncompress(destination.Ptr, &destL2, source.Ptr, &srcL);

			switch (s)
			{
			case .OK: return .Ok((.)destL);
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
			destination.Length = (.)length;
			return .Ok;
		}

		public static Result<void> Decompress(Span<uint8> source, uint8[] destination)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let length = Try!(Decompress(source, Span<uint8>(destination)));
			destination.Count = (.)length;
			return .Ok;
		}
	}
}
