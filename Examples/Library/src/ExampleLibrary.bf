using Pile;
using System;

namespace Dimtoo
{
	static
	{
		static this()
		{
			// Tell Pile that this library provides assets to be included in game builds!
			Packager.AddAssetPathForThisProject();
		}
	}
}