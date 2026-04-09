package gameMasterDictionary
;
   import dBGlobals.DBGlobal;
   
    class GMNpc extends GMActor
   {
      
      public var IsNavigable:Bool = false;
      
      public var IsAttackable:Bool = false;
      
      public var HasHealthbar:Bool = false;
      
      public var UsePetUI:Bool = false;
      
      public var IsBoss:Bool = false;
      
      public var ActivateSound:String;
      
      public var ActivateVolume:Float = Math.NaN;
      
      public var DeactivateSound:String;
      
      public var DeactivateVolume:Float = Math.NaN;
      
      public var DefaultHeading:Int = 0;
      
      public var DefaultLayer:String;
      
      public var UseFlashRotation:Bool = false;
      
      public var PermCorpse:Bool = false;
      
      public var ArchwayAlpha:Bool = false;
      
      public var ViolentDeathClassName:String;
      
      public var ViolentDeathFilePath:String;
      
      public var BlockingDotProduct:Float = Math.NaN;
      
      public var SellCoins:Int = 0;
      
      public var AttackRating:UInt = 0;
      
      public var DefenseRating:UInt = 0;
      
      public var SpeedRating:UInt = 0;
      
      public var TileTheme:String;
      
      public var UseTeleportAI:Bool = false;
      
      public var ShowHealNumbers:Bool = false;
      
      public function new(param1:ASObject)
      {
         super(param1);
         if(param1.Ability1 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability1) : UInt) : UInt);
         }
         if(param1.Ability2 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability2) : UInt) : UInt);
         }
         if(param1.Ability3 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability3) : UInt) : UInt);
         }
         if(param1.Ability4 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability4) : UInt) : UInt);
         }
         if(param1.Ability5 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability5) : UInt) : UInt);
         }
         Weapon1 = param1.Weapon1;
         Weapon2 = param1.Weapon2;
         Weapon3 = param1.Weapon3;
         Weapon4 = param1.Weapon4;
         Weapon5 = param1.Weapon5;
         SellCoins = ASCompat.toInt(param1.SellCoin);
         AttackRating = (ASCompat.toInt(param1.AttackRating) : UInt);
         DefenseRating = (ASCompat.toInt(param1.DefenseRating) : UInt);
         SpeedRating = (ASCompat.toInt(param1.SpeedRating) : UInt);
         IsNavigable = ASCompat.toNumberField(param1, "IsNavigable") == 1;
         if(Constant == "GARLIC_PLACEABLE_L2")
         {
            IsNavigable = true;
         }
         IsAttackable = ASCompat.toNumberField(param1, "IsAttackable") == 1;
         IsBoss = ASCompat.toNumberField(param1, "IsBoss") == 1;
         HasHealthbar = ASCompat.toBool(param1.HasHealthbar);
         UsePetUI = ASCompat.toBool(param1.UsePetUI);
         UseTeleportAI = param1.Aggro_AI_Type == "TELEPORT_AI";
         ActivateSound = param1.ActivateSound;
         ActivateVolume = ASCompat.toNumberField(param1, "ActivateVol");
         DeactivateSound = param1.DeactivateSound;
         DeactivateVolume = ASCompat.toNumberField(param1, "DeactivateVol");
         DefaultHeading = ASCompat.toInt(param1.DefaultHeading);
         DefaultLayer = param1.DefaultLayer;
         TileTheme = param1.TileTheme;
         UseFlashRotation = ASCompat.toBool(param1.UseFlashRotation);
         PermCorpse = ASCompat.toBool(param1.PermCorpse);
         ArchwayAlpha = ASCompat.toBool(param1.ArchwayAlpha);
         ViolentDeathClassName = param1.ViolentDeathClassName;
         ViolentDeathFilePath = param1.ViolentDeathFilePath;
         BlockingDotProduct = ASCompat.toNumberField(param1, "BlockingDotProduct");
         ShowHealNumbers = ASCompat.toBool(param1.ShowHealNumbers);
      }
      
      public function blocksNatively() : Bool
      {
         return BlockingDotProduct > -1.1;
      }
   }


