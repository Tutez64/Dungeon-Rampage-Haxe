package gameMasterDictionary;

class GMModifier extends GMItem {
	public var Type:String;

	public var Level:UInt = 0;

	public var IconName:String;

	public var Description:String;

	public var MELEE_SPD:Float = Math.NaN;

	public var SHOOT_SPD:Float = Math.NaN;

	public var MAGIC_SPD:Float = Math.NaN;

	public var MP_COST:Float = Math.NaN;

	public var CHAIN:Float = Math.NaN;

	public var PIERCE:Float = Math.NaN;

	public var MODIFIER_LEVEL:Float = Math.NaN;

	public var MODIFIER_TYPE:String;

	public var COOLDOWN_REDUC:Float = Math.NaN;

	public var CHARGE_REDUC:Float = Math.NaN;

	public var INCREASE_COLLISION:Float = Math.NaN;

	public var MAX_PROJECTILES:UInt = 0;

	public var INCREASED_PROJECTILE_ANGLE_PERCENT:Float = Math.NaN;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		Type = jsonAsset.MODIFIER_TYPE;
		Level = (ASCompat.toInt(jsonAsset.MODIFIER_LEVEL) : UInt);
		IconName = jsonAsset.IconName;
		Description = jsonAsset.Description;
		MODIFIER_LEVEL = ASCompat.toNumberField(jsonAsset, "MODIFIER_LEVEL");
		MODIFIER_TYPE = jsonAsset.MODIFIER_TYPE;
		MELEE_SPD = 1;
		SHOOT_SPD = 1;
		MAGIC_SPD = 1;
		MP_COST = 1;
		CHAIN = 0;
		PIERCE = 0;
		COOLDOWN_REDUC = 1;
		CHARGE_REDUC = 1;
		INCREASE_COLLISION = 1;
		MAX_PROJECTILES = (0 : UInt);
		INCREASED_PROJECTILE_ANGLE_PERCENT = 0;
		if (jsonAsset.hasOwnProperty("MELEE_SPD")) {
			MELEE_SPD = ASCompat.toNumberField(jsonAsset, "MELEE_SPD");
		}
		if (jsonAsset.hasOwnProperty("SHOOT_SPD")) {
			SHOOT_SPD = ASCompat.toNumberField(jsonAsset, "SHOOT_SPD");
		}
		if (jsonAsset.hasOwnProperty("MAGIC_SPD")) {
			MAGIC_SPD = ASCompat.toNumberField(jsonAsset, "MAGIC_SPD");
		}
		if (jsonAsset.hasOwnProperty("MP_COST")) {
			MP_COST = ASCompat.toNumberField(jsonAsset, "MP_COST");
		}
		if (jsonAsset.hasOwnProperty("PIERCE")) {
			PIERCE = ASCompat.toNumberField(jsonAsset, "PIERCE");
		}
		if (jsonAsset.hasOwnProperty("CHAIN")) {
			CHAIN = ASCompat.toNumberField(jsonAsset, "CHAIN");
		}
		if (jsonAsset.hasOwnProperty("MAX_PROJECTILES")) {
			MAX_PROJECTILES = (ASCompat.toInt(jsonAsset.MAX_PROJECTILES) : UInt);
		}
		if (jsonAsset.hasOwnProperty("INCREASED_PROJECTILE_ANGLE_PERCENT")) {
			INCREASED_PROJECTILE_ANGLE_PERCENT = ASCompat.toNumberField(jsonAsset, "INCREASED_PROJECTILE_ANGLE_PERCENT");
		}
		if (jsonAsset.hasOwnProperty("COOLDOWN_REDUC")) {
			COOLDOWN_REDUC = ASCompat.toNumberField(jsonAsset, "COOLDOWN_REDUC");
		}
		if (jsonAsset.hasOwnProperty("CHARGE_UP_REDUC")) {
			CHARGE_REDUC = ASCompat.toNumberField(jsonAsset, "CHARGE_UP_REDUC");
		}
		if (jsonAsset.hasOwnProperty("ATTACK_COLLISION_SCALE")) {
			INCREASE_COLLISION = ASCompat.asNumber(jsonAsset.ATTACK_COLLISION_SCALE);
		}
	}
}
