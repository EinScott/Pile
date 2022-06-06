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
		const int MAX_DATA_LEN = uint32.MaxValue;

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
		public this(Stream stream, CompressionLevel level, bool ownsStream = false, uint32 bufferSize = 8192) : this(stream, .Compress, ownsStream, level, bufferSize) {}

		[AllowAppend]
		public this(Stream stream, CompressionMode mode, bool ownsStream = false, CompressionLevel level = .DEFAULT_COMPRESSION, uint32 bufferSize = 8192)
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
			get
			{
				Runtime.FatalError("Position is not available on CompressionStream");
			}

			set
			{
				Runtime.FatalError("Position is not available on CompressionStream");
			}
		}

		public override int64 Length
		{
			get
			{
				Runtime.FatalError("Length is not available on CompressionStream");
			}
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

		public override Result<void> Seek(int64 pos, SeekKind seekKind = .Absolute)
		{
			return .Err;
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			if (!CanRead)
				return .Err;
			
			switch (streamState)
			{
			case .NeedsInit:
				mzStream.next_in = buffer;
				mzStream.avail_in = 0;

				if (mz_inflateInit(&mzStream) != .OK)
					return .Err;

				streamState = .Ok;
			case .HasEnded:
				return .Err;
			case .Ok:
			}

			// next_in and avail_in are persistent and will be set when the buffer is refilled!
			int dataOffset = 0;
			mzStream.next_out = data.Ptr;
			var availWrite = mzStream.avail_out = (.)Math.Min(MAX_DATA_LEN, data.Length);

			while (true)
			{
				if (mzStream.avail_in == 0)
				{
					bufferFill = (.)Try!(underlying.TryRead(.(buffer, bufferSize)));

					mzStream.next_in = buffer;
					mzStream.avail_in = bufferFill;
				}

				let status = mz_inflate(&mzStream, .NO_FLUSH);

				if (status == .STREAM_END)
				{
					streamState = .HasEnded;
					return .Ok(dataOffset + (availWrite - mzStream.avail_out));
				}
				else if (status < 0)
					return .Err;
				else if (mzStream.avail_out == 0)
				{
					// Since we didn't return yet, that means we've just done a full pass
					dataOffset += MAX_DATA_LEN;

					if (dataOffset >= data.Length) // We got everything we set out to get
						return .Ok(data.Length);
					else // We need more (unlikely)
					{
						mzStream.next_out = data.Ptr + dataOffset;
						availWrite = mzStream.avail_out = (.)Math.Min(MAX_DATA_LEN, data.Length - dataOffset);
					}
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
			mzStream.avail_in = (.)Math.Min(MAX_DATA_LEN, data.Length);

			while (true)
			{
				if (mzStream.avail_in == 0)
				{
					// Since we didn't return yet, that means we've just done a full pass
					dataOffset += MAX_DATA_LEN;

					if (dataOffset >= data.Length) // We got everything we set out to get
						return .Ok(data.Length);
					else // We need more (unlikely)
					{
						mzStream.next_in = data.Ptr + dataOffset;
						mzStream.avail_in = (.)Math.Min(MAX_DATA_LEN, data.Length - dataOffset);
					}
				}

				let status = mz_deflate(&mzStream, .NO_FLUSH);

				if (status < 0)
					return .Err;
				else if (mzStream.avail_out == 0)
				{
					let actualWrite = Try!(underlying.TryWrite(.(buffer, bufferSize)));

					if (actualWrite != bufferSize)
						return .Err;

					mzStream.next_out = buffer;
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

			mzStream.next_out = buffer;
			mzStream.avail_out = bufferSize;

			return .Ok;
		}

		public override Result<void> Close()
		{
			// Finish stream
			if (streamState != .NeedsInit)
			{
				defer
				{
					streamState = .NeedsInit;
				}

				switch (mode)
				{
				case .Decompress:
					mz_inflateEnd(&mzStream);
				case .Compress:
					while (true)
					{
						let res = mz_deflate(&mzStream, .FINISH);
						if (res == .OK && mzStream.avail_out == 0)
							Try!(Flush());
						else if (res == .STREAM_END)
						{
							Try!(Flush());
							break;
						}
						else return .Err;
					}
					if (mz_deflateEnd(&mzStream) != .OK)
						return .Err;
				}
			}

			return .Ok;
		}
	}

	static class Compression
	{
		const int CHUNK_SIZE = int32.MaxValue;

		public static int CompressionBound(int sourceLength)
		{
			Debug.Assert(sourceLength > 0);
			return (.)mz_deflateBound(null, (.)sourceLength);
		}

		public static Result<int> Compress(Span<uint8> source, Span<uint8> destination, CompressionLevel level = .DEFAULT_COMPRESSION)
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

				if (status == .STREAM_END)
					break;
				else if (status != .OK)
					LogErrorReturn!(scope $"Failed to deflate: {status}");
				else if (s.avail_out == 0)
				{
					outRemaining -= availOutGiven;

					if (outRemaining <= 0)
						LogErrorReturn!("Insufficient deflate destination buffer");

					s.next_out = &destination[destination.Length - outRemaining];
					availOutGiven = s.avail_out = (.)Math.Min(CHUNK_SIZE, outRemaining);
				}
			}

			if (mz_deflateEnd(&s) != .OK)
				LogErrorReturn!("Failed to end deflate");

			return .Ok((.)s.total_out);
		}

		public static Result<void> Compress(Span<uint8> source, ref Span<uint8> destination,  CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			let length = Try!(Compress(source, destination, level));
			destination.Length = length;
			return .Ok;
		}

		public static Result<void> Compress(Span<uint8> source, uint8[] destination,  CompressionLevel level = .DEFAULT_COMPRESSION)
		{
			if (destination == null)
				LogErrorReturn!("Destination array cannot be null");

			let length = Try!(Compress(source, Span<uint8>(destination), level));
			destination.Count = length;
			return .Ok;
		}

		public static Result<int> Decompress(Span<uint8> source, Span<uint8> destination)
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

				let status = mz_inflate(&s, .NO_FLUSH);

				if (status == .STREAM_END)
					break;
				else if (status != .OK)
					LogErrorReturn!(scope $"Failed to inflate: {status}");
				else if (s.avail_out == 0)
				{
					outRemaining -= availOutGiven;

					if (outRemaining <= 0)
						LogErrorReturn!("Insufficient inflate destination buffer");

					s.next_out = &destination[destination.Length - outRemaining];
					availOutGiven = s.avail_out = (.)Math.Min(CHUNK_SIZE, outRemaining);
				}
			}

			if (mz_inflateEnd(&s) != .OK)
				LogErrorReturn!("Failed to end inflate");

			return .Ok((.)s.total_out);
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
