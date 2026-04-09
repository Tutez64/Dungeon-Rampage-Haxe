package brain.render
;
   import brain.assetRepository.SwfAsset;
   import brain.facade.Facade;
   import brain.utils.IPoolable;
   import brain.utils.MemoryTracker;
   import brain.utils.ObjectPool;
   
    class MovieClipPool extends ObjectPool
   {
      
      public function new()
      {
         super();
      }
      
      override function getPoolKey(param1:Array<ASAny>) : String
      {
         var _loc3_= ASCompat.dynamicAs(param1[0], brain.facade.Facade);
         var _loc2_= cast(param1[1], SwfAsset).swfPath;
         var _loc4_:String = param1[2];
         return _loc2_ + ":" + _loc4_;
      }
      
      override function construct(param1:Array<ASAny>) : IPoolable
      {
         var _loc3_= ASCompat.dynamicAs(param1[0], brain.facade.Facade);
         var _loc4_= ASCompat.dynamicAs(param1[1], brain.assetRepository.SwfAsset);
         var _loc2_= _loc4_.swfPath;
         var _loc5_:String = param1[2];
         var _loc6_= _loc4_.getClass(_loc5_);
         var _loc7_= new MovieClipRenderController(_loc3_,ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), flash.display.MovieClip));
         _loc7_.swfPath = _loc2_;
         _loc7_.className = _loc5_;
         MemoryTracker.track(_loc7_,"MovieClipRenderController swf=" + _loc2_ + " class=" + _loc5_ + " - created in MovieClipPool.construct()","pool");
         return _loc7_;
      }
   }


