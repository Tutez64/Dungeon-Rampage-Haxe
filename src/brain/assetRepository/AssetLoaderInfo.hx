package brain.assetRepository
;
   import brain.logger.Logger;
   
    class AssetLoaderInfo
   {
      
      public var dependentAssetPath:String;
      
      public var useCache:Bool = false;
      
      public function new(param1:String, param2:Bool)
      {
         
         useCache = param2;
         dependentAssetPath = param1;
         if(dependentAssetPath == null || dependentAssetPath == "" || dependentAssetPath == "null" || dependentAssetPath.indexOf("../../../null") != -1)
         {
            Logger.error("Asset Path is null or empty");
         }
      }
      
      public function getKey() : String
      {
         return dependentAssetPath;
      }
      
      public function getRawAssetPath() : String
      {
         return dependentAssetPath;
      }
   }


