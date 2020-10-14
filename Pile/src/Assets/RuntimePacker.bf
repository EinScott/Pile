using System;
using System.Collections;

namespace Pile
{
	public class RuntimePacker
	{
		// Its kind of messy, but operates at runtime

		public class Entry
		{
			public readonly int Page;
			public readonly Rect Packed;
			public readonly Rect Frame;

			public this(int page, Rect packed, Rect frame)
			{
				Page = page;
				Packed = packed;
				Frame = frame;
			}
		}

		public class Page
		{
			public Bitmap bitmap = null ~ delete _;
			public Dictionary<String, Entry> entries = new Dictionary<String, Entry>() ~ DeleteDictionaryAndKeysAndItems!(_);

			public this(RuntimePacker packer)
			{
				bitmap = new Bitmap(packer.PageSize, packer.PageSize);
			}
		}

		public readonly bool Trim;
		public readonly int32 PageSize = 8192;
		public readonly int32 Padding = 1;

		readonly List<Page> pages = new List<Page>() ~ DeleteContainerAndItems!(_);

		public int Pages => pages.Count;

		public this(int pageSize, int32 padding, bool trim)
		{
			PageSize = PageSize;
			Padding = padding;
			Trim = trim;

			pages.Add(new Page(this));
		}

		public Result<Entry> Add(StringView name, Bitmap bitmap)
		{
			for (let p in pages)
				if (p.entries.ContainsKey(scope String(name))) LogErrorReturn!(scope String("Couldn't add bitmap to runtime packer. Name {0} is already taken")..Format(name));

			int top = 0, left = 0, right = bitmap.Width, bottom = bitmap.Height;

			// trim
			if (Trim)
			{
				TOP:
				for (int y = 0; y < bitmap.Height; y++)
				    for (int x = 0, int s = y * bitmap.Width; x < bitmap.Width; x++, s++)
				        if (bitmap.Pixels[s].A > 0)
				        {
				            top = y;
				            break TOP;
				        }
				LEFT:
				for (int x = 0; x < bitmap.Width; x++)
				    for (int y = top, int s = x + y * bitmap.Width; y < bitmap.Height; y++, s += bitmap.Width)
				        if (bitmap.Pixels[s].A > 0)
				        {
				            left = x;
				            break LEFT;
				        }
				RIGHT:
				for (int x = bitmap.Width - 1; x >= left; x--)
				    for (int y = top, int s = x + y * bitmap.Width; y < bitmap.Height; y++, s += bitmap.Width)
				        if (bitmap.Pixels[s].A > 0)
				        {
				            right = x + 1;
				            break RIGHT;
				        }
				BOTTOM:
				for (int y = bitmap.Height - 1; y >= top; y--)
				    for (int x = left, int s = x + y * bitmap.Width; x < right; x++, s++)
				        if (bitmap.Pixels[s].A > 0)
				        {
				            bottom = y + 1;
				            break BOTTOM;
				        }
			}

			Entry e;

			if (left <= right && top <= bottom)
			{
				// TODO: duplicate checking

				var packedRect = Rect(0, 0, right - left, bottom - top);
				var checkRect = Rect(0, 0, packedRect.Width + Padding * 2, packedRect.Height + Padding * 2);

				if (packedRect.Right > PageSize || packedRect.Bottom > PageSize)
					LogErrorReturn!(scope String("Bitmap {0} is too big for packer page resolution of {1}")..Format(name, PageSize));

				// TODO: optimize??
				int currPage = 0;
				while (true)
				{
					let p = pages[currPage];

					if (p.entries.Count == 0)
					{
						packedRect.X = 0;
						packedRect.Y = 0;
						break;
					}
					else if (p.entries.Count == 1)
					{
						packedRect.X = p.entries.Values.GetNext().Get().Packed.Right; // Place right of first one
						packedRect.Y = 0;
						break;
					}
					else if (p.entries.Count > 1)
					{
						int score = PageSize + PageSize;
						packedRect.X = PageSize;
						packedRect.Y = PageSize;
						for (let entry in p.entries.Values)
							for (let oEntry in p.entries.Values)
							{
								checkRect.X = entry.Packed.Right - Padding;
								checkRect.Y = oEntry.Packed.Y - Padding;
	
								CheckBetterFit();
	
								checkRect.X = entry.Packed.X - Padding;
								checkRect.Y = entry.Packed.Bottom - Padding;
	
								CheckBetterFit();
							}
	
	
						void CheckBetterFit()
						{
							// Score better than previous one
							if (checkRect.X + checkRect.Y >= score)
								return; // Worse placement than one we already found

							// Fits page
							if (checkRect.OverlapRect(Rect(0, 0, PageSize, PageSize)) != checkRect)
								return; // Off the page

							// AHHHH - lets at least make sure it only ever checks this when its worth it
							for (let entry in p.entries.Values)
								if (entry.Packed.Overlaps(checkRect))
									return;

							packedRect.X = checkRect.X + Padding;
							packedRect.Y = checkRect.Y + Padding;
							score = checkRect.X + checkRect.Y;
						}

						if (score < PageSize + PageSize) break; // Break if we found some fitting spot
					}

					currPage++;

					if (currPage == pages.Count)
					{
						Log.Message("NEW PAGE");
						pages.Add(new Page(this));
					}
				}

				e = new Entry(currPage, packedRect, Rect(-left, -top, bitmap.Width, bitmap.Height));
			}
			else
			{
				e = new Entry(0, Rect.Zero, Rect(0, 0, bitmap.Width, bitmap.Height));
			}

			pages[e.Page].entries.Add(new String(name), e);
			return .Ok(e);
		}

		public void Remove(StringView name)
		{

		}

		public void Get(int page, Texture outTexture)
		{

		}

		public void Get(int page, Bitmap outBitmap)
		{

		}
	}
}
