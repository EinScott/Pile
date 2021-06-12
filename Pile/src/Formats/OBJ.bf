/*
* Ported at 9255172 by EinBurgbauer
* Based on fast_obj (https://github.com/thisistherk/fast_obj) released under the MIT License:
*
* Copyright (c) 2018-2021 Richard Knight
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

using System;
using System.IO;
using System.Collections;

namespace Pile
{
	class OBJ
	{
		public struct TextureData : IDisposable
		{
			public String name;

			public this(StringView nameView)
			{
				name = new .(nameView);
			}

			public void Dispose()
			{
				if (IsEmpty)
					return;

				delete name;
			}

			[Inline]
			public bool IsEmpty => name == null;
		}

		public struct MaterialData : IDisposable
		{
			public String name;

			public Vector3 ambient = .Zero;
			public Vector3 diffuse = .One;
			public Vector3 specular = .Zero;
			public Vector3 emisson = .Zero;
			public Vector3 transmittance = .Zero;
			public float shininess = 1;
			public float indexOfRefraction = 1;
			public Vector3 transmissionFilter = .One;
			public float dissolve = 1; // Alpha
			public int illuminationModel = 1;

			// Only properly initialized when used. Check IsEmpty
			public TextureData ambientMap = default;
			public TextureData diffuseMap = default;
			public TextureData specularMap = default;
			public TextureData emissionMap = default;
			public TextureData transmittanceMap = default;
			public TextureData shininessMap = default;
			public TextureData indexOfRefractionMap = default;
			public TextureData dissolveMap = default;
			public TextureData bumpMap = default;

			public this(StringView nameView)
			{
				name = new .(nameView);
			}

			public void Dispose()
			{
				ambientMap.Dispose();
				diffuseMap.Dispose();
				specularMap.Dispose();
				emissionMap.Dispose();
				transmittanceMap.Dispose();
				shininessMap.Dispose();
				indexOfRefractionMap.Dispose();
				bumpMap.Dispose();

				delete name;
			}
		}

		public struct GroupData : IDisposable
		{
			public String name;

			public uint32 faceCount;
			public uint32 faceOffset;
			public uint32 indexOffset;

			public this() // This is what currGroup will call. Committing groups to the list will call CleanCopy()
			{
				this = default;
				name = new .();
			}

			this(String name, uint32 faceCount, uint32 faceOffset, uint32 indexOffset)
			{
				this.name = name;
				this.faceCount = faceCount;
				this.faceOffset = faceOffset;
				this.indexOffset = indexOffset;
			}

			public GroupData CleanCopy()
			{
				return .(new .(name), faceCount, faceOffset, indexOffset);
			}

			public void Dispose()
			{
				delete name;
			}
		}

		public struct FaceData
		{
			public uint32 vertices;
			public uint32 materialIndex;
		}

		public struct IndexData
		{
			public uint32 positionIndex;
			public uint32 texCoordIndex;
			public uint32 normalIndex;
		}

		// Add a dummy one in each
		public List<Vector3> positions = new .()..Add(.()) ~ delete _;
		public List<Vector2> texCoords = new .()..Add(.()) ~ delete _;
		public List<Vector3> normals = new .()..Add(.()) ~ delete _;

		public List<FaceData> faces = new .() ~ delete _;
		public List<IndexData> indices = new .() ~ delete _; // One element per face vertex

		public List<MaterialData> materials = new .() ~ DeleteContainerAndDisposeItems!(_);
		public List<GroupData> groups = new .() ~ DeleteContainerAndDisposeItems!(_);

		public List<String> mtlFiles = new .() ~ DeleteContainerAndItems!(_); // Contains relative paths

		GroupData currGroup;
		uint32 currMatIndex;
		uint currLine = 0;

		public Result<void> LoadFromDisk(StringView objPath)
		{
			if (!File.Exists(objPath))
				LogErrorReturn!("Couldn't find OBJ file at path");

			let fs = scope FileStream();
			if (fs.Open(objPath) case .Err(let err))
				LogErrorReturn!(scope $"Couldn't open OBJ file for reading: {err}");

			Try!(ParseObj(fs));
			fs.Close();

			// Should probably never error since we know objPath is valid
			let basePath = Path.GetDirectoryPath(objPath, .. scope .());
			for (let mtlFile in mtlFiles)
			{
				let mtlPath = Path.InternalCombine(.. scope .(), basePath, mtlFile);

				if (!File.Exists(mtlPath))
					continue; // This may happen

				if (fs.Open(mtlPath) case .Err(let err))
					LogErrorReturn!(scope $"Couldn't open OBJ file at {mtlPath} for reading: {err}");

				Try!(ParseMtl(fs));
				fs.Close();
			}

			return .Ok;
		}

		public Result<void> ParseObj(Stream stream)
		{
			if (currGroup.name != null)
				LogErrorReturn!("ParseObj can only be called once");

			// Only needs to be valid for the duration of this call
			currGroup = .();
			defer
			{
#unwarn // @do report bug: for some reason the Try! thinks that currGroup isn't accessible				
				[Friend]currGroup.Dispose();
			}

			Try!(ProcessStream(stream, scope => ProcessObjLine));

			// Flush final group
			FlushGroup();

			return .Ok;
		}

		/// After Parsing the Obj file, mtlFiles will be populated with the relative paths of referenced .mtl files.
		/// Checking for their existence and opening them is the callers responsibility. This also means we can just
		/// pass in MemoryStreams etc.
		public Result<void> ParseMtl(Stream stream)
		{
			if (currGroup.name == null)
				LogErrorReturn!("Call ParseObj first");

			return ProcessStream(stream, scope => ProcessMtlLine);
		}

		Result<void> ProcessStream(Stream stream, delegate Result<void>(StringView line) processFunc)
		{
			const int BUF_READ = 512;
			String buf = scope .(BUF_READ); // This should be more than enough for at least one line

			// Streams ReadStrSized32 is waaay too slow for us
			Result<void> ReadStrSized32()
			{
				char8[BUF_READ] charBuf = default;

				if (stream.TryRead(Span<uint8>((uint8*)&charBuf[0], BUF_READ)) case .Ok(let val))
				{
					if (val == 0)
						return .Err;

					buf.Append(StringView(&charBuf[0], val));
				}
				else return .Err;

				return .Ok;
			}

			currLine = 0;
			bool streamEnded = false;
			while (true)
			{
				if (!streamEnded && buf.Length < BUF_READ && ReadStrSized32() case .Err)
					streamEnded = true;
				if (streamEnded && buf.Length == 0) // End when we processed everything still in the buffer too
					break;

				int lineEndIndex = buf.IndexOf('\n');

				if (lineEndIndex == -1)
					continue; // Read more from buffer

				currLine++;
				var line = StringView(&buf[0], lineEndIndex);

				if (line.Length > 0 && line[0].IsWhiteSpace)
					line.TrimStart();
				if (line.Length > 0 && line[line.Length - 1].IsWhiteSpace)
					line.TrimEnd();

				if (line.Length > 0) // Skip empty lines
					Try!(processFunc(line));

				buf.Remove(0, lineEndIndex + 1);
			}

			return .Ok;
		}

		Result<void> ProcessMtlLine(StringView line)
		{
			// line is guaranteed to be at least length 1 and trimmed

			bool firstMtlDeclared = false;

			bool foundDissolve = false;
			MaterialData* material = null;
			switch (line[0])
			{
			case 'n':
				if (line.Length < 8) // newmtl_ + something to process further
					ErrLineEnd!();

				if (line.StartsWith("newmtl") && line[6].IsWhiteSpace)
				{
					if (!firstMtlDeclared)
						firstMtlDeclared = true;

					// Unless the declared material is unused, the material should always already exist
					let name = StringView(&line[7], line.Length - 6);
					if (IndexOfSpace(name) != -1)
						LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: '{name}' cannot include spaces");
					let index = GetOrAddMaterial(name);

					foundDissolve = false;
					material = &materials[index];
				}
				else ErrFormatting!();

			case 'K':
				if (line.Length < 4) // K__ + something to process further
					ErrLineEnd!();
				else if (!firstMtlDeclared || !line[2].IsWhiteSpace)
					ErrFormatting!();

				switch (line[1])
				{
				case 'a':
					material.ambient = Try!(ParseVec3(CleanedSubstr(line, 3)));
				case 'd':
					material.diffuse = Try!(ParseVec3(CleanedSubstr(line, 3)));
				case 's':
					material.specular = Try!(ParseVec3(CleanedSubstr(line, 3)));
				case 'e':
					material.emisson = Try!(ParseVec3(CleanedSubstr(line, 3)));
				case 't':
					material.transmittance = Try!(ParseVec3(CleanedSubstr(line, 3)));
				}

			case 'N':
				if (line.Length < 4) // N__ + something to process further
					ErrLineEnd!();
				else if (!firstMtlDeclared || !line[2].IsWhiteSpace)
					ErrFormatting!();

				switch (line[1])
				{
				case 's':
					material.shininess = Try!(ParseFloat(CleanedSubstr(line, 3)));
				case 'i':
					material.indexOfRefraction = Try!(ParseFloat(CleanedSubstr(line, 3)));
				}

			case 'T':
				if (line.Length < 4) // T__ + something to process further
					ErrLineEnd!();
				else if (!firstMtlDeclared || !line[2].IsWhiteSpace)
					ErrFormatting!();

				switch (line[1])
				{
				case 'r':
					let tr = Try!(ParseFloat(CleanedSubstr(line, 3)));
					if (!foundDissolve)
						material.dissolve = 1.0f - tr;
				case 'f':
					material.transmissionFilter = Try!(ParseVec3(CleanedSubstr(line, 3)));
				}

			case 'd':
				if (line.Length > 3) // d_ + something to process further
					ErrLineEnd!();
				else if (!firstMtlDeclared)
					ErrFormatting!();

				if (line[1].IsWhiteSpace)
				{
					material.dissolve = Try!(ParseFloat(CleanedSubstr(line, 2)));

					foundDissolve = true;
				}
				else ErrFormatting!();

			case 'i':
				if (line.Length < 7) // illum_ + something to process further
					ErrLineEnd!();
				else if (!firstMtlDeclared)
					ErrFormatting!();

				if (line.StartsWith("illum") && line[5].IsWhiteSpace)
					material.illuminationModel = Try!(ParseInt(CleanedSubstr(line, 6)));
				else ErrFormatting!();

			case 'm':
				if (line.Length < 5) // map_ + something to process further
					ErrLineEnd!();
				else if (!firstMtlDeclared)
					ErrFormatting!();

				if (line.StartsWith("map_"))
				{
					switch (line[4])
					{
					case 'K':
						if (line.Length < 8) // map_K__ + something to process further
							ErrLineEnd!();
						else if (!line[6].IsWhiteSpace)
							ErrFormatting!();

						switch (line[5])
						{
						case 'a':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.ambientMap));
						case 'd':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.diffuseMap));
						case 's':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.specularMap));
						case 'e':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.emissionMap));
						case 't':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.transmittanceMap));
						}

					case 'N':
						if (line.Length < 8) // map_N__ + something to process further
							ErrLineEnd!();
						else if (!line[6].IsWhiteSpace)
							ErrFormatting!();

						switch (line[5])
						{
						case 's':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.shininessMap));
						case 'i':
							Try!(ProcessMap(CleanedSubstr(line, 7), ref material.indexOfRefractionMap));
						}

					case 'd':
						if (line.Length < 7) // map_d_ + something to process further
							ErrLineEnd!();

						if (line[5].IsWhiteSpace)
							Try!(ProcessMap(CleanedSubstr(line, 6), ref material.dissolveMap));
						else ErrFormatting!();

					case 'b', 'B':
						if (line.Length < 10) // map_bump_ + something to process further
							ErrLineEnd!();

						if (line[8].IsWhiteSpace && line.StartsWith("map_bump", .OrdinalIgnoreCase))
							Try!(ProcessMap(CleanedSubstr(line, 9), ref material.bumpMap));
						else ErrFormatting!();
					}
				}
				else ErrFormatting!();

			/*case '#':
				break;*/
			}

			return .Ok;
		}

		Result<void> ProcessMap(StringView line, ref TextureData slot)
		{
			if (IndexOfSpace(line) != -1)
				ErrName!(line);

			slot = TextureData(line);
			return .Ok;
		}

		Result<void> ProcessObjLine(StringView line)
		{
			// line is guaranteed to be at least length 1 and trimmed

			switch (line[0])
			{
			case 'v':
				if (line.Length < 2)
					ErrLineEnd!();

				switch (line[1])
				{
				case ' ', '\t':
					if (line.Length < 3) // v_ + something to process further
						ErrLineEnd!();

					Try!(ProcessPosition(CleanedSubstr(line, 2)));

				case 't':
					if (line.Length < 4) // vt_ + something to process further
						ErrLineEnd!();
					else if (!line[2].IsWhiteSpace)
						ErrFormatting!();

					Try!(ProcessTexCoord(CleanedSubstr(line, 3)));

				case 'n':
					if (line.Length < 4) // vn_ + something to process further
						ErrLineEnd!();
					else if (!line[2].IsWhiteSpace)
						ErrFormatting!();

					Try!(ProcessNormal(CleanedSubstr(line, 3)));
				}

			case 'f':
				switch (line[1])
				{
				case ' ', '\t':
					if (line.Length < 3) // v_ + something to process further
						ErrLineEnd!();

					Try!(ProcessFace(CleanedSubstr(line, 2)));
				}

			case 'g':
				switch (line[1])
				{
				case ' ', '\t':
					if (line.Length < 3) // v_ + something to process further
						ErrLineEnd!();

					Try!(ProcessGroup(CleanedSubstr(line, 2)));
				}

			case 'm':
				if (line.Length < 8) // mtllib_ + something to process further
					ErrLineEnd!();

				if (line.StartsWith("mtllib") && line[6].IsWhiteSpace)
					Try!(ProcessMtlLib(CleanedSubstr(line, 7)));
				else ErrFormatting!();

			case 'u':
				if (line.Length < 8)
					ErrLineEnd!();

				if (line.StartsWith("usemtl") && line[6].IsWhiteSpace)
					Try!(ProcessUseMtl(CleanedSubstr(line, 7)));
				else ErrFormatting!();

			/*case '#':
				break;*/
			}

			return .Ok;
		}

		void FlushGroup()
		{
			if (currGroup.faceCount > 0)
				groups.Add(currGroup.CleanCopy());
			
			currGroup.faceCount = 0;
			currGroup.faceOffset = (.)faces.Count;
			currGroup.indexOffset = (.)indices.Count;
		}

		[Inline]
		Result<void> ProcessPosition(StringView line)
		{
			let pos = Try!(ParseVector<const 3>(line));
			positions.Add(.(pos[0], pos[1], pos[2]));
			return .Ok;
		}

		[Inline]
		Result<void> ProcessTexCoord(StringView line)
		{
			let tex = Try!(ParseVector<const 2>(line));
			texCoords.Add(.(tex[0], tex[1]));
			return .Ok;
		}

		[Inline]
		Result<void> ProcessNormal(StringView line)
		{
			let norm = Try!(ParseVector<const 3>(line));
			normals.Add(.(norm[0], norm[1], norm[2]));
			return .Ok;
		}

		[Inline]
		Result<void> ProcessFace(StringView line)
		{
			var line;

			IndexData index;
			uint32 count = 0;

			while (true)
			{
				index = default;

				int sepIndex = IndexOfSpace(line);
				bool lastPart = sepIndex == -1;
				if (lastPart)
					sepIndex = line.Length;

				// Parse part
				int32 v, t = 0, n = 0;
				do
				{
					var part = StringView(&line[0], sepIndex);
					var partSepIndex = part.IndexOf('/');

					Result<int32> ParseCurrInt()
					{
						let parse = StringView(&part[0], partSepIndex == -1 ? part.Length : partSepIndex);

						return ParseInt(parse);
					}

					v = Try!(ParseCurrInt());

					if (partSepIndex == -1)
						break;
					if (part.Length < partSepIndex + 1)
						ErrLineEnd!();

					if (part[partSepIndex + 1] != '/')
					{
						part = part.Substring(partSepIndex + 1);
						partSepIndex = part.IndexOf('/');

						t = Try!(ParseCurrInt());

						part = part.Substring(partSepIndex + 1);
					}
					else
					{
						partSepIndex++;
						part = part.Substring(partSepIndex + 1);
					}

					partSepIndex = part.IndexOf('/');
					n = Try!(ParseCurrInt());
				}

				if (v < 0)
					index.positionIndex = (.)(positions.Count + v);
				else index.positionIndex = (.)v;

				if (t < 0)
					index.texCoordIndex = (.)(positions.Count + t);
				else if (t > 0)
					index.texCoordIndex = (.)t;
				else index.texCoordIndex = 0;

				if (n < 0)
					index.normalIndex = (.)(normals.Count + n);
				else if (n > 0)
					index.normalIndex = (.)n;
				else index.normalIndex = 0;

				indices.Add(index);
				count++;

				if (lastPart)
					break;

				line = line.Substring(sepIndex + 1)..TrimStart();
			}

			faces.Add(FaceData{ vertices = count, materialIndex = currMatIndex });

			currGroup.faceCount++;
			return .Ok;
		}

		[Inline]
		Result<void> ProcessGroup(StringView line)
		{
			if (IndexOfSpace(line) != -1)
				ErrName!(line);

			// Begin new group
			FlushGroup();
			currGroup.name.Set(line);

			return .Ok;
		}

		[Inline]
		Result<void> ProcessUseMtl(StringView line)
		{
			// In this implementation, we actually just take not of mtl files
			// and load them later, so we will always create a placeholder here
			// first that may or may not get replaced

			if (IndexOfSpace(line) != -1)
				ErrName!(line);

			currMatIndex = GetOrAddMaterial(line);

			return .Ok;
		}

		[Inline]
		Result<void> ProcessMtlLib(StringView line)
		{
			mtlFiles.Add(new .(line));
			return .Ok;
		}

		StringView CleanedSubstr(StringView line, int subStrPos)
		{
			var arg = line.Substring(subStrPos);
			if (arg[arg.Length - 1].IsWhiteSpace)
				arg.TrimStart();
			return arg;
		}

		uint32 GetOrAddMaterial(StringView name)
		{
			int ret;
			SEARCH: do
			{
				for (var i < materials.Count)
					if (materials[i].name == name)
					{
						ret = i;
						break SEARCH;
					}

				// Create new
				ret = materials.Count;
				materials.Add(.(name));
			}

			return (.)ret;
		}

		[Inline]
		int IndexOfSpace(StringView view)
		{
			for (let i < view.Length)
				if (view[i] == ' ' || view[i] == '\t') // A \r at the end shouldn't have made it to this point
					return i;

			return -1;
		}

		// @do: typing return with the last backet removed crashes!
		Result<float[TComponents]> ParseVector<TComponents>(StringView line) where TComponents : const int
		{
			var line;

			float[TComponents] pos = ?;
			for (let i < TComponents)
			{
				int sepIndex = ?;
				if (i == TComponents - 1) // Last element uses remaining string
				{
					if (IndexOfSpace(line) != -1)
						LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: '{line}' can only list {TComponents} elements");
					sepIndex = line.Length;
				}
				else
				{
					sepIndex = IndexOfSpace(line);
					if (sepIndex == -1)
						LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: '{line}' must list {TComponents} elements");
				}

				pos[i] = Try!(ParseFloat(StringView(&line[0], sepIndex)));

				if (i < TComponents - 1)
					line = line.Substring(sepIndex + 1)..TrimStart();
			}

			return .Ok(pos);
		}

		Result<Vector3> ParseVec3(StringView line)
		{
			let vec = Try!(ParseVector<const 3>(line));
			return .Ok(.(vec[0], vec[1], vec[2]));
		}

		Result<float> ParseFloat(StringView line)
		{
			let res = float.Parse(line);
			switch (res)
			{
			case .Ok (let num):
				return num;
			case .Err:
				LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: Invalid float value: '{line}'");
			}
		}

		Result<int32> ParseInt(StringView line)
		{
			let res = int32.Parse(line);
			switch (res)
			{
			case .Ok (let num):
				return num;
			case .Err:
				LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: Invalid int value: '{line}'");
			}
		}

		mixin ErrLineEnd()
		{
			LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: Unexpected end of line");
		}

		mixin ErrFormatting()
		{
			LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: Unexpected line formatting");
		}

		mixin ErrName(StringView line)
		{
			LogErrorReturn!(scope $"Error parsing OBJ at line {currLine}: Invalid name '{line}', cannot include spaces");
		}
	}
}
