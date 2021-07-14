using System;

using internal Pile;

namespace Pile
{
	extension Shader
	{
		[SkipCall]
		protected override void Initialize() {}

		[SkipCall]
		protected override void Set(ShaderData source) {}

		protected override void ReflectCounts(out uint32 attributeCount, out uint32 uniformCount)
		{
			attributeCount = uniformCount = 0;
		}
		protected override System.Result<void> ReflectAttrib(uint32 index, System.String nameBuffer, out uint32 location, out uint32 length)
		{
			location = length = 0;
			return .Ok;
		}
		protected override System.Result<void> ReflectUniform(uint32 index, System.String nameBuffer, out uint32 location, out uint32 length, out Pile.UniformType type)
		{
			location = length = 0;
			type = .Unknown;
			return .Ok;
		}
	}
}
