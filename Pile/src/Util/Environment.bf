using System.Collections;

namespace System
{
	extension Environment
	{
		public static bool GetEnvironmentVariable(String key, String outString)
		{
			let dict = new Dictionary<String, String>();
			defer
			{
				DeleteDictionaryAndKeysAndValues!(dict);
			}

			Environment.GetEnvironmentVariables(dict);
			if (!dict.ContainsKey(key)) return false;

			outString.Append(dict[key]);

			return true;
		}
	}
}
