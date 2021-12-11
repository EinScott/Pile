using System;
using System.IO;

namespace Pile
{
	class PileFileGenerator : Compiler.Generator
	{
		public override String Name => "Pile New File";

		public override void InitUI()
		{
			AddEdit("name", "Type Name", "");
			AddCombo("type", "Type", "class", StringView[3]("class", "struct", "enum"));
			AddCheckbox("usings", "Generate Default Usings", true);
		}

		public override void Generate(String outFileName, String outText, ref Flags generateFlags)
		{
			var name = mParams["name"];
			if (name.EndsWith(".bf", .OrdinalIgnoreCase))
				name.RemoveFromEnd(3);
			outFileName.Append(name);

			let type = mParams["type"];
			if (mParams["usings"] == bool.TrueString)
				outText.Append(
					"""
					using System;
					using Pile;


					""");

			outText.AppendF(
				$"""
				namespace {Namespace}
				{{
					{type} {name}
					{{
					}}
				}}
				""");
		}
	}
}