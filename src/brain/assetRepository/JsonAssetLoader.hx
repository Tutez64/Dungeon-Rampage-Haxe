package brain.assetRepository
;
   import brain.facade.Facade;
   
    class JsonAssetLoader extends AssetLoader
   {
      
      public function new(param1:Facade, param2:AssetLoaderInfo, param3:ASFunction, param4:ASFunction)
      {
         super(param1,param2,param3,param4);
      }
      
      override function buildAsset(param1:ASObject) : Asset
      {
         return new JsonAsset(param1);
      }
   }


