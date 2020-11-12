using System;

namespace Pile
{
	public class ShaderData
	{
		// TODO: may need to be redone when doing other graphics platforms, very gl specific atm
		// Source will be graphics platform specific
		// consider adding a second call to the packager to build some platform specific shader package for each platform build config
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
