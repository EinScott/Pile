namespace System.Collections
{
	extension List<T> where T : String
	{
		public bool Contains(T item, StringComparison comparison)
		{
			if (item == null)
			{
			    for (int i = 0; i < mSize; i++)
			        if (mItems[i] == null)
			    		return true;
			    return false;
			}
			else
			{
				for (int i = 0; i < mSize; i++)
					if (mItems[i].Equals(item, comparison))
						return true;
			    return false;
			}
		}
	}
}
