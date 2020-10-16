using System;
using System.Collections;

namespace Pile
{
	public class RuntimePacker
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
		Packer packer = new Packer() ~ delete _;

		List<Bitmap> buffers = new List<Bitmap>() ~ DeleteContainerAndItems!(_); // Buffers for updating and refreshing the texture
		List<Texture> textures = new List<Texture>() ~ DeleteContainerAndItems!(_);

		Dictionary<String, Pack> packs = new Dictionary<String, Pack>() ~ DeleteDictionaryAndKeysAndItems!(_); // [packName, location] The rects of all current packRects by name 
		Dictionary<int32, List<Rect>> fittingRects = new Dictionary<int32, List<Rect>>(); // [page, rects] Mark free space, new packed rects are trying to fit inside one of them

		// [name, subtex] This list contains all subtextures from the current packer session that still need to be modified
		Dictionary<String, Subtexture> currentSubtextures = new Dictionary<String, Subtexture>();

		public this(bool ownsSubtextures)
		{
			OwnsSubtextures = ownsSubtextures;
			// Add first bitmap, texture and fittingRect
		}

		public ~this()
		{
			for (var fittingRectPage in fittingRects.Values)
				delete fittingRectPage;
			delete fittingRects;

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

			// WE HAVE TO RETURN A NEW SUBTEXTURE WITH THIS NAME HERE AND REUTRN IT FOR ACCESS, THEN COMPLETE IT LATER
			return .Ok(null);
		}

		/// Commit the packer output onto a texture
		public void CommitCurrentPack(StringView packName)
		{
			if (!packer.HasUnpackedData) return;

			// Commit packed rect to buffer bitmap, extend away from origin if necessary
			// But check for maxTextureSize, May create new pagen

			// Update fitRects

			// Modify subtextures from the packer result + placed offset in the texture

			packer.Pack();

			packer.Clear();
		}

		// Remove a pack from the a texture
		public void RemovePack(String packName)
		{
			if (!packs.ContainsKey(packName)) return;

			// Remove rect 
		}
	}
}
