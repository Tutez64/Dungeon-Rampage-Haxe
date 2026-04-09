package brain.assetRepository
;
   import org.as3commons.collections.Map;
   
    class SpriteSheetAssetLoaderInfo extends AssetLoaderInfo
   {
      
      static var mLoadedJson:Map = new Map();
      
      public var bitmapDataName:String;
      
      public function new(param1:String, param2:String, param3:String, param4:Bool)
      {
         super(param1,param4);
         this.bitmapDataName = param2;
      }
      
      override public function getKey() : String
      {
         return getRawAssetPath() + "_" + bitmapDataName;
      }
   }


