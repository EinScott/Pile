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
	static class PackageFormat
	{
		// HEADER (3 bytes)
		// VERSION (1 byte)
		// FLAGS (1 byte) (like patched: which says that this includes dead data and should be rebuild on next proper launch)
		// SOURCE_HASH (32 bytes)
		// INDEX_OFFSET (8 bytes, uint64)

		// CONTENT (?)

		// IMPORTER_ENTRY_COUNT (1 byte, uint8)
		// IMPORTER_ENTRY[]
		//   ENTRY:
		//   IMPORTER_NAME_LENGTH (1 byte, uint8)
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
			public List<IndexPassEntry> entries = new .();

			[Inline]
			public void Dispose()
			{
				DeleteNotNull!(importerConfig);
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

		public enum PackageFlags : uint8
		{
			None = 0,
			Patched = 1
		}

		const uint8 VERSION = 1;

		//const int32 MAXCHUNK = int16.MaxValue - 1; // TODO: why? make int32? move ?

		// TODO:
		// -> so... methods to read the index, do things with it, methods to load some collection of entries
		// patched by either fitting the new data into the old slot (keep it in there as long as possible) or just
		// appending it to the end and updating the index! -- both set the patched flag on file
		// -> hot reload is fast, next full run will clean it up and do a full rebuild (probably nicer for workflow)

		// TODO: compress content!
		// -> this kind of structure forces us to keep CompressionStreams out of most of the structure, we can basically only wrap them around single entries... like data
		//    ... in which case that would be soley PackageManagers job! (maybe? nah do it here)

		public static Result<void> WritePackageFile(StringView outputPath, List<BuildPass> passes, SHA256Hash sourceHash)
		{
			let outPath = Path.ChangeExtension(outputPath, ".bin", .. scope String(outputPath));
			let dir = scope String();
			if (Path.GetDirectoryPath(outPath, dir) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error getting directory of path {outPath}");

			if (!Directory.Exists(dir) && (Directory.CreateDirectory(dir) case .Err(let err)))
				LogErrorReturn!(scope $"Couldn't write package. Error creating directory {dir} ({err})");

			let fs = scope FileStream();
			if (fs.Open(outPath, .Create, .Write, .None, 65536) case .Err)
				LogErrorReturn!(scope $"Couldn't write package. Error opening stream to {outPath}");

			return WritePackage(fs, passes, sourceHash);
		}

		public static Result<void> WritePackage(Stream outStream, List<BuildPass> passes, SHA256Hash sourceHash)
		{
			if (passes.Count == 0)
				LogErrorReturn!("Couldn't write package. No passes");

			Serializer sr = scope .(outStream);

			// Already includes header size!
			uint64 offsetInFile = 5 /* header / version / flags */ + 32 /* sourceHash */ + 8 /* index offset */;

			PackageFlags mode = .None;
			sr.Write!(uint8[?](0x50, 0x4C, 0x50, VERSION, mode.Underlying)); // Header & Version & Flags

			// Write content hash
			var sourceHash;
			let hashSpan = Span<uint8>(&sourceHash.mHash[0], sourceHash.mHash.Count);
			sr.Write!(hashSpan);

			uint64 precomputedIndexOffset = offsetInFile;
			for (let pass in passes)
				for (let entry in pass.entries)
					if (entry.data != null)
						precomputedIndexOffset += (uint64)entry.data.Count;

			sr.Write<uint64>(precomputedIndexOffset);

			// Compute file index to write while dumping content
			Index fileIndex = scope .();

			for (let pass in passes)
			{
				if (pass.entries.Count == 0)
					continue; // Skip empty passes (if they even make it here)

				int importerIndex = fileIndex.importerNames.IndexOf(pass.importer);
				if (importerIndex == -1)
				{
					importerIndex = fileIndex.importerNames.Count;
					fileIndex.importerNames.Add(pass.importer);
				}

				fileIndex.passes.Add(.());
				var indexPass = ref fileIndex.passes.Back;

				if (importerIndex > uint8.MaxValue)
					LogErrorReturn!("Couldn't write package. Too many importers used! (max 256)");
				indexPass.importerIndex = (uint8)importerIndex;
				indexPass.importerConfig = pass.importerConfig != null ? new .(pass.importerConfig) : null;

				for (let entry in pass.entries)
				{
					indexPass.entries.Add(.());
					var indexEntry = ref indexPass.entries.Back;

					indexEntry.name = new .(entry.name);
					indexEntry.offset = offsetInFile;
					indexEntry.length = entry.data == null ? 0 : (uint64)entry.data.Count;

					if (indexEntry.length != 0)
						sr.Write!(entry.data);

					offsetInFile += indexEntry.length;
				}
			}

			Debug.Assert(precomputedIndexOffset == offsetInFile);

			if (sr.HadError)
				LogErrorReturn!("Couldn't write package. Failed to write data (header or content)");

			return WritePackageIndex(outStream, fileIndex, offsetInFile);
		}

		public static Result<void> WritePackageIndex(Stream outStream, Index fileIndex, uint64 fileSizeWithoutIndex)
		{
			Debug.Assert(fileIndex.passes.Count > 0 && fileIndex.importerNames.Count > 0);

			Serializer sr = scope .(outStream);

			var fileSize = fileSizeWithoutIndex;

			if (fileIndex.importerNames.Count > uint8.MaxValue)
				LogErrorReturn!("Couldn't write package. Too many importers used (max 256)");
			sr.Write<uint8>((.)fileIndex.importerNames.Count);
			fileSize += 1;
			for (let importerName in fileIndex.importerNames)
			{
				if (importerName.Length > uint8.MaxValue)
					LogErrorReturn!("Couldn't write package. Importer name too long (max 256 chars)");
				let nameLen = (uint8)importerName.Length;
				sr.Write<uint8>(nameLen);
				sr.Write!(Span<uint8>((.)&importerName[0], nameLen));

				fileSize += 1 + nameLen;
			}

			if (fileIndex.passes.Count > uint8.MaxValue)
				LogErrorReturn!("Couldn't write package. Too many import passes used (max 256)");
			sr.Write<uint8>((.)fileIndex.passes.Count);
			fileSize += 1;
			for (let pass in fileIndex.passes)
			{
				Debug.Assert(pass.importerIndex < fileIndex.importerNames.Count && pass.entries.Count != 0);

				sr.Write<uint8>(pass.importerIndex);

				let configLen = pass.importerConfig == null ? 0 : pass.importerConfig.Length;
				if (configLen > uint16.MaxValue)
					LogErrorReturn!("Couldn't write package. Importer config too long (max 65535 chars)");
				sr.Write<uint16>((.)configLen);
				sr.Write!(Span<uint8>((.)&pass.importerConfig[0], configLen));

				if (pass.entries.Count > uint32.MaxValue)
					LogErrorReturn!("Couldn't write package. Too many pass entries used (max uint32.MaxValue)");
				sr.Write<uint32>((.)pass.entries.Count);

				fileSize += 1 + 2 + (.)configLen + 4;

				for (let entry in pass.entries)
				{
					if (entry.name.Length > uint16.MaxValue & ~0x8000)
						LogErrorReturn!("Couldn't write package. Entry name too long (max 32767 chars)");

					uint16 nameLength = (.)entry.name.Length;
					if (entry.isPatched)
						nameLength |= 0x8000;
					sr.Write<uint16>(nameLength);
					sr.Write!(Span<uint8>((.)&entry.name[0], entry.name.Length));

					sr.Write<uint64>(entry.offset);
					sr.Write<uint64>(entry.length);

					fileSize += 2 + (.)entry.name.Length + 8 + 8;

					if (entry.isPatched)
					{
						sr.Write<uint64>(entry.slotSize);
						fileSize += 8;
					}
				}
			}

			fileSize += 8;
			sr.Write<uint64>(fileSize);

			if (sr.HadError)
				LogErrorReturn!("Couldn't write package. Failed to write data (index)");

			return .Ok;
		}

		public static mixin OpenPackageScoped(StringView packagePath)
		{
			let inPath = Path.Clean(packagePath, .. scope .());
			if (!inPath.EndsWith(".bin"))
				Path.ChangeExtension(inPath, ".bin", inPath);

			let fs = scope:mixin FileStream();
			if (fs.Open(inPath, .Open, .Read, .None, 65536) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't read package. Error opening stream to {inPath}");

			fs
		}

		public static Result<void> ReadPackageHeader(Stream inStream, out PackageFlags flags, out SHA256Hash sourceHash, out uint64 startPosition, out uint64 indexPosition)
		{
			Serializer sr = scope .(inStream);

			startPosition = (.)inStream.Position;
			let header = sr.ReadInto!(scope uint8[5]());
			if (header[0] != 0x50 || header[1] != 0x4C || header[2] != 0x50 || header[3] != VERSION)
			{
				flags = default;
				indexPosition = 0;
				sourceHash = .();
				LogErrorReturn!("Couldn't read package. Invalid file format");
			}
			flags = (.)header[4];

			// Read content hash
			sr.ReadInto!(sourceHash.mHash);

			indexPosition = (.)startPosition + sr.Read<uint64>();

			if (sr.HadError)
				LogErrorReturn!("Couldn't read package. Failed to read data (header)");

			return .Ok;
		}

		public static Result<void> ReadPackageIndex(Stream inStream, uint64 indexPosition, uint64 startPosition, PackageFlags flags, Index fileIndex)
		{
			Serializer sr = scope .(inStream);

			if (indexPosition == 0)
				LogErrorReturn!("Invalid index position");
			Try!(inStream.Seek((.)indexPosition));

			Debug.Assert(fileIndex != null);
			Debug.Assert(fileIndex.importerNames.Count == 0 && fileIndex.passes.Count == 0);

			let importerCount = sr.Read<uint8>();
			for (let i < importerCount)
			{
				let nameLength = sr.Read<uint8>();
				let name = new String(nameLength);
				sr.ReadInto!(Span<uint8>((.)&name[0], nameLength));

				fileIndex.importerNames.Add(name);
			}

			let passCount = sr.Read<uint8>();

			if (importerCount == 0 || passCount == 0)
				LogErrorReturn!("Couldn't read package. Index data corrupt (no passes or importers specified)");

			for (let i < passCount)
			{
				let importerIndex = sr.Read<uint8>();
				let importerConfigLength = sr.Read<uint16>();
				let config = importerConfigLength == 0 ? null : new String(importerConfigLength);
				if (importerConfigLength != 0)
					sr.ReadInto!(Span<uint8>((.)&config[0], importerConfigLength));
				let entryCount = sr.Read<uint32>();

				if (importerIndex > importerCount || entryCount == 0)
					LogErrorReturn!("Couldn't read package. Index data corrupt (invalid pass data / no entries)");

				fileIndex.passes.Add(.());
				var indexPass = ref fileIndex.passes.Back;
				indexPass.importerIndex = importerIndex;
				indexPass.importerConfig = config;
				
				for (let j < entryCount)
				{
					var entry = IndexPassEntry();

					let nameLengthAndPatchedFlag = sr.Read<uint16>();
					entry.isPatched = (nameLengthAndPatchedFlag & 0x8000) == 0x8000;
					let nameLength = nameLengthAndPatchedFlag & ~0x8000;

					if (nameLength == 0 || entry.isPatched && !flags.HasFlag(.Patched))
						LogErrorReturn!("Couldn't read package. Index data corrupt (invalid entry)");

					let name = new String(nameLength);
					sr.ReadInto!(Span<uint8>((.)&name[0], nameLength));
					entry.name = name;

					entry.offset = sr.Read<uint64>();
					entry.length = sr.Read<uint64>();
					if (entry.isPatched)
						entry.slotSize = sr.Read<uint64>();

					if (startPosition + entry.offset + entry.length > indexPosition
						|| startPosition + entry.offset + entry.slotSize > indexPosition)
					{
						delete name;
						LogErrorReturn!("Couldn't read package. Index data corrupt (invalid entry reference)");
					}

					indexPass.entries.Add(entry);
				}
			}

			let size = sr.Read<uint64>(); // File size
			if (size != (.)inStream.Position - startPosition)
				LogErrorReturn!("Couldn't read package. File size miss-match");

			if (sr.HadError)
				LogErrorReturn!("Couldn't read package. Failed to read data (index)");

			return .Ok;
		}

		public static Result<void> ReadPackageData(Stream inStream, uint64 startPosition, IndexPassEntry entry, List<uint8> buffer)
		{
			Try!(inStream.Seek((.)startPosition + (.)entry.offset));

			if (entry.length > (.)buffer.Count)
			{
				let addSize = entry.length - (.)buffer.Count;
				buffer.GrowUnitialized((.)addSize);
			}
			else buffer.Count = (.)entry.length;

			Debug.Assert(entry.length == (.)buffer.Count);

			Serializer sr = scope .(inStream);
			sr.ReadInto!(buffer);

			if (sr.HadError)
				LogErrorReturn!("Couldn't read package. Failed to read data (content entry)");

			return .Ok;
		}

		public static Result<void> PatchPackageData(Stream inStream, BuildPassEntry patchEntry, uint64 indexPosition, Index fileIndex, out uint64 appendSize)
		{
			// TODO: When we need to append, we need to put the index back with this offset and also change that in the header
			appendSize = 0;

			return .Err;
		}

		public static Result<void> PatchPackageHeader(Stream inStream, uint64 startPosition, uint64 indexPushedBackBy, SHA256Hash sourceHash)
		{
			// TOOD: change flags to Patched, modify index offse maybe, override sourceHash

			return .Err;
		}
	}
}
