using System;
using System.IO;

namespace Pile
{
	public enum FileResult : int32
	{
		Ok						= (int32)Platform.BfpFileResult.Ok,
		NoResults				= (int32)Platform.BfpFileResult.NoResults,
		UnknownError			= (int32)Platform.BfpFileResult.UnknownError,
		InvalidParameter		= (int32)Platform.BfpFileResult.InvalidParameter,
		Locked					= (int32)Platform.BfpFileResult.Locked,
		AlreadyExists			= (int32)Platform.BfpFileResult.AlreadyExists,
		NotFound				= (int32)Platform.BfpFileResult.NotFound,
		ShareError				= (int32)Platform.BfpFileResult.ShareError,
		AccessError				= (int32)Platform.BfpFileResult.AccessError,
		PartialData				= (int32)Platform.BfpFileResult.PartialData,
		InsufficientBuffer		= (int32)Platform.BfpFileResult.InsufficientBuffer,
		NotEmpty				= (int32)Platform.BfpFileResult.NotEmpty
	}

	public enum EnumerateFlags
	{
		Files = 1,
		Directories = 2
	}

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

			//switch(Environment.OSVersion.Platform)
		}

		protected abstract Input CreateInput();
		protected abstract Window CreateWindow(int32 width, int32 height);

		protected abstract void Initialize();
		protected abstract void Update();

		public String DataPath { get; private set; }

		// Wrap io

		public virtual bool FileExists(StringView path) => File.Exists(path);
		public virtual Result<void, FileResult> FileDelete(StringView path) => HandleBfpFileOperation(File.Delete(path));
		public virtual Result<void, FileResult> FileMove(StringView fromPath, StringView toPath) => HandleBfpFileOperation(File.Move(fromPath, toPath));
		public virtual Result<void, FileResult> FileCopy(StringView fromPath, StringView toPath, bool overwrite = true) => HandleBfpFileOperation(File.Copy(fromPath, toPath, overwrite));

		public virtual Result<void, FileError> FileReadAllText(StringView path, String outText, bool preserveLineEnding = false) => File.ReadAllText(path, outText, preserveLineEnding);
		public virtual Result<void> FileWriteAllText(StringView path, StringView text, bool doAppend = false) => File.WriteAllText(path, text, doAppend);
		public virtual Result<void> FileWriteAllText(StringView path, StringView text, System.Text.Encoding encoding) => File.WriteAllText(path, text, encoding);

		public virtual Result<uint8[], FileError> FileReadAllBytes(StringView path)
		{
			FileStream s = scope FileStream();
			if (s.Open(path) case .Err(let err))
				return .Err(.FileOpenError(err));
			let outData = new uint8[(.)s.Length];
			if (s.TryRead(outData) case .Err)
				return .Err(.FileReadError(.Unknown));

			return .Ok(outData);
		}
		public virtual Result<void> FileWriteAllBytes(StringView path, Span<uint8> data)
		{
			FileStream fs = scope FileStream();
			var result = fs.Open(path, .Create, .Write);
			if (result case .Err)
				return .Err;
			fs.TryWrite(data);
			return .Ok;
		}

		public virtual Result<DateTime> FileGetWriteTime(StringView path, bool utc = false) => utc ? File.GetLastWriteTimeUtc(path) : File.GetLastWriteTime(path);

		public virtual bool DirectoryExists(StringView path) => Directory.Exists(path);
		public virtual Result<void, FileResult> DirectoryDelete(StringView path) => HandleBfpFileOperation(Directory.Delete(path));
		public virtual Result<void, FileResult> DirectoryMove(StringView fromPath, StringView toPath) => HandleBfpFileOperation(Directory.Move(fromPath, toPath));
		public virtual Result<void, FileResult> DirectoryCreate(StringView path) => HandleBfpFileOperation(Directory.CreateDirectory(path));

		// TODO: File enumerator abstraction, is currently tied to beefplatform
		public virtual FileEnumerator DirectoryEnumerate(StringView searchPath, EnumerateFlags flags)
		{
			// Combine
			let searchStr = scope String(searchPath);

			// Make sure its actually searching for something
			if (searchStr.EndsWith(Path.DirectorySeparatorChar) || searchStr.EndsWith(Path.AltDirectorySeparatorChar))
				searchStr.Append("*");

			// This is slightly ugly, but Directory.EnumerateFlags is not public and thus i can't cast it
			if (!flags.HasFlag(.Directories))
				return Directory.Enumerate(searchStr, .Files);
			else if (!flags.HasFlag(.Files))
				return Directory.Enumerate(searchStr, .Directories);
			else
				return Directory.Enumerate(searchStr, .Directories | .Files);
		}

		Result<void, FileResult> HandleBfpFileOperation(Result<void, Platform.BfpFileResult> res)
		{
			switch (res)
			{
			case .Ok:
				return .Ok;
			case .Err(let err):
				return .Err((FileResult)err);
			}
		}
	}
}
