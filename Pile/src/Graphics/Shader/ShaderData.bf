using System;

namespace Pile
{
	class ShaderData
	{
		public String vertexSource = new .() ~ delete _;
		public String fragmentSource = new .() ~ delete _;
		public String geometrySource = new .() ~ delete _;

		public this(StringView vertexShader, StringView fragmentShader, StringView geometryShader = String.Empty)
		{
			vertexSource.Set(vertexShader);
			fragmentSource.Set(fragmentShader);
			geometrySource.Set(geometryShader);
		}
	}
}
