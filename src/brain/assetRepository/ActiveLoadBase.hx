package brain.assetRepository
;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.core.SetIterator;
   
    class ActiveLoadBase
   {
      
      public var mPendingSuccessCallback:Set;
      
      public var mPendingErrorCallbacks:Set;
      
      public var mInfo:AssetLoaderInfo;
      
      public var mAssetRepository:AssetRepository;
      
      public function new(param1:AssetRepository, param2:AssetLoaderInfo)
      {
         
         mPendingErrorCallbacks = new Set();
         mPendingSuccessCallback = new Set();
         mInfo = param2;
         mAssetRepository = param1;
      }
      
      public function AddCallback(param1:ASFunction, param2:ASFunction) 
      {
         if(param1 != null)
         {
            mPendingSuccessCallback.add(param1);
         }
         if(param2 != null)
         {
            mPendingErrorCallbacks.add(param2);
         }
      }
      
      public function removeCallback(param1:ASFunction, param2:ASFunction) : Bool
      {
         var _loc3_= false;
         if(param1 != null)
         {
            _loc3_ = mPendingSuccessCallback.remove(param1);
         }
         if(param2 != null)
         {
            _loc3_ = _loc3_ || mPendingErrorCallbacks.remove(param2);
         }
         return _loc3_;
      }
      
      public function hasNoCallbacks() : Bool
      {
         return mPendingSuccessCallback.size != 0 || mPendingErrorCallbacks.size != 0;
      }
      
      public function executeErrorCallbacks(param1:AssetLoaderInfo) 
      {
         var _loc3_:ASFunction = null;
         var _loc2_= ASCompat.reinterpretAs(mPendingErrorCallbacks.iterator() , SetIterator);
         while(_loc2_.hasNext())
         {
            _loc3_ = ASCompat.asFunction(_loc2_.next());
            if(_loc3_ != null)
            {
               _loc3_();
            }
         }
         mPendingErrorCallbacks.clear();
      }
      
      public function executeSucessCallbacks(param1:AssetLoaderInfo, param2:Asset) 
      {
         var _loc4_:ASFunction = null;
         var _loc3_= ASCompat.reinterpretAs(mPendingSuccessCallback.iterator() , SetIterator);
         while(_loc3_.hasNext())
         {
            _loc4_ = ASCompat.asFunction(_loc3_.next());
            if(_loc4_ != null)
            {
               _loc4_(param2);
            }
         }
         mPendingSuccessCallback.clear();
      }
      
      public function destroy() 
      {
         mPendingSuccessCallback.clear();
         mPendingErrorCallbacks.clear();
         mAssetRepository = null;
         mInfo = null;
      }
   }


