package combat.weapon
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import distributedObjects.DistributedDungeonFloor;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMStackable;
   import generatedCode.ConsumableDetails;
   import generatedCode.WeaponDetails;
   
    class ConsumableWeaponGameObject extends WeaponGameObject
   {
      
      public static inline final HEALTH_POTION_ID= (70000 : UInt);
      
      public static inline final MANA_POTION_ID= (70002 : UInt);
      
      public static inline final BUSTER_POTION_ID= (70009 : UInt);
      
      public static inline final HEALTH_SHOT_ID= (70016 : UInt);
      
      public static inline final MANA_SHOT_ID= (70017 : UInt);
      
      public static inline final BUSTER_SHOT_ID= (70018 : UInt);
      
      var mDefaultWeaponDetails:WeaponDetails = new WeaponDetails();
      
      var mConsumableDetails:ConsumableDetails;
      
      var mConsumableAttack:GMAttack;
      
      var mGMStackable:GMStackable;
      
      public function new(param1:ConsumableDetails, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:Float)
      {
         mConsumableDetails = param1;
         mDefaultWeaponDetails.type = (40000 : UInt);
         mDefaultWeaponDetails.rarity = (0 : UInt);
         mDefaultWeaponDetails.requiredlevel = (1 : UInt);
         mDefaultWeaponDetails.power = (1 : UInt);
         mDefaultWeaponDetails.modifier1 = (0 : UInt);
         mDefaultWeaponDetails.modifier2 = (0 : UInt);
         mDefaultWeaponDetails.legendarymodifier = (0 : UInt);
         super(mDefaultWeaponDetails,param2,param3,param4,param5,param6);
         mGMStackable = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(mConsumableDetails.type), gameMasterDictionary.GMStackable);
         mConsumableAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(mGMStackable.UsageAttack), gameMasterDictionary.GMAttack);
      }
      
      public function getConsumableAttack() : GMAttack
      {
         return mConsumableAttack;
      }
      
      public function getConsumableCount() : UInt
      {
         return mConsumableDetails.count;
      }
      
      public function consume() 
      {
         mConsumableDetails.count--;
         mDBFacade.hud.decrementConsumableCount((slot : UInt));
         if(mConsumableDetails.count == 0)
         {
            mDBFacade.hud.totalConsumableCountReached((slot : UInt));
         }
      }
      
      public function canExecute() : Bool
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(actorGameObject.isOwner)
         {
            _loc1_ = ASCompat.reinterpretAs(actorGameObject , HeroGameObjectOwner);
            switch(mConsumableDetails.type - 70000)
            {
               case 0:
                  mDBFacade.hud.showText("AT_MAX_HEALTH");
                  return _loc1_.hitPoints < _loc1_.maxHitPoints;
               case 2:
                  mDBFacade.hud.showText("AT_MAX_MANA");
                  return _loc1_.manaPoints < _loc1_.maxManaPoints;
               case 9:
                  mDBFacade.hud.showText("AT_MAX_DUNGEON_BUSTER");
                  return _loc1_.dungeonBusterPoints < _loc1_.maxBusterPoints;
               case 16:
                  mDBFacade.hud.showText("AT_MAX_HEALTH");
                  return _loc1_.hitPoints < _loc1_.maxHitPoints;
               case 17:
                  mDBFacade.hud.showText("AT_MAX_MANA");
                  return _loc1_.manaPoints < _loc1_.maxManaPoints;
               case 18:
                  mDBFacade.hud.showText("AT_MAX_DUNGEON_BUSTER");
                  return _loc1_.dungeonBusterPoints < _loc1_.maxBusterPoints;
            }
         }
         return true;
      }
      
      public function getGMStackable() : GMStackable
      {
         return mGMStackable;
      }
      
      override public function isConsumable() : Bool
      {
         return true;
      }
   }


