package facade
;
   import actor.ActorRenderer;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMSkin;
   import gameMasterDictionary.GMWeaponItem;
   
    class TrickleCacheLoader
   {
      
      public function new()
      {
         
      }
      
      public static function swfAsset(param1:String, param2:DBFacade) 
      {
         var name= param1;
         var dbFacade= param2;
         var trash_AssetLoadingComponent= new AssetLoadingComponent(dbFacade);
         trash_AssetLoadingComponent.getSwfAsset(name,function(param1:brain.assetRepository.SwfAsset)
         {
         });
      }
      
      public static function tilelibrary(param1:String, param2:DBFacade) 
      {
         var makeCallback:ASFunction;
         var name= param1;
         var dbFacade= param2;
         var trash_AssetLoadingComponent= new AssetLoadingComponent(dbFacade);
         if(dbFacade.getTileLibraryJson(name) == null)
         {
            makeCallback = function(param1:String):ASFunction
            {
               var path= param1;
               return function(param1:brain.assetRepository.JsonAsset)
               {
                  dbFacade.AddTileLibraryJson(path,param1);
               };
            };
            loadJsonHelperFunction(trash_AssetLoadingComponent,DBFacade.buildFullDownloadPath(name),ASCompat.asFunction(makeCallback(name)));
         }
      }
      
      static function loadJsonHelperFunction(param1:AssetLoadingComponent, param2:String, param3:ASFunction) 
      {
         var assetLoader= param1;
         var path= param2;
         var successCallback= param3;
         assetLoader.getJsonAsset(path,successCallback,function()
         {
            Logger.error("Unable to load tileLibrary from path: " + path);
         },false);
      }
      
      public static function loadNPCSpriteSheet(param1:GMNpc, param2:DBFacade, param3:Vector<String>) 
      {
         ActorRenderer.cache_loadSpriteSheetAsset(param2,DBFacade.buildFullDownloadPath(param1.SwfFilepath),(Std.int(param1.SpriteHeight) : UInt),(Std.int(param1.SpriteWidth) : UInt),param1.AssetType,param3);
      }
      
      public static function loadHeroSpriteSheet(param1:DBFacade, param2:GMSkin, param3:Vector<String> = null) 
      {
         if(param3 == null)
         {
            param3 = new Vector<String>();
         }
         var _loc4_= ASCompat.dynamicAs(param1.gameMaster.heroByConstant.itemFor(param2.ForHero), gameMasterDictionary.GMHero);
         ActorRenderer.cache_loadSpriteSheetAsset(param1,DBFacade.buildFullDownloadPath(param2.SwfFilepath),param2.SpriteHeight,param2.SpriteWidth,param2.AssetType,param3);
      }
      
      public static function loadHero(param1:DBFacade, param2:UInt) 
      {
         var _loc5_:GMSkin = null;
         var _loc4_= param1.gameMaster.getSkinByType(param2);
         var _loc3_= param1.gameMaster.getHeroByConstant(_loc4_.ForHero);
         if(_loc3_.Id == 106 && !param1.gameMaster.isSkinTypeADefaultSkin(_loc4_.Id))
         {
            _loc5_ = param1.gameMaster.getSkinByConstant(_loc3_.DefaultSkin);
            loadHeroSpriteSheet(param1,_loc5_);
         }
         loadHeroSpriteSheet(param1,_loc4_);
      }
      
      public static function swfVector(param1:Vector<String>, param2:DBFacade) 
      {
         var _loc4_= 0;
         var _loc3_:String = null;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = param1[_loc4_];
            swfAsset(_loc3_,param2);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      public static function npcVector(param1:Vector<UInt>, param2:DBFacade) 
      {
         var _loc5_= 0;
         var _loc7_= 0;
         var _loc3_:GMNpc = null;
         var _loc6_:Vector<String> = /*undefined*/null;
         var _loc4_:GMWeaponItem = null;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc7_ = (param1[_loc5_] : Int);
            _loc3_ = ASCompat.dynamicAs(param2.gameMaster.npcById.itemFor(_loc7_), gameMasterDictionary.GMNpc);
            if(_loc3_ != null)
            {
               if(_loc3_.SwfFilepath == null || _loc3_.SwfFilepath == "null")
               {
                  Logger.info("NPC with Costant: " + _loc3_.Constant + " does not contain a SwfFilePath.");
               }
               else
               {
                  _loc6_ = new Vector<String>();
                  if(ASCompat.stringAsBool(_loc3_.Weapon1) && _loc3_.Weapon1.length > 0)
                  {
                     _loc4_ = ASCompat.dynamicAs(param2.gameMaster.weaponItemByConstant.itemFor(_loc3_.Weapon1), gameMasterDictionary.GMWeaponItem);
                     if(_loc4_ != null)
                     {
                        if(_loc4_.WeaponAestheticList == null)
                        {
                           Logger.error("Unable to find aesthetics for npc weapon: " + _loc3_.Weapon1);
                           return;
                        }
                        _loc6_.push(_loc4_.WeaponAestheticList[0].ModelName);
                     }
                  }
                  loadNPCSpriteSheet(_loc3_,param2,_loc6_);
               }
            }
            else
            {
               trace(" No Npc Found For ",_loc7_);
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
      }
   }


