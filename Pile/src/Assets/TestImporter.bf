namespace Pile
{
	public class TestImporter : Assets.Importer
	{
		public override System.Object Load(uint8[] data, JetFistGames.Toml.TomlNode dataNode)
		{
			return default;
		}

		public override System.Result<void, System.String> Import(uint8[] data, uint8[] outData, JetFistGames.Toml.TomlNode outDataNode)
		{
			return default;
		}
	}
}
