namespace System.IO
{
	extension Path
	{
		public static void Clean(StringView inPath, String cleanPath)
		{
			let cleaned = scope String(inPath);
			cleaned.Replace(AltDirectorySeparatorChar, DirectorySeparatorChar);
			if (cleaned.EndsWith(DirectorySeparatorChar))
				cleaned.RemoveFromEnd(1);

			cleanPath.Append(cleaned);
		}

		/// This will modify on given string
		public static void Clean(String cleanPath)
		{
			cleanPath.Replace(AltDirectorySeparatorChar, DirectorySeparatorChar);
			if (cleanPath.EndsWith(DirectorySeparatorChar))
				cleanPath.RemoveFromEnd(1);
		}

		/// Will force the path to forward slashes
		/// This will modify on given string
		public static void Unify(String unifyPath)
		{
			unifyPath.Replace('\\', '/');
			if (unifyPath.EndsWith('/'))
				unifyPath.RemoveFromEnd(1);
		}
	}
}
