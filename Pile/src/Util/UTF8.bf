namespace System.Text
{
	extension UTF8
	{
		public static bool DecodeAt(StringView text, ref int currentIndex, ref char32 char)
		{
			// Encoded unicode char
			if (GetDecodedLength(text[currentIndex]) > 1)
			{
				let res = Decode(&text[currentIndex], Math.Min(5, text.Length - currentIndex));
				
				currentIndex += res.length - 1;

				if (res.c == (char32)-1)
					return false; // Invalid

				char = res.c;
			}
			else char = text[currentIndex];

			return true;
		}
	}
}
