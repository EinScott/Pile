using System;
using System.IO;
using Atma;

namespace Pile
{
	/**
	This thing loads a json file like this:
	{
		"vertexPath": "default.vs",
		"fragmentPath": "default.fs"
	}

	The geometry shader is optional.
	The paths are relative to the json files dir
	*/
	[RegisterImporter]
	class ShaderDataImporter : Importer
	{
		[Serializable]
		struct ShaderImportFile : IDisposable
		{
			public String vertexPath;
			public String fragmentPath;
			public String geometryPath;

			public void Dispose()
			{
				DeleteNotNull!(vertexPath);
				DeleteNotNull!(fragmentPath);
				DeleteNotNull!(geometryPath);
			}
		}

		public String Name => "shader";

		public Result<void> Load(StringView name, Span<uint8> data)
		{
			let vLen = (((uint32)data[0]) << 24) | (((uint32)data[1]) << 16) | (((uint32)data[2]) << 8) | ((uint32)data[3]);
			let fLen = (((uint32)data[4 + vLen]) << 24) | (((uint32)data[5 + vLen]) << 16) | (((uint32)data[6 + vLen]) << 8) | ((uint32)data[7 + vLen]);
			var gLen = 0;
			if (vLen + fLen + 2 * sizeof(uint32) > data.Length)
				gLen = (((uint32)data[8 + vLen + fLen]) << 24) | (((uint32)data[9 + vLen + fLen]) << 16) | (((uint32)data[10 + vLen + fLen]) << 8) | ((uint32)data[11 + vLen + fLen]);

			ShaderData sData = new .(.((char8*)&data[4], vLen), .((char8*)&data[8 + vLen], fLen), gLen == 0 ? .() : .((char8*)&data[12 + vLen + fLen], gLen));
			Importers.SubmitAsset(name, sData);

			return .Ok;
		}

		public Result<uint8[]> Build(Span<uint8> data, Span<StringView> config, StringView dataFilePath)
		{
			ShaderImportFile f = .();

			Try!(JsonConvert.Deserialize<ShaderImportFile>(&f, StringView((char8*)data.Ptr, data.Length)));

			if (f.vertexPath == null || f.fragmentPath == null)
				LogErrorReturn!("At least VertexPath and FragmentPath need to be declared in json structure");

			// Load the actual files
			let currDir = Path.GetDirectoryPath(dataFilePath, .. scope .());

			let vSource = File.ReadAllText(Path.GetAbsolutePath(f.vertexPath, currDir, .. scope .()), .. scope .(), true);
			let fSource = File.ReadAllText(Path.GetAbsolutePath(f.fragmentPath, currDir, .. scope .()), .. scope .(), true);
			String gSource = null;
			if (f.geometryPath != null)
			{
				gSource = File.ReadAllText(Path.GetAbsolutePath(f.geometryPath, currDir, .. scope .()), .. scope .(), true);
			}

			// todo: this could be nicer; rewrite when redoing packagefiles and passing streams to here

			// Prepare to slot in
			var neededLength = vSource.Length + fSource.Length + 2 * sizeof(uint32);
			if (gSource != null)
				neededLength += gSource.Length + sizeof(uint32);

			let outData = new uint8[neededLength];

			outData[0] = (uint8)((vSource.Length >> 24) & 0xFF);
			outData[1] = (uint8)((vSource.Length >> 16) & 0xFF);
			outData[2] = (uint8)((vSource.Length >> 8) & 0xFF);
			outData[3] = (uint8)(vSource.Length & 0xFF);

			Internal.MemCpy(&outData[4], &vSource[0], vSource.Length);

			outData[4 + vSource.Length] = (uint8)((fSource.Length >> 24) & 0xFF);
			outData[5 + vSource.Length] = (uint8)((fSource.Length >> 16) & 0xFF);
			outData[6 + vSource.Length] = (uint8)((fSource.Length >> 8) & 0xFF);
			outData[7 + vSource.Length] = (uint8)(fSource.Length & 0xFF);

			Internal.MemCpy(&outData[8 + vSource.Length], &fSource[0], fSource.Length);

			if (gSource != null)
			{
				outData[8 + vSource.Length + fSource.Length] = (uint8)((gSource.Length >> 24) & 0xFF);
				outData[9 + vSource.Length + fSource.Length] = (uint8)((gSource.Length >> 16) & 0xFF);
				outData[10 + vSource.Length + fSource.Length] = (uint8)((gSource.Length >> 8) & 0xFF);
				outData[11 + vSource.Length + fSource.Length] = (uint8)(gSource.Length & 0xFF);

				Internal.MemCpy(&outData[12 + vSource.Length + fSource.Length], &gSource[0], gSource.Length);
			}

			f.Dispose();
			return outData;
		}
	}
}
