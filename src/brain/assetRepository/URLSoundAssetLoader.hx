package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.sound.SoundAsset;
   import brain.utils.MemoryTracker;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.media.Sound;
   import flash.net.URLRequest;
   
    class URLSoundAssetLoader extends AssetLoader
   {
      
      var mSoundAsset:SoundAsset;
      
      var mSound:Sound;
      
      public function new(param1:Facade, param2:AssetLoaderInfo, param3:ASFunction, param4:ASFunction = null)
      {
         super(param1,param2,param3,param4,false);
      }
      
      override function loadAsset(param1:Facade, param2:String, param3:Bool = true) 
      {
         var _loc4_= new URLRequest(param2);
         if(param3)
         {
            _loc4_.url += "?v=" + param1.fileVersion(param2);
         }
         else
         {
            _loc4_.url += "?t=" + Std.string(Date.now().getTime());
         }
         mSound = new Sound();
         mSound.load(_loc4_);
         mSound.addEventListener("complete",soundLoadComplete);
         mSound.addEventListener("ioError",soundLoadIOError);
         mSound.addEventListener("securityError",soundLoadSecurityError);
         if(AssetLoader.mCollectingTrackLoads)
         {
            AssetLoader.mTrackedLoads.add(mAssetLoaderInfo.getRawAssetPath());
         }
      }
      
      function soundLoadComplete(param1:Event) 
      {
         Logger.info("Loader.loadComplete: " + Std.string(param1.target.url));
         mSoundAsset = new SoundAsset(mSound);
         MemoryTracker.track(mSoundAsset,"SoundAsset - URL: " + Std.string(param1.target.url),"brain");
         var _loc2_:Asset = mSoundAsset;
         var _loc3_= mAssetLoaderInfo;
         mAssetCreatedCallback(mAssetLoaderInfo,_loc2_);
         AssetLoader.updateTrackingLoad(_loc3_.getRawAssetPath());
      }
      
      function soundLoadIOError(param1:IOErrorEvent) 
      {
         var evt= param1;
         AssetLoader.updateTrackingLoad(mAssetLoaderInfo.getRawAssetPath());
         if(mFacade.gameClock.frame > 1)
         {
            mFacade.logicalWorkManager.doLater(0.1,function(param1:brain.clock.GameClock)
            {
               if(mAssetLoaderInfo != null)
               {
                  Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
                  if(mErrorCallback != null)
                  {
                     mErrorCallback(mAssetLoaderInfo);
                  }
               }
            },false,"URLSoundAssetLoader.handleIOError");
         }
         else
         {
            Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
            if(mErrorCallback != null)
            {
               mErrorCallback(mAssetLoaderInfo);
            }
         }
      }
      
      function soundLoadSecurityError(param1:SecurityErrorEvent) 
      {
         Logger.error("Loader.handleSecurityError from path: " + mAssetLoaderInfo.getRawAssetPath() + ".   " + param1.text);
         var _loc2_= mAssetLoaderInfo;
         if(mErrorCallback != null)
         {
            mErrorCallback(mAssetLoaderInfo);
         }
         AssetLoader.updateTrackingLoad(_loc2_.getRawAssetPath());
      }
   }


