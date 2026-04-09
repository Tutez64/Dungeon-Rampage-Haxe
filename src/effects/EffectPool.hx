package effects
;
   import brain.utils.IPoolable;
   import brain.utils.MemoryTracker;
   import brain.utils.ObjectPool;
   import facade.DBFacade;
   
    class EffectPool extends ObjectPool
   {
      
      public function new()
      {
         super();
      }
      
      override function getPoolKey(param1:Array<ASAny>) : String
      {
         var _loc3_= ASCompat.dynamicAs(param1[0], facade.DBFacade);
         var _loc2_:String = param1[1];
         var _loc4_:String = param1[2];
         return _loc2_ + ":" + _loc4_;
      }
      
      override function reset(param1:IPoolable, param2:Array<ASAny>) 
      {
         var _loc3_= ASCompat.reinterpretAs(param1 , EffectGameObject);
         _loc3_.setAssetLoadedCallback(ASCompat.asFunction(param2[3]));
      }
      
      override function construct(param1:Array<ASAny>) : IPoolable
      {
         var _loc4_= ASCompat.dynamicAs(param1[0], facade.DBFacade);
         var _loc3_:String = param1[1];
         var _loc5_:String = param1[2];
         var _loc6_= ASCompat.asFunction(param1[3]);
         var _loc2_= new EffectGameObject(_loc4_,_loc3_,_loc5_,1,(0 : UInt),_loc6_);
         MemoryTracker.track(_loc2_,"EffectGameObject \'" + _loc3_ + ":" + _loc5_ + "\' - created in EffectPool.construct()","pool");
         return _loc2_;
      }
   }


