package combat.weapon
;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class ConsumableWeaponController extends WeaponController
   {
      
      var consumableWeapon:ConsumableWeaponGameObject;
      
      public function new(param1:DBFacade, param2:ConsumableWeaponGameObject, param3:HeroGameObjectOwner)
      {
         super(param1,param2,param3);
         consumableWeapon = param2;
      }
      
      public function consume() 
      {
         if(consumableWeapon.canExecute() && consumableWeapon.getConsumableAttack() != null && consumableWeapon.getConsumableCount() > 0)
         {
            attack(consumableWeapon.getConsumableAttack().Id,false,1,consumableWeapon.getConsumableCount() > 1);
            consumableWeapon.consume();
         }
      }
      
      override function updateHudCooldown(param1:Bool) 
      {
         if(param1)
         {
            mDBFacade.hud.startConsumableCooldown(weapon.slot,mCoolDownTime / 1000);
         }
         else
         {
            mDBFacade.hud.stopConsumableCooldown(weapon.slot);
         }
      }
      
      override public function destroy() 
      {
         mDBFacade.hud.stopConsumableCooldown(weapon.slot);
      }
   }


