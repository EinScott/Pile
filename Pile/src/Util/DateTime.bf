namespace System
{
	extension DateTime
	{
		public int64 UnixTimestamp => (int64)this.Subtract(DateTime(1970, 1, 1)).TotalSeconds;
	}
}
