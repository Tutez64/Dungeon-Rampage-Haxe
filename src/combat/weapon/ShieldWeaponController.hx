package combat.weapon
;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class ShieldWeaponController extends WeaponController
   {
      
      public function new(param1:DBFacade, param2:WeaponGameObject, param3:HeroGameObjectOwner)
      {
         super(param1,param2,param3);
      }
      
      override public function onWeaponDown(param1:Bool = true) 
      {
         var _loc2_= 0;
         if(!mWeaponDownActive)
         {
            _loc2_ = (this.getNextAttackId() : Int);
            mWeaponDownActive = true;
            attack((_loc2_ : UInt),false);
         }
      }
      
      override public function onWeaponUp(param1:Bool = true) 
      {
         mWeaponDownActive = false;
         stopCurrentTimeline();
      }
      
      override public function canCombo() : Bool
      {
         return true;
      }
   }


