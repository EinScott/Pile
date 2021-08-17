namespace Pile
{
	public struct CharModifier : this(Vector2 offset, Vector2 scale, float rotation, Color color);

	extension CharModifier
	{
		public const CharModifier None = .(.Zero, .One, 0, .White);

		public function CharModifier GetFunc(Vector2 currPos, int index, char32 char);

		// We kind of abuse + as a "Combine" operator
		public static CharModifier operator+(CharModifier a, CharModifier b)
		{
			return .(a.offset + b.offset,
				a.scale * b.scale, // Apply scaling
				a.rotation + b.rotation,
				a.color * b.color); // Mask with each other
		}
	}
}
