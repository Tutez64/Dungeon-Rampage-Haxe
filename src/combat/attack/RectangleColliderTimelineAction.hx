package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.utils.MemoryTracker;
   import combat.CombatGameObject;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class RectangleColliderTimelineAction extends ColliderTimelineAction
   {
      
      public static inline final TYPE= "rectangleCollider";
      
      var mHalfWidth:Float = Math.NaN;
      
      var mHalfHeight:Float = Math.NaN;
      
      var mRotation:Float = Math.NaN;
      
      public function new(param1:WeaponGameObject, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:ASFunction, param7:Vector3D, param8:Vector3D, param9:Float, param10:Float, param11:Float, param12:UInt, param13:UInt)
      {
         mHalfWidth = param9;
         mHalfHeight = param10;
         mRotation = param11;
         super(param1,param2,param3,param4,param5,param6,param7,param8,param12,param13);
      }
      
      public static function buildFromJson(param1:WeaponGameObject, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:ASObject, param7:ASFunction) : RectangleColliderTimelineAction
      {
         var _loc17_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc14_:Vector3D = null;
         var _loc13_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc15_:Vector3D = null;
         var _loc18_= 0;
         var _loc19_= 0;
         if(param2.isOwner)
         {
            _loc17_ = param1 != null ? param1.collisionScale() : 1;
            _loc10_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "halfHeight") * _loc17_);
            _loc16_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "halfWidth") * _loc17_);
            _loc11_ = ASCompat.toNumber(param6.rotation);
            _loc9_ = 0;
            if(param6.xOffset != null)
            {
               _loc9_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "xOffset") * _loc17_);
            }
            _loc8_ = 0;
            if(param6.yOffset != null)
            {
               _loc8_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "yOffset") * _loc17_);
            }
            _loc14_ = new Vector3D(_loc9_,_loc8_);
            _loc13_ = 0;
            if(param6.xGlobalOffset != null)
            {
               _loc13_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "xGlobalOffset") * _loc17_);
            }
            _loc12_ = 0;
            if(param6.yGlobalOffset != null)
            {
               _loc12_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "yGlobalOffset") * _loc17_);
            }
            _loc15_ = new Vector3D(_loc13_,_loc12_);
            _loc18_ = 1;
            if(param6.lifeTime != null)
            {
               _loc18_ = ASCompat.toInt(param6.timeToLive);
            }
            _loc19_ = 0;
            if(param6.hitDelayPerObject != null)
            {
               _loc19_ = ASCompat.toInt(param6.hitDelayPerObject);
            }
            return new RectangleColliderTimelineAction(param1,param2,param3,param4,param5,param7,_loc14_,_loc15_,_loc16_,_loc10_,_loc11_,(_loc18_ : UInt),(_loc19_ : UInt));
         }
         return null;
      }
      
      override function buildCombatGameObject(param1:UInt, param2:UInt) : CombatGameObject
      {
         var _loc4_= new RectangleCombatCollider(mDBFacade,mActorGameObject,mDistributedDungeonFloor.box2DWorld,mHalfWidth,mHalfHeight,mActorGameObject.heading,mRotation);
         var _loc3_= new CombatGameObject(mDBFacade,mActorGameObject,mAttackType,mWeapon,mDistributedDungeonFloor,_loc4_,param1,param2,mCombatResultCallback);
         MemoryTracker.track(_loc3_,"CombatGameObject - created in RectangleColliderTimelineAction.buildCombatGameObject()");
         return _loc3_;
      }
      
      override public function destroy() 
      {
         mWeapon = null;
         mDistributedDungeonFloor = null;
         mCombatGameObject.destroy();
         super.destroy();
      }
   }


