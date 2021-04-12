using System;
using System.Collections;
using System.IO;
using System.Text;

using internal Pile;

namespace Pile
{
	/// Parses the Contents of an Aseprite file
	///
	/// Aseprite File Spec: https://github.com/aseprite/aseprite/blob/master/docs/ase-file-specs.md
	/// This is not a complete implementation and focuses on usage in loading aseprite files for games
	class Aseprite
	{
	    public enum Modes
	    {
	        Indexed = 1,
	        Grayscale = 2,
	        RGBA = 4
	    }

	    enum Chunks
	    {
	        OldPaletteA = 0x0004,
	        OldPaletteB = 0x0011,
	        Layer = 0x2004,
	        Cel = 0x2005,
	        CelExtra = 0x2006,
	        Mask = 0x2016,
	        Path = 0x2017,
	        FrameTags = 0x2018,
	        Palette = 0x2019,
	        UserData = 0x2020,
	        Slice = 0x2022
	    }

	    public Modes Mode { get; private set; }
	    public uint32 Width { get; private set; }
	    public uint32 Height { get; private set; }
	    int frameCount;

	    public readonly List<Layer> Layers = new List<Layer>() ~ DeleteContainerAndItems!(_);
	    public readonly List<Frame> Frames = new List<Frame>() ~ DeleteContainerAndItems!(_);
	    public readonly List<Tag> Tags = new List<Tag>() ~ DeleteContainerAndItems!(_);
	    public readonly List<Slice> Slices = new List<Slice>() ~ DeleteContainerAndItems!(_);

	    public this(Stream stream)
	    {
	        if (Parse(stream) case .Err)
				Log.Warn("Reading .ase from stream failed. See error above");
	    }

	    #region Data Structures

	    public class Frame
	    {
	        public Aseprite Sprite;
	        public int32 Duration;
	        public Bitmap Bitmap ~ delete _;
	        public Color[] Pixels => Bitmap.Pixels;
	        public List<Cel> Cels  = new List<Cel>() ~ DeleteContainerAndItems!(_);

	        public this(Aseprite sprite)
	        {
	            Sprite = sprite;
	            Bitmap = new Bitmap(sprite.Width, sprite.Height);
	        }
	    }

	    public class Tag
	    {
	        public enum LoopDirections
	        {
	            Forward = 0,
	            Reverse = 1,
	            PingPong = 2
	        }

	        public String Name = new String() ~ delete _;
	        public LoopDirections LoopDirection;
	        public int32 From;
	        public int32 To;
	        public Color Color;
	    }

	    public interface IUserData
	    {
	        String UserDataText { get; set; }
	        Color UserDataColor { get; set; }
	    }

	    public class Slice : IUserData
	    {
	        public uint32 Frame;
	        public String Name = new String() ~ delete _;
	        public int32 OriginX;
	        public int32 OriginY;
	        public uint32 Width;
	        public uint32 Height;
	        public Point2? Pivot;
	        public Rect? NineSlice;
	        public String UserDataText { get; set; }
	        public Color UserDataColor { get; set; }

			public this() => UserDataText = new String();

			public ~this()
			{
				delete UserDataText;
			}
	    }

	    public class Cel : IUserData
	    {
	        public Layer Layer;
	        public Color[] Pixels ~ delete _;
	        public Cel Link;

	        public int32 X;
	        public int32 Y;
	        public int32 Width;
	        public int32 Height;
	        public float Alpha;

	        public String UserDataText { get; set; }
	        public Color UserDataColor { get; set; }

	        public this(Layer layer, Span<Color> pixels)
	        {
	            Layer = layer;
	            Pixels = new Color[pixels.Length];
				pixels.CopyTo(Pixels);
				UserDataText = new String();
	        }

			public ~this()
			{
				delete UserDataText;
			}
	    }

	    public class Layer : IUserData
	    {
	        public enum Flags
	        {
	            Visible = 1,
	            Editable = 2,
	            LockMovement = 4,
	            Background = 8,
	            PreferLinkedCels = 16,
	            Collapsed = 32,
	            Reference = 64
	        }

	        public enum Types
	        {
	            Normal = 0,
	            Group = 1
	        }

	        public Flags Flag;
	        public Types Type;
	        public String Name = new String() ~ delete _;
	        public int32 ChildLevel;
	        public int32 BlendMode;
	        public float Alpha;
	        public bool Visible
			{
				get
				{
					return Flag.HasFlag(Flags.Visible);
				}
			}

	        public String UserDataText { get; set; }
	        public Color UserDataColor { get; set; }

			public this() => UserDataText = new String();
			public ~this()
			{
				delete UserDataText;
			}	
	    }

	    #endregion

	    #region .ase Parser

	    Result<void> Parse(Stream stream)
	    {
	        // wrote these to match the documentation names so it's easier (for me, anyway) to parse
	        uint8 BYTE() => stream.Read<uint8>();
	        uint16 WORD() => stream.Read<uint16>();
	        int16 SHORT() => stream.Read<int16>();
	        uint32 DWORD() => stream.Read<uint32>();
	        int32 LONG() => stream.Read<int32>();
	        mixin STRING()
			{
				let buf = scope uint8[WORD()];
				let length = Try!(stream.TryRead(buf)); // BYTES(count) is here

				if (length != buf.Count)
					LogErrorReturn!("Couldn't load Aseprite: Unexpected string size");

				let s = scope:mixin String((char8*)buf.Ptr, buf.Count);
				s
			}
	        void SEEK(int number) => stream.Position += number;

	        // Header
	        {
	            // file size
	            DWORD();

	            // Magic number (0xA5E0)
	            var magic = WORD();
	            if (magic != 0xA5E0)
				{
					LogErrorReturn!("Couldn't load Asprite: Invalid format");
				}

	            // Frames / Width / Height / Color Mode
	            frameCount = WORD();
	            Width = WORD();
	            Height = WORD();
	            Mode = (Modes)(WORD() / 8);

	            // Other Info, Ignored
	            DWORD();       // Flags
	            WORD();        // Speed (deprecated)
	            DWORD();       // Set be 0
	            DWORD();       // Set be 0
	            BYTE();        // Palette entry 
	            SEEK(3);       // Ignore these bytes
	            WORD();        // Number of colors (0 means 256 for old sprites)
	            BYTE();        // Pixel width
	            BYTE();        // Pixel height
	            SEEK(92);      // For Future
	        }

	        // temporary variables
	        //var temp = scope uint8[Width * Height * (uint)Mode];
	        var palette = scope Color[256];
	        IUserData last = null;

			List<uint8> compressedBuffer = new List<uint8>(Width * Height * (.)Mode);
			List<Color> colorBuffer = new List<Color>();
			defer delete compressedBuffer;
			defer delete colorBuffer;

	        // Frames
	        Loop:for (int i = 0; i < frameCount; i++)
	        {
	            var frame = new Frame(this);
	            Frames.Add(frame);

	            int64 frameStart, frameEnd;
	            int chunkCount;

	            // frame header
	            {
	                frameStart = stream.Position;
	                frameEnd = frameStart + DWORD();
	                WORD();                  // Magic number (always 0xF1FA)
	                chunkCount = WORD();     // Number of "chunks" in this frame
	                frame.Duration = WORD(); // Frame duration (in milliseconds)
	                SEEK(6);                 // For future (set to zero)
	            }

	            // chunks
	            for (int j = 0; j < chunkCount; j++)
	            {
					Chunk:
					{
		                int64 chunkStart, chunkEnd;
		                Chunks chunkType;

		                // chunk header
		                {
		                    chunkStart = stream.Position;
		                    chunkEnd = chunkStart + DWORD();
		                    chunkType = (Chunks)WORD();
		                }

		                // LAYER CHUNK
		                if (chunkType == Chunks.Layer)
		                {
		                    // create layer
		                    var layer = new Layer();

		                    // get layer data
		                    layer.Flag = (Layer.Flags)WORD();
		                    layer.Type = (Layer.Types)WORD();
		                    layer.ChildLevel = WORD();
		                    WORD(); // width (unused)
		                    WORD(); // height (unused)
		                    layer.BlendMode = WORD();
		                    layer.Alpha = (BYTE() / 255f);
		                    SEEK(3); // for future
		                    layer.Name.Set(STRING!());

		                    last = layer;
		                    Layers.Add(layer);
		                }
		                // CEL CHUNK
		                else if (chunkType == Chunks.Cel)
		                {
		                    var layer = Layers[WORD()];
		                    var x = SHORT();
		                    var y = SHORT();
		                    var alpha = BYTE() / 255f;
		                    var celType = WORD();
		                    int32 width = 0;
		                    int32 height = 0;
		                    Color[] linkPixels;
		                    Cel link;

		                    SEEK(7);

		                    // RAW or DEFLATE
		                    if (celType == 0 || celType == 2)
		                    {
		                        width = WORD();
		                        height = WORD();

		                        var count = width * height * (int)Mode;
								compressedBuffer.Count = count;

		                        // RAW
		                        if (celType == 0)
		                        {
		                            let length = LogErrorTry!(stream.TryRead(compressedBuffer), "Error reading ASE RAW Cell: Error reading");
									if (length != compressedBuffer.Count - 1)
										LogErrorReturn!("Error reading ASE RAW Cell: Unexpected size");
		                        }
		                        // DEFLATE
		                        else
		                        {
									let source = scope uint8[chunkEnd - stream.Position]; // Read to end of chunk
									let length = LogErrorTry!(stream.TryRead(source), "Error reading ASE COMPRESSED Cell: Error reading");
									if (length != source.Count)
										LogErrorReturn!("Error reading ASE COMPRESSED Cell: Unexpected size");

									if (Compression.Decompress(source, compressedBuffer) case .Err(let err))
										LogErrorReturn!(scope $"Error decompressing ASE COMPRESSED Cell: {err}");
								}

		                        // get pixel data
		                        //pixels = new Color[width * height];
								colorBuffer.Count = width * height;
		                        BytesToPixels(compressedBuffer, colorBuffer, Mode, palette);

		                    }
		                    // REFERENCE
		                    else if (celType == 1)
		                    {
		                        var linkFrame = Frames[WORD()];
		                        var linkCel = linkFrame.Cels[frame.Cels.Count];

		                        width = linkCel.Width;
		                        height = linkCel.Height;
								linkPixels = linkCel.Pixels;
		                        link = linkCel;
		                    }
		                    else
		                    {
								LogErrorReturn!("Error reading ASE Cell: Cell format not implemented");
		                    }

		                    var cel = new Cel(layer, celType == 1 ? Span<Color>(linkPixels) : colorBuffer)
		                    {
		                        X = x,
		                        Y = y,
		                        Width = width,
		                        Height = height,
		                        Alpha = alpha,
		                        Link = link
		                    };

		                    // draw to frame if visible
		                    if (cel.Layer.Visible)
		                        CelToFrame(frame, cel);

		                    last = cel;
		                    frame.Cels.Add(cel);
		                }
		                // PALETTE CHUNK
		                else if (chunkType == Chunks.Palette)
		                {
		                    /*var size =*/ DWORD(); // UNUSED
		                    var start = DWORD();
		                    var end = DWORD();
		                    SEEK(8); // for future

		                    for (int p = 0; p < (end - start) + 1; p++)
		                    {
		                        var hasName = WORD();
		                        palette[start + p] = Color(BYTE(), BYTE(), BYTE(), BYTE()).Premultiply();

		                        if (Math.IsBitSet(hasName, 0))
		                            STRING!();
		                    }
		                }
		                // USERDATA
		                else if (chunkType == Chunks.UserData)
		                {
		                    if (last != null)
		                    {
		                        var flags = (int)DWORD();

		                        // has text
		                        if (Math.IsBitSet(flags, 0))
		                            last.UserDataText.Set(STRING!());

		                        // has color
		                        if (Math.IsBitSet(flags, 1))
		                            last.UserDataColor = Color(BYTE(), BYTE(), BYTE(), BYTE()).Premultiply();
		                    }
		                }
		                // TAG
		                else if (chunkType == Chunks.FrameTags)
		                {
		                    var count = WORD();
		                    SEEK(8);

		                    for (int t = 0; t < count; t++)
		                    {
		                        var tag = new Tag();
		                        tag.From = WORD();
		                        tag.To = WORD();
		                        tag.LoopDirection = (Tag.LoopDirections)BYTE();
		                        SEEK(8);
		                        tag.Color = Color(BYTE(), BYTE(), BYTE(), (uint8)255).Premultiply();
		                        SEEK(1);
		                        tag.Name.Set(STRING!());
		                        Tags.Add(tag);
		                    }
		                }
		                // SLICE
		                else if (chunkType == Chunks.Slice)
		                {
		                    let count = (int)DWORD();
		                    let flags = (int)DWORD();
		                    DWORD(); // reserved
		                    let name = STRING!();

		                    for (int s = 0; s < count; s++)
		                    {
		                        var slice = new Slice()
		                        {
		                            Frame = DWORD(),
		                            OriginX = LONG(),
		                            OriginY = LONG(),
		                            Width = DWORD(),
		                            Height = DWORD()
		                        };
								slice.Name.Set(name);

		                        // 9 slice (ignored atm)
		                        if (Math.IsBitSet(flags, 0))
		                        {
		                            slice.NineSlice = Rect(
		                                (int)LONG(),
		                                (int)LONG(),
		                                (int)DWORD(),
		                                (int)DWORD());
		                        }

		                        // pivot point
		                        if (Math.IsBitSet(flags, 1))
		                            slice.Pivot = Point2(DWORD(), DWORD());
		                        
		                        last = slice;
		                        Slices.Add(slice);
		                    }
		                }
						
						stream.Position = chunkEnd;
					} // End of Cell scope
	            }

	            stream.Position = frameEnd;
	        }

			return .Ok;
	    }

	    #endregion

	    #region Blend Modes

	    // More or less copied from Aseprite's source code:
	    // https://github.com/aseprite/aseprite/blob/master/src/doc/blend_funcs.cpp
		// todo: support more blend modes
		// https://github.com/aseprite/aseprite/blob/master/docs/ase-file-specs.md#layer-chunk-0x2004

	    function void Blend(ref Color dest, Color src, uint8 opacity);

	    static readonly Blend[] BlendModes = new Blend[](
	        // 0 - NORMAL
	        (dest, src, opacity) =>
	        {
	            if (src.A != 0)
	            {
	                if (dest.A == 0)
	                {
	                    dest = src;
	                }
	                else
	                {
	                    var sa = MUL_UN8(src.A, opacity);
	                    var ra = dest.A + sa - MUL_UN8(dest.A, sa);

	                    dest.R = (uint8)(dest.R + ((int)src.R - dest.R) * sa / ra);
	                    dest.G = (uint8)(dest.G + ((int)src.G - dest.G) * sa / ra);
	                    dest.B = (uint8)(dest.B + ((int)src.B - dest.B) * sa / ra);
	                    dest.A = (uint8)ra;
	                }

	            }
	        }) ~ delete _;

	    [Inline]
	    static int MUL_UN8(int a, int b)
	    {
	        var t = (a * b) + 0x80;
	        return (((t >> 8) + t) >> 8);
	    }

	    #endregion

	    #region Utils

	    /// Converts an array of Bytes to an array of Colors, using the specific Aseprite Mode & Palette
	    void BytesToPixels(Span<uint8> bytes, Span<Color> pixels, Modes mode, Color[] palette)
	    {
	        int len = pixels.Length;
	        if (mode == .RGBA)
	        {
	            for (int p = 0, int b = 0; p < len; p++, b += 4)
	            {
	                pixels[p].R = (uint8)((int)bytes[b + 0] * ((int)bytes[b + 3] / 255f));
	                pixels[p].G = (uint8)((int)bytes[b + 1] * ((int)bytes[b + 3] / 255f));
	                pixels[p].B = (uint8)((int)bytes[b + 2] * ((int)bytes[b + 3] / 255f));
	                pixels[p].A = bytes[b + 3];
	            }
	        }
	        else if (mode == .Grayscale)
	        {
	            for (int p = 0, int b = 0; p < len; p++, b += 2)
	            {
	                pixels[p].R = pixels[p].G = pixels[p].B = (uint8)((int)bytes[b + 0] * ((int)bytes[b + 1] / 255f));
	                pixels[p].A = bytes[b + 1];
	            }
	        }
	        else if (mode == .Indexed)
	        {
	            for (int p = 0;  p < len; p++)
	                pixels[p] = palette[bytes[p]];
	        }
	    }

	    /// Applies a Cel's pixels to the Frame, using its Layer's BlendMode & Alpha
	    void CelToFrame(Frame frame, Cel cel)
	    {
	        var opacity = (uint8)((cel.Alpha * cel.Layer.Alpha) * 255);
	        var pxLen = frame.Bitmap.Pixels.Count;

	        var blend = BlendModes[0];
	        if (cel.Layer.BlendMode < BlendModes.Count)
	            blend = BlendModes[cel.Layer.BlendMode];

	        for (int sx = Math.Max(0, -cel.X), int right = Math.Min(cel.Width, (.)frame.Sprite.Width - cel.X); sx < right; sx++)
	        {
	            int dx = cel.X + sx;
	            int dy = cel.Y * (.)frame.Sprite.Width;

	            for (int sy = Math.Max(0, -cel.Y), int bottom = Math.Min(cel.Height, (.)frame.Sprite.Height - cel.Y); sy < bottom; sy++, dy += frame.Sprite.Width)
	            {
	                if (dx + dy >= 0 && dx + dy < pxLen)
	                    blend(ref frame.Bitmap.Pixels[dx + dy], cel.Pixels[sx + sy * cel.Width], opacity);
	            }
	        }
	    }
	    #endregion
	}
}