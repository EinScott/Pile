namespace System.IO
{
	extension Path
	{
		/// Basic comparison of two paths. Doesn't work with relative paths. Always cares about letter case regardless of file system atm.
		/// However this sees the two directory separator chars as the same thing.
		public static bool SamePath(StringView filePathA, StringView filePathB)
		{
			if (filePathA.Length != filePathB.Length) return false;

			bool matches = true;
			char8* a = filePathA.Ptr;
			char8* b = filePathB.Ptr;

			while (a != filePathA.EndPtr)
			{
				if (*a != *b && !(*a == Path.DirectorySeparatorChar && *b == Path.AltDirectorySeparatorChar || *a == Path.AltDirectorySeparatorChar && *b == Path.DirectorySeparatorChar))
				{
					matches = false;
					break;
				}
				a++;
				b++;
			}

			return matches;
		}

		public static void InternalCombineViews(String target, params StringView[] components)
		{
			for (var component in components)
			{
				if ((target.Length > 0) && (!target.EndsWith("\\")) && (!target.EndsWith("/")))
					target.Append(Path.DirectorySeparatorChar);
				target.Append(component);
			}
		}
	}
}
