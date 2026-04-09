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
   
    class CircleColliderAttackTimelineAction extends ColliderTimelineAction
   {
      
      public static inline final TYPE= "circleCollider";
      
      var mRadius:Float = Math.NaN;
      
      public function new(param1:WeaponGameObject, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:ASFunction, param7:Float, param8:Vector3D, param9:Vector3D, param10:UInt, param11:UInt)
      {
         mRadius = param7;
         super(param1,param2,param3,param4,param5,param6,param8,param9,param10,param11);
      }
      
      public static function buildFromJson(param1:WeaponGameObject, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:ASObject, param7:ASFunction) : CircleColliderAttackTimelineAction
      {
         var _loc14_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc10_:Vector3D = null;
         var _loc9_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc13_:Vector3D = null;
         var _loc15_= 0;
         var _loc17_= 0;
         if(param2.isOwner)
         {
            _loc14_ = param1 != null ? param1.collisionScale() : 1;
            _loc16_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "radius") * _loc14_);
            _loc12_ = 0;
            if(param6.xOffset != null)
            {
               _loc12_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "xOffset") * _loc14_);
            }
            _loc11_ = 0;
            if(param6.yOffset != null)
            {
               _loc11_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "yOffset") * _loc14_);
            }
            _loc10_ = new Vector3D(_loc12_,_loc11_);
            _loc9_ = 0;
            if(param6.xGlobalOffset != null)
            {
               _loc9_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "xGlobalOffset") * _loc14_);
            }
            _loc8_ = 0;
            if(param6.yGlobalOffset != null)
            {
               _loc8_ = ASCompat.toNumber(ASCompat.toNumberField(param6, "yGlobalOffset") * _loc14_);
            }
            _loc13_ = new Vector3D(_loc9_,_loc8_);
            _loc15_ = 1;
            if(param6.lifeTime != null)
            {
               _loc15_ = ASCompat.toInt(param6.lifeTime);
            }
            _loc17_ = 0;
            if(param6.hitDelayPerObject != null)
            {
               _loc17_ = ASCompat.toInt(param6.hitDelayPerObject);
            }
            return new CircleColliderAttackTimelineAction(param1,param2,param3,param4,param5,param7,_loc16_,_loc10_,_loc13_,(_loc15_ : UInt),(_loc17_ : UInt));
         }
         return null;
      }
      
      override function buildCombatGameObject(param1:UInt, param2:UInt) : CombatGameObject
      {
         var _loc3_= new CircleCombatCollider(mDBFacade,mActorGameObject,mDistributedDungeonFloor.box2DWorld,mRadius);
         var _loc4_= new CombatGameObject(mDBFacade,mActorGameObject,mAttackType,mWeapon,mDistributedDungeonFloor,_loc3_,param1,param2,mCombatResultCallback);
         MemoryTracker.track(_loc4_,"CombatGameObject - created in CircleColliderAttackTimelineAction.buildCombatGameObject()");
         return _loc4_;
      }
      
      override public function destroy() 
      {
         mWeapon = null;
         mDistributedDungeonFloor = null;
         mCombatGameObject.destroy();
         super.destroy();
      }
   }


