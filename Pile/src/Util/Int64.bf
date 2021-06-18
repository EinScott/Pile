using System.Globalization;

namespace System
{
	// fix for non hex numbers

	extension Int64
	{
		public static new Result<int64, ParseError> Parse(StringView val, NumberStyles style)
		{
			if (val.IsEmpty)
				return .Err(.NoValue);

			bool isNeg = false;
			int64 result = 0;

			int64 radix = style.HasFlag(.AllowHexSpecifier) ? 0x10 : 10;

			for (int32 i = 0; i < val.Length; i++)
			{
				char8 c = val[i];

				if ((i == 0) && (c == '-'))
				{
					isNeg = true;
					continue;
				}

				if ((c >= '0') && (c <= '9'))
				{
					result *= radix;
					result += (int32)(c - '0');
				}
				else if (c == '\'')
				{
					// Ignore
				}
				else
				{
					if (style.HasFlag(.AllowHexSpecifier))
					{
						if ((c >= 'a') && (c <= 'f'))
						{
							result *= radix;
							result += c - 'a' + 10;
							continue;
						}
						else if ((c >= 'A') && (c <= 'F'))
						{
							result *= radix;
							result += c - 'A' + 10;
							continue;
						}
						else if ((c == 'X') || (c == 'x'))
						{
							if (result != 0)
								return .Err(.InvalidChar(result));
							radix = 0x10;
							continue;
						}
					}

					return .Err(.InvalidChar(result));
				}
			}

			return isNeg ? -result : result;
		}
	}
}
