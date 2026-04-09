package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   import flash.display.Bitmap;
   
    class ImageAssetLoader extends AssetLoader
   {
      
      var mImageAsset:ImageAsset;
      
      public function new(param1:Facade, param2:AssetLoaderInfo, param3:ASFunction, param4:ASFunction = null)
      {
         super(param1,param2,param3,param4,true);
      }
      
      override function buildAsset(param1:ASObject) : Asset
      {
         var _loc2_= ASCompat.dynamicAs(param1 , Bitmap);
         mImageAsset = new ImageAsset(_loc2_);
         MemoryTracker.track(mImageAsset,"ImageAsset - created in ImageAssetLoader.buildAsset()","brain");
         return mImageAsset;
      }
   }


