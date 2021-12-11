using System;
using System.Diagnostics;

namespace Pile
{
	class CodeFormatHelper
	{
		int tabDepth;
		String outStr;

		public this(String outText)
		{
			outStr = outText;
		}

		void TabTap()
		{
			for (let i < tabDepth)
				outStr.Append('\t');
		}

		void TabPush()
		{
			tabDepth++;
		}

		void TabPop()
		{
			tabDepth--;

			Debug.Assert(tabDepth >= 0);
		}

		public void NewLine()
		{
			outStr.Append('\n');
			TabTap();
		}

		public void Start(StringView declaringLine)
		{
			NewLine();
			outStr.Append(declaringLine);
			NewLine();
			outStr.Append('{');
			TabPush();
		}

		public void End()
		{
			TabPop();
			NewLine();
			outStr.Append("}\n");
		}

		public void Put(StringView line)
		{
			NewLine();
			outStr.Append(line);
		}
	}

	class VectorGenerator : Compiler.Generator
	{
		public override String Name => "Pile Vector Generator (Internal)";

		public override void InitUI()
		{
			AddEdit("name", "Vector Name", "Vector2");
			AddEdit("components", "Components", "2");
			AddCombo("type", "Component Type", "float", StringView[?]("float", "double", "int", "uint"));
			AddEdit("conversions", "Compatible Vector Types", "");

		}

		public override void Generate(String outFileName, String outText, ref Flags generateFlags)
		{
			CodeFormatHelper f = scope .(outText);
			generateFlags |= .AllowRegenerate;

			var name = mParams["name"];
			if (name.EndsWith(".bf", .OrdinalIgnoreCase))
				name.RemoveFromEnd(3);
			outFileName.Append(name);

			// TODO parse more args

			f.Start("namespace Pile");
			f.Start(scope $"struct {name} : IFormattable, IEquatable<{name}>");

			

			f.End();
			f.End();
		}
	}
}