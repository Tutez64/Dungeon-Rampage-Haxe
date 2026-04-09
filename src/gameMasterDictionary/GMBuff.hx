package gameMasterDictionary
;
   import dBGlobals.DBGlobal;
   
    class GMBuff extends GMItem
   {
      
      public var Team:String;
      
      public var Duration:Float = Math.NaN;
      
      public var LayerPriority:Float = Math.NaN;
      
      public var SwapDisplay:Bool = false;
      
      public var Type:String;
      
      public var Ability:UInt = 0;
      
      public var DeltaValues:StatVector;
      
      public var Exp:Float = Math.NaN;
      
      public var EventExp:Float = Math.NaN;
      
      public var Gold:Float = Math.NaN;
      
      public var VFX:String;
      
      public var VFXFilepath:String;
      
      public var TintColor:Float = Math.NaN;
      
      public var TintAmountF:Float = Math.NaN;
      
      public var Description:String;
      
      public var SortLayer:String;
      
      public var BuffFloaterColor:UInt = 0;
      
      public var Scale:Float = Math.NaN;
      
      public var ScaleStartDelay:Float = Math.NaN;
      
      public var ShakeLocalCamera:Bool = false;
      
      public var ScaleUpIncrementTime:Float = Math.NaN;
      
      public var ScaleUpIncrementScale:Float = Math.NaN;
      
      public var ShowInHUD:Bool = false;
      
      public var IconSwf:String;
      
      public var IconName:String;
      
      public var DescriptionPercentForEachStack:Float = Math.NaN;
      
      public var AttackCooldownMultiplier:Float = Math.NaN;
      
      public function new(param1:ASObject)
      {
         super(param1);
         Team = param1.Team;
         Duration = ASCompat.toNumberField(param1, "Duration");
         LayerPriority = ASCompat.toNumberField(param1, "LayerPriority");
         SwapDisplay = param1.SwapDisplay != null;
         Type = param1.BuffType;
         Ability = (0 : UInt);
         Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability1) : UInt) : UInt);
         Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability2) : UInt) : UInt);
         Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability3) : UInt) : UInt);
         DeltaValues = new StatVector();
         DeltaValues.SetFromJSON(param1);
         Exp = ASCompat.toNumberField(param1, "EXP");
         EventExp = ASCompat.toNumberField(param1, "EVENT_EXP");
         Gold = ASCompat.toNumber(ASCompat.toBool(param1.Gold) ? ASCompat.toNumberField(param1, "Gold") : 1);
         VFX = param1.VFX;
         VFXFilepath = ASCompat.toBool(param1.VFXFilepath) ? param1.VFXFilepath : "Resources/Art2D/FX/db_fx_library.swf";
         SortLayer = param1.SortLayer;
         TintColor = -1;
         TintAmountF = 1;
         var _loc2_:String = param1.TintColor;
         if(_loc2_ != null)
         {
            TintColor = ASCompat.parseInt(_loc2_,16);
            TintAmountF = ASCompat.toNumberField(param1, "TintAmount");
         }
         Description = param1.Description;
         BuffFloaterColor = (ASCompat.toInt(param1.BuffFloaterColor) : UInt);
         Scale = ASCompat.toNumberField(param1, "Scale");
         ShakeLocalCamera = ASCompat.toBool(param1.ShakeLocalCamera);
         ScaleStartDelay = ASCompat.toNumberField(param1, "ScaleUpStartDelay");
         ScaleUpIncrementTime = ASCompat.toNumberField(param1, "ScaleUpIncrementTime");
         ScaleUpIncrementScale = ASCompat.toNumberField(param1, "ScaleUpIncrementScale");
         ShowInHUD = ASCompat.toBool(param1.ShowInHUD);
         IconSwf = param1.IconSwf;
         IconName = param1.IconName;
         DescriptionPercentForEachStack = ASCompat.toNumber(ASCompat.toBool(param1.DescriptionPercentForEachStack) ? ASCompat.toNumberField(param1, "DescriptionPercentForEachStack") : 0);
         AttackCooldownMultiplier = 1;
         if(param1.AttackCooldownMultiplier != null)
         {
            AttackCooldownMultiplier = ASCompat.toNumberField(param1, "AttackCooldownMultiplier");
         }
      }
      
      public function getStacksDescription(param1:Int) : String
      {
         var _loc2_= DescriptionPercentForEachStack * param1;
         if(_loc2_ > 0)
         {
            return Std.string(_loc2_) + "%";
         }
         return "";
      }
   }


