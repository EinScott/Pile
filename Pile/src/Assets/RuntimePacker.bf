using System;
using System.Collections;

namespace Pile
{
	/*public class RuntimePacker
	{
		private class Pack
		{
			RuntimePacker packer;
			int32 page;
			Rect rect;
			List<Subtexture> subtextures = new List<Subtexture>();

			public ~this()
			{
				if (packer.OwnsSubtextures)
					DeleteContainerAndItems!(subtextures);
				else delete subtextures;
			}
		}

		readonly bool OwnsSubtextures;
		readonly int32 DefaultSize;
		Packer packer = new Packer() ~ delete _;

		List<Bitmap> buffers = new List<Bitmap>() ~ DeleteContainerAndItems!(_); // Buffers for updating and refreshing the texture
		List<Texture> textures = new List<Texture>() ~ DeleteContainerAndItems!(_);

		Dictionary<String, Pack> packs = new Dictionary<String, Pack>() ~ DeleteDictionaryAndKeysAndItems!(_); // [packName, location] The rects of all current packRects by name 
		Dictionary<int32, List<Rect>> fittingRects = new Dictionary<int32, List<Rect>>() ~ DeleteDictionaryAndItems!(_); // [page, rects] Mark free space, new packed rects are trying to fit inside one of them

		// [name, subtex] This list contains all subtextures from the current packer session that still need to be modified
		Dictionary<String, Subtexture> currentSubtextures = new Dictionary<String, Subtexture>();

		public this(bool ownsSubtextures, int32 defaultSize = 1024)
		{
			OwnsSubtextures = ownsSubtextures;
			DefaultSize = defaultSize;

			// Add first bitmap, texture and fittingRect
			AddPage();
		}

		public ~this()
		{
			if (OwnsSubtextures)
				DeleteDictionaryAndKeysAndItems!(currentSubtextures);
			else DeleteDictionaryAndKeys!(currentSubtextures);
		}

		/// Add an image to the packer as normal
		public Result<Subtexture> AddToCurrentPack(StringView name, Bitmap bitmap)
		{
			// Check if currentSubtextures already contains name

			if (bitmap != null)
				packer.AddPixels(name, bitmap.Width, bitmap.Height, bitmap.Pixels);

			// Create subtexture to return it, put it in list to fill it in properly later
			let tex = new Subtexture();
			currentSubtextures.Add(new String(name), tex);
			return .Ok(tex);
		}

		/// Commit the packer output onto a texture
		public void CommitCurrentPack(StringView packName)
		{
			if (!packer.hasUnpackedData) return;
			
			packer.Pack();

			// Commit packed rect to buffer bitmap, extend away from origin if necessary
			// But check for maxTextureSize, May create new page

			// Update impacted fittingrects

			// Modify subtextures from the packer result + placed offset in the texture

			packer.Clear();
		}

		// Remove a pack from the a texture
		public void RemovePack(String packName)
		{
			if (!packs.ContainsKey(packName)) return;

			// Remove rect
		}

		private void AddPage()
		{
			buffers.Add(new Bitmap(DefaultSize, DefaultSize));
			textures.Add(new Texture(buffers[buffers.Count - 1]));
			fittingRects.Add((.)buffers.Count - 1, new List<Rect>()..Add(Rect(0, 0, DefaultSize, DefaultSize)));
		}

		private void ResizePage(int32 page)
		{
			// Resize page and extend all fittingrects
		}

		private void TryExtendFittingRect(ref Rect rect, int32 page)
		{

		}
	}*/
}
