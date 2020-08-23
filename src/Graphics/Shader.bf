using System;
using System.IO;

namespace Pile
{
	public class Shader
	{
		public class Platform
		{

		}

		readonly Platform platform;

		public this(String vertexShaderPath, String fragmentShaderPath, String geomeryShaderPath = "")
		{
			// possibly integrate this with assets in the future, i mean the files need to be stored somewhere anyway

			var vshSource = scope String();
			var fshSource = scope String();
			var gshSource = scope String();

			Read(vertexShaderPath, vshSource);
			Read(fragmentShaderPath, fshSource);
			Read(geomeryShaderPath, gshSource);

			// more disconnect between shaders and shader program??

			void Read(String path, String source)
			{
				if (!File.Exists(path)) return;

				var sr = scope StreamReader();
				if (sr.Open(path) case .Err(let err))
					Runtime.FatalError("{0}".Format(err));
				if (sr.ReadToEnd(source) case .Err)
					Runtime.FatalError("Error reading shader source file");
			}

			Runtime.Assert(vshSource.Length > 0 && fshSource.Length > 0, "At least vertex and fragment shader must be given");


		}

		public ~this()
		{
			delete platform;
		}

		
	}
}
