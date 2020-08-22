namespace Pile
{
	public enum Compare
	{
		None, // Ignore
		Always, // Always passes
		Never, // Never passes
		Less, // Passes when value is less than stored
		Equal, // Passes when value is equal to stored
		LessOrEqual, // Passes when value is less or equal to stored
		Greater, // Passes when value is greater than stored
		NotEqual, // Passes when value is not equal to stored
		GreaterOrEqual // Passes when value is greater or equal to stored
	}
}
