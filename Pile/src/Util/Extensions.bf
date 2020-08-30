using System;

namespace Pile
{
	static
	{
		public static void Format(this String format, params Object[] insertions) // THIS is missing here
		{
			var findString = scope String(4); // No one will probably ever exceed two digit numbers here... hopefully
			var insertBuf = scope String();

			for (int32 i = 0; i < insertions.Count; i++)
			{
				// FindString construction for i
				findString.Append('{');
				i.ToString(findString);
				findString.Append('}');

				// InsertBuf construction for insert
				insertions[i].ToString(insertBuf);

				// Look for findString
				format.Replace(findString, insertBuf);

				findString.Clear();
				insertBuf.Clear();
			}
		}
	}
}