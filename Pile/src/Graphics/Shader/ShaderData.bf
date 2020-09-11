using System;
using System.IO;

namespace Pile
{
	public class ShaderData
	{
		public String vertexSource = new .() ~ delete _;
		public String fragmentSource = new .() ~ delete _;
		public String geometrySource = new .() ~ delete _;

		public this(StringView vertexShaderPath, StringView fragmentShaderPath, StringView geomeryShaderPath = "")
		{
			// possibly integrate this with assets in the future, i mean the files need to be stored somewhere anyway

			Read(vertexShaderPath, vertexSource);
			Read(fragmentShaderPath, fragmentSource);
			Read(geomeryShaderPath, geometrySource);

			void Read(StringView path, String source)
			{
				if (!Core.System.FileExists(path))
				{
					// Log this if it doesn't seem to be intentional (empty path). If thats also wrong someone else will complain
					if (path.Length != 0) Log.Warning(scope String("Shader source file at {0} does not exist")..Format(path));
					return;
				}

				switch (Core.System.FileReadAllText(path, source, true))
				{
				case .Err(let err):
					if (err case .FileOpenError(let openErr))
						Runtime.FatalError(scope String("Error opening shader source file: {0}")..Format(err));
					else
						Runtime.FatalError("Error reading shader source file");
				case .Ok:
				}
			}

			Runtime.Assert(vertexSource.Length > 0 && fragmentSource.Length > 0, "At least vertex and fragment shader must be given");
		}
	}
}
