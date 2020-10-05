using System;
using System.IO;
using System.Text;

namespace Pile
{
	public static class PNG
	{
		private enum Colors : uint8
		{
		    Greyscale = 0,
		    Truecolor = 2,
		    Indexed = 3,
		    GreyscaleAlpha = 4,
		    TruecolorAlpha = 6
		}

		private enum Interlace : uint8
		{
		    None = 0,
		    Adam7 = 1
		}

		private static readonly uint8[8] header = uint8[8]( 137, 80, 78, 71, 13, 10, 26, 10 );
		private static readonly uint[] crcTable = new uint[256] ~ delete _;

		static this()
		{
		    // create the CRC table
		    // taken from libpng format specification: http://www.libpng.org/pub/png/spec/1.2/PNG-CRCAppendix.html

		    for (int n = 0; n < 256; n++)
		    {
		        uint c = (uint)n;
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

		public static Result<void, String> Read(Stream stream, ref Bitmap bitmap)
		{

		    // This could likely be optimized a buuunch more
		    // We also ignore all checksums when reading because they don't seem super important for game usage

		    var hasTransparency = false;
		    uint8 depth = 8;
		    var color = Colors.Truecolor;
		    uint8 compression = 0;
		    uint8 filter = 0;
		    Interlace interlace = Interlace.None;
		    var components = 4;

		    MemoryStream idat = scope MemoryStream(); // Close() does nothing on this
		    Span<uint8> idatChunk = scope uint8[4096];
		    uint8[] palette = scope uint8[0];
		    uint8[] alphaPalette = scope uint8[0];
		    uint8[4] fourbytes = uint8[4]();

		    bool hasIHDR = false, hasPLTE = false, hasIDAT = false;

		    // Check PNG Header
		    if (!IsValid(stream))
		        return .Err("Error reading PNG: Stream is not PNG");

		    // Skip PNG header
		    stream.Seek(8);

		    // Read Chunks
		    while (stream.Position < stream.Length)
		    {
		        int64 chunkStartPosition = stream.Position;

		        // chunk length
		        fourbytes = stream.Read<uint8[4]>();
		        int32 chunkLength = SwapEndian(BitConverter.Convert<uint8[4], int32>(fourbytes));

		        // chunk type
		        fourbytes = stream.Read<uint8[4]>();

		        // IHDR Chunk
		        if (Check("IHDR", fourbytes))
		        {
		            hasIHDR = true;
		            fourbytes = stream.Read<uint8[4]>();
		            let width = SwapEndian(BitConverter.Convert<uint8[4], int32>(fourbytes));
		            fourbytes = stream.Read<uint8[4]>();
		            let height = SwapEndian(BitConverter.Convert<uint8[4], int32>(fourbytes));
		            depth = stream.Read<uint8>();
		            color.UnderlyingRef = stream.Read<uint8>();
		            compression = stream.Read<uint8>();
		            filter = stream.Read<uint8>();
		            interlace.UnderlyingRef = stream.Read<uint8>();
		            hasTransparency = color == Colors.GreyscaleAlpha || color == Colors.TruecolorAlpha;

					bitmap.Resize(width, height);

		            if (color == Colors.Greyscale || color == Colors.Indexed)
		                components = 1;
		            else if (color == Colors.GreyscaleAlpha)
		                components = 2;
		            else if (color == Colors.Truecolor)
		                components = 3;
		            else if (color == Colors.TruecolorAlpha)
		                components = 4;

		            // currently don't support interlacing as I'm actually not sure where the interlace step takes place lol
		            if (interlace == Interlace.Adam7)
		                return .Err("Error reading PNG: Interlaced PNGs not implemented");

		            if (depth != 1 && depth != 2 && depth != 4 && depth != 8 && depth != 16)
		                return .Err(new String("Error reading PNG: {0}-bit depth not supported")..Format(depth));

		            if (filter != 0)
		                return .Err(new String("Error reading PNG: Filter {0} not supported")..Format(filter));

		            if (compression != 0)
		                return .Err(new String("Error reading PNG: Compression {} not supported")..Format(compression));
		        }
		        // PLTE Chunk (Indexed Palette)
		        else if (Check("PLTE", fourbytes))
		        {
		            hasPLTE = true;
		            palette = scope:: uint8[chunkLength];

		            let res = stream.TryRead(palette);
					if (res case .Err)
						return .Err("Error reading PNG: Couldn't read PLTE chunk");
					else if (res case .Ok(let val))
						if (val != palette.Count)
							return .Err("Error reading PNG: PLTE chunk was not of expected size");
		        }
		        // IDAT Chunk (Image Data)
		        else if (Check("IDAT", fourbytes))
		        {
		            hasIDAT = true;

		            for (int i = 0; i < chunkLength; i += idatChunk.Length)
		            {
		                int size = Math.Min(idatChunk.Length, chunkLength - i);

						let sizedChunk = idatChunk.Slice(0, size);
						let res = stream.TryRead(sizedChunk);
		                if (res case .Err)
							return .Err("Error reading PNG: Couldn't read IDAT chunk");
						else if (res case .Ok(let val))
							if (val != sizedChunk.Length)
								return .Err("Error reading PNG: IDAT chunk was not of expected size");

		                idat.Write(idatChunk.Slice(0, size));
		            }
		        }
		        // tRNS Chunk (Alpha Palette)
		        else if (Check("tRNS", fourbytes))
		        {
		            if (color == .Indexed)
		            {
		                alphaPalette = scope:: uint8[chunkLength];

						let res = stream.TryRead(alphaPalette);
						if (res case .Err)
							return .Err("Error reading PNG: Couldn't read tRNS chunk");
						else if (res case .Ok(let val))
							if (val != alphaPalette.Count)
								return .Err("Error reading PNG: tRNS chunk was not of expected size");
		            }
		            else if (color == .Greyscale)
		            {
						Log.Warning("Reading PNG: tRNS chunk with Grayscale not implemented/ignored");
		            }
		            else if (color == .Truecolor)
		            {
						Log.Warning("Reading PNG: tRNS chunk with Truecolor not implemented/ignored");
		            }
		        }
		        // bKGD Chunk (Background)
		        else if (Check("bKGD", fourbytes))
		        {
					Log.Warning("Reading PNG: bKGD chunk not implemented/ignored");
		        }

		        // seek to end of the chunk
		        stream.Seek(chunkStartPosition + chunkLength + 12);
		    }

		    // checks
		    if (!hasIHDR)
		        return .Err("Error reading PNG: Missing IHDR data");

		    if (!hasIDAT)
		        return .Err("Error reading PNG: PNG Missing IDAT data");

		    if (!hasPLTE && color == Colors.Indexed)
		        return .Err("Error reading PNG: PNG Missing PLTE data");

			let width = bitmap.Width;
			let height = bitmap.Height;

		    // Parse the IDAT data into Pixels
		    // It would be cool to do this line-by-line so we don't need to create a buffer to store the decompressed stream
		    {
		        uint8[] buffer = scope uint8[width * height * (depth == 16 ? 2 : 1) * 4 + height];

		        // decompress the image data
		        {
		            //idat.Seek(2);
		            //using DeflateStream deflateStream = new DeflateStream(idat, CompressionMode.Decompress);
		            //deflateStream.Read(buffer);

					let res = Compression.Decompress(idat.[Friend]mMemory, Span<uint8>(buffer));
					switch (res)
					{
					case .Ok(let val):
						if (buffer.Count != val)
							return .Err("Decompressed image data doesnt have expected size");
					case .Err(let err):
						return .Err(err);
					}
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
		                    {
		                        buffer[dest + x] = (uint8)(buffer[source + x] + buffer[dest + x - bpp]);
		                    }
		                }
		                // 2 - Up
		                else if (lineFilter == 2)
		                {
		                    if (y <= 0)
		                    {
		                        Array.Copy(buffer, source, buffer, dest, lineLength);
		                    }
		                    else
		                    {
		                        for (int x = 0; x < lineLength; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + buffer[dest + x - lineLength]);
		                        }
		                    }
		                }
		                // 3 - Average
		                else if (lineFilter == 3)
		                {
		                    if (y <= 0)
		                    {
		                        Array.Copy(buffer, source, buffer, dest, Math.Min(bpp, lineLength));
		                        for (int x = bpp; x < lineLength; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + ((buffer[dest + x - bpp] + 0) / 2));
		                        }
		                    }
		                    else
		                    {
		                        for (int x = 0; x < bpp; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + ((0 + buffer[dest + x - lineLength]) / 2));
		                        }

		                        for (int x = bpp; x < lineLength; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + ((buffer[dest + x - bpp] + buffer[dest + x - lineLength]) / 2));
		                        }
		                    }
		                }
		                // 4 - Paeth
		                else if (lineFilter == 4)
		                {
		                    if (y <= 0)
		                    {
		                        Array.Copy(buffer, source, buffer, dest, Math.Min(bpp, lineLength));
		                        for (int x = bpp; x < lineLength; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + buffer[dest + x - bpp]);
		                        }
		                    }
		                    else
		                    {
		                        for (int x = 0, int c = Math.Min(bpp, lineLength); x < c; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + buffer[dest + x - lineLength]);
		                        }

		                        for (int x = bpp; x < lineLength; x++)
		                        {
		                            buffer[dest + x] = (uint8)(buffer[source + x] + PaethPredictor(buffer[dest + x - bpp], buffer[dest + x - lineLength], buffer[dest + x - bpp - lineLength]));
		                        }
		                    }
		                }

		                dest += lineLength;
		            }
		        }

		        // if the bit-depth isn't 8, convert it
		        if (depth != 8)
		        {
		            return .Err("Non 8-bit PNGs not Implemented");
		        }

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
		            let pixels = Span<Color>((Color*)&buffer[0], width * height);
					bitmap.SetPixels(pixels);
					bitmap.Pixels[0] = Color.Red;
		        }
		    }

		    return .Ok;
		}

		/*public static Result<void, String> Write(Stream stream, Bitmap bitmap)
			=> Write(stream, bitmap.Width, bitmap.Height, bitmap.Pixels);*/

		/*public static Result<void, String> Write(Stream stream, int width, int height, Color[] pixels)
		{
		    const int MaxIDATChunkLength = 8192;

		    static void Chunk(BinaryWriter writer, string title, Span<byte> buffer)
		    {
		        // write chunk
		        {
		            writer.Write(SwapEndian(buffer.Length));
		            for (int i = 0; i < title.Length; i++)
		                writer.Write((byte)title[i]);
		            writer.Write(buffer);
		        }

		        // write CRC
		        {
		            uint crc = 0xFFFFFFFFU;
		            for (int n = 0; n < title.Length; n++)
		                crc = crcTable[(crc ^ (byte)title[n]) & 0xFF] ^ (crc >> 8);

		            for (int n = 0; n < buffer.Length; n++)
		                crc = crcTable[(crc ^ buffer[n]) & 0xFF] ^ (crc >> 8);

		            writer.Write(SwapEndian((int)(crc ^ 0xFFFFFFFFU)));
		        }
		    }

		    static void WriteIDAT(BinaryWriter writer, MemoryStream memory, bool writeAll)
		    {
		        var zlib = new Span<byte>(memory.GetBuffer());
		        var remainder = (int)memory.Position;
		        var offset = 0;

		        // write out IDAT chunks while there is memory to write
		        while ((writeAll ? remainder > 0 : remainder >= MaxIDATChunkLength))
		        {
		            var amount = Math.Min(remainder, MaxIDATChunkLength);

		            Chunk(writer, "IDAT", zlib.Slice(offset, amount));
		            offset += amount;
		            remainder -= amount;
		        }

		        // shift remaining memory back
		        if (!writeAll)
		        {
		            if (remainder > 0)
		                zlib.Slice(offset).CopyTo(zlib);
		            memory.Position = remainder;
		            memory.SetLength(remainder);
		        }
		    }

		    // PNG header
		    using BinaryWriter writer = new BinaryWriter(stream);
		    writer.Write(header);

		    // IHDR Chunk
		    {
		        Span<byte> buf = stackalloc byte[13];

		        BinaryPrimitives.WriteInt32BigEndian(buf.Slice(0), width);
		        BinaryPrimitives.WriteInt32BigEndian(buf.Slice(4), height);
		        buf[08] = 8; // depth
		        buf[09] = 6; // color (truecolor-alpha)
		        buf[10] = 0; // compression
		        buf[11] = 0; // filter
		        buf[12] = 0; // interlace

		        Chunk(writer, "IHDR", buf);
		    }

		    // IDAT Chunk(s)
		    {
		        using MemoryStream zlibMemory = new MemoryStream();

		        // zlib Header
		        zlibMemory.WriteByte(0x78);
		        zlibMemory.WriteByte(0x9C);

		        uint adler = 1U;

		        // filter & deflate data line by line
		        using (DeflateStream deflate = new DeflateStream(zlibMemory, CompressionLevel.Fastest, true))
		        {
		            fixed (Color* ptr = pixels)
		            {
		                Span<byte> filter = stackalloc byte[1] { 0 };
		                byte* pixelBuffer = (byte*)ptr;

		                for (int y = 0; y < height; y++)
		                {
		                    // deflate filter
		                    deflate.Write(filter);

		                    // update adler checksum
		                    adler = Calc.Adler32(adler, filter);

		                    // append the row of pixels (in steps, potentially)
		                    const int MaxHorizontalStep = 1024;
		                    for (int x = 0; x < width; x += MaxHorizontalStep)
		                    {
		                        var segment = new Span<byte>(pixelBuffer + x * 4, Math.Min(width - x, MaxHorizontalStep) * 4);

		                        // delfate the segment of the row
		                        deflate.Write(segment);

		                        // update adler checksum
		                        adler = Calc.Adler32(adler, segment);

		                        // write out chunks if we've hit out max IDAT chunk length
		                        if (zlibMemory.Position >= MaxIDATChunkLength)
		                            WriteIDAT(writer, zlibMemory, false);
		                    }

		                    pixelBuffer += width * 4;
		                }
		            }
		        }

		        // zlib adler32 trailer
		        using (BinaryWriter bytes = new BinaryWriter(zlibMemory, Encoding.UTF8, true))
		            bytes.Write(SwapEndian((int)adler));

		        // write out remaining chunks
		        WriteIDAT(writer, zlibMemory, true);
		    }

		    // IEND Chunk
		    Chunk(writer, "IEND", Span<uint8>());
		    return .Ok;
		}*/

		[Inline]
		private static uint8 PaethPredictor(uint8 a, uint8 b, uint8 c)
		{
		    int32 p = a + b - c;
		    int32 pa = Math.Abs(p - a);
		    int32 pb = Math.Abs(p - b);
		    int32 pc = Math.Abs(p - c);

		    if (pa <= pb && pa <= pc)
		        return a;
		    else if (pb <= pc)
		        return b;

		    return c;
		}

		[Inline]
		private static bool Check(String name, uint8[4] buffer)
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
		private static int32 SwapEndian(int32 input)
		{
		    if (BitConverter.IsLittleEndian)
		    {
		        uint value = (uint)input;
		        return (int32)((value & 0x000000FF) << 24 | (value & 0x0000FF00) << 8 | (value & 0x00FF0000) >> 8 | (value & 0xFF000000) >> 24);
		    }

		    return input;
		}
	}
}
