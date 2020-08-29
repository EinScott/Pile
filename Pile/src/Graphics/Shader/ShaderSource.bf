using System;
using System.IO;

namespace Pile
{
	public class ShaderSource
	{
		public String vertexSource = new .() ~ delete _;
		public String fragmentSource = new .() ~ delete _;
		public String geometrySource = new .() ~ delete _;

		public this(String vertexShaderPath, String fragmentShaderPath, String geomeryShaderPath = "")
		{
			// possibly integrate this with assets in the future, i mean the files need to be stored somewhere anyway

			Read(vertexShaderPath, vertexSource);
			Read(fragmentShaderPath, fragmentSource);
			Read(geomeryShaderPath, geometrySource);

			void Read(String path, String source)
			{
				if (!File.Exists(path))
				{
					if (!String.IsNullOrEmpty(path)) Log.Warning(scope String("Shader source file at {0} does not exist").Format(path));
					return;
				}

				var sr = scope StreamReader();
				if (sr.Open(path) case .Err(let err))
					Runtime.FatalError(scope String("Error opening shader source file: {0}")..Format(err));
				if (sr.ReadToEnd(source) case .Err)
					Runtime.FatalError("Error reading shader source file");

				sr.Dispose();
			}

			Runtime.Assert(vertexSource.Length > 0 && fragmentSource.Length > 0, "At least vertex and fragment shader must be given");
		}
	}
}
