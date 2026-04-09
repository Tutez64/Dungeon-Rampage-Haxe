package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.sound.SoundAsset;
   import brain.utils.MemoryTracker;
   import flash.media.Sound;
   import org.as3commons.collections.Map;


    class AssetRepository
   {
      
      static var mAssetCache:AssetCache = new AssetCache();
      
      var mPendingLoads:Map = new Map();
      
      var mFacade:Facade;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
      }
      
      public function tryCache(param1:AssetLoaderInfo, param2:ASFunction) : Bool
      {
         var _loc3_= mAssetCache.itemFor(param1);
         if(_loc3_ != null)
         {
            if(param2 != null)
            {
               param2(_loc3_);
            }
            return true;
         }
         return false;
      }
      
      function getAsset(param1:AssetLoaderInfo, param2:ASFunction, param3:ASFunction, param4:Dynamic) : Bool
      {
         var _loc5_:AssetLoader = null;
         var _loc7_= param1.getKey();
         if(tryCache(param1,param2))
         {
            return true;
         }
         var _loc6_= ASCompat.dynamicAs(mPendingLoads.itemFor(_loc7_), brain.assetRepository.ActiveLoadBase);
         if(_loc6_ == null)
         {
            _loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(param4, [mFacade,param1,this.executeSuccessCallbacks,this.executeErrorCallbacks]), brain.assetRepository.AssetLoader);
            MemoryTracker.track(_loc5_,"AssetLoader - loading: " + _loc7_,"brain");
            _loc6_ = new ActiveLoaderWithLoader(_loc5_,this,param1);
            MemoryTracker.track(_loc6_,"ActiveLoaderWithLoader - loading: " + _loc7_,"brain");
            mPendingLoads.add(_loc7_,_loc6_);
         }
         _loc6_.AddCallback(param2,param3);
         return false;
      }
      
      public function getJsonAsset(param1:AssetLoaderInfo, param2:ASFunction, param3:ASFunction = null) : AssetLoaderInfo
      {
         var _loc4_= getAsset(param1,param2,param3,JsonAssetLoader);
         return ASCompat.dynamicAs(_loc4_ ? null : param1, brain.assetRepository.AssetLoaderInfo);
      }
      
      public function getXMLAsset(param1:AssetLoaderInfo, param2:ASFunction, param3:ASFunction = null) : AssetLoaderInfo
      {
         var _loc4_= getAsset(param1,param2,param3,XMLAssetLoader);
         return ASCompat.dynamicAs(_loc4_ ? null : param1, brain.assetRepository.AssetLoaderInfo);
      }
      
      public function getByteArrayAsset(param1:AssetLoaderInfo, param2:ASFunction, param3:ASFunction = null) : AssetLoaderInfo
      {
         var _loc4_= getAsset(param1,param2,param3,ByteArrayAssetLoader);
         return ASCompat.dynamicAs(_loc4_ ? null : param1, brain.assetRepository.AssetLoaderInfo);
      }
      
      public function getSwfAsset(param1:AssetLoaderInfo, param2:ASFunction, param3:ASFunction = null) : AssetLoaderInfo
      {
         var _loc4_= getAsset(param1,param2,param3,SwfAssetLoader);
         return ASCompat.dynamicAs(_loc4_ ? null : param1, brain.assetRepository.AssetLoaderInfo);
      }
      
      public function getImageAsset(param1:AssetLoaderInfo, param2:ASFunction, param3:ASFunction = null) : AssetLoaderInfo
      {
         var _loc4_= getAsset(param1,param2,param3,ImageAssetLoader);
         return ASCompat.dynamicAs(_loc4_ ? null : param1, brain.assetRepository.AssetLoaderInfo);
      }
      
      public function getSpriteSheetAsset(param1:Facade, param2:SpriteSheetAssetLoaderInfo, param3:String, param4:ASFunction, param5:ASFunction, param6:ASFunction, param7:String, param8:AssetLoadingComponent = null) 
      {
         var activeLoad:ActiveLoadBase;
         var swfLoaderInfo:AssetLoaderInfo;
         var loadSpriteSheetFromCache:ASFunction;
         var loadSpriteSheet:ASFunction;
         var trackLoad:ActiveLoaderDependent;
         var facade= param1;
         var sheetLoaderInfo= param2;
         var bitmapDataName= param3;
         var loadedCallback= param4;
         var errorCallback= param5;
         var trickelLoaderCallback= param6;
         var shClassName= param7;
         var assetLoadingComponent= param8;
         if(tryCache(sheetLoaderInfo,loadedCallback))
         {
            return;
         }
         activeLoad = ASCompat.dynamicAs(mPendingLoads.itemFor(sheetLoaderInfo.getKey()), brain.assetRepository.ActiveLoadBase);
         if(activeLoad != null)
         {
            activeLoad.AddCallback(loadedCallback,errorCallback);
            return;
         }
         swfLoaderInfo = new AssetLoaderInfo(sheetLoaderInfo.getRawAssetPath(),sheetLoaderInfo.useCache);
         MemoryTracker.track(swfLoaderInfo,"AssetLoaderInfo - SpriteSheet SWF: " + sheetLoaderInfo.getRawAssetPath(),"brain");
         loadSpriteSheetFromCache = function(param1:SwfAsset)
         {
            var _loc2_:SpriteSheetAsset = null;
            if(ASCompat.toBool((param1.root : ASAny).JsonObject) && ASCompat.toBool((param1.root : ASAny).JsonObject[shClassName]))
            {
               _loc2_ = new SpriteSheetAsset(facade);
               _loc2_.FactoryFromSWf(StringTools.replace(bitmapDataName, ".png",""),(param1.root : ASAny).JsonObject[shClassName],param1);
               MemoryTracker.track(_loc2_,"SpriteSheetAsset - " + bitmapDataName + " (from cache)","brain");
               mAssetCache.add(sheetLoaderInfo,_loc2_);
               if(loadedCallback != null)
               {
                  loadedCallback(_loc2_);
               }
            }
         };
         if(tryCache(swfLoaderInfo,loadSpriteSheetFromCache))
         {
            return;
         }
         loadSpriteSheet = function(param1:SwfAsset)
         {
            var _loc2_:SpriteSheetAsset = null;
            if(ASCompat.toBool((param1.root : ASAny).JsonObject) && ASCompat.toBool((param1.root : ASAny).JsonObject[shClassName]))
            {
               _loc2_ = new SpriteSheetAsset(facade);
               _loc2_.FactoryFromSWf(StringTools.replace(bitmapDataName, ".png",""),(param1.root : ASAny).JsonObject[shClassName],param1);
               MemoryTracker.track(_loc2_,"SpriteSheetAsset - " + bitmapDataName + " (new load)","brain");
               mAssetCache.add(sheetLoaderInfo,_loc2_);
               executeSuccessCallbacks(sheetLoaderInfo,_loc2_);
            }
         };
         trackLoad = new ActiveLoaderDependent(this,loadSpriteSheet,sheetLoaderInfo);
         MemoryTracker.track(trackLoad,"ActiveLoaderDependent - SpriteSheet: " + bitmapDataName,"brain");
         mPendingLoads.add(sheetLoaderInfo.getKey(),trackLoad);
         trackLoad.AddCallback(loadedCallback,errorCallback);
         if(assetLoadingComponent != null)
         {
            assetLoadingComponent.getSwfAsset(swfLoaderInfo.getRawAssetPath(),trackLoad.successCallback,trackLoad.errorCallback);
         }
         else
         {
            getSwfAsset(swfLoaderInfo,trackLoad.successCallback,trackLoad.errorCallback);
         }
      }
      
      public function getSoundAsset(param1:SoundAssetLoaderInfo, param2:String, param3:ASFunction, param4:ASFunction = null) 
      {
         var activeLoad:ActiveLoadBase;
         var swfLoaderInfo:AssetLoaderInfo;
         var loadSoundFromCache:ASFunction;
         var loadSound:ASFunction;
         var trackLoad:ActiveLoaderDependent;
         var assetLoaderInfo= param1;
         var soundName= param2;
         var loadedCallback= param3;
         var errorCallback= param4;
         var cacheKey= assetLoaderInfo.getKey();
         if(tryCache(assetLoaderInfo,loadedCallback))
         {
            return;
         }
         activeLoad = ASCompat.dynamicAs(mPendingLoads.itemFor(cacheKey), brain.assetRepository.ActiveLoadBase);
         if(activeLoad != null)
         {
            activeLoad.AddCallback(loadedCallback,errorCallback);
            return;
         }
         swfLoaderInfo = new AssetLoaderInfo(assetLoaderInfo.getRawAssetPath(),assetLoaderInfo.useCache);
         MemoryTracker.track(swfLoaderInfo,"AssetLoaderInfo - Sound SWF: " + assetLoaderInfo.getRawAssetPath(),"brain");
         loadSoundFromCache = function(param1:SwfAsset)
         {
            var _loc3_:Sound = null;
            var _loc4_:SoundAsset = null;
            var _loc2_= param1.getClass(soundName);
            if(_loc2_ != null)
            {
               _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , Sound);
               _loc4_ = new SoundAsset(_loc3_);
               MemoryTracker.track(_loc4_,"SoundAsset - " + soundName + " (from cache)","brain");
               mAssetCache.add(assetLoaderInfo,_loc4_);
               loadedCallback(_loc4_);
            }
            else if(errorCallback != null)
            {
               errorCallback();
            }
         };
         if(tryCache(swfLoaderInfo,loadSoundFromCache))
         {
            return;
         }
         loadSound = function(param1:SwfAsset)
         {
            var _loc3_:Sound = null;
            var _loc4_:SoundAsset = null;
            var _loc2_= param1.getClass(soundName);
            if(_loc2_ != null)
            {
               _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , Sound);
               _loc4_ = new SoundAsset(_loc3_);
               MemoryTracker.track(_loc4_,"SoundAsset - " + soundName + " (new load)","brain");
               executeSuccessCallbacks(assetLoaderInfo,_loc4_);
            }
            else
            {
               executeErrorCallbacks(assetLoaderInfo);
            }
         };
         trackLoad = new ActiveLoaderDependent(this,loadSound,assetLoaderInfo);
         MemoryTracker.track(trackLoad,"ActiveLoaderDependent - Sound: " + soundName,"brain");
         mPendingLoads.add(cacheKey,trackLoad);
         trackLoad.AddCallback(loadedCallback,errorCallback);
         getSwfAsset(swfLoaderInfo,trackLoad.successCallback,trackLoad.errorCallback);
      }
      
      public function getURLSoundAsset(param1:SoundAssetLoaderInfo, param2:ASFunction, param3:ASFunction = null) : AssetLoaderInfo
      {
         var _loc4_= getAsset(param1,param2,param3,URLSoundAssetLoader);
         return ASCompat.dynamicAs(_loc4_ ? null : param1, brain.assetRepository.AssetLoaderInfo);
      }
      
      public function removeCallbackFromPendingDownload(param1:String, param2:ASFunction) : Bool
      {
         var _loc3_= false;
         var _loc4_= ASCompat.dynamicAs(mPendingLoads.itemFor(param1), brain.assetRepository.ActiveLoadBase);
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.removeCallback(param2,null);
            if(_loc4_.hasNoCallbacks())
            {
               mPendingLoads.removeKey(param1);
               _loc4_.destroy();
            }
         }
         return _loc3_;
      }
      
      public function removeErrorCallbackFromPendingDownload(param1:String, param2:ASFunction) : Bool
      {
         var _loc3_= false;
         var _loc4_= ASCompat.dynamicAs(mPendingLoads.itemFor(param1), brain.assetRepository.ActiveLoadBase);
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.removeCallback(null,param2);
            if(_loc4_.hasNoCallbacks())
            {
               mPendingLoads.removeKey(param1);
               _loc4_.destroy();
            }
         }
         return _loc3_;
      }
      
      function executeSuccessCallbacks(param1:AssetLoaderInfo, param2:Asset) 
      {
         var _loc4_= param1.getKey();
         mAssetCache.add(param1,param2);
         var _loc3_= ASCompat.dynamicAs(mPendingLoads.removeKey(_loc4_), brain.assetRepository.ActiveLoadBase);
         if(_loc3_ != null)
         {
            _loc3_.executeSucessCallbacks(param1,param2);
            _loc3_.destroy();
         }
      }
      
      public function executeErrorCallbacks(param1:AssetLoaderInfo) 
      {
         var _loc2_:ActiveLoadBase = null;
         var _loc3_= param1.getKey();
         if(mPendingLoads.hasKey(_loc3_))
         {
            _loc2_ = ASCompat.dynamicAs(mPendingLoads.removeKey(_loc3_), brain.assetRepository.ActiveLoadBase);
            if(_loc2_ != null)
            {
               _loc2_.executeErrorCallbacks(param1);
               _loc2_.destroy();
            }
         }
      }
      
      public function removeCacheForAllSpriteSheetAssets() 
      {
         mAssetCache.removeCacheForSpriteSheetAssets();
      }
      
      public function removeFromCache(param1:Asset) : Bool
      {
         return mAssetCache.remove(param1);
      }
      
      public function destroy() 
      {
      }
   }


final private class ActiveLoaderWithLoader extends brain.assetRepository.ActiveLoadBase
{
   
   public var mAssetLoader:AssetLoader;
   
   public function new(param1:AssetLoader, param2:AssetRepository, param3:AssetLoaderInfo)
   {
      super(param2,param3);
      this.mAssetLoader = param1;
   }
   
   override public function destroy() 
   {
      super.destroy();
      mAssetLoader.destroy();
      mAssetLoader = null;
   }
   
   override public function executeSucessCallbacks(param1:AssetLoaderInfo, param2:Asset) 
   {
      super.executeSucessCallbacks(param1,param2);
   }
}

final private class ActiveLoaderDependent extends brain.assetRepository.ActiveLoadBase
{
   
   public var mSuccess:ASFunction;
   
   public function new(param1:AssetRepository, param2:ASFunction, param3:AssetLoaderInfo)
   {
      super(param1,param3);
      mSuccess = param2;
   }
   
   public function successCallback(param1:ASObject) 
   {
      mSuccess(param1);
   }
   
   public function errorCallback() 
   {
      mAssetRepository.executeErrorCallbacks(mInfo);
   }
   
   override public function destroy() 
   {
      mSuccess = null;
      mAssetRepository.removeCallbackFromPendingDownload(mInfo.getKey(),successCallback);
      mAssetRepository.removeErrorCallbackFromPendingDownload(mInfo.getKey(),errorCallback);
      super.destroy();
   }
}
