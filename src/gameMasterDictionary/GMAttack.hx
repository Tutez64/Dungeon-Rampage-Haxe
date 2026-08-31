package gameMasterDictionary;

import brain.logger.Logger;

class GMAttack extends GMItem {
	public static final g_melee:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(8, 2, 5, 0);

	public static final g_range:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(9, 3, 6, 1);

	public static final g_magic:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(10, 4, 7, 2);

	public var Team:String;

	public var WeaponReq:String;

	public var AttackType:String;

	public var AffectsOthers:Bool = false;

	public var AffectsProps:Bool = false;

	public var AffectsSelf:Bool = false;

	public var Targeting:String;

	public var CombatUsage:String;

	public var LineOfSightReq:Float = Math.NaN;

	public var UseAutoAim:Bool = false;

	public var AttackTimeline:String;

	public var DamageMod:Float = Math.NaN;

	public var StunChance:Float = Math.NaN;

	public var HitStunDur:Float = Math.NaN;

	public var InvincibleDur:Float = Math.NaN;

	public var Knockback:Float = Math.NaN;

	public var KnockbackDur:Float = Math.NaN;

	public var AttackSpdF:Float = Math.NaN;

	public var Range:Float = Math.NaN;

	public var Defense:Float = Math.NaN;

	public var Projectile:String;

	public var ChargeTime:Float = Math.NaN;

	public var CooldownLength:Float = Math.NaN;

	public var LockControls:Float = Math.NaN;

	public var StrafeControls:Float = Math.NaN;

	public var HitsPerCollision:Float = Math.NaN;

	public var MoveAmount:Float = Math.NaN;

	public var MoveAngle:Float = Math.NaN;

	public var MoveDuration:Float = Math.NaN;

	public var AIRechargeT:Float = Math.NaN;

	public var SwordTrail:String;

	public var SwordTrailSizeF:Float = Math.NaN;

	public var TrailTint:Float = Math.NaN;

	public var TrailSaturation:Float = Math.NaN;

	public var HitEffect:String;

	public var HitEffectFilepath:String;

	public var HitEffectStopRotation:Bool = false;

	public var HitEffectBehindAvatar:Bool = false;

	public var HitEffectLerpFilepath:String;

	public var HitEffectToLerpToAttacker:String;

	public var HitEffectToLerpFromAttacker:String;

	public var HitEffectToLerpSpeed:Float = Math.NaN;

	public var HitEffectToLerpGlowColor:UInt = 0;

	public var AttackSound:String;

	public var AttackVolume:Float = Math.NaN;

	public var ImpactSound:String;

	public var ImpactVolume:Float = Math.NaN;

	public var Description:String;

	public var ComboWindow:Float = Math.NaN;

	public var RecoveryTime:Float = Math.NaN;

	public var IconFilepath:String;

	public var IconName:String;

	public var ManaCost:Float = Math.NaN;

	public var StatOffsets:GMAttack_StateVectorOffsets;

	public var CrowdCost:UInt = 0;

	public var Unblockable:Bool = false;

	public var SpawnNPC:String;

	public var SetTeleport:Bool = false;

	public var AttackOnHit:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		Team = jsonAsset.Team;
		WeaponReq = jsonAsset.WeaponReq;
		AttackType = jsonAsset.AttackType;
		Targeting = jsonAsset.Targeting;
		AffectsOthers = ASCompat.toBool(jsonAsset.AffectsOthers);
		AffectsProps = ASCompat.toBool(jsonAsset.AffectsProps);
		AffectsSelf = ASCompat.toBool(jsonAsset.AffectsSelf);
		CombatUsage = jsonAsset.CombatUsage;
		LineOfSightReq = ASCompat.toNumberField(jsonAsset, "LineOfSightReq");
		UseAutoAim = ASCompat.toBool(jsonAsset.UseAutoAim);
		AttackTimeline = jsonAsset.AttackTimeline;
		DamageMod = ASCompat.toNumberField(jsonAsset, "DamageMod");
		StunChance = ASCompat.toNumberField(jsonAsset, "StunChance");
		HitStunDur = ASCompat.toNumberField(jsonAsset, "HitStunDur");
		InvincibleDur = ASCompat.toNumberField(jsonAsset, "InvincibleDur");
		Knockback = ASCompat.toNumberField(jsonAsset, "Knockback");
		KnockbackDur = ASCompat.toNumberField(jsonAsset, "KnockbackDur");
		AttackSpdF = ASCompat.toNumberField(jsonAsset, "AttackSpd");
		Range = ASCompat.toNumberField(jsonAsset, "Range");
		Defense = ASCompat.toNumberField(jsonAsset, "Defense");
		Projectile = jsonAsset.Projectile;
		ChargeTime = ASCompat.toNumberField(jsonAsset, "ChargeTime");
		CooldownLength = ASCompat.toNumberField(jsonAsset, "CooldownLength");
		LockControls = ASCompat.toNumberField(jsonAsset, "LockControls");
		StrafeControls = ASCompat.toNumberField(jsonAsset, "StrafeControls");
		HitsPerCollision = ASCompat.toNumberField(jsonAsset, "HitsPerCollision");
		MoveAmount = ASCompat.toNumberField(jsonAsset, "MoveAmount");
		MoveAngle = ASCompat.toNumberField(jsonAsset, "MoveAngle");
		MoveDuration = ASCompat.toNumberField(jsonAsset, "MoveDuration");
		AIRechargeT = ASCompat.toNumberField(jsonAsset, "AI_RechargeT");
		SwordTrail = jsonAsset.SwordTrail;
		TrailTint = ASCompat.toNumberField(jsonAsset, "TrailTint");
		TrailSaturation = ASCompat.toNumberField(jsonAsset, "TrailSaturation") / 100 + 1;
		HitEffect = jsonAsset.HitEffect;
		HitEffectStopRotation = ASCompat.toBool(jsonAsset.HitEffectStopRotation);
		HitEffectFilepath = ASCompat.toBool(jsonAsset.HitEffectFilepath) ? jsonAsset.HitEffectFilepath : "Resources/Art2D/FX/db_fx_library.swf";
		HitEffectBehindAvatar = ASCompat.toBool(ASCompat.toBool(jsonAsset.HitEffectBehindAvatar) ? ASCompat.toBool(jsonAsset.HitEffectBehindAvatar) : false);
		HitEffectLerpFilepath = ASCompat.toBool(jsonAsset.HitEffectLerpFilepath) ? jsonAsset.HitEffectLerpFilepath : "Resources/Art2D/FX/db_fx_library.swf";
		HitEffectToLerpToAttacker = jsonAsset.HitEffectToLerpToAttacker;
		HitEffectToLerpFromAttacker = jsonAsset.HitEffectToLerpFromAttacker;
		HitEffectToLerpSpeed = ASCompat.toNumberField(jsonAsset, "HitEffectToLerpSpeed");
		HitEffectToLerpGlowColor = (ASCompat.toInt(jsonAsset.HitEffectToLerpGlowColor) : UInt);
		AttackSound = jsonAsset.AttackSound;
		AttackVolume = ASCompat.toNumberField(jsonAsset, "AttackVol");
		ImpactSound = jsonAsset.ImpactSound;
		ImpactVolume = ASCompat.toNumberField(jsonAsset, "ImpactVol");
		Description = jsonAsset.Description;
		ComboWindow = ASCompat.toNumberField(jsonAsset, "ComboWindow");
		RecoveryTime = ASCompat.toNumberField(jsonAsset, "RecoveryTime");
		ManaCost = ASCompat.toNumberField(jsonAsset, "ManaCost");
		IconFilepath = jsonAsset.IconFilepath;
		IconName = jsonAsset.IconName;
		CrowdCost = (ASCompat.toInt(jsonAsset.CrowdCost) : UInt);
		Unblockable = ASCompat.toBool(jsonAsset.Unblockable);
		SpawnNPC = jsonAsset.SpawnNPC;
		SetTeleport = ASCompat.toBool(jsonAsset.SetTeleport);
		AttackOnHit = jsonAsset.AttackOnHit;
		switch (AttackType) {
			case "MELEE":
				StatOffsets = g_melee;

			case "SHOOTING":
				StatOffsets = g_range;

			case "MAGIC":
				StatOffsets = g_magic;

			case "SUPPORT" | "ANIMATION":

			default:
				Logger.warn("GMAttack: unknown AttackType: " + AttackType);
		}
	}
}
