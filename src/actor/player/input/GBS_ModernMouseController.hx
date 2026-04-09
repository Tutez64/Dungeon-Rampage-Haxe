package actor.player.input
;
   import actor.ActorGameObject;
   import box2D.collision.B2Distance;
   import box2D.collision.B2DistanceInput;
   import box2D.collision.B2DistanceOutput;
   import box2D.collision.B2DistanceProxy;
   import box2D.collision.B2SimplexCache;
   import brain.logger.Logger;
   import brain.utils.Tuple;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import flash.events.MouseEvent;
   import flash.geom.Vector3D;
   
    class GBS_ModernMouseController extends MouseController
   {
      
      static inline final mLeftClickWeaponIndex= 0;
      
      static inline final mRightClickWeaponIndex= 1;
      
      static inline final mMiddleClickWeaponIndex= 2;
      
      var mCurrentTarget:ActorGameObject;
      
      var mClickedLocation:Vector3D;
      
      var mIsStationaryAttack:Bool = false;
      
      var mHeroLocationPreviousFrame:Vector3D;
      
      var mDistanceInputCache:B2DistanceInput;
      
      var mDistanceOutputCache:B2DistanceOutput;
      
      var mDistanceSimplexCache:B2SimplexCache;
      
      public function new(param1:DBFacade, param2:HeroGameObjectOwner)
      {
         super(param1,param2);
         mInputHeading = new Vector3D();
         mDistanceInputCache = new B2DistanceInput();
         mDistanceInputCache.proxyA = new B2DistanceProxy();
         mDistanceInputCache.proxyB = new B2DistanceProxy();
         mDistanceOutputCache = new B2DistanceOutput();
         mDistanceSimplexCache = new B2SimplexCache();
         mDistanceSimplexCache.count = (0 : UInt);
         mHeroLocationPreviousFrame = mHeroGameObjectOwner.view.position;
      }
      
      override function handleMouseDown(param1:MouseEvent) 
      {
         super.handleMouseDown(param1);
      }
      
      override function determineSelection() 
      {
         checkStationaryKey();
         if(mMouseDownThisFrame)
         {
            faceLocation(getMouseWorldLocation());
            cancelMovementAction();
            clearCurrentTarget();
            if(mMouseDownActorThisFrame != null && isValidTarget(mMouseDownActorThisFrame))
            {
               mCurrentTarget = mMouseDownActorThisFrame;
            }
            else
            {
               mClickedLocation = getMouseWorldLocation();
               mHeroGameObjectOwner.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"UI_pointer_click",mClickedLocation);
            }
         }
         if(mMouseUpThisFrame)
         {
            if(mCurrentTarget != null && mActorMousedOver != mCurrentTarget)
            {
               setCurrentTargetSelection(false);
            }
         }
         if(mCurrentTarget != null && mCurrentTarget.isDead())
         {
            handleCurrentTargetDied();
         }
      }
      
      function checkStationaryKey() 
      {
         if(!mIsStationaryAttack && mDBFacade.inputManager.check(16))
         {
            cancelMovementAction();
            mIsStationaryAttack = true;
         }
         else if(mIsStationaryAttack && !mDBFacade.inputManager.check(16))
         {
            mHeroGameObjectOwner.PlayerAttack.stopAttacking();
            mIsStationaryAttack = false;
         }
      }
      
      function checkForAlternateWeaponAttacks() 
      {
         if(mRightMouseDown)
         {
            handleAlternateWeaponAttack(1);
         }
         else if(mMiddleMouseDown)
         {
            handleAlternateWeaponAttack(2);
         }
      }
      
      function handleAlternateWeaponAttack(param1:Int) 
      {
         clearMovement();
         faceLocation(getMouseWorldLocation());
         beginAttack(param1);
      }
      
      function handleCurrentTargetDied() 
      {
         if(mCurrentTarget.actorView != null)
         {
            mCurrentTarget.actorView.mouseOverUnhighlight();
         }
         setCurrentTargetSelection(false);
         mCurrentTarget = null;
         mHeroGameObjectOwner.PlayerAttack.stopAttacking();
      }
      
      override function determineMotion() 
      {
         var _loc1_:Vector3D = null;
         var _loc2_:Vector3D = null;
         if(mCurrentTarget != null && mCurrentTarget.actorView != null)
         {
            attackMoveToTarget(mCurrentTarget);
         }
         else if(mClickedLocation != null)
         {
            if(mDBFacade.inputManager.mouseDown)
            {
               _loc1_ = getMouseWorldLocation();
               _loc2_ = _loc1_.subtract(mHeroGameObjectOwner.view.position);
               if(_loc2_.length > 50)
               {
                  mClickedLocation = _loc1_;
               }
            }
            walkToLocation();
         }
      }
      
      override function determineAttacks() 
      {
         checkForAlternateWeaponAttacks();
         if(mIsStationaryAttack)
         {
            handleStationaryAttack();
         }
      }
      
      function handleStationaryAttack() 
      {
         if(mDBFacade.inputManager.mouseDown)
         {
            faceLocation(getMouseWorldLocation());
            beginAttack();
         }
         else
         {
            mHeroGameObjectOwner.PlayerAttack.stopAttacking();
         }
      }
      
      function zeroVelocity() 
      {
         mInputVelocity.x = 0;
         mInputVelocity.y = 0;
      }
      
      function getMouseWorldLocation() : Vector3D
      {
         return mDBFacade.camera.getWorldCoordinateFromMouse(mDBFacade.inputManager.mouseX,mDBFacade.inputManager.mouseY);
      }
      
      function setCurrentTargetSelection(param1:Bool) 
      {
         if(mCurrentTarget.actorView == null)
         {
            return;
         }
         if(param1)
         {
            mCurrentTarget.actorView.mouseSelectedHighlight();
         }
         else
         {
            mCurrentTarget.actorView.mouseSelectedUnhighlight();
         }
      }
      
      function clearCurrentTarget() 
      {
         if(mCurrentTarget == null)
         {
            return;
         }
         setCurrentTargetSelection(false);
         mCurrentTarget = null;
      }
      
      function cancelMovementAction() 
      {
         mClickedLocation = null;
      }
      
      function isPrimaryWeaponRanged() : Bool
      {
         if(mHeroGameObjectOwner.weapons.length == 0)
         {
            return false;
         }
         var _loc1_= mHeroGameObjectOwner.weapons[0];
         if(_loc1_ == null)
         {
            return false;
         }
         return mHeroGameObjectOwner.weapons[0].weaponData.ClassType == "SHOOTING" || mHeroGameObjectOwner.weapons[0].weaponData.ClassType == "MAGIC";
      }
      
      function isValidTarget(param1:ActorGameObject) : Bool
      {
         return !param1.isDead();
      }
      
      function walkToLocation() 
      {
         var _loc2_= Math.NaN;
         var _loc3_:Vector3D = null;
         var _loc1_= Math.NaN;
         if(mClickedLocation != null)
         {
            _loc2_ = 10;
            _loc3_ = mClickedLocation.subtract(mHeroGameObjectOwner.view.position);
            if(_loc3_.length > _loc2_)
            {
               _loc1_ = 50;
               moveTowardsLocation(mClickedLocation,_loc3_.length > _loc1_);
            }
            else
            {
               if(!mDBFacade.inputManager.mouseDown)
               {
                  mClickedLocation = null;
               }
               zeroVelocity();
            }
         }
      }
      
      function attackMoveToTarget(param1:ActorGameObject) 
      {
         setCurrentTargetSelection(true);
         if(isHeroInWeaponRange(param1))
         {
            beginAttack();
            zeroVelocity();
            if(!mDBFacade.inputManager.mouseDown)
            {
               clearCurrentTarget();
            }
         }
         else
         {
            moveTowardsLocation(param1.actorView.position,true);
         }
      }
      
      function isHeroInWeaponRange(param1:ActorGameObject) : Bool
      {
         if(isPrimaryWeaponRanged())
         {
            return true;
         }
         var _loc3_:Float = 0.25;
         var _loc2_= getHeroDistanceToObject(param1);
         return _loc3_ >= _loc2_;
      }
      
      public function getHeroDistanceToObject(param1:ActorGameObject) : Float
      {
         if(mHeroGameObjectOwner.navCollisions.length == 0)
         {
            Logger.warn("getHeroDistanceToObject - Hero Game Object has no NavColliders");
            return 0;
         }
         if(param1.navCollisions.length == 0)
         {
            Logger.warn("getHeroDistanceToObject - GameObject has no NavColliders");
            return 0;
         }
         var _loc3_= mHeroGameObjectOwner.navCollisions[0];
         var _loc2_= param1.navCollisions[0];
         mDistanceInputCache.proxyA.Set(_loc3_.getShape());
         mDistanceInputCache.proxyB.Set(_loc2_.getShape());
         mDistanceInputCache.transformA = _loc3_.getBody().GetTransform();
         mDistanceInputCache.transformB = _loc2_.getBody().GetTransform();
         mDistanceInputCache.useRadii = true;
         mDistanceSimplexCache.count = (0 : UInt);
         B2Distance.Distance(mDistanceOutputCache,mDistanceSimplexCache,mDistanceInputCache);
         return mDistanceOutputCache.distance;
      }
      
      public function beginAttack(param1:Int = 0) 
      {
         mPotentialAttacksThisFrame.push(new Tuple(param1,false));
      }
      
      public function moveTowardsLocation(param1:Vector3D, param2:Bool) 
      {
         var _loc5_= mHeroGameObjectOwner.view.position;
         if(mDBFacade.inputManager.mouseUp)
         {
            if(mHeroLocationPreviousFrame.equals(_loc5_))
            {
               clearMovement();
               return;
            }
         }
         if(param2)
         {
            faceLocation(param1);
         }
         var _loc3_= mHeroGameObjectOwner.movementSpeed;
         var _loc4_= param1.subtract(_loc5_);
         _loc4_.normalize();
         _loc4_.scaleBy(_loc3_);
         mInputVelocity = _loc4_;
         mHeroLocationPreviousFrame = _loc5_;
      }
      
      public function faceLocation(param1:Vector3D) 
      {
         var _loc2_= param1.subtract(mHeroGameObjectOwner.worldCenter);
         _loc2_.normalize();
         mInputHeading = _loc2_;
      }
      
      override public function clearMovement() 
      {
         if(mDBFacade.inputManager.mouseUp)
         {
            clearCurrentTarget();
            cancelMovementAction();
         }
         zeroVelocity();
         mInputHeading.setTo(0,0,0);
      }
   }


