package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   
    class XMLAssetLoader extends AssetLoader
   {
      
      var mXMLAsset:XMLAsset;
      
      public function new(param1:Facade, param2:AssetLoaderInfo, param3:ASFunction, param4:ASFunction = null)
      {
         super(param1,param2,param3,param4);
      }
      
      override function buildAsset(param1:ASObject) : Asset
      {
         mXMLAsset = new XMLAsset(new compat.XML(param1));
         MemoryTracker.track(mXMLAsset,"XMLAsset - created in XMLAssetLoader.buildAsset()","brain");
         return mXMLAsset;
      }
   }


