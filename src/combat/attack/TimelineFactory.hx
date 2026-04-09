package combat.attack
;
   import actor.ActorGameObject;
   import brain.assetRepository.JsonAsset;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import org.as3commons.collections.Map;
   
    class TimelineFactory
   {
      
      static inline final TIMELINE_FILE_PATH= "Resources/Combat/AttackTimeline.json";
      
      var mDBFacade:DBFacade;
      
      var mJsonAsset:JsonAsset;
      
      var mTimelines:Map;
      
      var mSecurityValue:Int = 0;
      
      public function new(param1:DBFacade, param2:JsonAsset)
      {
         var _loc3_:String = null;
         
         mDBFacade = param1;
         mJsonAsset = param2;
         mTimelines = new Map();
         var _loc5_= 0;
         mSecurityValue = 0;
         var _loc4_:ASAny;
         final __ax4_iter_44:Array<ASAny> = param2.json.attacks;
         if (checkNullIteratee(__ax4_iter_44)) for (_tmp_ in __ax4_iter_44)
         {
            _loc4_ = _tmp_;
            _loc3_ = _loc4_.attackName;
            mTimelines.add(_loc3_,_loc4_);
            _loc5_ += GetSecurityValue(_loc4_);
         }
         _loc5_ %= 1097;
         mSecurityValue += _loc5_;
         _loc5_ = 0;
      }
      
      public function GetSecurityValue(param1:ASObject) : Int
      {
         var _loc2_= 0;
         var _loc3_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in iterateDynamicValues(param1))
         {
            _loc3_ = _tmp_;
            if(ASCompat.getQualifiedClassName(_loc3_) == "int")
            {
               _loc2_ += Std.int(Math.abs(ASCompat.toInt(_loc3_)) % 17 + Math.abs(ASCompat.toInt(_loc3_)) / 19);
            }
         }
         return _loc2_ % 541;
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mTimelines.clear();
         mTimelines = null;
         mJsonAsset = null;
      }
      
      @:isVar public var securityChecksum(get,never):Int;
public function  get_securityChecksum() : Int
      {
         return mSecurityValue;
      }
      
      public function createAttackTimeline(param1:String, param2:WeaponGameObject, param3:ActorGameObject, param4:DistributedDungeonFloor) : AttackTimeline
      {
         var _loc6_:AttackTimeline = null;
         var _loc5_:ASObject = mTimelines.itemFor(param1);
         if(param3.isOwner)
         {
            _loc6_ = new OwnerAttackTimeline(param2,ASCompat.reinterpretAs(param3 , HeroGameObjectOwner),param3.actorView,_loc5_,mDBFacade,param4);
         }
         else
         {
            _loc6_ = new AttackTimeline(param2,param3,param3.actorView,_loc5_,mDBFacade,param4);
         }
         return _loc6_;
      }
      
      public function createScriptTimeline(param1:String, param2:ActorGameObject, param3:DistributedDungeonFloor) : ScriptTimeline
      {
         var _loc5_:ASAny = null;
         var _loc4_:ASObject = mTimelines.itemFor(param1);
         return new ScriptTimeline(param2,param2.actorView,_loc4_,mDBFacade,param3);
      }
   }


