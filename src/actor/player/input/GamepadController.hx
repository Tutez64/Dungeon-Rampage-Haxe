package actor.player.input
;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import steamInput.SteamInputManager;
   import flash.geom.Vector3D;
   
    class GamepadController
   {
      
      var mDBFacade:DBFacade;
      
      var mHeroOwner:HeroGameObjectOwner;
      
      var mSteamInputManager:SteamInputManager;
      
      var mCombatDisabled:Bool = false;
      
      var mMovementInput:Vector3D = new Vector3D();
      
      var mMovementVelocity:Vector3D = new Vector3D();
      
      var mInputHeading:Vector3D = new Vector3D();
      
      var mPressedCombatButtonsThisFrame:Vector<Int> = new Vector();
      
      var mReleasedCombatButtonsThisFrame:Vector<Int> = new Vector();
      
      var mReleasedConsumableButtonsThisFrame:Vector<Int> = new Vector();
      
      public function new(param1:DBFacade, param2:HeroGameObjectOwner, param3:SteamInputManager)
      {
         
         mDBFacade = param1;
         mHeroOwner = param2;
         mSteamInputManager = param3;
         mCombatDisabled = false;
      }
      
      @:isVar public var inputVelocity(get,never):Vector3D;
public function  get_inputVelocity() : Vector3D
      {
         return mMovementVelocity;
      }
      
      @:isVar public var inputHeading(get,never):Vector3D;
public function  get_inputHeading() : Vector3D
      {
         return mInputHeading;
      }
      
      @:isVar public var pressedCombatButtonsThisFrame(get,never):Vector<Int>;
public function  get_pressedCombatButtonsThisFrame() : Vector<Int>
      {
         return mPressedCombatButtonsThisFrame;
      }
      
      @:isVar public var releasedCombatButtonsThisFrame(get,never):Vector<Int>;
public function  get_releasedCombatButtonsThisFrame() : Vector<Int>
      {
         return mReleasedCombatButtonsThisFrame;
      }
      
      @:isVar public var releasedConsumableButtonsThisFrame(get,never):Vector<Int>;
public function  get_releasedConsumableButtonsThisFrame() : Vector<Int>
      {
         return mReleasedConsumableButtonsThisFrame;
      }
      
      public function init() 
      {
         mPressedCombatButtonsThisFrame.length = 0;
         mReleasedCombatButtonsThisFrame.length = 0;
         mReleasedConsumableButtonsThisFrame.length = 0;
      }
      
      public function destroy() 
      {
         mMovementVelocity = null;
         mInputHeading = null;
         mPressedCombatButtonsThisFrame.length = 0;
         mPressedCombatButtonsThisFrame = null;
         mReleasedCombatButtonsThisFrame.length = 0;
         mReleasedCombatButtonsThisFrame = null;
         mReleasedConsumableButtonsThisFrame.length = 0;
         mReleasedConsumableButtonsThisFrame = null;
      }
      
      @:isVar public var combatDisabled(never,set):Bool;
public function  set_combatDisabled(param1:Bool) :Bool      {
         return mCombatDisabled = param1;
      }
      
      public function perFrameUpCall() 
      {
         updateMovement();
         updateCombatButtons();
      }
      
      function updateMovement() 
      {
         mMovementInput = calcMovementInput();
         calcMovementVelocity(mMovementInput);
         updateInputHeading(mMovementInput);
      }
      
      function updateCombatButtons() 
      {
         mPressedCombatButtonsThisFrame.length = 0;
         mReleasedCombatButtonsThisFrame.length = 0;
         if(mCombatDisabled)
         {
            return;
         }
         handleAttackInputs();
         handleConsumableInputs();
      }
      
      function calcMovementInput() : Vector3D
      {
         var _loc1_= mSteamInputManager.getAnalogAction("game_movement");
         _loc1_.y = -_loc1_.y;
         return _loc1_;
      }
      
      function calcMovementVelocity(param1:Vector3D) 
      {
         var _loc3_= mSteamInputManager.heldAction("hold_in_place");
         if(_loc3_)
         {
            mMovementVelocity.setTo(0,0,0);
            return;
         }
         mMovementVelocity.copyFrom(mMovementInput);
         var _loc2_= mHeroOwner.movementSpeed;
         mMovementVelocity.scaleBy(_loc2_);
      }
      
      function updateInputHeading(param1:Vector3D) 
      {
         mInputHeading.setTo(param1.x,param1.y,0);
      }
      
      function handleAttackInputs() 
      {
         checkWeaponButton(0,"attack_weapon_1");
         checkWeaponButton(1,"attack_weapon_2");
         checkWeaponButton(2,"attack_weapon_3");
         checkWeaponButton(3,"use_dungeon_buster");
      }
      
      function checkWeaponButton(param1:Int, param2:String) 
      {
         var _loc3_= mSteamInputManager.pressedAction(param2);
         var _loc4_= mSteamInputManager.releasedAction(param2);
         if(_loc3_)
         {
            mPressedCombatButtonsThisFrame.push(param1);
         }
         if(_loc4_)
         {
            mReleasedCombatButtonsThisFrame.push(param1);
         }
      }
      
      function handleConsumableInputs() 
      {
         mReleasedConsumableButtonsThisFrame.length = 0;
         var _loc1_= mSteamInputManager.releasedAction("use_consumable_one");
         if(_loc1_)
         {
            mReleasedConsumableButtonsThisFrame.push(0);
         }
         var _loc2_= mSteamInputManager.releasedAction("use_consumable_two");
         if(_loc2_)
         {
            mReleasedConsumableButtonsThisFrame.push(1);
         }
      }
   }


