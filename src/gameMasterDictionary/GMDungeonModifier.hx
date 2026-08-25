package gameMasterDictionary;

class GMDungeonModifier {
	public var Id:UInt = 0;

	public var Constant:String;

	public var Name:String;

	public var Description:String;

	public var BuffId:UInt = 0;

	public var IsPlayerBuff:Bool = false;

	public var NPCSpawnId:UInt = 0;

	public var NPCDeathSpawnId:UInt = 0;

	public var NPCDeathSpawnCharType:String;

	public var NPCDeathSpawnMaxGeneration:UInt = 0;

	public var NPCDeathSpawnChance:Float = Math.NaN;

	public var NPCDeathSpawnMinCount:UInt = 0;

	public var NPCDeathSpawnMaxCount:UInt = 0;

	public var IconFilepath:String;

	public var IconName:String;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Constant = jsonAsset.Constant;
		Name = jsonAsset.Name;
		Description = jsonAsset.Description;
		BuffId = (ASCompat.toInt(jsonAsset.BuffId) : UInt);
		IsPlayerBuff = ASCompat.toBool(jsonAsset.IsPlayerBuff);
		NPCSpawnId = (ASCompat.toInt(jsonAsset.NPCSpawnId) : UInt);
		NPCDeathSpawnId = (ASCompat.toInt(jsonAsset.NPCDeathSpawnId) : UInt);
		NPCDeathSpawnCharType = jsonAsset.NPCDeathSpawnCharType;
		NPCDeathSpawnMaxGeneration = (ASCompat.toInt(jsonAsset.NPCDeathSpawnMaxGeneration) : UInt);
		NPCDeathSpawnChance = ASCompat.toNumberField(jsonAsset, "NPCDeathSpawnChance");
		NPCDeathSpawnMinCount = (ASCompat.toInt(jsonAsset.NPCDeathSpawnMinCount) : UInt);
		NPCDeathSpawnMaxCount = (ASCompat.toInt(jsonAsset.NPCDeathSpawnMaxCount) : UInt);
		IconFilepath = jsonAsset.IconFilepath;
		IconName = jsonAsset.IconName;
	}
}
