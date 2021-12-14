using System;
using System.Diagnostics;

namespace Pile
{
	class CodeFormatHelper
	{
		public struct FormatBlockEnd : IDisposable
		{
			CodeFormatHelper f;

			[Inline]
			public this(CodeFormatHelper format)
			{
				f = format;
			}

			[Inline]
			public void Dispose()
			{
				f.End();
			}
		}

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

		public FormatBlockEnd Start(StringView declaringLine)
		{
			NewLine();
			outStr.Append(declaringLine);
			NewLine();
			outStr.Append('{');
			TabPush();

			return .(this);
		}

		// Also useful for when you need to compose the declaring line through many calls, then just call this in the end
		public FormatBlockEnd Block()
		{
			NewLine();
			outStr.Append('{');
			TabPush();

			return .(this);
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
			var floatingTypeName = mParams["ftype"];
			let intType = mParams["itype"];
			let conversion = mParams["conversions"];

			// Double vector type cannot have float as floating type!
			if (typeName == "double" && floatingTypeName != typeName)
				floatingTypeName = "double";

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
			using (f.Start("public this()"))
				f.Put("this = default;");

			f.NewLine();

			using (f.Start(scope $"public this({typeName} all)"))
			{
				if (componentCount <= 4)
				{
					for (let compIdx < componentCount)
						f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)} = all;");
				}
				else
				{
					f.Put(scope $"Internal.MemSet(&components[0], all, {componentCount});");
				}
			}

			f.NewLine();

			f.Put("public this(");
			for (let compIdx < componentCount)
				outText.Append(scope $"{typeName} {GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()}, ");
			outText..RemoveFromEnd(2).Append(')');
			using (f.Block())
				for (let compIdx < componentCount)
					f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)} = {GetComponentName(.. scope .(), compIdx, componentCount)..ToLower()};");
			
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

			// Interface Methods
			f.Put("[Inline]");
			f.Put("public bool Equals(Self o) => o == this;");

			f.NewLine();

			using (f.Start("public override void ToString(String strBuffer)"))
			{
				f.Put("strBuffer.Append(\"[ \");");
				for (let compIdx < componentCount)
				{
					f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)}.ToString(strBuffer);");
					if (compIdx + 1 < componentCount)
						f.Put("strBuffer.Append(\", \");");
				}
				f.Put("strBuffer.Append(\" ]\");");
			}

			f.NewLine();

			using (f.Start("public void ToString(String outString, String format, IFormatProvider formatProvider)"))
			{
				f.Put("outString.Append(\"[ \");");
				for (let compIdx < componentCount)
				{
					f.Put(scope $"{GetComponentField(.. scope .(), compIdx, componentCount)}.ToString(outString, format, formatProvider);");
					if (compIdx + 1 < componentCount)
						f.Put("outString.Append(\", \");");
				}
				f.Put("outString.Append(\" ]\");");
			}

			f.NewLine();

			// Methods
			f.Put("/// Returns the Euclidean distance between the two given points.");
			f.Put("[Inline]");
			using (f.Start(scope $"public {floatingTypeName} DistanceTo(Self other)"))
				f.Put("return (this - other).Length;");

			f.NewLine();

			f.Put("/// Returns the Euclidean distance between the two given points squared.");
			f.Put("[Inline]");
			using (f.Start(scope $"public {floatingTypeName} DistanceTo(Self other)"))
				f.Put("return (this - other).LengthSquared;");

			f.NewLine();

			// Static Methods
			if ((typeName == "float" || typeName == "double") && intType != "")
			{
				f.Put("/// Rounds the vector to a point.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static {intType} Round()"))
				{
					f.Put("return .(");
					for (let compIdx < componentCount)
						outText.Append(scope $"(int)Math.Round({GetComponentField(.. scope .(), compIdx, componentCount)}), ");
					outText..RemoveFromEnd(2).Append(");");
				}

				f.NewLine();
			}

			f.Put("/// Returns a vector with the same direction as the given vector, but with a length of 1.");
			f.Put("/// Vector2.Zero will still just return Vector2.Zero.");
			f.Put("[Inline]");
			using (f.Start("public static Self Normalize()"))
			{
				f.Put("// Normalizing a zero vector is not possible and will return NaN.");
				f.Put("// We ignore this in favor of not NaN-ing vectors.");
				f.NewLine();
				f.Put("return this == .Zero ? .Zero : this / Length;");
			}

			f.NewLine();

			f.Put("/// Returns the dot product of two vectors.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {floatingTypeName} Dot(Self value1, Self value2)"))
			{
				f.Put("return ");
				for (let compIdx < componentCount)
				{
					let field = GetComponentField(.. scope .(), compIdx, componentCount);
					outText.Append(scope $"value1.{field} * value2.{field} + ");
				}
				outText..RemoveFromEnd(3).Append(';');
			}

			f.NewLine();

			if (componentCount == 2)
			{
				f.Put("/// Returns the angle of the vector.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static {floatingTypeName} Angle(Self vec)"))
				{
					// Names of components are guaranteed
					f.Put("return Math.Atan2(vec.Y, vec.X);");
				}

				f.NewLine();

				f.Put("/// Returns the angle betweem two vectors.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static {floatingTypeName} Angle(Self from, Self to)"))
					f.Put("return Math.Atan2(to.Y - from.Y, to.X - from.X);");

				f.NewLine();

				f.Put("/// Constructs a vector from a given angle and a length.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static Self AngleToVector({floatingTypeName} angle, {floatingTypeName} length = 1)"))
					f.Put("return .(Math.Cos(angle) * length, Math.Sin(angle) * length);");

				f.NewLine();
			}
			
			f.Put("/// Returns the Euclidean distance between the two given points.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {floatingTypeName} Distance(Self value1, Self value2)"))
				f.Put("return (value1 - value2).Length;");

			f.NewLine();

			f.Put("/// Returns the Euclidean distance between the two given points squared.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {floatingTypeName} Distance(Self value1, Self value2)"))
				f.Put("return (value1 - value2).LengthSquared;");

			f.NewLine();

			f.Put("/// Returns the reflection of a vector off a surface that has the specified normal.");
			f.Put("[Inline]");
			using (f.Start("public static Self Reflect(Self vector, Self normal)"))
				f.Put("return vector - (normal * 2 * Self.Dot(vector, normal));");

			f.NewLine();

			f.Put("/// Restricts a vector between a min and max value.");
			using (f.Start("public static Self Clamp(Self value1, Self min, Self max)"))
			{
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
			}

			f.NewLine();

			f.Put("/// Linearly interpolates between two vectors based on the given weighting.");
			using (f.Start(scope $"public static Self Lerp(Self a, Self b, {floatingTypeName} amount)"))
			{
				f.Put("return .(");
				for (let compIdx < componentCount)
				{
					let field = GetComponentField(.. scope .(), compIdx, componentCount);
					outText.Append(scope $"a.{field} + (b.{field} - a.{field}) * amount, ");
				}
				outText..RemoveFromEnd(2).Append(");");
			}

			f.NewLine();

			f.Put("/// Approaches the target vector by a constant given amount.");
			using (f.Start(scope $"public static Self Approach(Self from, Self target, {floatingTypeName} amount)"))
			{
				using (f.Start("if (from == target)"))
					f.Put("return target;");
				using (f.Start("else"))
				{
					f.Put("let diff = target - from;");
					using (f.Start("if (diff.Length <= amount * amount)"))
						f.Put("return target;");
					using (f.Start("else"))
						f.Put("return from + Self.Normalize(diff) * amount;");
				}
			}

			f.NewLine();

			// max min abs sqrt
			// transform

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