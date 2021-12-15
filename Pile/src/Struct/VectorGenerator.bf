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
		}

		public void PrepLine()
		{
			NewLine();
			TabTap();
		}

		public FormatBlockEnd Start(StringView declaringLine)
		{
			PrepLine();
			outStr.Append(declaringLine);
			PrepLine();
			outStr.Append('{');
			TabPush();

			return .(this);
		}

		// Also useful for when you need to compose the declaring line through many calls, then just call this in the end
		public FormatBlockEnd Block()
		{
			PrepLine();
			outStr.Append('{');
			TabPush();

			return .(this);
		}

		public void End()
		{
			TabPop();
			PrepLine();
			outStr.Append('}');
		}

		public void Put(StringView line)
		{
			PrepLine();
			outStr.Append(line);
		}
	}

	class VectorGenerator : Compiler.Generator
	{
		public override String Name => "Pile Vector Generator (Internal)";

		// TODO a way to generate constructors that are composed of smaller vectors: Vector3(myVec2, 1);
		// + then conversion operator with default value!
		// TODO promotion operators (UPoint2 can be divided by int, but results in Point2)
		// TODO: getters for swizzles -> YX ...

		// TODO: floatingVectorType for Normalize on points

		public override void InitUI()
		{
			AddEdit("name", "Vector Name", "Vector2");
			AddEdit("components", "Components", "2");
			AddCombo("type", "Component Type", "float", StringView[?]("float", "double", "int", "uint"));
			AddCombo("ftype", "Floating Type", "component", StringView[?]("float", "double", "component"));
			AddEdit("itype", "Int Equivalent Type (Rounding)", "Point2");
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

			// Floating
			if (!(typeName.StartsWith("int") || typeName.StartsWith("uint")) && floatingTypeName != typeName)
			{
				if (floatingTypeName != "component")
				{
					Fail("Vectors with float components must use 'component' as the floatingTypeName");
					return;
				}

				floatingTypeName = typeName;
			}
			else if (floatingTypeName == "component")
			{
				Fail("'component' is not valid as a floating type in this case");
				return;
			}

			var intVectorType = mParams["itype"];
			StringView intUVectorType = "";

			// iType can contain the unsigned equivalent as well!
			if (intVectorType.Contains(';'))
			{
				let semicolon = intVectorType.IndexOf(';');
				if (!intVectorType.EndsWith(';'))
				{
					intUVectorType = intVectorType.Substring(semicolon + 1, intVectorType.Length - semicolon - 1);
				}

				intVectorType.RemoveToEnd(semicolon);
			}

			let isFloating = (typeName == "float" || typeName == "double");
			let isUnsigned = typeName.StartsWith("uint");

			// PutCompLine(f, componentCount, "return .(", "Math.Abs(vector.{})", ", ", ");");
			mixin PutCompField(StringView lineStart, StringView componentInsert, StringView seperator, StringView end)
			{
				f.Put(lineStart);
				for (let compIdx < componentCount)
				{
					let field = GetComponentField(.. scope .(), compIdx, componentCount);
					outText..AppendF(componentInsert, field).Append(seperator);
				}
				outText..RemoveFromEnd(seperator.Length).Append(end);
			}

			mixin PutCompName(StringView lineStart, StringView componentInsert, StringView seperator, StringView end)
			{
				f.Put(lineStart);
				for (let compIdx < componentCount)
				{
					let field = GetComponentName(.. scope .(), compIdx, componentCount);
					outText..AppendF(componentInsert, field).Append(seperator);
				}
				outText..RemoveFromEnd(seperator.Length).Append(end);
			}

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

				if (!isUnsigned)
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
			PutCompField!(scope $"public {floatingTypeName} Length => (.)Math.Sqrt((.)", "{0} * {0}", " + ", ");");

			f.NewLine();
			
			f.Put("/// Returns the length of the vector squared. This operation is cheaper than Length.");
			f.Put("[Inline]");
			PutCompField!(scope $"public {typeName} LengthSquared => ", "{0} * {0}", " + ", ";");

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
			using (f.Start(scope $"public {typeName} DistanceToSquared(Self other)"))
				f.Put("return (this - other).LengthSquared;");

			f.NewLine();

			if (isFloating && intVectorType != "")
			{
				f.Put("/// Rounds the vector to a point.");
				f.Put("[Inline]");
				using (f.Start(scope $"public {intVectorType} ToRounded()"))
					f.Put("return Self.Round(this);");

				f.NewLine();
			}

			f.Put("/// Returns a vector with the same direction as the given vector, but with a length of 1.");
			f.Put("/// Vector2.Zero will still just return Vector2.Zero.");
			f.Put("[Inline]");
			using (f.Start("public Self ToNormalized()"))
				f.Put("return Self.Normalize(this);");

			f.NewLine();

			// Static Methods
			if (isFloating && intVectorType != "")
			{
				f.Put("/// Rounds the vector to a point.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static {intVectorType} Round(Self vector)"))
					PutCompField!("return .(", "(int)Math.Round(vector.{})", ", ", ");");

				f.NewLine();
			}

			f.Put("/// Returns a vector with the same direction as the given vector, but with a length of 1.");
			f.Put("/// Vector2.Zero will still just return Vector2.Zero.");
			f.Put("[Inline]");
			using (f.Start("public static Self Normalize(Self vector)"))
			{
				f.Put("// Normalizing a zero vector is not possible and will return NaN.");
				f.Put("// We ignore this in favor of not NaN-ing vectors.");
				f.NewLine();
				f.Put("return vector == .Zero ? .Zero : vector / vector.Length;");
			}

			// TODO: investigate pattern
			/*f.NewLine();

			f.Put("/// Computes the cross product of two vectors.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {typeName} Cross(Self a, Self b)"))
				PutCompField!("return ", "a.{0} * b.{0}", " + ", ";");*/

			f.NewLine();

			f.Put("/// Returns the dot product of two vectors.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {typeName} Dot(Self a, Self b)"))
				PutCompField!("return ", "a.{0} * b.{0}", " + ", ";");

			f.NewLine();

			if (componentCount == 2)
			{
				f.Put("/// Returns the angle of the vector.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static {floatingTypeName} Angle(Self vector)"))
				{
					// Names of components are guaranteed
					f.Put("return (.)Math.Atan2(vector.Y, vector.X);");
				}

				f.NewLine();

				f.Put("/// Returns the angle betweem two vectors.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static {floatingTypeName} Angle(Self from, Self to)"))
					f.Put("return (.)Math.Atan2(to.Y - from.Y, to.X - from.X);");

				f.NewLine();

				f.Put("/// Constructs a vector from a given angle and a length.");
				f.Put("[Inline]");
				using (f.Start(scope $"public static Self AngleToVector({typeName} angle, {typeName} length = 1)"))
					f.Put("return .((.)(Math.Cos(angle) * length), (.)(Math.Sin(angle) * length));");

				f.NewLine();
			}
			
			f.Put("/// Returns the Euclidean distance between the two given points.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {floatingTypeName} Distance(Self a, Self b)"))
				f.Put("return (a - b).Length;");

			f.NewLine();

			f.Put("/// Returns the Euclidean distance between the two given points squared.");
			f.Put("[Inline]");
			using (f.Start(scope $"public static {typeName} DistanceSquared(Self a, Self b)"))
				f.Put("return (a - b).LengthSquared;");

			f.NewLine();

			f.Put("/// Returns the reflection of a vector off a surface that has the specified normal.");
			f.Put("[Inline]");
			using (f.Start("public static Self Reflect(Self vector, Self normal)"))
				f.Put("return vector - (normal * 2 * Self.Dot(vector, normal));");

			f.NewLine();

			f.Put("/// Restricts a vector between a min and max value.");
			using (f.Start("public static Self Clamp(Self vector, Self min, Self max)"))
			{
				for (let compIdx < componentCount)
				{
					let field = GetComponentField(.. scope .(), compIdx, componentCount);
					let fieldName = GetComponentName(.. scope .(), compIdx, componentCount)..ToLower();
					f.Put(scope $"var {fieldName} = vector.{field};");
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
				if (isFloating)
					PutCompField!("return .(", "a.{0} + (b.{0} - a.{0}) * amount", ", ", ");");
				else PutCompField!("return .(", "a.{0} + (.)Math.Round((b.{0} - a.{0}) * amount)", ", ", ");");
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
						f.Put("return from + (Self)(Self.Normalize(diff) * amount);");
				}
			}

			f.NewLine();

			f.Put("/// Returns a vector whose elements are the minimum of each of the pairs of elements in the two source vectors.");
			using (f.Start("public static Self Min(Self a, Self b)"))
				PutCompField!("return .(", "(a.{0} < b.{0}) ? a.{0} : b.{0}", ", ", ");");

			f.NewLine();

			f.Put("/// Returns a vector whose elements are the maximum of each of the pairs of elements in the two source vectors.");
			using (f.Start("public static Self Max(Self a, Self b)"))
				PutCompField!("return .(", "(a.{0} > b.{0}) ? a.{0} : b.{0}", ", ", ");");

			f.NewLine();

			f.Put("/// Returns a vector whose elements are the absolute values of each of the source vector's elements.");
			f.Put("[Inline]");
			using (f.Start("public static Self Abs(Self vector)"))
				PutCompField!("return .(", "Math.Abs(vector.{})", ", ", ");");

			f.NewLine();

			f.Put("/// Returns a vector whose elements are the square root of each of the source vector's elements.");
			f.Put("[Inline]");
			using (f.Start("public static Self Sqrt(Self vector)"))
				PutCompField!("return .(", "Math.Sqrt(vector.{})", ", ", ");");

			// transform

			// special funcs

			f.NewLine();

			// Conversion Operators
			PutCompName!("public static operator Self((", scope $"{typeName} {{}}", ", ", ") tuple) => .(");
			for (let compIdx < componentCount) // Append constructor fill-in
			{
				outText..Append("tuple.")..Append(GetComponentName(.. scope .(), compIdx, componentCount))
					.Append(", ");
			}
			outText..RemoveFromEnd(2).Append(");");

			if (intVectorType != "")
				PutCompName!(scope $"public static operator Self({intVectorType} a) => .(", "a.{}", ", ", ");"); // Assume that this vector has the same amount of components, thus the same member notation

			if (intUVectorType != "")
				PutCompName!(scope $"public static operator Self({intUVectorType} a) => .(", "a.{}", ", ", ");"); // Assume that this vector has the same amount of components, thus the same member notation

			f.NewLine();

			// Arithmetic Operators
			f.Put("[Commutable]");
			PutCompName!(scope $"public static bool operator==(Self a, Self b) => ", "a.{0} == b.{0}", " && ", ";");

			f.NewLine();

			PutCompName!(scope $"public static Self operator+(Self a, Self b) => .(", "a.{0} + b.{0}", ", ", ");");
			PutCompName!(scope $"public static Self operator-(Self a, Self b) => .(", "a.{0} - b.{0}", ", ", ");");
			PutCompName!(scope $"public static Self operator*(Self a, Self b) => .(", "a.{0} * b.{0}", ", ", ");");
			PutCompName!(scope $"public static Self operator/(Self a, Self b) => .(", "a.{0} / b.{0}", ", ", ");");

			f.NewLine();

			PutCompName!(scope $"public static Self operator*({typeName} a, Self b) => .(", "a * b.{}", ", ", ");");
			PutCompName!(scope $"public static Self operator*(Self a, {typeName} b) => .(", "a.{} * b", ", ", ");");
			PutCompName!(scope $"public static Self operator/(Self a, {typeName} b) => .(", "a.{} / b", ", ", ");");

			f.NewLine();

			if (!isUnsigned)
				PutCompName!(scope $"public static Self operator-(Self a) => .(", "-a.{}", ", ", ");");

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