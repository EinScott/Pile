using static Pile.MiniZ;
using System;
using System.IO;
using System.Diagnostics;

namespace Pile
{
	enum CompressionMode
	{
		Compress,
		Decompress
	}

	class CompressionStream : Stream
	{
		bool ownsStream;
		CompressionLevel level;
		CompressionMode mode;
		Stream underlying;

		enum StreamState { NeedsInit, Ok, HasEnded }
		StreamState streamState;

		uint8* buffer;
		uint32 bufferFill;
		uint32 bufferSize;

		mz_stream mzStream;

		[Inline]
		public Stream UnderlyingStream => underlying;

		[AllowAppend]
		public this(Stream stream, CompressionLevel level, bool ownsStream, uint32 bufferSize = 8192) : this(stream, .Compress, ownsStream, level, bufferSize) {}

		[AllowAppend]
		public this(Stream stream, CompressionMode mode, bool ownsStream, CompressionLevel level = .DEFAULT_COMPRESSION, uint32 bufferSize = 8192)
		{
			Debug.Assert(stream != null);

			let ptr = append uint8[bufferSize]*;

			buffer = ptr;
			underlying = stream;

			this.bufferSize = bufferSize;
			this.ownsStream = ownsStream;
			this.mode = mode;
			this.level = level;
		}

		public ~this()
		{
			Close();

			if (ownsStream && underlying != null)
				DeleteAndNullify!(underlying);
		}

		public override int64 Position
		{
			[Error("Position is not available on this stream"),Inline]
			get
			{
				Runtime.FatalError();
			}

			[Error("Position is not available on this stream"),Inline]
			set
			{
				Runtime.FatalError();
			}
		}

		public override int64 Length
		{
			[Warn("Length is from the underlying stream"),Inline]
			get => underlying.Length;
		}

		public override bool CanRead
		{
			[Inline]
			get => mode == .Decompress && underlying.CanRead;
		}

		public override bool CanWrite
		{
			[Inline]
			get => mode == .Compress && underlying.CanWrite;
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			if (!CanRead)
				return .Err;
			
			switch (streamState)
			{
			case .NeedsInit:
				mzStream.next_in = buffer;
				mzStream.avail_in = bufferSize;

				if (mz_inflateInit(&mzStream)  != .OK)
					return .Err;

				streamState = .Ok;
			case .HasEnded:
				return .Err;
			case .Ok:
			}

			// next_in and avail_in are persistent and will be set when the buffer is refilled!
			int dataOffset = 0;
			mzStream.next_out = data.Ptr;
			var availWrite = mzStream.avail_out = (.)Math.Min((int)uint32.MaxValue, data.Length);

			while (true)
			{
				if (mzStream.avail_in == 0)
				{
					bufferFill = (.)Try!(underlying.TryRead(.(buffer, bufferSize)));

					mzStream.next_in = buffer; // TODO: look if we actually need to do this?
					mzStream.avail_in = bufferFill;
				}

				let status = mz_inflate(&mzStream, .SYNC_FLUSH);
				if (status < 0)
					return .Err;

				if (mzStream.avail_out == 0)
				{
					// Since we didn't return yet, that means we've just done a full pass
					dataOffset += uint32.MaxValue;

					if (dataOffset >= data.Length) // We got everything we set out to get
						return .Ok(data.Length);
					else // We need more (unlikely)
					{
						mzStream.next_out = data.Ptr + dataOffset;
						availWrite = mzStream.avail_out = (.)Math.Min((int)uint32.MaxValue, data.Length - dataOffset);
					}
				}

				if (status == .STREAM_END)
				{
					streamState = .HasEnded;
					return .Ok(dataOffset + (availWrite - mzStream.avail_out));
				}
			}
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			if (!CanWrite)
				return .Err;

			switch (streamState)
			{
			case .NeedsInit:
				mzStream.next_out = buffer;
				mzStream.avail_out = bufferSize;

				if (mz_deflateInit(&mzStream, level)  != .OK)
					return .Err;

				streamState = .Ok;
			case .HasEnded:
				return .Err;
			case .Ok:
			}

			// next_out and avail_out are persistent and will be set when the buffer is flushed!
			int dataOffset = 0;
			mzStream.next_in = data.Ptr;
			mzStream.avail_in = (.)Math.Min((int)uint32.MaxValue, data.Length);

			while (true)
			{
				if (mzStream.avail_in == 0)
				{
					// Since we didn't return yet, that means we've just done a full pass
					dataOffset += uint32.MaxValue;

					if (dataOffset >= data.Length) // We got everything we set out to get
						return .Ok(data.Length);
					else // We need more (unlikely)
					{
						mzStream.next_in = data.Ptr + dataOffset;
						mzStream.avail_in = (.)Math.Min((int)uint32.MaxValue, data.Length - dataOffset);
					}
				}

				let status = mz_deflate(&mzStream, .SYNC_FLUSH);
				if (status < 0)
					return .Err;

				if (mzStream.avail_out == 0)
				{
					let actualWrite = Try!(underlying.TryWrite(.(buffer, bufferSize)));

					if (actualWrite != bufferSize)
						return .Err;

					mzStream.next_out = buffer; // TODO: do we actually need to refresh this?
					mzStream.avail_out = bufferSize;
				}
			}
		}

		public override Result<void> Flush()
		{
			if (!CanWrite)
				return .Err;

			let write = bufferSize - mzStream.avail_out;
			let actualWrite = Try!(underlying.TryWrite(.(buffer, write)));

			if (actualWrite != write)
				return .Err;

			mzStream.next_out = buffer; // TODO: do we actually need to refresh this?
			mzStream.avail_out = bufferSize;

			return .Ok;
		}

		public override Result<void> Close()
		{
			// Finish stream
			if (streamState != .NeedsInit)
			{
				switch (mode)
				{
				case .Decompress:
					mz_inflateEnd(&mzStream);
				case .Compress:
					if (mz_deflate(&mzStream, .FULL_FLUSH) != .OK)
						return .Err;
					mz_deflateEnd(&mzStream);
					Try!(Flush());
				}
				streamState = .NeedsInit;
			}

			return .Ok;
		}
	}

	static class Compression
	{
		const int CHUNK_SIZE = int32.MaxValue;
		// TODO: use way more streams in the packages pipeline! (a bit off-topic in this file)
		
		public static Result<uint> Compress(Span<uint8> source, Span<uint8> destination, CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			mz_stream s = default;
			s.next_in = source.Ptr;
			s.avail_in = 0;
			s.next_out = destination.Ptr;
			int availOutGiven = s.avail_out = (.)Math.Min(CHUNK_SIZE, destination.Length);

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

				let status = mz_deflate(&s, (inRemaining - s.avail_out > 0) ? .NO_FLUSH : .FINISH);

				if (s.avail_out == 0)
				{
					outRemaining -= availOutGiven;

					if (outRemaining < 0 && status != .STREAM_END)
						LogErrorReturn!("Insufficient deflate destination buffer");

					s.next_out = &destination[destination.Length - outRemaining];
					availOutGiven = s.avail_out = (.)Math.Min(CHUNK_SIZE, outRemaining);
				}

				if (status == .STREAM_END)
					break;
				else if (status != .OK)
					LogErrorReturn!(scope $"Failed to deflate: {status}");
			}

			if (mz_deflate(&s, .FULL_FLUSH) == .OK && mz_deflateEnd(&s) != .OK)
				LogErrorReturn!("Failed to end deflate");

			return .Ok(s.total_out);

			/*uint destL = (.)destination.Length;
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
			}*/
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
			mz_stream s = default;
			s.next_in = source.Ptr;
			s.avail_in = 0;
			s.next_out = destination.Ptr;
			int availOutGiven = s.avail_out = (.)Math.Min(CHUNK_SIZE, destination.Length);

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
					outRemaining -= availOutGiven;

					if (outRemaining < 0 && status != .STREAM_END)
						LogErrorReturn!("Insufficient inflate destination buffer");

					s.next_out = &destination[destination.Length - outRemaining];
					availOutGiven = s.avail_out = (.)Math.Min(CHUNK_SIZE, outRemaining);
				}

				if (status == .STREAM_END || outRemaining == 0)
					break;
				else if (status != .OK)
					LogErrorReturn!(scope $"Failed to inflate: {status}");
			}

			if (mz_inflateEnd(&s) != .OK)
				LogErrorReturn!("Failed to end inflate");

			return .Ok(s.total_out);

			/*int destL = (.)destination.Length;
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
			}*/
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
