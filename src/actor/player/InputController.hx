package actor.player
;
   import actor.player.input.GBS_ModernMouseController;
   import actor.player.input.IMouseController;
   import actor.player.input.KeyboardController;
   import brain.utils.Tuple;
   import brain.workLoop.LogicalWorkComponent;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class InputController
   {
      
      public static inline final FREE= "free";
      
      static inline final LOCK_XY= "lock_xy";
      
      static inline final LOCK_R= "lock_r";
      
      static inline final LOCK_XY_R= "lock_xy_r";
      
      var mDBFacade:DBFacade;
      
      var mHeroGameObject:HeroGameObjectOwner;
      
      var mDirectionVector:Vector3D = new Vector3D();
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAbortAstarPathWalk:Bool = false;
      
      var mWantCameraZoom:Bool = false;
      
      var mKeyboardController:KeyboardController;
      
      var mMouseController:IMouseController;
      
      var mInputType:String = "free";
      
      var mCombatDisabled:Bool = false;
      
      public function new(param1:HeroGameObjectOwner, param2:DBFacade)
      {
         
         mDBFacade = param2;
         mHeroGameObject = param1;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mWantCameraZoom = mDBFacade.dbConfigManager.getConfigBoolean("camera_zoom",false);
         mKeyboardController = new KeyboardController(mDBFacade,mHeroGameObject);
         mMouseController = new GBS_ModernMouseController(mDBFacade,mHeroGameObject);
         mCombatDisabled = false;
      }
      
      public function destroy() 
      {
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mKeyboardController.destroy();
         mKeyboardController = null;
         mMouseController.destroy();
         mMouseController = null;
         mDBFacade = null;
         mHeroGameObject = null;
      }
      
      public function init() 
      {
         mMouseController.init();
      }
      
      public function stop() 
      {
         mMouseController.stop();
      }
      
      public function perFrameUpCall() 
      {
         var _loc5_= false;
         mHeroGameObject.position = mHeroGameObject.navCollisions[0].position;
         var _loc3_:Float = mDBFacade.inputManager.mouseWheelDelta;
         if(_loc3_ != 0)
         {
            _loc5_ = _loc3_ > 0;
            mHeroGameObject.PlayerAttack.scrollWeapons(_loc5_);
         }
         mKeyboardController.perFrameUpCall();
         mMouseController.perFrameUpCall();
         var _loc4_= determineInputHeading();
         var _loc1_= determineInputVelocity();
         var _loc2_= Math.atan2(_loc4_.y,_loc4_.x) * 180 / 3.141592653589793;
         if(_loc4_.x != 0 || _loc4_.y != 0)
         {
            mHeroGameObject.inputHeading = _loc2_;
         }
         if(!mCombatDisabled)
         {
            translateInputIntoAttacks();
            mHeroGameObject.PlayerAttack.weaponCommandQueueUpCall();
         }
         translateInputIntoConsumableUse();
         if(!canMoveXY(mInputType))
         {
            _loc1_.scaleBy(0);
            mMouseController.clearMovement();
         }
         mHeroGameObject.inputVelocity = _loc1_;
         mHeroGameObject.setViewVelocity();
         if(canMoveR(mInputType) && (_loc4_.x != 0 || _loc4_.y != 0))
         {
            mHeroGameObject.heading = _loc2_;
         }
      }
      
      public function disableCombat() 
      {
         mCombatDisabled = true;
         inputType = "lock_xy";
         mKeyboardController.combatDisabled = true;
         mMouseController.combatDisabled = true;
         mHeroGameObject.PlayerAttack.resetWeapons();
      }
      
      public function enableCombat() 
      {
         mCombatDisabled = false;
         inputType = "free";
         mKeyboardController.combatDisabled = false;
         mMouseController.combatDisabled = false;
      }
      
      function translateInputIntoAttacks() 
      {
         var _loc4_= 0;
         var _loc5_= 0;
         var _loc6_:Array<ASAny> = null;
         var _loc3_:Tuple = null;
         var _loc2_= false;
         var _loc1_= mKeyboardController.pressedCombatKeysThisFrame;
         var _loc7_= mKeyboardController.releasedCombatKeysThisFrame;
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc4_ = mKeyboardController.KeyIndexToAttack(_loc5_);
            if(_loc1_[_loc5_] != 0)
            {
               mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((_loc4_ : UInt),true,true);
               _loc2_ = true;
            }
            if(_loc7_[_loc5_] != 0)
            {
               mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((_loc4_ : UInt),false,true);
               _loc2_ = true;
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         if(!_loc2_)
         {
            _loc6_ = mMouseController.potentialAttacksThisFrame;
            _loc5_ = 0;
            while(_loc5_ < _loc6_.length)
            {
               _loc3_ = ASCompat.dynamicAs(_loc6_[_loc5_], brain.utils.Tuple);
               mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((ASCompat.toInt(_loc3_.first) : UInt),ASCompat.toBool(_loc3_.second),false);
               _loc5_ = ASCompat.toInt(_loc5_) + 1;
            }
         }
      }
      
      function translateInputIntoConsumableUse() 
      {
         var _loc2_= 0;
         var _loc3_= 0;
         var _loc1_= false;
         var _loc4_= mKeyboardController.releasedConsumableKeysThisFrame;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            _loc2_ = mKeyboardController.KeyIndexToConsumable(_loc3_);
            if(_loc4_[_loc3_] != 0)
            {
               mHeroGameObject.tryToUseConsumable((_loc2_ : UInt));
               _loc1_ = true;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      function determineInputVelocity() : Vector3D
      {
         var _loc1_= mKeyboardController.inputVelocity;
         if(_loc1_.x == 0 && _loc1_.y == 0)
         {
            _loc1_ = mMouseController.inputVelocity;
         }
         else
         {
            mMouseController.clearMovement();
         }
         return _loc1_;
      }
      
      function determineInputHeading() : Vector3D
      {
         var _loc1_= mKeyboardController.inputHeading;
         if(_loc1_.x == 0 && _loc1_.y == 0)
         {
            _loc1_ = mMouseController.inputHeading;
         }
         return _loc1_;
      }
      
      public function canMoveR(param1:String) : Bool
      {
         return param1 != "lock_r" && param1 != "lock_xy_r";
      }
      
      public function canMoveXY(param1:String) : Bool
      {
         return param1 != "lock_xy" && param1 != "lock_xy_r" && !mDBFacade.inputManager.check(16);
      }
      
      @:isVar public var directionVector(get,never):Vector3D;
public function  get_directionVector() : Vector3D
      {
         return mDirectionVector;
      }
      
      @:isVar public var inputType(never,set):String;
public function  set_inputType(param1:String) :String      {
         return mInputType = param1;
      }
      
      public function getInputType() : String
      {
         return mInputType;
      }
   }


