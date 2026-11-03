package gameMasterDictionary;

import flash.Boot;

class GMDungeonModifier {
	public var Name:String;

	public var NPCSpawnId:UInt = 0;

	public var NPCDeathSpawnMinCount:UInt = 0;

	public var NPCDeathSpawnMaxGeneration:UInt = 0;

	public var NPCDeathSpawnMaxCount:UInt = 0;

	public var NPCDeathSpawnId:UInt = 0;

	public var NPCDeathSpawnCharType:String;

	public var NPCDeathSpawnChance:Float = Math.NaN;

	public var IsPlayerBuff:Bool = false;

	public var Id:UInt = 0;

	public var IconName:String;

	public var IconFilepath:String;

	public var Description:String;

	public var Constant:String;

	public var BuffId:UInt = 0;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
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
		NPCDeathSpawnChance = ASCompat.toNumber(jsonAsset.NPCDeathSpawnChance);
		NPCDeathSpawnMinCount = (ASCompat.toInt(jsonAsset.NPCDeathSpawnMinCount) : UInt);
		NPCDeathSpawnMaxCount = (ASCompat.toInt(jsonAsset.NPCDeathSpawnMaxCount) : UInt);
		IconFilepath = jsonAsset.IconFilepath;
		IconName = jsonAsset.IconName;
	}
}
