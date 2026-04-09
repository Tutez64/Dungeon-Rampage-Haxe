package combat.attack
;
   import actor.player.HeroView;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class TavernPlayerOwnerAttackController extends PlayerOwnerAttackController
   {
      
      public function new(param1:HeroGameObjectOwner, param2:HeroView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      override function canQueueWeaponDown(param1:PotentialWeaponInputQueueStruct) : Bool
      {
         return true;
      }
      
      override function canQueueWeaponUp(param1:PotentialWeaponInputQueueStruct) : Bool
      {
         return true;
      }
      
      override function tryAttack() 
      {
         if(mNextWeaponCommand == null)
         {
            return;
         }
         mDistributedPlayerOwner.currentWeaponIndex = (mNextWeaponCommand.weaponIndex : Int);
         mNextWeaponCommand = null;
      }
   }


