using System;

namespace Pile
{
	interface IPersistentAsset<TDataAsset> where TDataAsset : class
	{
		public Result<void> Reset(TDataAsset data);
	}
}
