package gameMasterDictionary
;
   import brain.logger.Logger;
   
    class GMAttack extends GMItem
   {
      
      public static final g_melee:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(8,2,5,0);
      
      public static final g_range:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(9,3,6,1);
      
      public static final g_magic:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(10,4,7,2);
      
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
      
      public function new(param1:ASObject)
      {
         super(param1);
         Team = param1.Team;
         WeaponReq = param1.WeaponReq;
         AttackType = param1.AttackType;
         Targeting = param1.Targeting;
         AffectsOthers = ASCompat.toBool(param1.AffectsOthers);
         AffectsProps = ASCompat.toBool(param1.AffectsProps);
         AffectsSelf = ASCompat.toBool(param1.AffectsSelf);
         CombatUsage = param1.CombatUsage;
         LineOfSightReq = ASCompat.toNumberField(param1, "LineOfSightReq");
         UseAutoAim = ASCompat.toBool(param1.UseAutoAim);
         AttackTimeline = param1.AttackTimeline;
         DamageMod = ASCompat.toNumberField(param1, "DamageMod");
         StunChance = ASCompat.toNumberField(param1, "StunChance");
         HitStunDur = ASCompat.toNumberField(param1, "HitStunDur");
         InvincibleDur = ASCompat.toNumberField(param1, "InvincibleDur");
         Knockback = ASCompat.toNumberField(param1, "Knockback");
         KnockbackDur = ASCompat.toNumberField(param1, "KnockbackDur");
         AttackSpdF = ASCompat.toNumberField(param1, "AttackSpd");
         Range = ASCompat.toNumberField(param1, "Range");
         Defense = ASCompat.toNumberField(param1, "Defense");
         Projectile = param1.Projectile;
         ChargeTime = ASCompat.toNumberField(param1, "ChargeTime");
         CooldownLength = ASCompat.toNumberField(param1, "CooldownLength");
         LockControls = ASCompat.toNumberField(param1, "LockControls");
         StrafeControls = ASCompat.toNumberField(param1, "StrafeControls");
         HitsPerCollision = ASCompat.toNumberField(param1, "HitsPerCollision");
         MoveAmount = ASCompat.toNumberField(param1, "MoveAmount");
         MoveAngle = ASCompat.toNumberField(param1, "MoveAngle");
         MoveDuration = ASCompat.toNumberField(param1, "MoveDuration");
         AIRechargeT = ASCompat.toNumberField(param1, "AI_RechargeT");
         SwordTrail = param1.SwordTrail;
         TrailTint = ASCompat.toNumberField(param1, "TrailTint");
         TrailSaturation = ASCompat.toNumberField(param1, "TrailSaturation") / 100 + 1;
         HitEffect = param1.HitEffect;
         HitEffectStopRotation = ASCompat.toBool(param1.HitEffectStopRotation);
         HitEffectFilepath = ASCompat.toBool(param1.HitEffectFilepath) ? param1.HitEffectFilepath : "Resources/Art2D/FX/db_fx_library.swf";
         HitEffectBehindAvatar = ASCompat.toBool(ASCompat.toBool(param1.HitEffectBehindAvatar) ? ASCompat.toBool(param1.HitEffectBehindAvatar) : false);
         HitEffectLerpFilepath = ASCompat.toBool(param1.HitEffectLerpFilepath) ? param1.HitEffectLerpFilepath : "Resources/Art2D/FX/db_fx_library.swf";
         HitEffectToLerpToAttacker = param1.HitEffectToLerpToAttacker;
         HitEffectToLerpFromAttacker = param1.HitEffectToLerpFromAttacker;
         HitEffectToLerpSpeed = ASCompat.toNumberField(param1, "HitEffectToLerpSpeed");
         HitEffectToLerpGlowColor = (ASCompat.toInt(param1.HitEffectToLerpGlowColor) : UInt);
         AttackSound = param1.AttackSound;
         AttackVolume = ASCompat.toNumberField(param1, "AttackVol");
         ImpactSound = param1.ImpactSound;
         ImpactVolume = ASCompat.toNumberField(param1, "ImpactVol");
         Description = param1.Description;
         ComboWindow = ASCompat.toNumberField(param1, "ComboWindow");
         RecoveryTime = ASCompat.toNumberField(param1, "RecoveryTime");
         ManaCost = ASCompat.toNumberField(param1, "ManaCost");
         IconFilepath = param1.IconFilepath;
         IconName = param1.IconName;
         CrowdCost = (ASCompat.toInt(param1.CrowdCost) : UInt);
         Unblockable = ASCompat.toBool(param1.Unblockable);
         SpawnNPC = param1.SpawnNPC;
         SetTeleport = ASCompat.toBool(param1.SetTeleport);
         AttackOnHit = param1.AttackOnHit;
         switch(AttackType)
         {
            case "MELEE":
               StatOffsets = g_melee;
               
            case "SHOOTING":
               StatOffsets = g_range;
               
            case "MAGIC":
               StatOffsets = g_magic;
               
            case "SUPPORT"
               | "ANIMATION":
               
            default:
               Logger.warn("GMAttack: unknown AttackType: " + AttackType);
         }
      }
   }


