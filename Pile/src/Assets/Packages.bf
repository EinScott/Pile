using System;
using System.IO;
using System.Collections;
using System.Diagnostics;
using System.Security.Cryptography;

using internal Pile;

namespace Pile
{
#if !DEBUG
	[Optimize]
#endif
	static class Packages
	{
		// TODO:
		// -> so... methods to read the index, do things with it, methods to load some collection of entries
		// patched by either fitting the new data into the old slot (keep it in there as long as possible) or just
		// appending it to the end and updating the index! -- both set the patched flag on file
		// -> hot reload is fast, next full run will clean it up and do a full rebuild (probably nicer for workflow)

		// HEADER (3 bytes)
		// VERSION (1 byte)
		// FLAGS (1 byte) (like patched: which says that this includes dead data and should be rebuild on next proper launch)
		// SOURCE_HASH (32 bytes)
		// INDEX_OFFSET (8 bytes, uint64)

		// CONTENT (?)

		// IMPORTER_ENTRY_COUNT (1 byte, uint8)
		// IMPORTER_ENTRY[]
		//   ENTRY:
		//   IMPORTER_NAME_LENGTH (2 bytes, uint16)
		//   IMPORTER_NAME[]
		// PASS_ENTRY_COUNT (1 byte, uint8)
		// PASS_ENTRY[]
		//   ENTRY:
		//   IMPORTER_INDEX (1 byte, uint8)
		//   IMPORTER_CONFIG_LENGTH (2 bytes, uint16)
		//   IMPORTER_CONFIG[]
		//   CONTENT_ENTRY_COUNT (4 bytes, uint32)
		//   CONTENT_ENTRY[]
		//     ENTRY:
		//     NAME_LENGTH (2 bytes, uint16 - most significant bit signals "data_patched")
		//     NAME[]
		//     OFFSET (8 bytes, uint64)
		//     LENGTH (8 bytes, uint64)
		//     SLOT_SIZE (8 bytes, uint64) -- only if "data_patched"

		// FILE_SIZE (8 bytes, uint64)

		// TODO: how do we do reading?
		// --> maybe code write first... but
		// verify()
		// read_index()
		// read_and_process_content(index_data)
		// -> normally we do all of those after one another?

		// former read interaction (read -> process_data_though_importers -> importers_add_to_assets) is weird?
		// -> now do it as it comes in? -> we read by index, so sorted by pass anyway.. just no collecting it first

		// TODO: manage separate bon context (and our own logging hook)

		public class Index
		{
			public List<String> importerNames = new .() ~ DeleteContainerAndItems!(_);
			public List<IndexPass> passes = new .() ~ DeleteContainerAndDisposeItems!(_);
		}

		public struct IndexPass : IDisposable
		{
			public uint8 importerIndex;
			public String importerConfig;
			public List<IndexPassEntry> entries; // Allocate with appropriate capacity

			[Inline]
			public void Dispose()
			{
				DeleteNotNull!(importerConfig);
				Debug.Assert(entries != null);
				DeleteContainerAndDisposeItems!(entries);
			}
		}

		public struct IndexPassEntry : IDisposable
		{
			public String name; // Allocate with appropriate capacity
			public bool isPatched;
			public uint64 offset;
			public uint64 length;
			public uint64 slotSize;

			[Inline]
			public void Dispose()
			{
				Debug.Assert(name != null);
				delete name;
			}
		}

		public struct BuildPass : IDisposable
		{
			public String importer; // Allocate with appropriate capacity
			public String importerConfig;
			public List<BuildPassEntry> entries; // Allocate with appropriate capacity

			public void Dispose()
			{
				Debug.Assert(importer != null);
				delete importer;
				DeleteNotNull!(importerConfig);
				Debug.Assert(entries != null);
				DeleteContainerAndDisposeItems!(entries);
			}
		}

		public struct BuildPassEntry : IDisposable
		{
			public String name; // Allocate with appropriate capacity
			public uint8[] data;

			public void Dispose()
			{
				Debug.Assert(name != null);
				delete name;
				DeleteNotNull!(data);
			}
		}

		enum PackageFlags : uint8
		{
			None = 0,
			Patched = 1
		}

		const int32 MAXCHUNK = int16.MaxValue - 1; // TODO: why? make int32? move ?

		// proposal:
		// writePackage(stream ... list<buildpass>)
		// readPackageHeader(stream) -> headerInfo
		// readPackageIndex(stream) -> index, fileSize
		// readPackageData(stream, indexEntry) -> buildPassEntry?? better name but struct would fit i guess? - you can assemble back a complete buildPass from this
		// patchPackageData(stream, ref indexEntry, buildPassEntry)
		// patchPackageHeader(stream) -> for hash? invalidate it? -- in any case update flags for patched
		// patchPackageIndex(stream, index) -> also patch fileSize!

		// -> this kind of structure forces us to keep CompressionStreams out of most of the structure, we can basically only wrap them around single entries... like data
		//    ... in which case that would be soley PackageManagers job!

		/*public static Result<void> ReadPackage(StringView packagePath, List<IndexPassEntry> nodes, List<String> importerNames, out SHA256Hash contentHash)
		{
			contentHash = .();
			let inPath = Path.Clean(packagePath, .. scope .());

			if (!inPath.EndsWith(".bin"))
				Path.ChangeExtension(inPath, ".bin", inPath);
			
			// Get file
			let fs = scope BufferedFileStream();
			if (fs.Open(inPath, .Open, .Read, .None, 65536) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Error reading file: {err}");

			// HEADER (3 bytes)
			// MODE (1 byte)
			// FILESIZE (4 bytes, uint32)
			// CONTENTHASH (32 bytes)

			// IMPORTERNAMECOUNT (uint32)
			// IMPORTERNAMEARRAY[]
			// 		ELEMENT:
			// 		STRINGSIZE (uint32)
			// 		STRING[]

			// NODECOUNT (uint32)
			// NODEDATAARRAY[]
			//		ELEMENT:
			//		IMPORTERNAMEINDEX (uint32)
			// 		NAMELENGTH (uint32)
			// 		NAMEDATA[]
			// 		DATALENGTH (uint32)
			// 		DATAARRAY[]

			Serializer sr = scope .(fs);

			let header = sr.ReadInto!(scope uint8[4]());
			if (header[0] != 0x50 || header[1] != 0x4C || header[2] != 0x50) // Check file header (currently we ignore "mode" at header[3])
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Invalid file format");

			let size = sr.Read<uint32>(); // File size

			// Read content hash
			sr.ReadInto!(contentHash.mHash);

			// Read file body
			{
				let ds = scope CompressionStream(fs, .Decompress);
				sr.underlyingStream = ds;

				// Read importer names
				let importerNameCount = sr.Read<uint32>();
				for (uint32 i = 0; i < importerNameCount; i++)
				{
					let importerNameLength = sr.Read<uint32>();

					let nameString = new String(importerNameLength)..PrepareBuffer(importerNameLength);
					sr.ReadInto!(Span<uint8>((uint8*)nameString.Ptr, importerNameLength));

					importerNames.Add(nameString);
				}

				// Read nodes
				let nodeCount = sr.Read<uint32>();
				for (uint32 i = 0; i < nodeCount; i++)
				{
					let importerIndex = sr.Read<uint32>();

					let nameLength = sr.Read<uint32>();
					let name = sr.ReadInto!(new uint8[nameLength]);

					let dataLength = sr.Read<uint32>();
					let data = sr.ReadInto!(new uint8[dataLength]);

					nodes.Add(Node(importerIndex, name, data));
				}
			}

			if (sr.HadError)
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Error reading from file");

			// Confirm we read what we put in
			if (size != fs.Position)
				LogErrorReturn!(scope $"Couldn't load package at {inPath}. Invalid file format: The file contains {size} bytes, but the file content ended at {fs.Position}");

			fs.Close(); // We did only read, this should never error.

			return .Ok;
		}

		static Result<void> WritePackage(StringView cPackagePath, List<IndexPassEntry> nodes, List<String> importerNames, SHA256Hash contentHash)
		{
			let outPath = Path.ChangeExtension(cPackagePath, ".bin", .. scope String(cPackagePath));
			let dir = scope String();
			if (Path.GetDirectoryPath(outPath, dir) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error getting directory of path {outPath}");

			if (!Directory.Exists(dir) && (Directory.CreateDirectory(dir) case .Err(let err)))
				LogErrorReturn!(scope $"Couldn't write package. Error creating directory {dir} ({err})");

			let fs = scope BufferedFileStream();
			if (fs.Open(outPath, .Create, .Write, .None, 65536) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error opening stream to {outPath}");

			// HEADER (3 bytes)
			// MODE (1 byte)
			// FILESIZE (4 bytes, uint32)
			// CONTENTHASH (32 bytes)

			// IMPORTERNAMECOUNT (uint32)
			// IMPORTERNAMEARRAY[]
			// 		ELEMENT:
			// 		STRINGSIZE (uint32)
			// 		STRING[]

			// NODECOUNT (uint32)
			// NODEDATAARRAY[]
			//		ELEMENT:
			//		IMPORTERNAMEINDEX (uint32)
			// 		NAMELENGTH (uint32)
			// 		NAMEDATA[]
			// 		DATALENGTH (uint32)
			// 		DATAARRAY[]

			Serializer sr = scope .(fs);

			PackageMode mode = .None;
			sr.Write!(uint8[?](0x50, 0x4C, 0x50, mode.Underlying)); // Header & Mode
			sr.Write<uint32>(0); // Size placeholder

			// Write content hash
			var contentHash;
			let hashSpan = Span<uint8>(&contentHash.mHash[0], contentHash.mHash.Count);
			sr.Write!(hashSpan);

			// Compress this block (main file content)
			{
				let cs = scope CompressionStream(fs, .BEST_SPEED);
				sr.underlyingStream = cs;
	
				// Write importer strings
				sr.Write<uint32>((.)importerNames.Count);
				for (let s in importerNames)
				{
					sr.Write<uint32>((.)s.Length);
					let span = Span<uint8>((uint8*)s.Ptr, s.Length);
					sr.Write!(span);
				}
	
				// Write nodes
				sr.Write<uint32>((.)nodes.Count);
				for (let node in nodes)
				{
					sr.Write<uint32>(node.Importer);
					sr.Write<uint32>((.)node.Name.Count);
					sr.Write!(node.Name);
					sr.Write<uint32>((.)node.Data.Count);
					sr.Write!(node.Data);
				}

				if (cs.Close() case .Err)
					LogErrorReturn!(scope $"Couldn't write package. Error flushing compressionStream into file");
			}

			// Fill in size
			let size = fs.Position;
			fs.Seek(4);

			sr.underlyingStream = fs;
			sr.Write<uint32>((.)size);

			if (sr.HadError)
				LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath}");

			if (fs.Close() case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error writing data to {outPath} when closing stream");

			return .Ok;
		}*/
	}
}
