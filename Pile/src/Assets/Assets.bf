using System;
using System.Collections;

namespace Pile
{
	public static class Assets
	{
		// merge Assets, Images (loading of images with dynamic format registering)
		// 					=> bitmap loading
		// have asset packages
		// make loading assets async? - nah why, but maybe the compiling part but who cares
		// make registering assets types possible?
		//  => instead of this, register importers (tilemap importer, sprite importer and choose them by string match)

		// need packer and data file format to continue

		public abstract class Importer<Tasset>
		{
			public Type AssetType = typeof(Tasset);

			// look at old importer
			// this somehow needs to convert some data into a datafile and 

			public abstract bool Accepts(uint8[] data);
			public abstract Tasset Import(uint8[] data /*, DATAFILE*/); // This also needs to have some way to access a texture/bitmap list???
			public abstract Result<void, String> Build(uint8[] data, ref uint8[] outdata /*, ref DATAFILEFORMAT, PACKER (put texture data in here)*/);
		}

		// Do simple text and copy importer

		public class Package
		{
			List<String> ownedAssets = new List<String>() ~ delete _;

			readonly String name = new String() ~ delete _;
			public StringView Name => name;
		}

		static class AssetLookup<T> where T : class, delete
		{
			static Dictionary<String, T> L = new Dictionary<String, T>() ~ DeleteDictionaryAndKeysAndItems!(_);
		}

		static class ImporterLookup<T, Tasset> where T : Importer<Tasset> // I DONT KNOW IF THIS EVEN WORKS
		{
			static List<Importer<Tasset>> L = new List<Importer<Tasset>>() ~ DeleteContainerAndItems!(_); 
		}

		public static Event<Action> RegisterImporters ~ RegisterImporters.Dispose();

		static List<Package> loadedPackages = new List<Package>() ~ DeleteContainerAndItems!(_); // have public functions to access this

		static void Startup()
		{
			// handle registering importers here

			// do master file that lists all packages?? no, just load by path
			// in any case, the packages all have their data file listing the path of all assets and a string of their importers
		}

		public static Result<void, String> LoadPackage(StringView packageName)
		{
			return .Ok;
		}

		public static void UnloadPackage(StringView packageName)
		{
			
		}

		public static Result<void, String> BuildPackage(StringView packagePath)
		{
			return .Ok;
		}
	}
}
