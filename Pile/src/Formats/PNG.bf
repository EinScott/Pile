using System;
using System.IO;
using System.Text;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	static class PNG
	{
		enum Colors : uint8
		{
		    Greyscale = 0,
		    Truecolor = 2,
		    Indexed = 3,
		    GreyscaleAlpha = 4,
		    TruecolorAlpha = 6
		}

		enum Interlace : uint8
		{
		    None = 0,
		    Adam7 = 1
		}

		static readonly uint8[8] header = uint8[8]( 137, 80, 78, 71, 13, 10, 26, 10 );
		static readonly uint32[] crcTable = new uint32[256] ~ delete _;

		static this()
		{
		    // Create the CRC table
		    // Taken from libpng format specification: http://www.libpng.org/pub/png/spec/1.2/PNG-CRCAppendix.html

		    for (int32 n = 0; n < 256; n++)
		    {
		        uint32 c = (uint32)n;
		        for (int k = 0; k < 8; k++)
		        {
		            if ((c & 1) != 0)
		                c = 0xedb88320U ^ (c >> 1);
		            else
		                c >>= 1;
		        }
		        crcTable[n] = c;
		    }
		}

		public static bool IsValid(Stream stream)
		{
		    var pos = stream.Position;

			if (stream.Length < 8)
				return false;

		    // check PNG header
		    bool isPng =
		        stream.Read<uint8>() == header[0] && // 8-bit format
		        stream.Read<uint8>() == header[1] && // P
		        stream.Read<uint8>() == header[2] && // N
		        stream.Read<uint8>() == header[3] && // G
		        stream.Read<uint8>() == header[4] && // Carriage Return
		        stream.Read<uint8>() == header[5] && // Line Feed
		        stream.Read<uint8>() == header[6] && // Ctrl-Z
		        stream.Read<uint8>() == header[7];   // Line Feed

		    stream.Seek(pos);

		    return isPng;
		}

		public static bool IsValid(Span<uint8> data)
		{
			if (data.Length < 8)
				return false;

		    // check PNG header
		    return
		        data[0] == header[0] && // 8-bit format
		        data[1] == header[1] && // P
		        data[2] == header[2] && // N
		        data[3] == header[3] && // G
		        data[4] == header[4] && // Carriage Return
		        data[5] == header[5] && // Line Feed
		        data[6] == header[6] && // Ctrl-Z
		        data[7] == header[7];   // Line Feed
		}

		static mixin HandleRead(Result<int> res)
		{
			LogErrorTry!(res, "Error reading PNG: Couldn't read span");
		}

		static mixin HandleWrite(Result<void> res)
		{
			LogErrorTry!(res, "Error writing PNG: Couldn't write span");
		}

		public static Result<void> Read(Stream stream, Bitmap bitmap)
		{
		    // We also ignore all checksums when reading because they don't seem super important for game usage

		    var hasTransparency = false;
		    uint8 depth = 8;
		    var color = Colors.Truecolor;
		    uint8 compression = 0;
		    uint8 filter = 0;
		    Interlace interlace = Interlace.None;
		    var components = 4;

		    MemoryStream idat = new MemoryStream(); // Close() does nothing on this
		    uint8[] idatChunk = new uint8[4096];
		    uint8[] palette = new uint8[0];
		    uint8[] alphaPalette = new uint8[0];
		    uint8[4] fourbytes = uint8[4]();

		    bool hasIHDR = false, hasPLTE = false, hasIDAT = false;

			Result<int> ReadFour() => stream.TryRead(Span<uint8>(&fourbytes[0], 4));

		    // Check PNG Header
		    if (!IsValid(stream))
		        LogErrorReturn!("Error reading PNG: Stream is not PNG");

		    // Skip PNG header
		    stream.Seek(8);

		    // Read Chunks
		    while (stream.Position < stream.Length)
		    {
		        int64 chunkStartPosition = stream.Position;

		        // chunk length
				HandleRead!(ReadFour());
		        int64 chunkLength = (int64)SwapEndian(BitConverter.Convert<uint8[4], int32>(fourbytes));

		        // chunk type
		        HandleRead!(ReadFour());

		        // IHDR Chunk
		        if (Check("IHDR", fourbytes))
		        {
		            hasIHDR = true;
		            HandleRead!(ReadFour());
		            let width = SwapEndian(BitConverter.Convert<uint8[4], int32>(fourbytes));
		            HandleRead!(ReadFour());
		            let height = SwapEndian(BitConverter.Convert<uint8[4], int32>(fourbytes));
		            depth = stream.Read<uint8>();
		            color.UnderlyingRef = stream.Read<uint8>();
		            compression = stream.Read<uint8>();
		            filter = stream.Read<uint8>();
		            interlace.UnderlyingRef = stream.Read<uint8>();
		            hasTransparency = color == .GreyscaleAlpha || color == .TruecolorAlpha;

					bitmap.ResizeAndClear((.)width, (.)height);

		            if (color == .Greyscale || color == .Indexed)
		                components = 1;
		            else if (color == .GreyscaleAlpha)
		                components = 2;
		            else if (color == .Truecolor)
		                components = 3;
		            else if (color == .TruecolorAlpha)
		                components = 4;

		            // currently don't support interlacing as I'm actually not sure where the interlace step takes place lol
		            if (interlace == .Adam7)
		                LogErrorReturn!("Error reading PNG: Interlaced PNGs not implemented");

		            if (depth != 1 && depth != 2 && depth != 4 && depth != 8 && depth != 16)
		                LogErrorReturn!(scope $"Error reading PNG: {depth}-bit depth not supported");

		            if (filter != 0)
		                LogErrorReturn!(scope $"Error reading PNG: Filter {filter} not supported");

		            if (compression != 0)
		                LogErrorReturn!(scope $"Error reading PNG: Compression {compression} not supported");
		        }
		        // PLTE Chunk (Indexed Palette)
		        else if (Check("PLTE", fourbytes))
		        {
		            hasPLTE = true;
					delete palette;
		            palette = new uint8[chunkLength];

		            let length = LogErrorTry!(stream.TryRead(palette), "Error reading PNG: Couldn't read PLTE chunk");
					if (length != palette.Count)
						LogErrorReturn!("Error reading PNG: PLTE chunk was not of expected size");
		        }
		        // IDAT Chunk (Image Data)
		        else if (Check("IDAT", fourbytes))
		        {
		            hasIDAT = true;

		            for (int i = 0; i < chunkLength; i += idatChunk.Count)
		            {
		                int size = Math.Min(idatChunk.Count, chunkLength - i);

						let sizedChunk = ((Span<uint8>)idatChunk).Slice(0, size);
						let length = LogErrorTry!(stream.TryRead(sizedChunk), "Error reading PNG: Couldn't read IDAT chunk");
		                if (length != sizedChunk.Length)
							LogErrorReturn!("Error reading PNG: IDAT chunk was not of expected size");

		                idat.Write(sizedChunk);
		            }
		        }
		        // tRNS Chunk (Alpha Palette)
		        else if (Check("tRNS", fourbytes))
		        {
		            if (color == .Indexed)
		            {
						delete alphaPalette;
		                alphaPalette = new uint8[chunkLength];

						let length = LogErrorTry!(stream.TryRead(alphaPalette), "Error reading PNG: Couldn't read tRNS chunk");
						if (length != alphaPalette.Count)
							LogErrorReturn!("Error reading PNG: tRNS chunk was not of expected size");
		            }
		            else if (color == .Greyscale)
		            {
						Log.Warn("Reading PNG: tRNS chunk with Grayscale not implemented/ignored");
		            }
		            else if (color == .Truecolor)
		            {
						Log.Warn("Reading PNG: tRNS chunk with Truecolor not implemented/ignored");
		            }
		        }
		        // bKGD Chunk (Background)
		        else if (Check("bKGD", fourbytes))
		        {
					Log.Warn("Reading PNG: bKGD chunk not implemented/ignored");
		        }

		        // seek to end of the chunk
		        stream.Seek(chunkStartPosition + chunkLength + (int64)12);
		    }

		    // checks
		    if (!hasIHDR)
		        LogErrorReturn!("Error reading PNG: Missing IHDR data");

		    if (!hasIDAT)
		        LogErrorReturn!("Error reading PNG: PNG Missing IDAT data");

		    if (!hasPLTE && color == Colors.Indexed)
		        LogErrorReturn!("Error reading PNG: PNG Missing PLTE data");

			let width = bitmap.Width;
			let height = bitmap.Height;

		    // Parse the IDAT data into Pixels
		    {
		        uint8[] buffer = new uint8[width * height * (depth == 16 ? 2 : 1) * 4 + height];

		        // decompress the image data
		        {
					if (Compression.Decompress(idat.[Friend]mMemory, Span<uint8>(buffer)) case .Err)
						LogErrorReturn!("Error reading PNG: PNG IDAT decompression failed");
		        }

		        // apply filter pass - this happens in-place
		        {
		            int lineLength = (int)Math.Ceiling((width * components * depth) / 8f);
		            int bpp = Math.Max(1, (components * depth) / 8);
		            int dest = 0;

		            // each scanline
		            for (int y = 0; y < height; y++)
		            {
		                int source = y * (lineLength + 1) + 1;
		                uint8 lineFilter = buffer[source - 1];

		                // 0 - None
		                if (lineFilter == 0)
		                {
		                    Array.Copy(buffer, source, buffer, dest, lineLength);
		                }
		                // 1 - Sub
		                else if (lineFilter == 1)
		                {
		                    Array.Copy(buffer, source, buffer, dest, Math.Min(bpp, lineLength));
		                    for (int x = bpp; x < lineLength; x++)
		                    	buffer[dest + x] = (uint8)((int)buffer[source + x] + (int)buffer[dest + x - bpp]);
		                }
		                // 2 - Up
		                else if (lineFilter == 2)
		                {
		                    if (y <= 0)
								Array.Copy(buffer, source, buffer, dest, lineLength);
		                    else
		                        for (int x = 0; x < lineLength; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + (int)buffer[dest + x - lineLength]);
		                }
		                // 3 - Average
		                else if (lineFilter == 3)
		                {
		                    if (y <= 0)
		                    {
		                        Array.Copy(buffer, source, buffer, dest, Math.Min(bpp, lineLength));
		                        for (int x = bpp; x < lineLength; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + ((int)buffer[dest + x - bpp] / 2));
		                    }
		                    else
		                    {
		                        for (int x = 0; x < bpp; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + ((int)buffer[dest + x - lineLength] / 2));

		                        for (int x = bpp; x < lineLength; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + (((int)buffer[dest + x - bpp] + (int)buffer[dest + x - lineLength]) / 2));
		                    }
		                }
		                // 4 - Paeth
		                else if (lineFilter == 4)
		                {
		                    if (y <= 0)
		                    {
		                        Array.Copy(buffer, source, buffer, dest, Math.Min(bpp, lineLength));
		                        for (int x = bpp; x < lineLength; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + (int)buffer[dest + x - bpp]);
		                    }
		                    else
		                    {
		                        for (int x = 0, int c = Math.Min(bpp, lineLength); x < c; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + (int)buffer[dest + x - lineLength]);

		                        for (int x = bpp; x < lineLength; x++)
		                            buffer[dest + x] = (uint8)((int)buffer[source + x] + PaethPredictor(buffer[dest + x - bpp], buffer[dest + x - lineLength], buffer[dest + x - bpp - lineLength]));
		                    }
		                }

		                dest += lineLength;
		            }
		        }

		        // if the bit-depth isn't 8, convert it
		        if (depth != 8)
		            LogErrorReturn!("Non 8-bit PNGs not Implemented");

		        // Convert bytes to RGBA data
		        // We work backwards as to not overwrite data
		        {
		            // Indexed Color
		            if (color == Colors.Indexed)
		            {
		                for (int p = width * height - 1, int i = width * height * 4 - 4; p >= 0; p--, i -= 4)
		                {
		                    int id = buffer[p] * 3;
		                    buffer[i + 3] = (alphaPalette == null || buffer[p] >= alphaPalette.Count) ? (uint8)255 : alphaPalette[buffer[p]];
		                    buffer[i + 2] = palette[id + 2];
		                    buffer[i + 1] = palette[id + 1];
		                    buffer[i + 0] = palette[id + 0];
		                }
		            }
		            // Grayscale
		            else if (color == Colors.Greyscale)
		            {
		                for (int p = width * height - 1, int i = width * height * 4 - 4; p >= 0; p--, i -= 4)
		                {
		                    buffer[i + 3] = 255;
		                    buffer[i + 2] = buffer[p];
		                    buffer[i + 1] = buffer[p];
		                    buffer[i + 0] = buffer[p];
		                }
		            }
		            // Grayscale-Alpha
		            else if (color == Colors.GreyscaleAlpha)
		            {
		                for (int p = width * height * 2 - 2, int i = width * height * 4 - 4; p >= 0; p -= 2, i -= 4)
		                {
		                    //uint8 val = buffer[p], alpha = buffer[p + 1]; // UNUSED
		                    buffer[i + 3] = buffer[p + 1];
		                    buffer[i + 2] = buffer[p];
		                    buffer[i + 1] = buffer[p];
		                    buffer[i + 0] = buffer[p];
		                }
		            }
		            // Truecolor
		            else if (color == Colors.Truecolor)
		            {
		                for (int p = width * height * 3 - 3, int i = width * height * 4 - 4; p >= 0; p -= 3, i -= 4)
		                {
		                    buffer[i + 3] = 255;
		                    buffer[i + 2] = buffer[p + 2];
		                    buffer[i + 1] = buffer[p + 1];
		                    buffer[i + 0] = buffer[p + 0];
		                }
		            }
		        }

		        // set RGBA data to Color array
		        {
		            let pixels = Span<Color>((Color*)buffer.Ptr, width * height);
					bitmap.SetPixels(pixels);
		        }

				delete buffer;
		    }

			delete alphaPalette;
			delete palette;
			delete idatChunk;
			delete idat;

		    return .Ok;
		}

		public static Result<void> Write(Stream stream, Bitmap bitmap, MiniZ.CompressionLevel compressionLevel = .DEFAULT_COMPRESSION)
			=> Write(stream, bitmap.Width, bitmap.Height, bitmap.Pixels);

		public static Result<void> Write(Stream stream, uint32 width, uint32 height, Color[] pixels, MiniZ.CompressionLevel compressionLevel = .DEFAULT_COMPRESSION)
		{
		    const int32 MaxIDATChunkLength = 8192;
			const uint32 MaxImageSize = 2147483648;

		    Result<void> Chunk(Stream stream, String title, Span<uint8> buffer)
		    {
		        // write chunk
	            HandleWrite!(stream.Write(SwapEndian((int32)buffer.Length)));
	            HandleWrite!(stream.Write(Span<uint8>((uint8*)title.Ptr, title.Length)));
	            HandleWrite!(stream.Write(buffer));

		        // write CRC
		        {
		            uint32 crc = 0xFFFFFFFFU;
		            for (int n = 0; n < title.Length; n++)
		                crc = crcTable[((int32)crc ^ (uint8)title[n]) & 0xFF] ^ (crc >> 8);

		            for (int n = 0; n < buffer.Length; n++)
		                crc = crcTable[((int32)crc ^ buffer[n]) & 0xFF] ^ (crc >> 8);

		            HandleWrite!(stream.Write(SwapEndian((int32)(crc ^ 0xFFFFFFFFU))));
		        }

				return .Ok;
		    }

		    Result<void> WriteIDAT(Stream stream, MemoryStream memory, bool writeAll)
		    {
		        let zlib = (Span<uint8>)memory.[Friend]mMemory;
		        var remainder = (int32)memory.Position;
		        int32 offset = 0;

		        // write out IDAT chunks while there is memory to write
		        while ((writeAll ? remainder > 0 : remainder >= MaxIDATChunkLength))
		        {
		            int32 amount = Math.Min(remainder, MaxIDATChunkLength);

		            Try!(Chunk(stream, "IDAT", zlib.Slice(offset, amount)));
		            offset += amount;
		            remainder -= amount;
		        }

		        // shift remaining memory back
		        if (!writeAll)
		        {
		            if (remainder > 0)
		                zlib.Slice(offset).CopyTo(zlib);
		            memory.Position = remainder;
		            memory.[Friend]mMemory.Count = remainder;
		        }

				return .Ok;
		    }

		    // PNG header
		    HandleWrite!(stream.Write(header));

		    // IHDR Chunk
		    {
		        Span<uint8> buf = scope uint8[13];

				if (width == 0 || height == 0
					|| width > MaxImageSize || height > MaxImageSize)
					return .Err;

				uint32 val = width;
				buf[00] = (uint8)((val >> 24) & 0xFF);
				buf[01] = (uint8)((val >> 16) & 0xFF);
				buf[02] = (uint8)((val >> 8) & 0xFF);
				buf[03] = (uint8)(val & 0xFF);

				val = height;
				buf[04] = (uint8)((val >> 24) & 0xFF);
				buf[05] = (uint8)((val >> 16) & 0xFF);
				buf[06] = (uint8)((val >> 8) & 0xFF);
				buf[07] = (uint8)(val & 0xFF);

		        buf[08] = 8; // depth
		        buf[09] = 6; // color (truecolor-alpha)
		        buf[10] = 0; // compression
		        buf[11] = 0; // filter
		        buf[12] = 0; // interlace

		        Try!(Chunk(stream, "IHDR", buf));
		    }

		    // IDAT Chunk(s)
		    {
				MemoryStream zlibMemory = scope .();

				CompressionStream deflate = scope .(zlibMemory, compressionLevel, false);

				let filter = uint8[1]();
				uint8* pixelBuffer = (.)pixels.Ptr;

				for (int y = 0; y < height; y++)
				{
				    // deflate filter
				    HandleWrite!(deflate.Write(filter));

				    // append the row of pixels (in steps, potentially)
				    const int MaxHorizontalStep = 1024;
				    for (int x = 0; x < width; x += MaxHorizontalStep)
				    {
				        var segment = Span<uint8>(pixelBuffer + x * sizeof(Color), Math.Min(width - x, MaxHorizontalStep) * sizeof(Color));

						// TODO: use filter here?

				        // delfate the segment of the row
				        HandleWrite!(deflate.Write(segment));

				        // write out chunks if we've hit out max IDAT chunk length
				        if (zlibMemory.Position >= MaxIDATChunkLength)
				            HandleWrite!(WriteIDAT(stream, zlibMemory, false));
				    }

				    pixelBuffer += width * sizeof(Color);
				}
				HandleWrite!(deflate.Write(0, 1)); // TODO: Without this it doesn't load in some programs and i don't know why -- seems to be a issue of the stream though!
				HandleWrite!(deflate.Close());

				// Since we incremented the pointer at the end of the loop we will end up overstepping by one
				Debug.Assert(pixelBuffer == pixels.Ptr + pixels.Count);

				// Write all
				HandleWrite!(WriteIDAT(stream, zlibMemory, true));
		    }

		    // IEND Chunk
		    Chunk(stream, "IEND", Span<uint8>());
		    return .Ok;
		}

		[Inline]
		static uint8 PaethPredictor(uint8 a, uint8 b, uint8 c)
		{
		    int32 p = (int32)a + b - c;
		    int32 pa = Math.Abs((int32)p - a);
		    int32 pb = Math.Abs((int32)p - b);
		    int32 pc = Math.Abs((int32)p - c);

		    if (pa <= pb && pa <= pc)
		        return a;
		    else if (pb <= pc)
		        return b;

		    return c;
		}

		[Inline]
		static bool Check(String name, uint8[4] buffer)
		{
		    if (buffer.Count < name.Length)
		        return false;

		    for (int i = 0; i < name.Length; i++)
		    {
		        if ((char8)buffer[i] != name[i])
		            return false;
		    }

		    return true;
		}

		[Inline]
		static int32 SwapEndian(int32 input)
		{
#if BF_LITTLE_ENDIAN
	        uint32 value = (uint32)input;
	        return (int32)((value & 0x000000FF) << 24 | (value & 0x0000FF00) << 8 | (value & 0x00FF0000) >> 8 | (value & 0xFF000000) >> 24);
#else
		    return input;
#endif
		}
	}
}
