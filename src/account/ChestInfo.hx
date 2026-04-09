package account
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import facade.DBFacade;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMRarity;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
    class ChestInfo extends InventoryBaseInfo
   {
      
      var mGMChestData:GMChest;
      
      var mIsFromDungeonSummary:Bool = false;
      
      public function new(param1:DBFacade, param2:ASObject)
      {
         super(param1,param2);
         mIsFromDungeonSummary = false;
         if(param2 == null)
         {
            return;
         }
         mGMChestData = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(mGMId), gameMasterDictionary.GMChest);
         if(mGMChestData == null)
         {
            Logger.error("GMChest is null cannot find item for ID: " + mGMId);
         }
         else
         {
            mGMChestInfo = mGMChestData;
         }
      }
      
      public static function loadItemIcon(param1:String, param2:String, param3:DisplayObjectContainer, param4:DBFacade, param5:UInt, param6:UInt, param7:AssetLoadingComponent = null) 
      {
         var swfPath= param1;
         var iconName= param2;
         var container= param3;
         var dbFacade= param4;
         var desiredSize= param5;
         var iconsNativeSize= param6;
         var assetLoadingComponent= param7;
         var destroyAssetLoaderOnCompletion= false;
         if(assetLoadingComponent == null)
         {
            assetLoadingComponent = new AssetLoadingComponent(dbFacade);
            destroyAssetLoaderOnCompletion = true;
         }
         if(swfPath == null || swfPath == "")
         {
            Logger.error("swfPath provided to ItemInfo::loadItemIcon is empty or null.");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass(iconName);
            if(_loc3_ == null)
            {
               Logger.error("Unable to get iconClass for iconName: " + iconName);
               return;
            }
            var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            _loc2_.scaleX = _loc2_.scaleY = desiredSize / iconsNativeSize;
            container.addChild(_loc2_);
            if(destroyAssetLoaderOnCompletion)
            {
               assetLoadingComponent.destroy();
            }
         });
      }
      
      public static function loadItemIconFromId(param1:UInt, param2:DisplayObjectContainer, param3:DBFacade, param4:UInt, param5:UInt, param6:AssetLoadingComponent = null) 
      {
         var _loc7_= ASCompat.dynamicAs(param3.gameMaster.chestsById.itemFor(param1), gameMasterDictionary.GMChest);
         loadItemIcon(_loc7_.IconSwf,_loc7_.IconName,param2,param3,param4,param5,param6);
      }
      
      override public function  get_iconScale() : Float
      {
         return 120;
      }
      
      override function parseJson(param1:ASObject) 
      {
         if(param1 == null)
         {
            return;
         }
         mGMId = ASCompat.asUint(param1.chest_id );
         mDatabaseId = ASCompat.asUint(param1.id );
         mIsNew = false;
      }
      
      public function setParams(param1:UInt) 
      {
         mDatabaseId = param1;
         mGMId = (ASCompat.toInt(mDBFacade.gameMaster.dooberById.itemFor(mDatabaseId).ChestId) : UInt);
         mGMChestData = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(mGMId), gameMasterDictionary.GMChest);
         if(mGMChestData == null)
         {
            Logger.error("GMChest (setParams) is null cannot find item for ID: " + mGMId);
         }
         mGMChestInfo = mGMChestData;
      }
      
      public function isFromDungeonSummary() : Bool
      {
         return mIsFromDungeonSummary;
      }
      
      public function setFromDungeonSummary() 
      {
         mIsFromDungeonSummary = true;
      }
      
      override public function  get_uiSwfFilepath() : String
      {
         return mGMChestData.IconSwf;
      }
      
      override public function  get_iconName() : String
      {
         return mGMChestData.IconName;
      }
      
      override public function  get_hasColoredBackground() : Bool
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.HasColoredBackground : false;
      }
      
      override public function  get_backgroundIconName() : String
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.BackgroundIcon : "";
      }
      
      override public function  get_backgroundSwfPath() : String
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.BackgroundSwf : "";
      }
      
      override public function  get_Name() : String
      {
         return mGMChestData.Name;
      }
      
      @:isVar public var rarity(get,never):String;
public function  get_rarity() : String
      {
         return mGMChestData.Rarity;
      }
      
      override public function  get_needsRenderer() : Bool
      {
         return true;
      }
   }


