using System;

namespace Pile
{
	static
	{
		public static void DoStuff()
		{
			// /*
			var s = scope String("{0} things");
			s.Format(3);
			Log.Message(s); 															// insertions.Count: 0, outputs: {0} things

			Log.Message(scope String("{0} things").Format(scope int[1] {3}));						// insertions.Count: 1, outputs: 3 things
			Log.Message(scope String("many {0} {0}, {0}").Format(3, 5));				// insertions.Count: 1, outputs: many 3 3, 3
			Log.Message(scope String("many {0} {1} {2}").Format(3, 5));					// insertions.Count: 1, outputs: many 3 {1} {2}
			Log.Message(scope String("many {0} {1} {2}").Format(3, "hi", 6));			// insertions.Count: 2, outputs: many 3 hi {2}
			Log.Message(scope String("many {0} {1} {2}").Format(3, "hi", -3, 4));		// insertions.Count: 3, outputs: many 3 hi -3
			// */

			/*
			var s = scope String("{0} things"); // Test for when "this" is removed from method declaration
			Log.Message(Format(s, 2));
			*/
		}

		public static String Format(this String format, params Object[] insertions) // Removing the "this" seems to fix it. Is it not counting the first argument when it is an extension method because of 'format'?
		{
			var findString = scope String(4); // No one will probably ever exceed two digit numbers here... hopefully
			var insertBuf = scope String();

			Log.Message(insertions.Count);

			for (int32 i = 0; i < insertions.Count; i++) // Setting this to "for (int32 i = 0; i <= insertions.Count; i++)" will result in "out of range" as expected
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

			return format; // Do this so we can make one-liners => scope String("{0} is {1}").Format(a_value, b_value)
		}
	}
}
