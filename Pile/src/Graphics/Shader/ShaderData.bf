using System;
using System.Diagnostics;

namespace Pile
{
	class ShaderData
	{
		public String vertexSource = new .() ~ delete _;
		public String fragmentSource = new .() ~ delete _;
		public String geometrySource = new .() ~ delete _;

		public this(StringView vertexShader, StringView fragmentShader, StringView geometryShader = .())
		{
			Debug.Assert(vertexShader.Ptr != null && fragmentShader.Ptr != null);

			vertexSource.Set(vertexShader);
			fragmentSource.Set(fragmentShader);

			if (geometryShader.Ptr != null)
				geometrySource.Set(geometryShader);
		}
	}
}
