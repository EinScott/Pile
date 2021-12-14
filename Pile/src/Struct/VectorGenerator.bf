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
			AddCombo("ftype", "Floating Type", "float", StringView[?]("float", "double"));
			AddEdit("itype", "Int Equivalent Type", "Point2");
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
			let floatingTypeName = mParams["ftype"];
			let intType = mParams["itype"];
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

			f.NewLine();

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

			f.NewLine();

			f.Put("public this(");
			for (let compIdx < componentCount)
				outText.Append(scope $"{typeName} {GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()}, ");
			outText..RemoveFromEnd(2).Append(')');
			f.Block();
			for (let compIdx < componentCount)
				f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)} = {GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()};");
			f.End();

			f.NewLine();

			// Getter properties
			f.Put("/// Returns the length of the vector.");
			f.Put("[Inline]");
			f.Put(scope $"public {floatingTypeName} Length => (.)Math.Sqrt((.)");
			for (let compIdx < componentCount)
			{
				let field = GetComponentField(.. scope .(), compIdx, componentCount);
				outText.Append(scope $"{field} * {field} + ");
			}
			outText..RemoveFromEnd(3).Append(");");

			f.NewLine();
			
			f.Put("/// Returns the length of the vector squared. This operation is cheaper than Length.");
			f.Put("[Inline]");
			f.Put(scope $"public {typeName} LengthSquared => ");
			for (let compIdx < componentCount)
			{
				let field = GetComponentField(.. scope .(), compIdx, componentCount);
				outText.Append(scope $"{field} * {field} + ");
			}
			outText..RemoveFromEnd(3).Append(';');

			f.NewLine();

			// Interface functions
			f.Put("[Inline]");
			f.Put("public bool Equals(Self o) => o == this;");

			f.NewLine();

			f.Start("public override void ToString(String strBuffer)");
			f.Put("strBuffer.Append(\"[ \");");
			for (let compIdx < componentCount)
			{
				f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)}.ToString(strBuffer);");
				if (compIdx + 1 < componentCount)
					f.Put("strBuffer.Append(\", \");");
			}
			f.Put("strBuffer.Append(\" ]\");");
			f.End();

			f.NewLine();

			f.Start("public void ToString(String outString, String format, IFormatProvider formatProvider)");
			f.Put("outString.Append(\"[ \");");
			for (let compIdx < componentCount)
			{
				f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)}.ToString(outString, format, formatProvider);");
				if (compIdx + 1 < componentCount)
					f.Put("outString.Append(\", \");");
			}
			f.Put("outString.Append(\" ]\");");
			f.End();

			f.NewLine();

			// Functions
			if ((typeName == "float" || typeName == "double") && intType != "")
			{
				f.Put("/// Rounds the vector to a point.");
				f.Put("[Inline]");
				f.Start(scope $"public {intType} Round()");
				f.Put("return .(");
				for (let compIdx < componentCount)
					outText.Append(scope $"(int)Math.Round({GetComponentField(.. scope .(), compIdx, componentCount)}), ");
				outText..RemoveFromEnd(2).Append(");");
				f.End();

				f.NewLine();
			}

			f.Put("/// Returns a vector with the same direction as the given vector, but with a length of 1.");
			f.Put("/// Vector2.Zero will still just return Vector2.Zero.");
			f.Put("[Inline]");
			f.Start("public Self Normalize()");
			f.Put("// Normalizing a zero vector is not possible and will return NaN.");
			f.Put("// We ignore this in favor of not NaN-ing vectors.");
			f.NewLine();
			f.Put("return this == .Zero ? .Zero : this / Length;");
			f.End();

			f.NewLine();

			f.Put("/// Returns the dot product of two vectors.");
			f.Put("[Inline]");
			f.Start(scope $"public static {floatingTypeName} Dot(Self value1, Self value2)");
			f.Put("return ");
			for (let compIdx < componentCount)
			{
				let field = GetComponentField(.. scope .(), compIdx, componentCount);
				outText.Append(scope $"value1.{field} * value2.{field} + ");
			}
			outText..RemoveFromEnd(3).Append(';');
			f.End();

			f.NewLine();
			
			f.Put("/// Returns the Euclidean distance between the two given points.");
			f.Put("[Inline]");
			f.Start(scope $"public static {floatingTypeName} Distance(Self value1, Self value2)");
			f.Put("return (value1 - value2).Length;");
			f.End();

			f.NewLine();

			f.Put("/// Returns the Euclidean distance between the two given points squared.");
			f.Put("[Inline]");
			f.Start(scope $"public static {floatingTypeName} Distance(Self value1, Self value2)");
			f.Put("return (value1 - value2).LengthSquared;");
			f.End();

			f.NewLine();

			f.Put("/// Returns the Euclidean distance between the two given points.");
			f.Put("[Inline]");
			f.Start(scope $"public {floatingTypeName} DistanceTo(Self other)");
			f.Put("return (this - other).Length;");
			f.End();

			f.NewLine();

			f.Put("/// Returns the Euclidean distance between the two given points squared.");
			f.Put("[Inline]");
			f.Start(scope $"public {floatingTypeName} DistanceTo(Self other)");
			f.Put("return (this - other).LengthSquared;");
			f.End();

			f.NewLine();

			f.Put("/// Returns the reflection of a vector off a surface that has the specified normal.");
			f.Put("[Inline]");
			f.Start("public static Self Reflect(Self vector, Self normal)");
			f.Put("return vector - (normal * 2 * Self.Dot(vector, normal));");
			f.End();

			f.NewLine();

			f.Put("/// Restricts a vector between a min and max value.");
			f.Start("public static Self Clamp(Self value1, Self min, Self max)");
			for (let compIdx < componentCount)
			{
				let field = GetComponentField(.. scope .(), compIdx, componentCount);
				let fieldName = GetComponentName(.. scope .(), compIdx, componentCount)..ToLower();
				f.Put(scope $"var {fieldName} = value1.{field};");
				f.Put(scope $"{fieldName} = ({fieldName} > max.{field}) ? max.{field} : {fieldName};");
				f.Put(scope $"{fieldName} = ({fieldName} < min.{field}) ? min.{field} : {fieldName};");
				f.NewLine();
			}
			f.Put("return .(");
			for (let compIdx < componentCount)
				outText..Append(GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()).Append(", ");
			outText..RemoveFromEnd(2).Append(");");
			f.End();

			f.NewLine();

			f.Put("/// Linearly interpolates between two vectors based on the given weighting.");
			f.Start(scope $"public static Self Lerp(Self a, Self b, {floatingTypeName} amount)");
			f.Put("return .(");
			for (let compIdx < componentCount)
			{
				let field = GetComponentField(.. scope .(), compIdx, componentCount);
				outText.Append(scope $"a.{field} + (b.{field} - a.{field}) * amount, ");
			}
			outText..RemoveFromEnd(2).Append(");");
			f.End();

			f.NewLine();

			f.Put("/// Approaches the target vector by a constant given amount.");
			f.Start("");
			f.End();

			// ANGLE (to vec)
			// max min abs sqrt
			// transform
			// clamp, lerp, approach

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