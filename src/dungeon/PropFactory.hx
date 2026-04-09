package dungeon
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import facade.DBFacade;
   import gameMasterDictionary.GMProp;
   import flash.display.MovieClip;
   import org.as3commons.collections.Map;
   
    class PropFactory
   {
      
      var mDBFacade:DBFacade;
      
      var mLibraryJson:Array<ASAny>;
      
      var mConstantToJsonMap:Map;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function new(param1:DBFacade, param2:Array<ASAny>)
      {
         
         mDBFacade = param1;
         mLibraryJson = param2;
         mConstantToJsonMap = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         buildLibraryMap();
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mLibraryJson = null;
         mConstantToJsonMap.clear();
         mConstantToJsonMap = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
      }
      
      function buildLibraryMap() 
      {
         var _loc2_= 0;
         var _loc1_:ASObject = null;
         while(_loc2_ < mLibraryJson.length)
         {
            _loc1_ = mLibraryJson[_loc2_];
            mConstantToJsonMap.add(_loc1_.constant,_loc1_);
            _loc2_++;
         }
      }
      
      public function getNavCollisionJson(param1:String) : Array<ASAny>
      {
         var _loc2_:ASObject = mConstantToJsonMap.itemFor(param1);
         if(ASCompat.toBool(_loc2_))
         {
            return ASCompat.dynamicAs(_loc2_.navCollisions, Array);
         }
         return null;
      }
      
      public function getNavCollisionTriggerOffJson(param1:String) : Array<ASAny>
      {
         var _loc2_:ASObject = mConstantToJsonMap.itemFor(param1);
         if(ASCompat.toBool(_loc2_))
         {
            return ASCompat.dynamicAs(_loc2_.navCollisions_off, Array);
         }
         return null;
      }
      
      public function createProp(param1:String, param2:ASFunction) 
      {
         var swfPath:String;
         var assetClassName:String;
         var constant= param1;
         var assetLoadedCallback= param2;
         var gmProp= ASCompat.dynamicAs(mDBFacade.gameMaster.propByConstant.itemFor(constant) , GMProp);
         if(gmProp == null)
         {
            Logger.warn("createProp constant not found in GM data: " + constant);
            return;
         }
         swfPath = DBFacade.buildFullDownloadPath(gmProp.SwfFilepath);
         assetClassName = gmProp.AssetClassName;
         mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass(assetClassName);
            var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
            assetLoadedCallback(_loc3_);
         });
      }
   }


