package projectile
;
   import actor.ActorGameObject;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2BodyDef;
   import box2D.dynamics.B2FilterData;
   import box2D.dynamics.B2Fixture;
   import box2D.dynamics.B2FixtureDef;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import collision.IContactResolver;
   import combat.CombatGameObject;
   import combat.weapon.WeaponGameObject;
   import dBGlobals.DBGlobal;
   import distributedObjects.DistributedDungeonFloor;
   import distributedObjects.HeroGameObjectOwner;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMProjectile;
   import flash.geom.Vector3D;
   
    class ProjectileGameObject extends FloorObject implements IContactResolver
   {
      
      var mProjectileView:ProjectileView;
      
      var mNumCollisions:UInt = (0 : UInt);
      
      var mStartPosition:Vector3D;
      
      var mVelocity:Vector3D = new Vector3D();
      
      var mAngularVelocity:Float = Math.NaN;
      
      var mDontRotate:Bool = false;
      
      var mFlightComponent:FlightComponent;
      
      var mCollisionComponent:CollisionComponent;
      
      var mUseRange:Bool = false;
      
      var mGMAttack:GMAttack;
      
      var mGMProjectile:GMProjectile;
      
      var mParentActorId:UInt = 0;
      
      var mParentActorTeam:UInt = 0;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mFinishedCallback:ASFunction;
      
      var mEffectName:String;
      
      var mEffectPath:String;
      
      var mEffectTimeOffset:Float = Math.NaN;
      
      var mB2Body:B2Body;
      
      var mB2Fixture:B2Fixture;
      
      var mAttackType:UInt = 0;
      
      var mVisualOffset:Vector3D;
      
      var mCollisionScale:Float = Math.NaN;
      
      var mIsAlive:Bool = true;
      
      var mWeaponGameObject:WeaponGameObject;
      
      var mCombatResultCallback:ASFunction;
      
      var mEffectObject:ASObject;
      
      var mUpdateTask:Task;
      
      var mLastHitActor:Bool = false;
      
      var mLastHitWall:Bool = false;
      
      var mRange:Float = 0;
      
      public function new(param1:DBFacade, param2:UInt, param3:UInt, param4:UInt, param5:WeaponGameObject, param6:DistributedDungeonFloor, param7:Vector3D, param8:Vector3D, param9:Vector3D, param10:Float = 0, param11:ASObject = null, param12:ASFunction = null, param13:Bool = true, param14:Bool = false, param15:UInt = (0 : UInt))
      {
         mCombatResultCallback = param12;
         mAttackType = param4;
         mGMAttack = ASCompat.dynamicAs(param1.gameMaster.attackById.itemFor(param4), gameMasterDictionary.GMAttack);
         if(mGMAttack == null)
         {
            Logger.error("Unable to find GMAttack record for attack type: " + param4);
         }
         mGMProjectile = ASCompat.dynamicAs(param1.gameMaster.projectileByConstant.itemFor(mGMAttack.Projectile), gameMasterDictionary.GMProjectile);
         if(mGMProjectile == null)
         {
            Logger.error("No projectile defined for attack type: " + param4);
         }
         mEffectObject = param11;
         if(mEffectObject != null)
         {
            mEffectName = mEffectObject.attackEffectName;
            mEffectPath = mEffectObject.attackEffectPath;
            mEffectTimeOffset = ASCompat.toNumberField(mEffectObject, "attackEffectTimeOffset");
            if(!ASCompat.floatAsBool(mEffectTimeOffset))
            {
               mEffectTimeOffset = 0;
            }
         }
         mDontRotate = param14;
         mCollisionScale = param5 != null ? param5.collisionScale() : 1;
         mRange = param10 == 0 ? mGMProjectile.Range : param10;
         super(param1);
         this.layer = mGMProjectile.NoFade == true ? 46 : 20;
         if(mEffectObject.layer == "foreground")
         {
            this.layer = 30;
         }
         else if(mEffectObject.layer == "background")
         {
            this.layer = 10;
         }
         else if(mEffectObject.layer == "sorted")
         {
            this.layer = 20;
         }
         distributedDungeonFloor = param6;
         mWeaponGameObject = param5;
         var _loc22_= (0 : UInt);
         var _loc23_= (0 : UInt);
         if(param5 != null)
         {
            _loc22_ = param5.power;
            _loc23_ = param5.weaponType;
         }
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ProjectileGameObject");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mParentActorId = param2;
         mParentActorTeam = param3;
         mVisualOffset = param9;
         var _loc16_= new Vector3D();
         mUpdateTask = mLogicalWorkComponent.doEveryFrame(update);
         var _loc19_= new B2FixtureDef();
         _loc19_.isSensor = true;
         var _loc17_= new B2CircleShape(mGMProjectile.CollisionSize * mCollisionScale / 50);
         _loc19_.shape = _loc17_;
         var _loc20_= new B2FilterData();
         _loc20_.categoryBits = (2 : UInt);
         _loc20_.maskBits = (0 : UInt);
         _loc20_.groupIndex = -1;
         if(mGMProjectile.CollisionSize > 0)
         {
            switch(mGMAttack.Team)
            {
               case "FRIENDLY":
                  _loc20_.maskBits = ((_loc20_.maskBits | DBGlobal.b2dMaskForTeam(mParentActorTeam) : UInt) : UInt);
                  
               case "HOSTILE":
                  _loc20_.maskBits = ((_loc20_.maskBits | DBGlobal.b2dMaskForAllTeamsBut(mParentActorTeam) : UInt) : UInt);
            }
         }
         _loc20_.maskBits = ((_loc20_.maskBits | (1 : UInt) : UInt) : UInt);
         _loc19_.filter = _loc20_;
         _loc19_.isSensor = true;
         _loc19_.userData = this.id;
         var _loc18_= new B2BodyDef();
         _loc18_.userData = this.id;
         _loc18_.type = B2Body.b2_dynamicBody;
         mB2Body = mDistributedDungeonFloor.box2DWorld.CreateBody(_loc18_);
         mB2Fixture = mB2Body.CreateFixture(_loc19_);
         this.position = param7.add(param9);
         var _loc21_= mDistributedDungeonFloor.getActor(mParentActorId);
         mUseRange = true;
         mVelocity = param8;
         do {
                  switch(mGMProjectile.FlightPattern)
         {
            case "HOMING":
               mFlightComponent = new HomingFlightComponent(param7,param8,this,mParentActorId,param1,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               if(param5 == null)
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0,true,param15);
                  break;
               }
               mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,param5.slot,param5.pierces(),true,param15);
               
            case "BOOMERANG":
               mUseRange = false;
               mFlightComponent = new BoomerangFlightComponent(param7,param8,this,mParentActorId,param1,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               if(param5 == null)
               {
                  mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0);
                  break;
               }
               mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,param5.slot,param5.pierces());
               
            case "ORBITER":
               mUseRange = false;
               mFlightComponent = new OrbiterFlightComponent(param7,param8,this,mParentActorId,param1,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               if(param5 == null)
               {
                  mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0);
                  break;
               }
               mCollisionComponent = new BounceBackCollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,param5.slot,param5.pierces());
               
            default:
               if(param5 == null)
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,0,0,true);
               }
               else
               {
                  mCollisionComponent = new CollisionComponent(mDBFacade,this,mParentActorId,mDistributedDungeonFloor,_loc23_,_loc22_,mGMAttack,mCombatResultCallback,param5.slot,param5.pierces(),true,param15);
               }
               if(Std.isOfType(_loc21_ , HeroGameObjectOwner) && param13 && mGMAttack.UseAutoAim)
               {
                  mFlightComponent = new AutoAimFlightComponent(param7,param8,this,mParentActorId,param1,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
                  break;
               }
               mFlightComponent = new FlightComponent(param7,param8,this,mParentActorId,param1,mDistributedDungeonFloor,mGMAttack.Team == "FRIENDLY",applySteeringVector);
               mVelocity = param8;
         }
         } while (false);
         mVelocity.scaleBy(mGMProjectile.ProjSpeedF);
         mStartPosition = mPosition.clone();
         mAngularVelocity = mGMProjectile.RotationSpeedF;
         mB2Body.SetPosition(NavCollider.convertToB2Vec2(param7.clone()));
         mB2Body.SetLinearVelocity(NavCollider.convertToB2Vec2(mVelocity));
         this.init();
      }
      
      @:isVar public var weapon(get,never):WeaponGameObject;
public function  get_weapon() : WeaponGameObject
      {
         return mWeaponGameObject;
      }
      
      @:isVar public var team(get,never):UInt;
public function  get_team() : UInt
      {
         return mParentActorTeam;
      }
      
      @:isVar public var effectName(get,never):String;
public function  get_effectName() : String
      {
         return mEffectName;
      }
      
      @:isVar public var effectPath(get,never):String;
public function  get_effectPath() : String
      {
         return mEffectPath;
      }
      
      @:isVar public var effectTimeOffset(get,never):Float;
public function  get_effectTimeOffset() : Float
      {
         return mEffectTimeOffset;
      }
      
            
      @:isVar public var velocity(get,set):Vector3D;
public function  get_velocity() : Vector3D
      {
         return mVelocity;
      }
function  set_velocity(param1:Vector3D) :Vector3D      {
         return mVelocity = param1;
      }
      
            
      @:isVar public var rotationSpeed(get,set):Float;
public function  get_rotationSpeed() : Float
      {
         return mAngularVelocity;
      }
function  set_rotationSpeed(param1:Float) :Float      {
         return mAngularVelocity = param1;
      }
      
      @:isVar public var gmProjectile(get,never):GMProjectile;
public function  get_gmProjectile() : GMProjectile
      {
         return mGMProjectile;
      }
      
      @:isVar public var gmAttack(get,never):GMAttack;
public function  get_gmAttack() : GMAttack
      {
         return mGMAttack;
      }
      
      @:isVar public var shouldRotate(get,never):Bool;
public function  get_shouldRotate() : Bool
      {
         return !mDontRotate;
      }
      
      function update(param1:GameClock) 
      {
         if(!distributedDungeonFloor.isAlive())
         {
            destroy();
            return;
         }
         var _loc2_= NavCollider.convertToVector3D(mB2Body.GetPosition());
         _loc2_ = _loc2_.add(mVisualOffset);
         this.position = _loc2_;
         mProjectileView.position = _loc2_;
         if(!checkIfDone())
         {
            applyFlightPattern(_loc2_);
         }
      }
      
      function applyFlightPattern(param1:Vector3D) 
      {
         if(mGMProjectile != null && mFlightComponent != null)
         {
            mFlightComponent.update();
         }
         else if(mGMProjectile == null)
         {
            Logger.error("!mGMProjectile");
         }
         else if(mFlightComponent == null)
         {
            Logger.error("!mFlightComponent");
         }
      }
      
      function applySteeringVector(param1:Vector3D) 
      {
         mVelocity = mVelocity.add(param1);
         var _loc2_= mVelocity.length;
         var _loc3_= Math.min(_loc2_,mGMProjectile.ProjSpeedF);
         mVelocity.scaleBy(_loc3_ / _loc2_);
         mB2Body.SetLinearVelocity(NavCollider.convertToB2Vec2(mVelocity));
      }
      
      function checkIfDone() : Bool
      {
         if(mCollisionComponent.markedForDeletion() || mUseRange && Vector3D.distance(this.position,mStartPosition) >= mRange)
         {
            this.destroy();
            return true;
         }
         return false;
      }
      
      override function buildView() 
      {
         mProjectileView = new ProjectileView(mDBFacade,this);
         MemoryTracker.track(mProjectileView,"ProjectileView - created in ProjectileGameObject.buildView()");
         this.view = mProjectileView ;
      }
      
      @:isVar public var rotation(never,set):Float;
public function  set_rotation(param1:Float) :Float      {
         mProjectileView.setRotation(param1);
return param1;
      }
      
      public function enterContact(param1:UInt) 
      {
         if(!mIsAlive)
         {
            return;
         }
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , ActorGameObject);
         if(_loc2_ == null)
         {
            if(!gmProjectile.IgnoreWalls)
            {
               mCollisionComponent.hitWall();
            }
         }
         else if(_loc2_.id != mParentActorId)
         {
            if(!_loc2_.isAttackable)
            {
               if(!gmProjectile.IgnoreWalls)
               {
                  mCollisionComponent.hitWall();
               }
            }
            else if(CombatGameObject.determineIfHitBasedOnTeam(mParentActorTeam,(_loc2_.team : UInt),mGMAttack.Team))
            {
               hitActor(_loc2_);
            }
         }
         if(mIsAlive && mCollisionComponent.updatedVelocity)
         {
            mB2Body.SetLinearVelocity(NavCollider.convertToB2Vec2(mVelocity));
         }
      }
      
      function hitActor(param1:ActorGameObject) : Bool
      {
         return mCollisionComponent.hitActor(param1);
      }
      
      public function exitContact(param1:UInt) 
      {
         if(mCollisionComponent != null)
         {
            mCollisionComponent.exitContact(param1);
         }
      }
      
      public function onHitWall() 
      {
         mLastHitActor = false;
         mLastHitWall = true;
      }
      
      public function onHitActor(param1:ActorGameObject) 
      {
         var _loc2_:HeroGameObjectOwner = null;
         mLastHitActor = false;
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner))
         {
            _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner);
            if(param1.team != _loc2_.team)
            {
               mLastHitActor = true;
            }
         }
         mFlightComponent.informOfHit(param1);
         mLastHitWall = false;
      }
      
      function setTeleDest() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner))
         {
            if(mLastHitActor && Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner))
            {
               _loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner);
               _loc1_.setTeleDest(position);
            }
         }
      }
      
      function doAttackOnHit() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(mLastHitActor && Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner))
         {
            _loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mParentActorId) , HeroGameObjectOwner);
            _loc1_.doAttackOnHit(mGMAttack.AttackOnHit,mWeaponGameObject);
         }
      }
      
      override public function destroy() 
      {
         var _loc2_:GMNpc = null;
         var _loc3_:HeroGameObjectOwner = null;
         if(mGMAttack.SetTeleport)
         {
            setTeleDest();
         }
         if(ASCompat.stringAsBool(mGMAttack.AttackOnHit))
         {
            doAttackOnHit();
         }
         var _loc1_= mDistributedDungeonFloor.getActor(mParentActorId);
         if(_loc1_ != null && _loc1_.isOwner && mGMProjectile != null && ASCompat.stringAsBool(mGMProjectile.OnDeathNPC))
         {
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.npcByConstant.itemFor(mGMProjectile.OnDeathNPC), gameMasterDictionary.GMNpc);
            _loc3_ = ASCompat.reinterpretAs(_loc1_ , HeroGameObjectOwner);
            _loc3_.ProposeCreateNPC(_loc2_.Id,(this.weapon.slot : UInt),Std.int(position.x),Std.int(position.y));
         }
         mIsAlive = false;
         mWeaponGameObject = null;
         mFinishedCallback = null;
         mCombatResultCallback = null;
         mEffectObject = null;
         mStartPosition = null;
         mProjectileView = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         if(mFlightComponent != null)
         {
            mFlightComponent.destroy();
            mFlightComponent = null;
         }
         mDistributedDungeonFloor.box2DWorld.DestroyBody(mB2Body);
         mB2Body.SetUserData(null);
         mB2Body.GetDefinition().userData = null;
         mB2Fixture.SetUserData(null);
         mB2Body.DestroyFixture(mB2Fixture);
         mB2Fixture = null;
         mB2Body = null;
         if(mUpdateTask != null)
         {
            mUpdateTask.destroy();
            mUpdateTask = null;
         }
         if(mCollisionComponent != null)
         {
            mCollisionComponent.destroy();
            mCollisionComponent = null;
         }
         super.destroy();
      }
      
      @:isVar public var parentActorSkinId(get,never):UInt;
public function  get_parentActorSkinId() : UInt
      {
         var _loc1_= mDistributedDungeonFloor.getActor(mParentActorId);
         if(_loc1_ != null && _loc1_.gmSkin != null)
         {
            return _loc1_.gmSkin.Id;
         }
         return (0 : UInt);
      }
   }


