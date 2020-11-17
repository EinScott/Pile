using System;
using System.Collections;

namespace Pile
{
	public class Packer
	{
		public class Entry
		{
			readonly String name ~ delete _;
			public StringView Name => name;

			public readonly int32 Page;
			public readonly Rect Source;
			public readonly Rect Frame;

			public this(String name, int32 page, Rect source, Rect frame)
			{
				// This is the string here and also in the dictionary (a fresh one only for this)
				this.name = name;

				Page = page;
				Source = source;
				Frame = frame;
			}
		}

		public class Output
		{
			public readonly List<Bitmap> Pages = new List<Bitmap>() ~ DeleteContainerAndItems!(_);
			public readonly Dictionary<String, Entry> Entries = new Dictionary<String, Entry>() ~ DeleteDictionaryAndItems!(_);
		}

		public class Source
		{
			public String name = new String() ~ delete _;
			public Rect packed;
			public Rect frame;
			public Color[] pixels = null ~ DeleteNotNull!(_);
			public Source duplicateOf = null;

			public bool Empty => packed.Width <= 0 || packed.Height <= 0;

			public this(StringView name)
			{
				this.name.Set(name);
			}
		}

		bool hasUnpackedData;

		public bool trim = true;
		public uint32 maxSize = 8192;
		public uint32 padding = 1;
		public bool powerOfTwo = false;
		public bool combineDuplicates = false;

		public int SourceImageCount => sources.Count;

		readonly List<Source> sources = new List<Source>() ~ DeleteContainerAndItems!(_);
		readonly Dictionary<int32, Source> duplicateLookup = new Dictionary<int32, Source>() ~ delete _;

		public void AddBitmap(StringView name, Bitmap bitmap)
		{
			if (bitmap != null)
				AddPixels(name, bitmap.Width, bitmap.Height, bitmap.Pixels);
		}

		public void AddPixels(StringView name, uint32 width, uint32 height, Span<Color> pixels)
		{
			hasUnpackedData = true;

			let source = new Source(name);
			int top = 0, left = 0, right = width, bottom = height;

			// trim
			if (trim)
			{
				TOP:
				for (int y = 0; y < height; y++)
				    for (int x = 0, int s = y * width; x < width; x++, s++)
				        if (pixels[s].A > 0)
				        {
				            top = y;
				            break TOP;
				        }
				LEFT:
				for (int x = 0; x < width; x++)
				    for (int y = top, int s = x + y * width; y < height; y++, s += width)
				        if (pixels[s].A > 0)
				        {
				            left = x;
				            break LEFT;
				        }
				RIGHT:
				for (int x = width - 1; x >= left; x--)
				    for (int y = top, int s = x + y * width; y < height; y++, s += width)
				        if (pixels[s].A > 0)
				        {
				            right = x + 1;
				            break RIGHT;
				        }
				BOTTOM:
				for (int y = height - 1; y >= top; y--)
				    for (int x = left, int s = x + y * width; x < right; x++, s++)
				        if (pixels[s].A > 0)
				        {
				            bottom = y + 1;
				            break BOTTOM;
				        }
			}

			// determine sizes
			// there's a chance this image was empty in which case we have no width / height
			if (left <= right && top <= bottom)
			{
			    var isDuplicate = false;

			    if (combineDuplicates)
			    {
			        let hash = GetHash(left, right, top, bottom, pixels);

			        if (duplicateLookup.TryGetValue(hash, let duplicate))
			        {
			            source.duplicateOf = duplicate;
			            isDuplicate = true;
			        }
			        else
			        {
			            duplicateLookup.Add(hash, source);
			        }
			    }

			    source.packed = Rect(0, 0, right - left, bottom - top);
			    source.frame = Rect(-left, -top, width, height);

			    if (!isDuplicate)
			    {
			        source.pixels = new Color[source.packed.Width * source.packed.Height];

			        // copy our trimmed pixel data to the main buffer
			        for (int i = 0; i < source.packed.Height; i++)
			        {
			            let run = source.packed.Width;
			            let from = pixels.Slice(left + (top + i) * width, run);
			            let to = Span<Color>(source.pixels, i * run, run);

			            from.CopyTo(to);
			        }
			    }
			}
			else
			{
			    source.packed = Rect();
			    source.frame = Rect(0, 0, width, height);
			}

			sources.Add(source);
		}

		public void RemoveSource(StringView name)
		{
			hasUnpackedData = true;

			// Find source & remove it
			Source removeSource = null;
			for (int i = 0; i < sources.Count; i++)
			{
				if (sources[i].name == name)
				{
					removeSource = sources[i];
					sources.RemoveAtFast(i);
				}
			}

			if (removeSource == null) return;

			// Find duplicates of this
			if (duplicateLookup.ContainsValue(removeSource))
			{
				Source replacement = null;
				for (let source in sources)
					if (source.duplicateOf == removeSource)
					{
						if (replacement == null)
						{
							// Replace the removed source in the duplicate lookup
							replacement = source;
							source.duplicateOf = null;
							let hash = GetHash(0, source.packed.Width, 0, source.packed.Height, source.pixels);
							duplicateLookup[hash] = source;
						}
						else source.duplicateOf = replacement;
					}
			}

			// Delete source
			delete removeSource;
		}

		int32 GetHash(int left, int right, int top, int bottom, Span<Color> pixels)
		{
			int32 hash = 0;
			let width = right - left;
			for (int x = left; x < right; x++)
			    for (int y = top; y < bottom; y++)
			        hash = ((hash << 5) + hash) + (int32)pixels[x + y * width];

			return hash;
		}

		struct PackingNode
		{
		    public bool Used;
		    public Rect Rect;
		    public PackingNode* Right;
		    public PackingNode* Down;
		}

		public void Clear()
		{
			hasUnpackedData = false;

			for (var source in sources)
				delete source;
			sources.Clear();
			duplicateLookup.Clear();
		}

		public Result<Output> Pack()
		{
			// Already been packed
			if (!hasUnpackedData)
			    return .Err;

			// Reset
			hasUnpackedData = false;

			// Nothing to pack
			if (sources.Count <= 0)
			    return .Err;

			// sort the sources by size
			sources.Sort(scope (a, b) => b.packed.Width * b.packed.Height - a.packed.Width * a.packed.Height);

			// make sure the largest isn't too large
			if (sources[0].packed.Width > maxSize || sources[0].packed.Height > maxSize)
			    LogErrorReturn!("Source image is larger than max atlas size");

			// why do we sometimes need more than source images * 3? [FOSTERCOMMENT]
			// for safety I've just made it 4 ... but it should really only be 3?
			// --> changed this to 3 to look into it. If this crashes here, investigate further or change back

			int nodeCount = sources.Count * 3;
			Span<PackingNode> buffer = scope PackingNode[nodeCount];

			var padding = Math.Max(0, padding);
			let output = new Output();

			// using pointer operations here was faster
			PackingNode* nodes = buffer.Ptr;

		    int32 packed = 0, page = 0;
		    while (packed < sources.Count)
		    {
		        if (sources[packed].Empty)
		        {
		            packed++;
		            continue;
		        }

		        let from = packed;
		        var nodePtr = nodes;
		        var rootPtr = ResetNode(nodePtr++, 0, 0, sources[from].packed.Width + padding, sources[from].packed.Height + padding);

		        while (packed < sources.Count)
		        {
		            if (sources[packed].Empty || sources[packed].duplicateOf != null)
		            {
		                packed++;
		                continue;
		            }

		            int w = sources[packed].packed.Width + padding;
		            int h = sources[packed].packed.Height + padding;
		            var node = FindNode(rootPtr, w, h);

		            // try to expand
		            if (node == null)
		            {
		                bool canGrowDown = (w <= rootPtr.Rect.Width) && (rootPtr.Rect.Height + h < maxSize);
		                bool canGrowRight = (h <= rootPtr.Rect.Height) && (rootPtr.Rect.Width + w < maxSize);
		                bool shouldGrowRight = canGrowRight && (rootPtr.Rect.Height >= (rootPtr.Rect.Width + w));
		                bool shouldGrowDown = canGrowDown && (rootPtr.Rect.Width >= (rootPtr.Rect.Height + h));

		                if (canGrowDown || canGrowRight)
		                {
		                    // grow right
		                    if (shouldGrowRight || (!shouldGrowDown && canGrowRight))
		                    {
		                        var next = ResetNode(nodePtr++, 0, 0, rootPtr.Rect.Width + w, rootPtr.Rect.Height);
		                        next.Used = true;
		                        next.Down = rootPtr;
		                        next.Right = node = ResetNode(nodePtr++, rootPtr.Rect.Width, 0, w, rootPtr.Rect.Height);
		                        rootPtr = next;
		                    }
		                    // grow down
		                    else
		                    {
		                        var next = ResetNode(nodePtr++, 0, 0, rootPtr.Rect.Width, rootPtr.Rect.Height + h);
		                        next.Used = true;
		                        next.Down = node = ResetNode(nodePtr++, 0, rootPtr.Rect.Height, rootPtr.Rect.Width, h);
		                        next.Right = rootPtr;
		                        rootPtr = next;
		                    }
		                }
		            }

		            // doesn't fit in this page
		            if (node == null)
		                break;

		            // add
		            node.Used = true;
		            node.Down = ResetNode(nodePtr++, node.Rect.X, node.Rect.Y + h, node.Rect.Width, node.Rect.Height - h);
		            node.Right = ResetNode(nodePtr++, node.Rect.X + w, node.Rect.Y, node.Rect.Width - w, h);

		            sources[packed].packed.X = node.Rect.X;
		            sources[packed].packed.Y = node.Rect.Y;

		            packed++;
		        }

		        // get page size
		        uint32 pageWidth, pageHeight;
		        if (powerOfTwo)
		        {
		            pageWidth = 2;
		            pageHeight = 2;
		            while (pageWidth < rootPtr.Rect.Width)
		                pageWidth *= 2;
		            while (pageHeight < rootPtr.Rect.Height)
		                pageHeight *= 2;
		        }
		        else
		        {
		            pageWidth = (.)rootPtr.Rect.Width;
		            pageHeight = (.)rootPtr.Rect.Height;
		        }

		        // create each page
		        {
		            var bmp = new Bitmap(pageWidth, pageHeight);
		            output.Pages.Add(bmp);

		            // create each entry for this page and copy its image data
		            for (int i = from; i < packed; i++)
		            {
		                var source = sources[i];

		                // do not pack duplicate entries yet
		                if (source.duplicateOf == null)
		                {
							let key = new String(source.name);
		                    output.Entries[key] = new Entry(key, page, source.packed, source.frame);

		                    if (!source.Empty)
		                        bmp.SetPixels(source.packed, source.pixels);
		                }
		            }
		        }

		        page++;
		    }

			// make sure duplicates have entries
			if (combineDuplicates)
			{
			    for (var source in sources)
			    {
			        if (source.duplicateOf != null)
			        {
			            let entry = output.Entries[source.duplicateOf.name];
						let key = new String(source.name);
			            output.Entries[key] = new Entry(key, entry.Page, entry.Source, entry.Frame);
			        }
			    }
			}

			return .Ok(output);

			PackingNode* FindNode(PackingNode* root, int w, int h)
			{
			    if (root.Used)
			    {
			        var r = FindNode(root.Right, w, h);
			        return (r != null ? r : FindNode(root.Down, w, h));
			    }
			    else if (w <= root.Rect.Width && h <= root.Rect.Height)
			    {
			        return root;
			    }

			    return null;
			}

			PackingNode* ResetNode(PackingNode* node, int x, int y, int w, int h)
			{
			    node.Used = false;
			    node.Rect = Rect(x, y, w, h);
			    node.Right = null;
			    node.Down = null;
			    return node;
			}
		}
	}
}
