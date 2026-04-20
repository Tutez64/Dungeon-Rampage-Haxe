package actor.player.input
;
   import brain.logger.Logger;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class KeyboardController
   {
      
      static final KEYS_TO_ATTACK_INDEX:Array<ASAny> = [0,1,2,3,0,1,2,0];
      
      static final KEYS_TO_CONSUMABLE_INDEX:Array<ASAny> = [0,1];
      
      var mDBFacade:DBFacade;
      
      var mHeroOwner:HeroGameObjectOwner;
      
      var mInputVector:Vector3D;
      
      var mMovementVelocity:Vector3D;
      
      var mInputHeading:Vector3D;
      
      var mCombatKeys:Vector<Int>;
      
      var mPressedCombatKeysThisFrame:Vector<Int>;
      
      var mReleasedCombatKeysThisFrame:Vector<Int>;
      
      var mConsumableKeys:Vector<Int>;
      
      var mReleasedConsumableKeysThisFrame:Vector<Int>;
      
      var mCombatDisabled:Bool = false;
      
      public function new(param1:DBFacade, param2:HeroGameObjectOwner)
      {
         
         mDBFacade = param1;
         mHeroOwner = param2;
         mMovementVelocity = new Vector3D();
         mInputHeading = new Vector3D();
         mCombatKeys = new Vector<Int>();
         mPressedCombatKeysThisFrame = new Vector<Int>();
         mConsumableKeys = new Vector<Int>();
         mReleasedConsumableKeysThisFrame = new Vector<Int>();
         ASCompat.ASArray.pushMultiple(mCombatKeys, 90,88,67,66,74,75,76,89);
         mCombatDisabled = false;
         ASCompat.ASArray.pushMultiple(mConsumableKeys, 49,50);
      }
      
      public function perFrameUpCall() 
      {
         getInputDirectionVector();
         checkCombatButtons();
         determineMotion();
         checkForDebugIdentifyTile();
      }
      
      function checkForDebugIdentifyTile() 
      {
         if(mDBFacade.inputManager.pressed(73))
         {
            Logger.warn("[ DEBUG ] Tile ID is : " + mHeroOwner.distributedDungeonFloor.GetTileIdWhichAvatarIsOn());
         }
      }
      
      function getInputDirectionVector() 
      {
         mInputVector = new Vector3D();
         if(mDBFacade.inputManager.check(38) || mDBFacade.inputManager.check(87))
         {
            mInputVector.y -= 1;
         }
         if(mDBFacade.inputManager.check(40) || mDBFacade.inputManager.check(83))
         {
            mInputVector.y += 1;
         }
         if(mDBFacade.inputManager.check(39) || mDBFacade.inputManager.check(68))
         {
            mInputVector.x += 1;
         }
         if(mDBFacade.inputManager.check(37) || mDBFacade.inputManager.check(65))
         {
            mInputVector.x -= 1;
         }
         mInputVector.normalize();
      }
      
      @:isVar public var combatDisabled(never,set):Bool;
public function  set_combatDisabled(param1:Bool) :Bool      {
         return mCombatDisabled = param1;
      }
      
      public function KeyIndexToAttack(param1:Int) : Int
      {
         return ASCompat.toInt(KEYS_TO_ATTACK_INDEX[param1]);
      }
      
      public function KeyIndexToConsumable(param1:Int) : Int
      {
         return ASCompat.toInt(KEYS_TO_CONSUMABLE_INDEX[param1]);
      }
      
      function checkCombatButtons() 
      {
         if(!mCombatDisabled)
         {
            mReleasedCombatKeysThisFrame = new Vector<Int>();
            mPressedCombatKeysThisFrame = new Vector<Int>();
            ASCompat.ASVector.forEach(mCombatKeys, checkCombatButton,this);
         }
         mReleasedConsumableKeysThisFrame = new Vector<Int>();
         ASCompat.ASVector.forEach(mConsumableKeys, checkConsumableButton,this);
      }
      
      function checkCombatButton(param1:Int, param2:UInt, param3:Vector<Int>) 
      {
         mPressedCombatKeysThisFrame.push(ASCompat.toInt(mDBFacade.inputManager.check(param1)));
         mReleasedCombatKeysThisFrame.push(ASCompat.toInt(mDBFacade.inputManager.released(param1)));
      }
      
      function checkConsumableButton(param1:Int, param2:UInt, param3:Vector<Int>) 
      {
         mReleasedConsumableKeysThisFrame.push(ASCompat.toInt(mDBFacade.inputManager.released(param1)));
      }
      
      public function determineMotion() 
      {
         mMovementVelocity.copyFrom(mInputVector);
         var _loc1_= mHeroOwner.movementSpeed;
         mMovementVelocity.scaleBy(_loc1_);
         mInputHeading.copyFrom(mInputVector);
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
      
      @:isVar public var pressedCombatKeysThisFrame(get,never):Vector<Int>;
public function  get_pressedCombatKeysThisFrame() : Vector<Int>
      {
         return mPressedCombatKeysThisFrame;
      }
      
      @:isVar public var releasedCombatKeysThisFrame(get,never):Vector<Int>;
public function  get_releasedCombatKeysThisFrame() : Vector<Int>
      {
         return mReleasedCombatKeysThisFrame;
      }
      
      @:isVar public var releasedConsumableKeysThisFrame(get,never):Vector<Int>;
public function  get_releasedConsumableKeysThisFrame() : Vector<Int>
      {
         return mReleasedConsumableKeysThisFrame;
      }
      
      public function destroy() 
      {
      }
   }


