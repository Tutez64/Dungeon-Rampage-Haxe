package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   import flash.utils.ByteArray;
   
    class ByteArrayAssetLoader extends AssetLoader
   {
      
      var mByteArrayAsset:ByteArrayAsset;
      
      public function new(param1:Facade, param2:AssetLoaderInfo, param3:ASFunction, param4:ASFunction = null)
      {
         super(param1,param2,param3,param4,false,"binary");
      }
      
      override function buildAsset(param1:ASObject) : Asset
      {
         mByteArrayAsset = new ByteArrayAsset((param1 : ByteArray) );
         MemoryTracker.track(mByteArrayAsset,"ByteArrayAsset - created in ByteArrayAssetLoader.buildAsset()","brain");
         return mByteArrayAsset;
      }
   }


