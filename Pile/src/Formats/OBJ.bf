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
			public String name = new .(16);
			public String path = new .(32);

			public void Dispose()
			{
				delete name;
				delete path;
			}
		}

		public struct MaterialData : IDisposable
		{
			public String name = new .(16);

			public Vector3 ambient;
			public Vector3 diffuse;
			public Vector3 specular;
			public Vector3 emisson;
			public Vector3 transmittance;
			public float shininess;
			public float indexOfRefraction;
			public Vector3 transmissionFilter;
			public float dissolve; // Alpha
			public int illuminationModel;

			public TextureData ambientMap;
			public TextureData diffuseMap;
			public TextureData specularMap;
			public TextureData emissionMap;
			public TextureData transmittanceMap;
			public TextureData shininessMap;
			public TextureData refractionMap;
			public TextureData dissolveMap;
			public TextureData bumpMap;

			public void Dispose()
			{
				ambientMap.Dispose();
				diffuseMap.Dispose();
				specularMap.Dispose();
				emissionMap.Dispose();
				transmittanceMap.Dispose();
				shininessMap.Dispose();
				refractionMap.Dispose();
				bumpMap.Dispose();

				delete name;
			}
		}

		public struct GroupData : IDisposable
		{
			public String name = new .(16);

			public uint32 faceCount;
			public uint32 faceOffset;
			public uint32 indexOffset;

			public void Dispose()
			{
				delete name;
			}
		}

		/*public struct VertexData
		{
			public Vector3 position; // prev float
			public Vector2 texCoord;
			public Vector3 normal;
		}*/

		public struct FaceData
		{
			public uint32 vertices;
			public uint32 materials;
		}

		public struct IndexData
		{
			public uint32 p; // @do what are these?
			public uint32 t;
			public uint32 n;
		}

		// @do: put back into struct? could have nextPosIndex etc for all 3 ??
		public List<Vector3> positions = new .() ~ delete _;
		public List<Vector2> texCoords = new .() ~ delete _;
		public List<Vector3> normals = new .() ~ delete _;

		public List<FaceData> faces = new .() ~ delete _;
		public List<IndexData> indices = new .() ~ delete _; // One element per face vertex

		public List<MaterialData> materials = new .() ~ DeleteContainerAndDisposeItems!(_);
		public List<GroupData> groups = new .() ~ DeleteContainerAndDisposeItems!(_);

		public List<String> mtlFiles = new .() ~ DeleteContainerAndItems!(_); // Contains relative paths
		GroupData currGroup = default;
		uint32 nextMatIndex = 0;
		uint currLine = 0;

		public Result<void> ParseObj(Stream stream)
		{
			const int BUF_READ = 512;
			String buf = scope .(BUF_READ); // This should be more than enough for at least one line

			defer
			{
				if (@return == .Err && [Friend]currGroup.name != null)
				{
#unwarn // @do This is a bug where somehow the the Try!(ProcessLine()) doesn't work due to currGroup being "inaccessible"
					[Friend]currGroup.Dispose();
				}
			}

			bool streamEnded = false;
			while (true)
			{
				if (!streamEnded && buf.Length < BUF_READ && stream.ReadStrSized32(BUF_READ, buf) case .Err)
					streamEnded = true;
				if (streamEnded && buf.Length == 0) // End when we processed everyhing still in the buffer too
					break;

				int lineEndIndex = buf.IndexOf('\n');

				if (lineEndIndex == -1)
					continue; // Read more from buffer

				let line = StringView(&buf[0], lineEndIndex)..Trim();

				if (line.Length > 0) // Skip empty lines
					Try!(ProcessLine(line));

				buf.Remove(0, lineEndIndex + 1);
			}

			return .Ok;
		}

		[Inline]
		Result<void> ProcessLine(StringView line)
		{
			// Guaranteed to be at least length 1 and trimmed

			switch (line[0])
			{
			case 'v':
				if (line.Length < 2)
					return .Err;

				switch (line[1])
				{
				case ' ', '\t':
					if (line.Length < 3) // v_ + something to process further
						return .Err;

					Try!(ProcessPosition(line.Substring(2)..TrimStart()));

				case 't':
					if (line.Length < 4 && line[2].IsWhiteSpace) // vt_ + something to process further
						return .Err;

					Try!(ProcessTexCoord(line.Substring(3)..TrimStart()));

				case 'n':
					if (line.Length < 4 && line[2].IsWhiteSpace) // vn_ + something to process further
						return .Err;

					Try!(ProcessNormal(line.Substring(3)..TrimStart()));
				}

			case 'f':
				switch (line[1])
				{
				case ' ', '\t':
					if (line.Length < 3) // v_ + something to process further
						return .Err;

					Try!(ProcessFace(line.Substring(2)..TrimStart()));
				}

			case 'g':
				switch (line[1])
				{
				case ' ', '\t':
					if (line.Length < 3) // v_ + something to process further
						return .Err;

					Try!(ProcessGroup(line.Substring(2)..TrimStart()));
				}

			case 'm':
				if (line.Length < 8) // mtllib_ + something to process further
					return .Err;

				if (line.StartsWith("mtllib") && line[6].IsWhiteSpace)
					Try!(ProcessMtlLib(line.Substring(7)..TrimStart()));

			case 'u':
				if (line.Length < 8)
					return .Err;

				if (line.StartsWith("usemtl") && line[6].IsWhiteSpace)
					Try!(ProcessUseMtl(line.Substring(7)..TrimStart()));

			/*case '#':
				break;*/
			}

			return .Ok;
		}

		/// After Parsing the Obj file, mtlFiles will be populated with the relative paths of referenced .mtl files.
		/// Checking for their existence and opening them is the callers responsibility. This also means we can just
		/// pass in MemoryStreams etc.
		public Result<void> ParseMtl(Stream stream)
		{
			return .Ok;
		}

		[Inline]
		Result<void> ProcessPosition(StringView line)
		{
			let pos = Try!(ProcessVector<const 3>(line));
			positions.Add(.(pos[0], pos[1], pos[2]));
			return .Ok;
		}

		[Inline]
		Result<void> ProcessTexCoord(StringView line)
		{
			let tex = Try!(ProcessVector<const 2>(line));
			texCoords.Add(.(tex[0], tex[1]));
			return .Ok;
		}

		[Inline]
		Result<void> ProcessNormal(StringView line)
		{
			let norm = Try!(ProcessVector<const 3>(line));
			normals.Add(.(norm[0], norm[1], norm[2]));
			return .Ok;
		}

		[Inline]
		Result<void> ProcessFace(StringView line)
		{


			return .Ok;
		}

		[Inline]
		Result<void> ProcessGroup(StringView line)
		{
			return .Ok;
		}

		[Inline]
		Result<void> ProcessMtlLib(StringView line)
		{
			return .Ok; // Ignore for now
		}

		[Inline]
		Result<void> ProcessUseMtl(StringView line)
		{
			return .Ok;
		}

		[Inline]
		int IndexOfSpace(StringView view)
		{
			for (let i < view.Length)
				if (view[i] == ' ' || view[i] == '\t') // A \r at the end shouldnt have made it to this point
					return i;

			return -1;
		}

		// @do: typing return with the last backet removed crashes!
		Result<float[TComponents]> ProcessVector<TComponents>(StringView line) where TComponents : const int
		{
			var line;

			float[TComponents] pos = ?;
			for (let i < TComponents)
			{
				int sepIndex = ?;
				if (i == TComponents - 1) // Last element uses remaining string
					sepIndex = line.Length;
				else
				{
					sepIndex = IndexOfSpace(line);
					if (sepIndex == -1)
						return .Err;
				}

				let num = Try!(float.Parse(StringView(&line[0], sepIndex)));
				pos[i] = num;

				if (i < TComponents - 1)
					line = line.Substring(sepIndex + 1)..TrimStart();
			}

			return .Ok(pos);
		}
	}
}
