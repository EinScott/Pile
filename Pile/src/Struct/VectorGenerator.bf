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

		// Also useful for when you need to compose the declaring line through many calls, then just call this in the end
		public void Block()
		{
			NewLine();
			outStr.Append('{');
			TabPush();
		}

		public void End()
		{
			TabPop();
			NewLine();
			outStr.Append('}');
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

			int componentCount;
			if (int.Parse(mParams["components"]) case .Ok(let val))
			{
				if (val <= 1)
				{
					Fail("Input for 'Components' cannot be smaller than '2'");
					return;
				}

				componentCount = val;
			}
			else
			{
				Fail("Input for 'Components' must be a valid integer number");
				return;
			}

			let typeName = mParams["type"];
			let conversion = mParams["conversions"];

			f.Put("using System;");
			f.NewLine();

			f.Start("namespace Pile");
			f.Start(scope $"struct {name} : IFormattable, IEquatable<{name}>");

			// Consts
			{
				f.Put("public const Self Zero = .();");
				f.Put("public const Self One = .(1);");

				for (let unitCompIdx < componentCount)
				{
					f.Put("public const Self Unit");
					outText..Append(GetComponentName(.. scope .(), unitCompIdx, componentCount))
						.Append(" = .(");

					for (let compIdx < componentCount)
					{
						outText..Append(compIdx == unitCompIdx ? '1' : '0')
							.Append(", ");
					}
					outText..RemoveFromEnd(2) // trailing ", "
						.Append(");");
				}

				if (typeName != "uint")
				{
					for (let unitCompIdx < componentCount)
					{
						f.Put("public const Self Negate");
						outText..Append(GetComponentName(.. scope .(), unitCompIdx, componentCount))
							.Append(" = .(");

						for (let compIdx < componentCount)
						{
							if (compIdx == unitCompIdx)
								outText.Append('-');
							outText.Append("1, ");
						}
						outText..RemoveFromEnd(2) // trailing ", "
							.Append(");");
					}
				}
			}

			f.NewLine();

			// Component variables
			f.Put(scope $"public {typeName}");
			if (componentCount <= 4)
			{
				outText.Append(' ');
				for (let compIdx < componentCount)
				{
					outText..Append(GetComponentName(.. scope .(), compIdx, componentCount))
						.Append(", ");
				}
				outText..RemoveFromEnd(2).Append(';');
			}
			else outText.Append(scope $"[{componentCount}] components;");

			f.NewLine();

			// Constructors
			f.Start("public this()");
			f.Put("this = default;");
			f.End();

			f.Start(scope $"public this({typeName} all)");
			if (componentCount <= 4)
			{
				for (let compIdx < componentCount)
					f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)} = all;");
			}
			else
			{
				f.Put(scope $"Internal.MemSet(&components[0], all, {componentCount});");
			}
			f.End();

			f.Put("public this(");
			for (let compIdx < componentCount)
				outText.Append(scope $"{typeName} {GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()}, ");
			outText..RemoveFromEnd(2).Append(')');
			f.Block();
			for (let compIdx < componentCount)
				f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)} = {GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()};");
			f.End();

			// Functions

			f.End();
			f.End();
		}

		void GetComponentName(String buffer, int componentIdx, int componentCount)
		{
			if (componentCount > 4)
			{
				buffer.Append("M");
				componentIdx.ToString(buffer);
			}
			else
			{
				switch (componentIdx)
				{
				case 0:
					buffer.Append('X');
				case 1:
					buffer.Append('Y');
				case 2:
					buffer.Append('Z');
				case 3:
					buffer.Append('W');
				}
			}
		}

		void GetComponentField(String buffer, int componentIdx, int componentCount)
		{
			if (componentCount > 4) // We'll have those in an array
			{
				buffer.Append("components[");
				componentIdx.ToString(buffer);
				buffer.Append(']');
			}
			else GetComponentName(buffer, componentIdx, componentCount);
		}
	}
}