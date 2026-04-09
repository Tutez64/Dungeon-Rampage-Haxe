package account
;
   import brain.logger.Logger;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   
    class DBAccountParams
   {
      
      static inline final BETA_PLAYER= (0 : UInt);
      
      static inline final CHARGE= (1 : UInt);
      
      static inline final REPEATER= (2 : UInt);
      
      static inline final SCALING= (3 : UInt);
      
      static inline final COOLDOWN= (4 : UInt);
      
      static inline final MOVEMENT= (5 : UInt);
      
      static inline final REVIVE= (6 : UInt);
      
      static inline final LOOT_SHARING= (7 : UInt);
      
      static inline final CHEST_NEARBY= (8 : UInt);
      
      static inline final CHEST_COLLECTED= (9 : UInt);
      
      static inline final DUNGEON_BUSTER= (10 : UInt);
      
      static inline final BETA_REWARDS= (11 : UInt);
      
      static inline final KEY_INTRO= (12 : UInt);
      
      static inline final LIFESTREET= (13 : UInt);
      
      static inline final ACHIEVEMENT_1= (14 : UInt);
      
      static inline final ACHIEVEMENT_2= (15 : UInt);
      
      static inline final ACHIEVEMENT_3= (16 : UInt);
      
      static inline final ACHIEVEMENT_4= (17 : UInt);
      
      static inline final ACHIEVEMENT_5= (18 : UInt);
      
      static inline final ACHIEVEMENT_6= (19 : UInt);
      
      static inline final SUPER_WEAK= (20 : UInt);
      
      static var staticDBAccountParamsHelper:DBAccountParamsHelper;
      
      var mDBAccountInfo:DBAccountInfo;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:DBAccountInfo)
      {
         
         mDBFacade = param1;
         mDBAccountInfo = param2;
         if(staticDBAccountParamsHelper == null)
         {
            staticDBAccountParamsHelper = new DBAccountParamsHelper();
            staticDBAccountParamsHelper.saved_account_flags = mDBAccountInfo.account_flags;
            staticDBAccountParamsHelper.current_account_flags = mDBAccountInfo.account_flags;
         }
      }
      
      public function hasParam(param1:UInt) : Bool
      {
         var _loc2_= ((staticDBAccountParamsHelper.current_account_flags : Int) & 1 << (param1 : Int)) != 0;
         return ((staticDBAccountParamsHelper.current_account_flags : Int) & 1 << (param1 : Int)) != 0;
      }
      
      public function setParam(param1:UInt, param2:Bool = true) 
      {
         staticDBAccountParamsHelper.current_account_flags = ((staticDBAccountParamsHelper.current_account_flags | (1 << (param1 : Int) : UInt) : UInt) : UInt);
         if(param2)
         {
            flushParams();
         }
      }
      
      public function flushParams() 
      {
         var rpcSuccessCallback:ASFunction;
         var rpcFailureCallback:ASFunction;
         var rpcFunc:ASFunction;
         if(staticDBAccountParamsHelper.saved_account_flags == staticDBAccountParamsHelper.current_account_flags)
         {
            return;
         }
         rpcSuccessCallback = function(param1:ASAny)
         {
         };
         rpcFailureCallback = function(param1:ASAny)
         {
            Logger.warn("Flushing Params failed!");
         };
         rpcFunc = JSONRPCService.getFunction("addAccountBits",mDBFacade.rpcRoot + "account");
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,staticDBAccountParamsHelper.current_account_flags,rpcSuccessCallback,rpcFailureCallback);
         staticDBAccountParamsHelper.saved_account_flags = staticDBAccountParamsHelper.current_account_flags;
      }
      
      public function hasBetaPlayerParam() : Bool
      {
         return hasParam((0 : UInt));
      }
      
      public function hasChargeTutorialParam() : Bool
      {
         return hasParam((1 : UInt));
      }
      
      public function setChargeTutorialParam() 
      {
         setParam((1 : UInt),false);
      }
      
      public function hasRepeaterTutorialParam() : Bool
      {
         return hasParam((2 : UInt));
      }
      
      public function setRepeaterTutorialParam() 
      {
         setParam((2 : UInt),false);
      }
      
      public function hasScalingTutorialParam() : Bool
      {
         return hasParam((3 : UInt));
      }
      
      public function setScalingTutorialParam() 
      {
         setParam((3 : UInt),false);
      }
      
      public function hasCooldownTutorialParam() : Bool
      {
         return hasParam((4 : UInt));
      }
      
      public function setCooldownTutorialParam() 
      {
         setParam((4 : UInt),false);
      }
      
      public function hasMovementTutorialParam() : Bool
      {
         return hasParam((5 : UInt));
      }
      
      public function setMovementTutorialParam() 
      {
         setParam((5 : UInt),false);
      }
      
      public function hasReviveTutorialParam() : Bool
      {
         return hasParam((6 : UInt));
      }
      
      public function setReviveTutorialParam() 
      {
         setParam((6 : UInt),false);
      }
      
      public function hasLootSharingTutorialParam() : Bool
      {
         return hasParam((7 : UInt));
      }
      
      public function setLootSharingTutorialParam() 
      {
         setParam((7 : UInt),false);
      }
      
      public function hasChestNearbyTutorialParam() : Bool
      {
         return hasParam((8 : UInt));
      }
      
      public function setChestNearbyTutorialParam() 
      {
         setParam((8 : UInt),false);
      }
      
      public function hasChestCollectedTutorialParam() : Bool
      {
         return hasParam((9 : UInt));
      }
      
      public function setChestCollectedTutorialParam() 
      {
         setParam((9 : UInt),false);
      }
      
      public function hasDungeonBusterTutorialParam() : Bool
      {
         return hasParam((10 : UInt));
      }
      
      public function setDungeonBusterTutorialParam() 
      {
         setParam((10 : UInt),false);
      }
      
      public function hasBetaRewardsParam() : Bool
      {
         return hasParam((11 : UInt));
      }
      
      public function setBetaRewardsParam() 
      {
         setParam((11 : UInt),true);
      }
      
      public function hasKeyIntroParam() : Bool
      {
         return hasParam((12 : UInt));
      }
      
      public function setKeyIntroParam() 
      {
         setParam((12 : UInt),true);
      }
      
      public function hasLifestreetParam() : Bool
      {
         return hasParam((13 : UInt));
      }
      
      public function setLifestreetParam() 
      {
         setParam((13 : UInt),true);
      }
      
      public function hasAchievement(param1:UInt) : Bool
      {
         switch(param1 - 1)
         {
            case 0:
               return hasParam((14 : UInt));
            case 1:
               return hasParam((15 : UInt));
            case 2:
               return hasParam((16 : UInt));
            case 3:
               return hasParam((17 : UInt));
            case 4:
               return hasParam((18 : UInt));
            case 5:
               return hasParam((19 : UInt));
            default:
               return false;
         }
return false;
      }
      
      public function setAchievement(param1:UInt) 
      {
         switch(param1 - 1)
         {
            case 0:
               return setParam((14 : UInt),true);
            case 1:
               return setParam((15 : UInt),true);
            case 2:
               return setParam((16 : UInt),true);
            case 3:
               return setParam((17 : UInt),true);
            case 4:
               return setParam((18 : UInt),true);
            case 5:
               return setParam((19 : UInt),true);
            default:
               return;
         }
      }
      
      public function hasSuperWeakParam() : Bool
      {
         return hasParam((20 : UInt));
      }
      
      public function setSuperWeakParam() 
      {
         setParam((20 : UInt),true);
      }
   }


private class DBAccountParamsHelper
{
   
   public var saved_account_flags:UInt = 0;
   
   public var current_account_flags:UInt = 0;
   
   public function new()
   {
      
   }
}
