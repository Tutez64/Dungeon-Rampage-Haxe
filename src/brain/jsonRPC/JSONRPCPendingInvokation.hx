package brain.jsonRPC
;
   import brain.utils.MemoryTracker;
   import flash.events.EventDispatcher;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class JSONRPCPendingInvokation extends EventDispatcher
   {
      
      var mRegisteredListeners:Map = new Map();
      
      var mURLStream:flash.net.URLLoader;
      
      var mDestroyCallback:ASFunction;
      
      public function new(param1:flash.net.URLLoader)
      {
         mURLStream = param1;
         super(this);
         MemoryTracker.track(mRegisteredListeners,"Map - registered listeners in JSONRPCPendingInvokation()","brain");
      }
      
      public function handleError(param1:Error) 
      {
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
         this.dispatchEvent(new FaultEvent(param1));
         destory();
      }
      
      public function handleResult(param1:ASAny) 
      {
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
         this.dispatchEvent(new ResultEvent(param1));
         destory();
      }
      
      public function addDestroyCallback(param1:ASFunction) 
      {
         mDestroyCallback = param1;
      }
      
      public function addListener(param1:String, param2:ASFunction) 
      {
         mRegisteredListeners.add(param1,param2);
         addEventListener(param1,param2);
      }
      
      public function removeListener(param1:String) 
      {
         if(!mRegisteredListeners.has(param1))
         {
            return;
         }
         var _loc2_= ASCompat.asFunction(mRegisteredListeners.itemFor(param1));
         removeEventListener(param1,_loc2_);
         mRegisteredListeners.remove(param1);
      }
      
      public function destory() 
      {
         removeAllListeners();
         mRegisteredListeners.clear();
         mRegisteredListeners = null;
         mURLStream.close();
         mURLStream = null;
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
      }
      
      public function removeAllListeners() 
      {
         var _loc2_:String = null;
         var _loc1_= ASCompat.reinterpretAs(mRegisteredListeners.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc1_.next();
            _loc2_ = ASCompat.asString(_loc1_.current );
            removeListener(_loc2_);
         }
      }
   }


