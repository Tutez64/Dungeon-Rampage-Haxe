package brain.assetRepository
;
    class SoundAssetLoaderInfo extends AssetLoaderInfo
   {
      
      var mSoundName:String;
      
      public function new(param1:String, param2:String, param3:Bool)
      {
         super(param1,param3);
         mSoundName = param2;
      }
      
      override public function getKey() : String
      {
         return getRawAssetPath() + "_" + mSoundName;
      }
   }


