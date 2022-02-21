using System;
using System.IO;
using Bon;

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
		[BonTarget]
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
		public bool RebuildOnAdditionalChanged => true;

		public Result<void> Load(StringView name, Span<uint8> data)
		{
			ArrayStream s = scope ArrayStream(data);
			Serializer sr = scope Serializer(s);

			let vSource = sr.ReadInto!(scope uint8[sr.Read<uint32>()]);
			let fSource = sr.ReadInto!(scope uint8[sr.Read<uint32>()]);
			uint8[] gSource = null;
			if (s.Position < s.Length)
				gSource = sr.ReadInto!(scope:: uint8[sr.Read<uint32>()]);

			ShaderData asset = new .(.((char8*)&vSource[0], vSource.Count), .((char8*)&fSource[0], fSource.Count), gSource != null ? .((char8*)&gSource[0], gSource.Count) : .());

			if (Importers.SubmitAsset(name, asset) case .Err)
			{
				delete asset;
				return .Err;
			}
			else return .Ok;
		}

		public Result<uint8[]> Build(Stream data, Span<StringView> config, StringView dataFilePath)
		{
			ShaderImportFile f = .();

			String filename = scope .();
			Try!(data.ReadStrSized32(data.Length, filename));

			Try!(Bon.Deserialize<ShaderImportFile>(ref f, filename));

			if (f.vertexPath == null || f.fragmentPath == null)
				LogErrorReturn!("ShaderImporter: At least VertexPath and FragmentPath need to be declared in bon structure");

			// Load the actual files
			let currDir = scope String();
			Try!(Path.GetDirectoryPath(dataFilePath, currDir));

			let vSource = scope String();
			let fSource = scope String();
			String gSource = null;
			{
				Try!(File.ReadAllText(Path.GetAbsolutePath(f.vertexPath, currDir, .. scope .()), vSource, true));
				Try!(File.ReadAllText(Path.GetAbsolutePath(f.fragmentPath, currDir, .. scope .()), fSource, true));
				if (f.geometryPath != null)
				{
					gSource = scope:: String();
					Try!(File.ReadAllText(Path.GetAbsolutePath(f.geometryPath, currDir, .. scope .()), gSource, true));
				}
			}

			// Prepare to slot in
			var neededLength = vSource.Length + fSource.Length + 2 * sizeof(uint32);
			if (gSource != null)
				neededLength += gSource.Length + sizeof(uint32);

			ArrayStream s = scope ArrayStream(neededLength);
			Serializer sr = scope Serializer(s);

			sr.Write<uint32>((.)vSource.Length);
			sr.Write!(Span<uint8>((uint8*)&vSource[0], vSource.Length));

			sr.Write<uint32>((.)fSource.Length);
			sr.Write!(Span<uint8>((uint8*)&fSource[0], fSource.Length));

			if (gSource != null)
			{
				sr.Write<uint32>((.)gSource.Length);
				sr.Write!(Span<uint8>((uint8*)&gSource[0], gSource.Length));
			}

			if (sr.HadError)
				LogErrorReturn!("ShaderImporter: Could not write shader contents to file");

			f.Dispose();
			return s.TakeOwnership();
		}
	}
}
