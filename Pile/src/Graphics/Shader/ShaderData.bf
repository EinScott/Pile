using System;

namespace Pile
{
	public class ShaderData
	{
		// TODO: may need to be redone when doing other graphics platforms, very gl specific atm
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
