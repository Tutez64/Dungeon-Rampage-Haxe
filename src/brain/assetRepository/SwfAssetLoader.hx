package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import flash.display.MovieClip;
   import flash.filesystem.File;
   
    class SwfAssetLoader extends AssetLoader
   {
      
      var mSwfAsset:SwfAsset;
      
      var mOriginalLoadedCallback:ASFunction;
      
      var mHdAssetLoader:AssetLoader;
      
      var mIsHdLoader:Bool = false;
      
      public function new(param1:Facade, param2:AssetLoaderInfo, param3:ASFunction, param4:ASFunction, param5:Bool = false)
      {
         mIsHdLoader = param5;
         if(!mIsHdLoader)
         {
            mOriginalLoadedCallback = param3;
         }
         var _loc6_:ASAny = param3;
         if(!mIsHdLoader && param1.featureFlags.getFlagValue("use-hd-assets"))
         {
            _loc6_ = hdAwareLoadedCallback;
         }
         super(param1,param2,ASCompat.asFunction(_loc6_),param4,true);
      }
      
      override function buildAsset(param1:ASObject) : Asset
      {
         var _loc2_= ASCompat.dynamicAs(param1 , MovieClip);
         mSwfAsset = new SwfAsset(_loc2_,mAssetLoaderInfo.getRawAssetPath());
         return mSwfAsset;
      }
      
      function hdAwareLoadedCallback(param1:AssetLoaderInfo, param2:Asset) 
      {
         var _loc3_:AssetLoaderInfo = null;
         mSwfAsset = ASCompat.reinterpretAs(param2 , SwfAsset);
         var _loc4_= param1.getRawAssetPath();
         var _loc5_= getHdPath(_loc4_);
         if(_loc5_ != null && hdFileExists(_loc5_))
         {
            Logger.info("SwfAssetLoader: HD file exists, loading: " + _loc5_);
            _loc3_ = new AssetLoaderInfo(_loc5_,param1.useCache);
            mHdAssetLoader = new SwfAssetLoader(mFacade,_loc3_,hdLoadedCallback,hdErrorCallback,true);
         }
         else
         {
            mOriginalLoadedCallback(param1,param2);
         }
      }
      
      function hdLoadedCallback(param1:AssetLoaderInfo, param2:Asset) 
      {
         var _loc3_= ASCompat.reinterpretAs(param2 , SwfAsset);
         mSwfAsset.setHdAsset(_loc3_.root,param1.getRawAssetPath());
         Logger.info("SwfAssetLoader: HD version loaded successfully: " + param1.getRawAssetPath());
         mHdAssetLoader = null;
         mOriginalLoadedCallback(mAssetLoaderInfo,mSwfAsset);
      }
      
      function hdErrorCallback(param1:AssetLoaderInfo) 
      {
         Logger.info("SwfAssetLoader: HD version not found or failed to load: " + param1.getRawAssetPath());
         mHdAssetLoader = null;
         mOriginalLoadedCallback(mAssetLoaderInfo,mSwfAsset);
      }
      
      function hdFileExists(param1:String) : Bool
      {
         var _loc8_:Bool;
         var _loc4_:ASAny = null;
         var _loc3_:String = null;
         var _loc2_:File = null;
         try
         {
            _loc4_ = param1;
            if(ASCompat.toNumber(_loc4_.indexOf("./")) == 0)
            {
               _loc4_ = Std.string(_loc4_).substring(2);
               _loc3_ = "app:/" + Std.string(_loc4_);
               _loc2_ = new File(_loc3_);
               return _loc2_.exists;
            }
            Logger.info("SwfAssetLoader: Failed to strip prefix ./ when detecting HD asset: " + param1);
            return false;
         }
         catch(error:Dynamic)
         {
            Logger.info("SwfAssetLoader: Error checking HD file existence: " + param1 + " - " + Std.string(error.message));
            _loc8_ = false;
         }
         return _loc8_;
      }
      
      function getHdPath(param1:String) : String
      {
         var _loc3_= param1.lastIndexOf(".");
         if(_loc3_ == -1)
         {
            return null;
         }
         var _loc2_= param1.substring(_loc3_);
         if(_loc2_.toLowerCase() != ".swf")
         {
            return null;
         }
         var _loc4_= param1.substring(0,_loc3_);
         return _loc4_ + ".HD.swf";
      }
      
      override public function destroy() 
      {
         mSwfAsset = null;
         mOriginalLoadedCallback = null;
         mHdAssetLoader = null;
         super.destroy();
      }
   }


