using System;

namespace FreeType
{
	public class Library;

	public enum FreeTypeResult : int32
	{
		// ...
	}

	public static class FreeType
	{
		[LinkName("FT_Init_FreeType")]
		public static extern FreeTypeResult Init(out Library* library);

		[LinkName("FT_Done_FreeType")]
		public static extern FreeTypeResult Done(Library* library);
	}
}
