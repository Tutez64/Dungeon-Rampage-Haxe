package gameMasterDictionary;

import brain.logger.Logger;
import dBGlobals.As3Compat;
import dBGlobals.DBGlobal;
import flash.Boot;

class GMAttack extends GMItem {
	public static var g_melee:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(DBGlobal.MELEE_SPD, DBGlobal.MELEE_ATK, DBGlobal.MELEE_DEF,
		DBGlobal.ATTTACK_TYPE_MELEE);

	public static var g_range:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(DBGlobal.SHOOT_SPD, DBGlobal.SHOOT_ATK, DBGlobal.SHOOT_DEF,
		DBGlobal.ATTTACK_TYPE_RANGE);

	public static var g_magic:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(DBGlobal.MAGIC_SPD, DBGlobal.MAGIC_ATK, DBGlobal.MAGIC_DEF,
		DBGlobal.ATTTACK_TYPE_MAGIC);

	public var WeaponReq:String;

	public var UseAutoAim:Bool = false;

	public var Unblockable:Bool = false;

	public var TrailTint:Float = Math.NaN;

	public var TrailSaturation:Float = Math.NaN;

	public var Team:String;

	public var Targeting:String;

	public var SwordTrailSizeF:Float = Math.NaN;

	public var SwordTrail:String;

	public var StunChance:Float = Math.NaN;

	public var StrafeControls:Float = Math.NaN;

	public var StatOffsets:GMAttack_StateVectorOffsets;

	public var SpawnNPC:String;

	public var SetTeleport:Bool = false;

	public var RecoveryTime:Float = Math.NaN;

	public var Range:Float = Math.NaN;

	public var Projectile:String;

	public var MoveDuration:Float = Math.NaN;

	public var MoveAngle:Float = Math.NaN;

	public var MoveAmount:Float = Math.NaN;

	public var ManaCost:Float = Math.NaN;

	public var LockControls:Float = Math.NaN;

	public var LineOfSightReq:Float = Math.NaN;

	public var KnockbackDur:Float = Math.NaN;

	public var Knockback:Float = Math.NaN;

	public var InvincibleDur:Float = Math.NaN;

	public var ImpactVolume:Float = Math.NaN;

	public var ImpactSound:String;

	public var IconName:String;

	public var IconFilepath:String;

	public var HitsPerCollision:Float = Math.NaN;

	public var HitStunDur:Float = Math.NaN;

	public var HitEffectToLerpToAttacker:String;

	public var HitEffectToLerpSpeed:Float = Math.NaN;

	public var HitEffectToLerpGlowColor:UInt = 0;

	public var HitEffectToLerpFromAttacker:String;

	public var HitEffectStopRotation:Bool = false;

	public var HitEffectLerpFilepath:String;

	public var HitEffectFilepath:String;

	public var HitEffectBehindAvatar:Bool = false;

	public var HitEffect:String;

	public var Description:String;

	public var Defense:Float = Math.NaN;

	public var DamageMod:Float = Math.NaN;

	public var CrowdCost:UInt = 0;

	public var CooldownLength:Float = Math.NaN;

	public var ComboWindow:Float = Math.NaN;

	public var CombatUsage:String;

	public var ChargeTime:Float = Math.NaN;

	public var AttackVolume:Float = Math.NaN;

	public var AttackType:String;

	public var AttackTimeline:String;

	public var AttackSpdF:Float = Math.NaN;

	public var AttackSound:String;

	public var AttackOnHit:String;

	public var AffectsSelf:Bool = false;

	public var AffectsProps:Bool = false;

	public var AffectsOthers:Bool = false;

	public var AIRechargeT:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		var _loc2_:Float;
		var _loc3_:String;
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			Team = jsonAsset.Team;
			WeaponReq = jsonAsset.WeaponReq;
			AttackType = jsonAsset.AttackType;
			Targeting = jsonAsset.Targeting;
			AffectsOthers = ASCompat.toBool(jsonAsset.AffectsOthers);
			AffectsProps = ASCompat.toBool(jsonAsset.AffectsProps);
			AffectsSelf = ASCompat.toBool(jsonAsset.AffectsSelf);
			CombatUsage = jsonAsset.CombatUsage;
			LineOfSightReq = ASCompat.toNumber(jsonAsset.LineOfSightReq);
			UseAutoAim = ASCompat.toBool(jsonAsset.UseAutoAim);
			AttackTimeline = jsonAsset.AttackTimeline;
			DamageMod = ASCompat.toNumber(jsonAsset.DamageMod);
			StunChance = ASCompat.toNumber(jsonAsset.StunChance);
			HitStunDur = ASCompat.toNumber(jsonAsset.HitStunDur);
			InvincibleDur = ASCompat.toNumber(jsonAsset.InvincibleDur);
			Knockback = ASCompat.toNumber(jsonAsset.Knockback);
			KnockbackDur = ASCompat.toNumber(jsonAsset.KnockbackDur);
			AttackSpdF = ASCompat.toNumber(jsonAsset.AttackSpd);
			Range = ASCompat.toNumber(jsonAsset.Range);
			Defense = ASCompat.toNumber(jsonAsset.Defense);
			Projectile = jsonAsset.Projectile;
			ChargeTime = ASCompat.toNumber(jsonAsset.ChargeTime);
			CooldownLength = ASCompat.toNumber(jsonAsset.CooldownLength);
			LockControls = ASCompat.toNumber(jsonAsset.LockControls);
			StrafeControls = ASCompat.toNumber(jsonAsset.StrafeControls);
			HitsPerCollision = ASCompat.toNumber(jsonAsset.HitsPerCollision);
			MoveAmount = ASCompat.toNumber(jsonAsset.MoveAmount);
			MoveAngle = ASCompat.toNumber(jsonAsset.MoveAngle);
			MoveDuration = ASCompat.toNumber(jsonAsset.MoveDuration);
			AIRechargeT = ASCompat.toNumber(jsonAsset.AI_RechargeT);
			SwordTrail = jsonAsset.SwordTrail;
			TrailTint = ASCompat.toNumber(jsonAsset.TrailTint);
			_loc2_ = ASCompat.toNumber(jsonAsset.TrailSaturation);
			TrailSaturation = _loc2_ / 100 + 1;
			HitEffect = jsonAsset.HitEffect;
			HitEffectStopRotation = ASCompat.toBool(jsonAsset.HitEffectStopRotation);
			HitEffectFilepath = As3Compat.truthy(jsonAsset.HitEffectFilepath) ? jsonAsset.HitEffectFilepath : "Resources/Art2D/FX/db_fx_library.swf";
			HitEffectBehindAvatar = As3Compat.truthy(jsonAsset.HitEffectBehindAvatar) && ASCompat.toBool(jsonAsset.HitEffectBehindAvatar);
			HitEffectLerpFilepath = As3Compat.truthy(jsonAsset.HitEffectLerpFilepath) ? jsonAsset.HitEffectLerpFilepath : "Resources/Art2D/FX/db_fx_library.swf";
			HitEffectToLerpToAttacker = jsonAsset.HitEffectToLerpToAttacker;
			HitEffectToLerpFromAttacker = jsonAsset.HitEffectToLerpFromAttacker;
			HitEffectToLerpSpeed = ASCompat.toNumber(jsonAsset.HitEffectToLerpSpeed);
			HitEffectToLerpGlowColor = (ASCompat.toInt(jsonAsset.HitEffectToLerpGlowColor) : UInt);
			AttackSound = jsonAsset.AttackSound;
			AttackVolume = ASCompat.toNumber(jsonAsset.AttackVol);
			ImpactSound = jsonAsset.ImpactSound;
			ImpactVolume = ASCompat.toNumber(jsonAsset.ImpactVol);
			Description = jsonAsset.Description;
			ComboWindow = ASCompat.toNumber(jsonAsset.ComboWindow);
			RecoveryTime = ASCompat.toNumber(jsonAsset.RecoveryTime);
			ManaCost = ASCompat.toNumber(jsonAsset.ManaCost);
			IconFilepath = jsonAsset.IconFilepath;
			IconName = jsonAsset.IconName;
			CrowdCost = (ASCompat.toInt(jsonAsset.CrowdCost) : UInt);
			Unblockable = ASCompat.toBool(jsonAsset.Unblockable);
			SpawnNPC = jsonAsset.SpawnNPC;
			SetTeleport = ASCompat.toBool(jsonAsset.SetTeleport);
			AttackOnHit = jsonAsset.AttackOnHit;
			_loc3_ = AttackType;
			while (true) {
				if (_loc3_ != "ANIMATION") {
					if (_loc3_ != "SUPPORT") {
						if (_loc3_ == "MAGIC") {
							StatOffsets = GMAttack.g_magic;
							break;
						}
						if (_loc3_ == "MELEE") {
							StatOffsets = GMAttack.g_melee;
							break;
						}
						if (_loc3_ == "SHOOTING") {
							StatOffsets = GMAttack.g_range;
							break;
						}
						Logger.warn("GMAttack: unknown AttackType: " + AttackType);
						break;
					}
				}
				break;
			}
		}
	}
}
