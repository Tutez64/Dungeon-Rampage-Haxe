package steamInput;

class RumbleEffect {
	public static final MENU_SELECTION:RumbleEffect = new RumbleEffect("MenuSelection", 0, 0.1, 0.1);

	public static final DUNGEON_BUSTER:RumbleEffect = new RumbleEffect("DungeonBuster", 1, 1, 3);

	public static final BERSERKER_MODE:RumbleEffect = new RumbleEffect("BerserkerMode", 0.9, 0.9, 1);

	public static final PLAYER_TAKING_DAMAGE:RumbleEffect = new RumbleEffect("PlayerTakingDamage", 0.3, 0.5, 0.2);

	public static final PLAYER_DEALING_DAMAGE:RumbleEffect = new RumbleEffect("PlayerDealingDamage", 0.5, 0.3, 0.2);

	public static final PLAYER_BIG_ATTACK:RumbleEffect = new RumbleEffect("PlayerBigAttack", 0, 0, 0.2);

	public static final PLAYER_MISS_ATTACK:RumbleEffect = new RumbleEffect("PlayerMiss", 0.1, 0, 0.05);

	public static final PLAYER_LOW_HEALTH:RumbleEffect = new RumbleEffect("PlayerLowHealth", 0.1, 0.1, 0.1);

	public static final ABILITY_CHARGING:RumbleEffect = new RumbleEffect("AbilityCharging", 0.2, 0.2, 1);

	public static final PLAYER_LEVEL_UP:RumbleEffect = new RumbleEffect("PlayerLevelUp", 0.5, 0.8, 0.5);

	public static final PLAYER_REVIVING_PARTY:RumbleEffect = new RumbleEffect("PlayerRevivingParty", 0.8, 0.8, 1);

	public static final PLAYER_REVIVING_INDIVIDUAL:RumbleEffect = new RumbleEffect("PlayerRevivingIndividual", 0.8, 0.5, 0.5);

	public static final BOSS_FIGHT_END:RumbleEffect = new RumbleEffect("BossFightEnd", 0.8, 0.8, 0.5);

	public static final PICKING_UP_ITEM:RumbleEffect = new RumbleEffect("PickingUpItem", 0.1, 0, 0.1);

	var mName:String;

	var mLeftIntensity:Float = Math.NaN;

	var mRightIntensity:Float = Math.NaN;

	var mDurationSeconds:Float = Math.NaN;

	public function new(name:String, leftIntensity:Float, rightIntensity:Float, durationSeconds:Float) {
		mName = name;
		mLeftIntensity = clampIntensity(leftIntensity);
		mRightIntensity = clampIntensity(rightIntensity);
		mDurationSeconds = durationSeconds > 0 ? durationSeconds : 0;
	}

	static function clampIntensity(intensity:Float):Float {
		if (intensity <= 0) {
			return 0;
		}
		return intensity < 1 ? intensity : 1;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return mName;
	}

	@:isVar public var leftIntensity(get, never):Float;

	public function get_leftIntensity():Float {
		return mLeftIntensity;
	}

	@:isVar public var rightIntensity(get, never):Float;

	public function get_rightIntensity():Float {
		return mRightIntensity;
	}

	@:isVar public var durationSeconds(get, never):Float;

	public function get_durationSeconds():Float {
		return mDurationSeconds;
	}

	public function scaled(multiplier:Float):RumbleEffect {
		return new RumbleEffect(mName, mLeftIntensity * multiplier, mRightIntensity * multiplier, mDurationSeconds);
	}

	public function withDuration(durationSeconds:Float):RumbleEffect {
		return new RumbleEffect(mName, mLeftIntensity, mRightIntensity, durationSeconds);
	}
}
