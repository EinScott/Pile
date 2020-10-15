using System;

namespace Pile
{
	public class ShaderData
	{
		// Source will be graphics platform specific
		public String vertexSource = new .() ~ delete _;
		public String fragmentSource = new .() ~ delete _;
		public String geometrySource = new .() ~ delete _;

		public this(StringView vertexShader, StringView fragmentShader, StringView geometryShader = "")
		{
			vertexSource.Set(vertexShader);
			fragmentSource.Set(fragmentShader);
			geometrySource.Set(geometryShader);
		}
	}
}
