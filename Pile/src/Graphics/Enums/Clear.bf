namespace Pile
{
	enum Clear : uint8
	{
		Color   = 0b001,
		Depth   = 0b010,
		Stencil = 0b100,
		All = Color | Depth | Stencil
	}
}
