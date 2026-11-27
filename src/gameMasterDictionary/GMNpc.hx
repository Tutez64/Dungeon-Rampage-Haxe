package gameMasterDictionary;

import dBGlobals.DBGlobal;

class GMNpc extends GMActor {
	public var ViolentDeathFilePath:String;

	public var ViolentDeathClassName:String;

	public var UseTeleportAI:Bool = false;

	public var UsePetUI:Bool = false;

	public var UseFlashRotation:Bool = false;

	public var TileTheme:String;

	public var SpeedRating:UInt = 0;

	public var ShowHealNumbers:Bool = false;

	public var SellCoins:Int = 0;

	public var PermCorpse:Bool = false;

	public var IsNavigable:Bool = false;

	public var IsBoss:Bool = false;

	public var IsAttackable:Bool = false;

	public var HasHealthbar:Bool = false;

	public var DefenseRating:UInt = 0;

	public var DefaultLayer:String;

	public var DefaultHeading:Int = 0;

	public var DeactivateVolume:Float = Math.NaN;

	public var DeactivateSound:String;

	public var BlockingDotProduct:Float = Math.NaN;

	public var AttackRating:UInt = 0;

	public var ArchwayAlpha:Bool = false;

	public var ActivateVolume:Float = Math.NaN;

	public var ActivateSound:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		if (jsonAsset.Ability1 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability1) : UInt) : UInt);
		}
		if (jsonAsset.Ability2 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability2) : UInt) : UInt);
		}
		if (jsonAsset.Ability3 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability3) : UInt) : UInt);
		}
		if (jsonAsset.Ability4 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability4) : UInt) : UInt);
		}
		if (jsonAsset.Ability5 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability5) : UInt) : UInt);
		}
		Weapon1 = jsonAsset.Weapon1;
		Weapon2 = jsonAsset.Weapon2;
		Weapon3 = jsonAsset.Weapon3;
		Weapon4 = jsonAsset.Weapon4;
		Weapon5 = jsonAsset.Weapon5;
		SellCoins = ASCompat.toInt(jsonAsset.SellCoin);
		AttackRating = (ASCompat.toInt(jsonAsset.AttackRating) : UInt);
		DefenseRating = (ASCompat.toInt(jsonAsset.DefenseRating) : UInt);
		SpeedRating = (ASCompat.toInt(jsonAsset.SpeedRating) : UInt);
		IsNavigable = ASCompat.toInt(jsonAsset.IsNavigable) == 1;
		if (Constant == "GARLIC_PLACEABLE_L2") {
			IsNavigable = true;
		}
		IsAttackable = ASCompat.toInt(jsonAsset.IsAttackable) == 1;
		IsBoss = ASCompat.toInt(jsonAsset.IsBoss) == 1;
		HasHealthbar = ASCompat.toBool(jsonAsset.HasHealthbar);
		UsePetUI = ASCompat.toBool(jsonAsset.UsePetUI);
		UseTeleportAI = jsonAsset.Aggro_AI_Type == "TELEPORT_AI";
		ActivateSound = jsonAsset.ActivateSound;
		ActivateVolume = ASCompat.toNumber(jsonAsset.ActivateVol);
		DeactivateSound = jsonAsset.DeactivateSound;
		DeactivateVolume = ASCompat.toNumber(jsonAsset.DeactivateVol);
		DefaultHeading = ASCompat.toInt(jsonAsset.DefaultHeading);
		DefaultLayer = jsonAsset.DefaultLayer;
		TileTheme = jsonAsset.TileTheme;
		UseFlashRotation = ASCompat.toBool(jsonAsset.UseFlashRotation);
		PermCorpse = ASCompat.toBool(jsonAsset.PermCorpse);
		ArchwayAlpha = ASCompat.toBool(jsonAsset.ArchwayAlpha);
		ViolentDeathClassName = jsonAsset.ViolentDeathClassName;
		ViolentDeathFilePath = jsonAsset.ViolentDeathFilePath;
		BlockingDotProduct = ASCompat.toNumber(jsonAsset.BlockingDotProduct);
		ShowHealNumbers = ASCompat.toBool(jsonAsset.ShowHealNumbers);
	}

	public function blocksNatively():Bool {
		return BlockingDotProduct > -1.1;
	}
}
