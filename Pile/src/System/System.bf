using System;
using System.IO;

namespace Pile
{
	public abstract class System
	{
		public abstract String ApiName { get; }

		public ~this()
		{
			delete DataPath;
		}

		protected virtual void DetermineDataPath()
		{
			String exePath = scope .();
			Environment.GetExecutableFilePath(exePath);
			String exeDir = new .();
			Path.GetDirectoryPath(exePath, exeDir);
			DataPath = exeDir;

			Directory.SetCurrentDirectory(DataPath);

			//switch(Environment.OSVersion.Platform)
		}

		protected abstract Input CreateInput();
		protected abstract Window CreateWindow(int32 width, int32 height);

		protected abstract void Initialize();
		protected abstract void Update();

		public String DataPath { get; private set; }
	}
}
