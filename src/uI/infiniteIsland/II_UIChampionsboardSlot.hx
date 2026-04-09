package uI.infiniteIsland
;
   import account.FriendInfo;
   import account.ItemInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import gameMasterDictionary.GMRarity;
   import gameMasterDictionary.GMWeaponItem;
   import uI.inventory.UIWeaponTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
    class II_UIChampionsboardSlot
   {
      
      public static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      public static inline final LINKAGE_NAME= "leaderboard_slot";
      
      var mDBFacade:DBFacade;
      
      var mNum:Int = 0;
      
      var mRoot:MovieClip;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mIconMC:MovieClip;
      
      var mWeaponSlotA:UIObject;
      
      var mWeaponSlotB:UIObject;
      
      var mWeaponSlotC:UIObject;
      
      public function new(param1:DBFacade, param2:Int)
      {
         
         mDBFacade = param1;
         mNum = param2;
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),setupUI);
      }
      
      public function setupUI(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass("leaderboard_slot");
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mRoot.x = 10;
         mWeaponSlotA = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).loot_slot_A1, flash.display.MovieClip));
         mWeaponSlotB = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).loot_slot_A2, flash.display.MovieClip));
         mWeaponSlotC = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).loot_slot_A3, flash.display.MovieClip));
         mRoot.y = mNum * mRoot.height;
         if(mNum % 2 != 0)
         {
            ASCompat.setProperty((mRoot : ASAny).dark_row_2, "visible", false);
         }
         else
         {
            ASCompat.setProperty((mRoot : ASAny).dark_row_1, "visible", false);
         }
      }
      
      public function setDungeonDetails(param1:Int, param2:FriendInfo, param3:Bool) 
      {
         ASCompat.setProperty((mRoot : ASAny).friend_name, "text", param2.name);
         ASCompat.setProperty((mRoot : ASAny).player01_number, "text", param2.getIILeaderboardScoreForNode(param1));
         ASCompat.setProperty((mRoot : ASAny).friend_pic.you_online, "visible", param3);
         loadAvatarSkinPic(param2.getIILeaderboardAvatarSkinForNode(param1));
         loadWeaponsUsed(param2.getWeaponsUsedForNode((param1 : UInt)));
      }
      
      function loadWeaponsUsed(param1:Array<Dynamic>) 
      {
         var weapons= param1;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset)
         {
            var _loc5_:UIWeaponTooltip = null;
            var _loc4_:UIWeaponTooltip = null;
            var _loc3_:UIWeaponTooltip = null;
            var _loc2_= param1.getClass("DR_weapon_tooltip");
            while(mWeaponSlotA.root.numChildren > 1)
            {
               mWeaponSlotA.root.removeChildAt(1);
            }
            if(mWeaponSlotA.tooltip != null)
            {
               mWeaponSlotA.tooltip = null;
            }
            while(mWeaponSlotB.root.numChildren > 1)
            {
               mWeaponSlotB.root.removeChildAt(1);
            }
            if(mWeaponSlotB.tooltip != null)
            {
               mWeaponSlotB.tooltip = null;
            }
            while(mWeaponSlotC.root.numChildren > 1)
            {
               mWeaponSlotC.root.removeChildAt(1);
            }
            if(mWeaponSlotC.tooltip != null)
            {
               mWeaponSlotC.tooltip = null;
            }
            if(weapons.length > 0 && weapons[0] != null)
            {
               _loc5_ = new UIWeaponTooltip(mDBFacade,_loc2_);
               weaponTooltipHelper(weapons[0],_loc5_,mWeaponSlotA);
            }
            if(weapons.length > 1 && weapons[1] != null)
            {
               _loc4_ = new UIWeaponTooltip(mDBFacade,_loc2_);
               weaponTooltipHelper(weapons[1],_loc4_,mWeaponSlotB);
            }
            if(weapons.length > 2 && weapons[2] != null)
            {
               _loc3_ = new UIWeaponTooltip(mDBFacade,_loc2_);
               weaponTooltipHelper(weapons[2],_loc3_,mWeaponSlotC);
            }
         });
      }
      
      function weaponTooltipHelper(param1:ASObject, param2:UIWeaponTooltip, param3:UIObject) 
      {
         var _loc7_= (ASCompat.toInt(param1.type) : UInt);
         var _loc4_= ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(param1.type), gameMasterDictionary.GMWeaponItem);
         if(_loc4_ == null)
         {
            Logger.warn("Unable to determine gmWeapon from type: " + Std.string(param1.type));
            return;
         }
         var _loc6_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(param1.rarity), gameMasterDictionary.GMRarity);
         var _loc5_= _loc4_.getWeaponAesthetic((ASCompat.toInt(param1.requiredLevel) : UInt),ASCompat.toNumberField(param1, "rarity") == 4);
         ItemInfo.loadItemIcon(_loc5_.IconSwf,_loc5_.IconName,param3.root,mDBFacade,(Std.int(param3.root.width * 2) : UInt),(0 : UInt),mAssetLoadingComponent);
         param2.setWeaponItemFromData(_loc5_.Name,(ASCompat.toInt(param1.power) : UInt),_loc4_.TapIcon,_loc4_.HoldIcon,(ASCompat.toInt(param1.modifier1) : UInt),(ASCompat.toInt(param1.modifier2) : UInt),(ASCompat.toInt(param1.legendaryModifier) : UInt),(ASCompat.toInt(param1.rarity) : UInt),(ASCompat.toInt(param1.requiredLevel) : UInt));
         param3.tooltip = param2;
         param3.tooltipPos = new Point(0,0);
      }
      
      public function setDungeonDetailsForTopTwenty(param1:String, param2:Int, param3:Int, param4:Array<Dynamic>) 
      {
         ASCompat.setProperty((mRoot : ASAny).friend_name, "text", param1);
         ASCompat.setProperty((mRoot : ASAny).player01_number, "text", param2);
         loadAvatarSkinPic(param3);
         loadWeaponsUsed(param4);
      }
      
      function loadAvatarSkinPic(param1:Int) 
      {
         var skinId= param1;
         var gmSkin= mDBFacade.gameMaster.getSkinByType((skinId : UInt));
         var swfPath= gmSkin.UISwfFilepath;
         var iconName= gmSkin.IconName;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset)
         {
            var _loc2_= param1.getClass(iconName);
            mIconMC = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
            (mRoot : ASAny).friend_pic.default_pic.addChild(mIconMC);
            mIconMC.scaleX = mIconMC.scaleY = 0.5;
         });
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
      public function destroy() 
      {
         if(mIconMC != null)
         {
            (mRoot : ASAny).friend_pic.default_pic.removeChild(mIconMC);
            mIconMC = null;
         }
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mRoot = null;
      }
   }


