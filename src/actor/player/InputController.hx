package actor.player
;
   import actor.player.input.GBS_ModernMouseController;
   import actor.player.input.GamepadController;
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
      
      var mGamepadController:GamepadController;
      
      var mInputType:String = "free";
      
      var mCombatDisabled:Bool = false;
      
      public function new(param1:HeroGameObjectOwner, param2:DBFacade)
      {
         
         mDBFacade = param2;
         mHeroGameObject = param1;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"InputController");
         mWantCameraZoom = mDBFacade.dbConfigManager.getConfigBoolean("camera_zoom",false);
         mKeyboardController = new KeyboardController(mDBFacade,mHeroGameObject);
         mMouseController = new GBS_ModernMouseController(mDBFacade,mHeroGameObject);
         mGamepadController = new GamepadController(mDBFacade,mHeroGameObject,param2.steamInputManager);
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
         mGamepadController.destroy();
         mGamepadController = null;
         mDBFacade = null;
         mHeroGameObject = null;
      }
      
      public function init() 
      {
         mMouseController.init();
         mGamepadController.init();
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
         doFrameUpCallsOnInputControllers();
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
      
      public function doFrameUpCallsOnInputControllers() 
      {
         mKeyboardController.perFrameUpCall();
         mMouseController.perFrameUpCall();
         mGamepadController.perFrameUpCall();
      }
      
      public function disableCombat() 
      {
         mCombatDisabled = true;
         inputType = "lock_xy";
         mKeyboardController.combatDisabled = true;
         mMouseController.combatDisabled = true;
         mGamepadController.combatDisabled = true;
         mHeroGameObject.PlayerAttack.resetWeapons();
      }
      
      public function enableCombat() 
      {
         mCombatDisabled = false;
         inputType = "free";
         mKeyboardController.combatDisabled = false;
         mMouseController.combatDisabled = false;
         mGamepadController.combatDisabled = false;
      }
      
      function translateInputIntoAttacks() 
      {
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc6_:Array<ASAny> = null;
         var _loc2_:Tuple = null;
         var _loc7_= false;
         var _loc1_= mKeyboardController.pressedCombatKeysThisFrame;
         var _loc11_= mKeyboardController.releasedCombatKeysThisFrame;
         _loc4_ = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc3_ = mKeyboardController.KeyIndexToAttack(_loc4_);
            if(_loc1_[_loc4_] != 0)
            {
               mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((_loc3_ : UInt),true,true);
               _loc7_ = true;
            }
            if(_loc11_[_loc4_] != 0)
            {
               mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((_loc3_ : UInt),false,true);
               _loc7_ = true;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         var _loc8_= mGamepadController.pressedCombatButtonsThisFrame;
         var _loc9_= mGamepadController.releasedCombatButtonsThisFrame;
         var _loc10_:Int;
         if (checkNullIteratee(_loc8_)) for (_tmp_ in _loc8_)
         {
            _loc10_ = _tmp_;
            mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((_loc10_ : UInt),true,true);
            _loc7_ = true;
         }
         var _loc5_:Int;
         if (checkNullIteratee(_loc9_)) for (_tmp_ in _loc9_)
         {
            _loc5_ = _tmp_;
            mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((_loc5_ : UInt),false,true);
            _loc7_ = true;
         }
         if(!_loc7_)
         {
            _loc6_ = mMouseController.potentialAttacksThisFrame;
            _loc4_ = 0;
            while(_loc4_ < _loc6_.length)
            {
               _loc2_ = ASCompat.dynamicAs(_loc6_[_loc4_], brain.utils.Tuple);
               mHeroGameObject.PlayerAttack.addToPotentialWeaponInputQueue((ASCompat.toInt(_loc2_.first) : UInt),ASCompat.toBool(_loc2_.second),false);
               _loc7_ = true;
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
      }
      
      function translateInputIntoConsumableUse() 
      {
         var _loc2_= 0;
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc1_= false;
         var _loc6_= mKeyboardController.releasedConsumableKeysThisFrame;
         _loc3_ = 0;
         while(_loc3_ < _loc6_.length)
         {
            _loc2_ = mKeyboardController.KeyIndexToConsumable(_loc3_);
            if(_loc6_[_loc3_] != 0)
            {
               mHeroGameObject.tryToUseConsumable((_loc2_ : UInt));
               _loc1_ = true;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         var _loc5_= mGamepadController.releasedConsumableButtonsThisFrame;
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            _loc2_ = _loc5_[_loc4_];
            mHeroGameObject.tryToUseConsumable((_loc2_ : UInt));
            _loc1_ = true;
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      function determineInputVelocity() : Vector3D
      {
         var _loc1_= mKeyboardController.inputVelocity;
         if(_loc1_.x == 0 && _loc1_.y == 0)
         {
            _loc1_ = mGamepadController.inputVelocity;
            if(_loc1_.x == 0 && _loc1_.y == 0)
            {
               _loc1_ = mMouseController.inputVelocity;
            }
            else
            {
               mMouseController.clearMovement();
            }
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
         if(_loc1_.x == 0 && _loc1_.y == 0)
         {
            _loc1_ = mGamepadController.inputHeading;
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


