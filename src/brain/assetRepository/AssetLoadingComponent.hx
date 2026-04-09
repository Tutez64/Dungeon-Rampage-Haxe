package brain.assetRepository
;
   import brain.component.Component;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
    class AssetLoadingComponent extends Component
   {
      
      public var mPendingDownloads:Set;
      
      var mTransitionToEmptyFunction:ASFunction;
      
      var mAssetRepository:AssetRepository;
      
      public function new(param1:Facade)
      {
         super(param1);
         mAssetRepository = param1.assetRepository;
         mPendingDownloads = new Set();
      }
      
      public function getJsonAsset(param1:String, param2:ASFunction, param3:ASFunction, param4:Bool = true) 
      {
         var _loc5_= new AssetLoaderInfo(param1,param4);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - JSON asset: " + param1,"brain");
         if(param4)
         {
            if(mAssetRepository.tryCache(_loc5_,param2))
            {
               return;
            }
         }
         var _loc6_= new AssetLoadingTracker(param1,this,param2,param3);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - JSON asset: " + param1,"brain");
         mAssetRepository.getJsonAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getXMLAsset(param1:String, param2:ASFunction, param3:ASFunction = null, param4:Bool = true) 
      {
         var _loc5_= new AssetLoaderInfo(param1,param4);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - XML asset: " + param1,"brain");
         if(param4)
         {
            if(mAssetRepository.tryCache(_loc5_,param2))
            {
               return;
            }
         }
         var _loc6_= new AssetLoadingTracker(param1,this,param2,param3);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - XML asset: " + param1,"brain");
         mAssetRepository.getXMLAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getByteArrayAsset(param1:String, param2:ASFunction, param3:ASFunction = null, param4:Bool = true) 
      {
         var _loc5_= new AssetLoaderInfo(param1,param4);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - ByteArray asset: " + param1,"brain");
         if(param4)
         {
            if(mAssetRepository.tryCache(_loc5_,param2))
            {
               return;
            }
         }
         var _loc6_= new AssetLoadingTracker(param1,this,param2,param3);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - ByteArray asset: " + param1,"brain");
         mAssetRepository.getByteArrayAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getSwfAsset(param1:String, param2:ASFunction, param3:ASFunction = null, param4:Bool = true) 
      {
         var _loc5_= new AssetLoaderInfo(param1,param4);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - SWF asset: " + param1,"brain");
         if(param4)
         {
            if(mAssetRepository.tryCache(_loc5_,param2))
            {
               return;
            }
         }
         var _loc6_= new AssetLoadingTracker(param1,this,param2,param3);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - SWF asset: " + param1,"brain");
         mAssetRepository.getSwfAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getSpriteSheetAsset(param1:String, param2:String, param3:ASFunction, param4:ASFunction, param5:Bool, param6:ASFunction, param7:String) 
      {
         var _loc8_= new SpriteSheetAssetLoaderInfo(param1,param2,param7,param5);
         MemoryTracker.track(_loc8_,"SpriteSheetAssetLoaderInfo - " + param2 + " from: " + param1,"brain");
         if(param5)
         {
            if(mAssetRepository.tryCache(_loc8_,param3))
            {
               return;
            }
         }
         var _loc9_= new AssetLoadingTracker(_loc8_.getKey(),this,param3,param4);
         MemoryTracker.track(_loc9_,"AssetLoadingTracker - SpriteSheet: " + param2,"brain");
         mAssetRepository.getSpriteSheetAsset(mFacade,_loc8_,param2,_loc9_.successCallback,_loc9_.errorCallback,param6,param7,this);
      }
      
      public function getSoundAsset(param1:String, param2:String, param3:ASFunction, param4:ASFunction = null, param5:Bool = true) 
      {
         if(param2 == null)
         {
            return;
         }
         var _loc6_= new SoundAssetLoaderInfo(param1,param2,param5);
         MemoryTracker.track(_loc6_,"SoundAssetLoaderInfo - sound: " + param2 + " from: " + param1,"brain");
         if(param5)
         {
            if(mAssetRepository.tryCache(_loc6_,param3))
            {
               return;
            }
         }
         var _loc7_= new AssetLoadingTracker(param1,this,param3,param4);
         MemoryTracker.track(_loc7_,"AssetLoadingTracker - Sound: " + param2,"brain");
         mAssetRepository.getSoundAsset(_loc6_,param2,_loc7_.successCallback,_loc7_.errorCallback);
      }
      
      public function getURLSoundAsset(param1:String, param2:ASFunction, param3:ASFunction = null, param4:Bool = true) 
      {
         var _loc5_= new SoundAssetLoaderInfo(param1,"",param4);
         MemoryTracker.track(_loc5_,"SoundAssetLoaderInfo - URL sound: " + param1,"brain");
         if(param4)
         {
            if(mAssetRepository.tryCache(_loc5_,param2))
            {
               return;
            }
         }
         var _loc6_= new AssetLoadingTracker(param1,this,param2,param3);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - URL Sound: " + param1,"brain");
         mAssetRepository.getURLSoundAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getImageAsset(param1:String, param2:ASFunction, param3:ASFunction = null, param4:Bool = true) 
      {
         var _loc5_= new AssetLoaderInfo(param1,param4);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - Image asset: " + param1,"brain");
         if(param4)
         {
            if(mAssetRepository.tryCache(_loc5_,param2))
            {
               return;
            }
         }
         var _loc6_= new AssetLoadingTracker(param1,this,param2,param3);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - Image: " + param1,"brain");
         mAssetRepository.getImageAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      override public function destroy() 
      {
         var _loc1_:ISetIterator = null;
         mTransitionToEmptyFunction = null;
         _loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator() , ISetIterator);
         while(_loc1_.hasNext())
         {
            RemoveLoader(ASCompat.dynamicAs(_loc1_.next() , AssetLoadingTracker));
            _loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator() , ISetIterator);
         }
         mPendingDownloads = null;
         super.destroy();
      }
      
      public function clearAllActive() 
      {
         var _loc1_:ISetIterator = null;
         mTransitionToEmptyFunction = null;
         _loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator() , ISetIterator);
         while(_loc1_.hasNext())
         {
            RemoveLoader(ASCompat.dynamicAs(_loc1_.next() , AssetLoadingTracker));
            _loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator() , ISetIterator);
         }
      }
      
      public function RemoveLoader(param1:AssetLoadingTracker) 
      {
         mAssetRepository.removeCallbackFromPendingDownload(param1.assetKey,param1.successCallback);
         mAssetRepository.removeErrorCallbackFromPendingDownload(param1.assetKey,param1.errorCallback);
         param1.destroy();
         var _loc2_= mPendingDownloads.remove(param1);
         if(_loc2_ && mPendingDownloads.size == 0 && mTransitionToEmptyFunction != null)
         {
            mTransitionToEmptyFunction();
            mTransitionToEmptyFunction = null;
         }
      }
      
      public function setTransitionToEmptyCallback(param1:ASFunction) 
      {
         if(mPendingDownloads.size == 0 && param1 != null)
         {
            param1();
            mTransitionToEmptyFunction = null;
         }
         else
         {
            mTransitionToEmptyFunction = param1;
         }
      }
   }


