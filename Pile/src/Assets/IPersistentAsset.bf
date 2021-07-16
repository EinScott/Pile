using System;

namespace Pile
{
	interface IPersistentAsset<TDataAsset> where TDataAsset : class
	{
		public bool IsSetup { [Inline]get; }
		public Result<void> Reset(TDataAsset data);
	}
}
