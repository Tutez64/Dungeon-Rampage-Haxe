package uI.inventory
;
   import account.AvatarInfo;
   import account.ChestInfo;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import account.PetInfo;
   import account.StackableInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIRadioButton;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import dBGlobals.DBGlobal;
   import distributedObjects.DistributedDungeonSummary;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMStackable;
   import gameMasterDictionary.GMWeaponItem;
   import town.TownHeader;
   import uI.DBUIOneButtonPopup;
   import uI.DBUITwoButtonPopup;
   import uI.equipPicker.HeroWithEquipPicker;
   import uI.equipPicker.PetsWithEquipPicker;
   import uI.equipPicker.StacksWithEquipPicker;
   import uI.equipPicker.StuffWithEquipPicker;
   import uI.inventory.chests.ChestInfoCard;
   import uI.UIHud;
   import uI.UIPagingPanel;
   import uI.UITownTweens;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class UIInventory
   {
      
      static inline final BUY_KEY_POPUP_SWF_PATH= "Resources/Art2D/UI/db_UI_score_report.swf";
      
      static inline final SELECTED_TAB_SCALE:Float = 1.15;
      
      static inline final NUM_GRID_ELEMENTS= (15 : UInt);
      
      static inline final INV_SLOT_CLASS_NAME= "inv_slot";
      
      static inline final WEAPON_TOOLTIP_CLASS_NAME= "DR_weapon_tooltip";
      
      public static inline final CHARGE_TOOLTIP_CLASS_NAME= "DR_charge_tooltip";
      
      public static inline final EQUIPPABLE_TRUE= (1 : UInt);
      
      public static inline final EQUIPPABLE_NOT_YET= (2 : UInt);
      
      public static inline final EQUIPPABLE_NEVER= (3 : UInt);
      
      static final CATEGORY_ARRAY:Array<ASAny> = ["WEAPON","POWERUP","PET","STUFF"];
      
      var mDBFacade:DBFacade;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mRoot:Sprite;
      
      var mInventoryRoot:MovieClip;
      
      var mSwfAsset:SwfAsset;
      
      var mTownHeader:TownHeader;
      
      var mDungeonRewardPanel:DungeonRewardPanel;
      
      var mTabButtons:Map;
      
      var mPagination:UIPagingPanel;
      
      var mCurrentPage:UInt = (0 : UInt);
      
      var mCurrentTab:String;
      
      var mWantPets:Bool = false;
      
      var mItems:Vector<UIInventoryItem>;
      
      var mInventoryGridElements:Vector<MovieClip>;
      
      var mCategorizedItems:Map;
      
      var mAddStorageButton:UIButton;
      
      var mInfoCard:ItemInfoCard;
      
      var mDungeonSummary:DistributedDungeonSummary;
      
      var mNewItemIds:Array<ASAny>;
      
      var mNewChestIds:Array<ASAny>;
      
      var mNewStackableIds:Array<ASAny>;
      
      var mNewPetIds:Array<ASAny>;
      
      var mHeroWithEquipPicker:HeroWithEquipPicker;
      
      var mStacksWithEquipPicker:StacksWithEquipPicker;
      
      var mPetsWithEquipPicker:PetsWithEquipPicker;
      
      var mStuffWithEquipPicker:StuffWithEquipPicker;
      
      var mSelectedItemInfo:InventoryBaseInfo;
      
      var mSelectedAvatar:UInt = 0;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mChestCard:ChestInfoCard;
      
      var mAbandonChestPopUp:DBUITwoButtonPopup;
      
      var mChestOpenFullPopUp:DBUIOneButtonPopup;
      
      var mEventComponent:EventComponent;
      
      var mRevealedItemType:UInt = 0;
      
      var mRevealedItemOfferId:UInt = 0;
      
      var mRevealedShowEquip:Bool = false;
      
      var mConsumableChestCard:ChestInfoCard;
      
      var mBoosterCard:BoosterInfoCard;
      
      public function new(param1:DBFacade, param2:TownHeader = null, param3:DistributedDungeonSummary = null)
      {
         
         mDBFacade = param1;
         mTownHeader = param2;
         mDungeonSummary = param3;
         mRevealedItemType = (0 : UInt);
         mRevealedItemOfferId = (0 : UInt);
         mRoot = new Sprite();
         if(mDBFacade.dbConfigManager.getConfigBoolean("want_pets",true))
         {
            mWantPets = true;
         }
         mTabButtons = new Map();
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mInventoryGridElements = new Vector<MovieClip>();
         mItems = new Vector<UIInventoryItem>();
         mNewItemIds = [];
         mNewChestIds = [];
         mNewStackableIds = [];
         mNewPetIds = [];
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
      }
      
      public function setRevealedState(param1:UInt, param2:UInt, param3:Bool = false) 
      {
         mRevealedItemType = param1;
         mRevealedItemOfferId = param2;
         mRevealedShowEquip = param3;
      }
      
      function setSelectedAvatar(param1:Int) 
      {
         mSelectedAvatar = (param1 : UInt);
      }
      
      function getSelectedAvatar() : Int
      {
         return (mSelectedAvatar : Int);
      }
      
      @:isVar public var root(get,never):Sprite;
public function  get_root() : Sprite
      {
         return mRoot;
      }
      
      function swfLoaded(param1:SwfAsset) 
      {
         mSwfAsset = param1;
         var _loc2_= mSwfAsset.getClass("DR_UI_town_inventory");
         mInventoryRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mRoot.addChild(mInventoryRoot);
         var _loc3_= param1.getClass("DR_weapon_tooltip");
         var _loc4_= param1.getClass("avatar_tooltip");
         ASCompat.setProperty((mInventoryRoot : ASAny).pet_picker, "visible", false);
         ASCompat.setProperty((mInventoryRoot : ASAny).potion_picker, "visible", false);
         ASCompat.setProperty((mInventoryRoot : ASAny).stuff_picker, "visible", false);
         mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).weapon_picker, flash.display.MovieClip),_loc3_,_loc4_,heroSelected,itemSelected,getSelectedAvatar,setSelectedAvatar,refresh,true);
         mStacksWithEquipPicker = new StacksWithEquipPicker(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).potion_picker, flash.display.MovieClip),_loc3_,_loc4_,itemSelected,refresh,true,getSelectedAvatar,setSelectedAvatar);
         if(mWantPets)
         {
            mPetsWithEquipPicker = new PetsWithEquipPicker(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).pet_picker, flash.display.MovieClip),_loc3_,_loc4_,itemSelected,getSelectedAvatar,setSelectedAvatar,refresh,true);
         }
         mStuffWithEquipPicker = new StuffWithEquipPicker(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).stuff_picker, flash.display.MovieClip),_loc4_,getSelectedAvatar,setSelectedAvatar);
         ASCompat.setProperty((mInventoryRoot : ASAny).close, "visible", false);
         var _loc5_= ASCompat.dynamicAs((mInventoryRoot : ASAny).treasure, flash.display.MovieClip);
         if(mDungeonSummary != null)
         {
            mDungeonRewardPanel = new DungeonRewardPanel(mDBFacade,_loc5_,mDungeonSummary,itemSelected);
            ASCompat.setProperty((_loc5_ : ASAny).label, "text", Locale.getString("LOOT"));
         }
         else
         {
            _loc5_.visible = false;
         }
         buildCategories();
         setupUI(mInventoryRoot);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",accountInfoUpdated);
      }
      
      function accountInfoUpdated(param1:Event) 
      {
         refresh(false);
      }
      
      public function hide() 
      {
         mRoot.visible = false;
      }
      
      public function show(param1:GMChest) 
      {
         mRoot.visible = true;
         mBoosterCard.hide();
         refresh(true);
         if(mDungeonSummary != null)
         {
            mDungeonRewardPanel.setChestAsSelected(param1);
         }
      }
      
      function heroSelected(param1:GMHero, param2:Bool) 
      {
         if(param1 == null)
         {
            return;
         }
         var _loc3_= mDBFacade.gameMaster.Heroes[(mSelectedAvatar : Int)];
         if(_loc3_.Id != param1.Id)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(param1.Id);
         }
         var _loc4_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(param1.Id);
         if(_loc4_ != null && Std.isOfType(mSelectedItemInfo , ChestInfo))
         {
            mChestCard.selectedHeroId = mSelectedAvatar;
            mChestCard.refreshHeroInfoUI();
            refresh(false,true);
         }
         else
         {
            refresh(false);
         }
      }
      
      function determineEquippableItems(param1:GMHero) 
      {
         var _loc7_:InventoryBaseInfo = null;
         var _loc6_:ItemInfo = null;
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc5_= mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc2_= _loc5_.getAvatarInfoForHeroType(param1.Id);
         _loc4_ = 0;
         while(_loc4_ < mItems.length)
         {
            _loc7_ = mItems[_loc4_].info;
            _loc6_ = ASCompat.reinterpretAs(_loc7_ , ItemInfo);
            if(_loc7_ != null && _loc6_ != null && _loc6_.gmWeaponItem != null)
            {
               _loc3_ = 1;
               if(_loc2_ == null)
               {
                  _loc3_ = 3;
               }
               else if(!_loc5_.canAvatarEquipThisMasterType(_loc2_,_loc6_.gmWeaponItem.MasterType))
               {
                  _loc3_ = 3;
               }
               else if(_loc2_.level < _loc6_.requiredLevel)
               {
                  _loc3_ = 2;
               }
               mItems[_loc4_].equippable = (_loc3_ : UInt);
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      function sellItem(param1:InventoryBaseInfo) 
      {
         var info= param1;
         if(info != null)
         {
            if(Std.isOfType(info , ItemInfo) || Std.isOfType(info , StackableInfo) || Std.isOfType(info , PetInfo))
            {
               StoreServicesController.trySellItem(mDBFacade,info,function()
               {
                  var _loc1_= 0;
                  if(Std.isOfType(info , ItemInfo))
                  {
                     _loc1_ = mNewItemIds.indexOf(info.databaseId);
                     if(_loc1_ != -1)
                     {
                        mNewItemIds.splice(_loc1_,(1 : UInt));
                     }
                  }
                  else if(Std.isOfType(info , StackableInfo))
                  {
                     _loc1_ = mNewStackableIds.indexOf(info.databaseId);
                     if(_loc1_ != -1)
                     {
                        mNewStackableIds.splice(_loc1_,(1 : UInt));
                     }
                  }
                  else if(Std.isOfType(info , PetInfo))
                  {
                     _loc1_ = mNewPetIds.indexOf(info.databaseId);
                     if(_loc1_ != -1)
                     {
                        mNewPetIds.splice(_loc1_,(1 : UInt));
                     }
                  }
                  refresh();
               });
            }
            mSelectedItemInfo = null;
         }
         else
         {
            Logger.error("Trying to sell null item info.");
         }
      }
      
      function takeItemCallback() 
      {
         mSelectedItemInfo = null;
      }
      
      function setupUI(param1:MovieClip) 
      {
         var chargeTooltipClass:Dynamic;
         var group:String;
         var tabButton:UIRadioButton;
         var iter:IMapIterator;
         var itemTemplateClass:Dynamic;
         var weaponTooltipClass:Dynamic;
         var uiInventoryItem:UIInventoryItem;
         var i:UInt;
         var root= param1;
         mInventoryRoot = root;
         if(mPagination != null)
         {
            mPagination.destroy();
            mPagination = null;
         }
         mPagination = new UIPagingPanel(mDBFacade,this.numPagesInCurrentCategory(),ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.pagination, flash.display.MovieClip),mSwfAsset.getClass("pagination_button"),this.setCurrentPage);
         chargeTooltipClass = mSwfAsset.getClass("DR_charge_tooltip");
         mInfoCard = new ItemInfoCard(mDBFacade,ASCompat.dynamicAs((root : ASAny).item_card, flash.display.MovieClip),chargeTooltipClass,mHeroWithEquipPicker,mPetsWithEquipPicker,refresh,mDungeonSummary,false,sellItem,takeItemCallback);
         mInfoCard.visible = false;
         if(mChestCard != null)
         {
            mChestCard.destroy();
            mChestCard = null;
         }
         mChestCard = new ChestInfoCard(mDBFacade,mSceneGraphComponent,ASCompat.dynamicAs((root : ASAny).inv_chests, flash.display.MovieClip),abandonChest,openChest,abandonChestDS,openChestDS,keepChestDS);
         if(mConsumableChestCard != null)
         {
            mConsumableChestCard.destroy();
            mConsumableChestCard = null;
         }
         mConsumableChestCard = new ChestInfoCard(mDBFacade,mSceneGraphComponent,ASCompat.dynamicAs((root : ASAny).inv_consumable, flash.display.MovieClip),abandonChest,openChest,abandonChestDS,openChestDS,keepChestDS);
         if(mBoosterCard != null)
         {
            mBoosterCard.destroy();
            mBoosterCard = null;
         }
         mBoosterCard = new BoosterInfoCard(mDBFacade,mSceneGraphComponent,ASCompat.dynamicAs((root : ASAny).booster_card, flash.display.MovieClip));
         group = "UIInventoryTabGroup";
         mTabButtons.add("WEAPON",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.tab_weapons, flash.display.MovieClip),group));
         ASCompat.setProperty((mInventoryRoot : ASAny).grid_widget.tab_weapons.label, "text", Locale.getString("TAB_LOOT"));
         mTabButtons.add("POWERUP",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.tab_potions, flash.display.MovieClip),group));
         ASCompat.setProperty((mInventoryRoot : ASAny).grid_widget.tab_potions.label, "text", Locale.getString("TAB_POWERUPS"));
         if(mWantPets)
         {
            mTabButtons.add("PET",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.tab_pets, flash.display.MovieClip),group));
            ASCompat.setProperty((mInventoryRoot : ASAny).grid_widget.tab_pets.label, "text", Locale.getString("TAB_PETS"));
         }
         mTabButtons.add("STUFF",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.tab_stuff, flash.display.MovieClip),group));
         ASCompat.setProperty((mInventoryRoot : ASAny).grid_widget.tab_stuff.label, "text", Locale.getString("TAB_STUFF"));
         iter = ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(iter.hasNext())
         {
            tabButton = ASCompat.dynamicAs(iter.next(), brain.uI.UIRadioButton);
            ASCompat.setProperty((tabButton.root : ASAny).new_label, "text", Locale.getString("INV_NEW"));
            ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", this.categoryHasAnyNewItems(iter.key));
            ASCompat.setProperty(tabButton.root, "category", iter.key);
            tabButton.releaseCallbackThis = function(param1:UIButton)
            {
               showTab((param1.root : ASAny).category);
            };
            tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         }
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_0, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_1, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_2, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_3, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_4, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_5, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_6, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_7, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_8, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_9, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_10, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_11, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_12, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_13, flash.display.MovieClip));
         mInventoryGridElements.push(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.slot_14, flash.display.MovieClip));
         itemTemplateClass = mSwfAsset.getClass("inv_slot");
         weaponTooltipClass = mSwfAsset.getClass("DR_weapon_tooltip");
         i = (0 : UInt);
         while(i < (mItems.length : UInt))
         {
            mItems[(i : Int)].destroy();
            i = i + 1;
         }
         mItems.splice(0,(mItems.length : UInt));
         i = (0 : UInt);
         while(i < 15)
         {
            uiInventoryItem = new UIInventoryItem(mDBFacade,mInventoryGridElements[(i : Int)],itemTemplateClass,weaponTooltipClass,itemSelected);
            mItems.push(uiInventoryItem);
            uiInventoryItem.visible = false;
            i = i + 1;
         }
         mAddStorageButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget.add_storage_button, flash.display.MovieClip));
         mAddStorageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mAddStorageButton.label.text = Locale.getString("INV_ADD_STORAGE");
         mAddStorageButton.releaseCallback = function()
         {
            StoreServicesController.showStoragePage(mDBFacade);
         };
         mAddStorageButton.visible = false;
      }
      
      function closeEquipButton() 
      {
      }
      
      function abandonChest(param1:ChestInfo) 
      {
         var index:Int;
         var chestInfo= param1;
         mAbandonChestPopUp = new DBUITwoButtonPopup(mDBFacade,Locale.getString("ABANDON_CHEST_POPUP_TITLE"),Locale.getString("ABANDON_CHEST_POPUP_DESC"),Locale.getString("ABANDON_CHEST_POPUP_CANCEL"),closeAbandonChestPopUp,Locale.getString("ABANDON_CHEST_POPUP_CONFIRM"),function()
         {
            mDBFacade.metrics.log("ChestAbandoned",{
               "chestId":chestInfo.gmChestInfo.Id,
               "rarity":chestInfo.rarity,
               "category":"storage"
            });
            mDBFacade.dbAccountInfo.inventoryInfo.dropChest(chestInfo.databaseId,dropChestSuccessfullCallback,abandonChestFailedPopUp);
            closeAbandonChestPopUp();
         },false,null);
         MemoryTracker.track(mAbandonChestPopUp,"DBUITwoButtonPopup - created in UIInventory.abandonChest()");
         index = mNewChestIds.indexOf(chestInfo.databaseId);
         if(index != -1)
         {
            mNewChestIds.splice(index,(1 : UInt));
         }
      }
      
      function closeAbandonChestPopUp() 
      {
         mAbandonChestPopUp = null;
      }
      
      function dropChestSuccessfullCallback(param1:UInt, param2:ASAny) 
      {
         removeChestFromInventory(param1);
         refresh(true);
      }
      
      function returnFromOpenFullPopUp() 
      {
         if(mChestOpenFullPopUp != null)
         {
            mSceneGraphComponent.removeChild(mChestOpenFullPopUp.root);
            mChestOpenFullPopUp = null;
         }
      }
      
      function openChest(param1:ChestInfo) 
      {
         var _loc4_= 0;
         var _loc6_= 0;
         var _loc2_= 0;
         var _loc3_= mChestCard;
         if(UIHud.isThisAConsumbleChestId((param1.gmChestInfo.Id : Int)))
         {
            _loc3_ = mConsumableChestCard;
         }
         if(_loc3_.canChestBeOpened())
         {
            if(param1.isFromDungeonSummary())
            {
               mDungeonSummary.openChestFromInventory(param1.gmChestInfo,true);
            }
            else
            {
               _loc3_.createRevealPopUp(closeRevealPopUp,goToStorage);
               _loc4_ = (mHeroWithEquipPicker.currentlySelectedHero.Id : Int);
               _loc6_ = (mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType((_loc4_ : UInt)).id : Int);
               _loc2_ = (mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType((_loc4_ : UInt)).skinId : Int);
               mDBFacade.dbAccountInfo.inventoryInfo.openChest(param1.databaseId,(_loc6_ : UInt),(_loc2_ : UInt),updateRevealLoot,openChestFailedPopUp);
            }
         }
         else
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"),_loc3_.showBuyKeysPopUp);
         }
         var _loc5_= mNewChestIds.indexOf(param1.databaseId);
         if(_loc5_ != -1)
         {
            mNewChestIds.splice(_loc5_,(1 : UInt));
         }
      }
      
      public function goToStorage(param1:UInt, param2:UInt, param3:Bool) 
      {
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
         mRevealedItemType = param1;
         mRevealedItemOfferId = param2;
         mRevealedShowEquip = param3;
         refresh();
      }
      
      function closeRevealPopUp(param1:UInt, param2:UInt, param3:Bool) 
      {
         mRevealedItemType = param1;
         mRevealedItemOfferId = param2;
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
         refresh();
      }
      
      function updateRevealLoot(param1:UInt, param2:ASAny) 
      {
         mConsumableChestCard.updateRevealLoot(param2);
         mChestCard.updateRevealLoot(param2);
         removeChestFromInventory(param1);
      }
      
      function abandonChestDS(param1:ChestInfo) 
      {
         var chestInfo= param1;
         mAbandonChestPopUp = new DBUITwoButtonPopup(mDBFacade,Locale.getString("ABANDON_CHEST_POPUP_TITLE"),Locale.getString("ABANDON_CHEST_POPUP_DESC"),Locale.getString("ABANDON_CHEST_POPUP_CANCEL"),closeAbandonChestPopUp,Locale.getString("ABANDON_CHEST_POPUP_CONFIRM"),function()
         {
            mDBFacade.metrics.log("ChestAbandoned",{
               "chestId":chestInfo.gmChestInfo.Id,
               "rarity":chestInfo.rarity,
               "category":"storageFromDungeonSummary"
            });
            var _loc1_= mDungeonSummary.findSlotForChest(chestInfo.gmChestInfo);
            mDungeonSummary.abandonChestFromInventory(_loc1_);
            closeAbandonChestPopUp();
         },false,null);
         MemoryTracker.track(mAbandonChestPopUp,"DBUITwoButtonPopup - created in UIInventory.abandonChestDS()");
      }
      
      function openChestDS(param1:ChestInfo) 
      {
         if(mDungeonSummary != null && !mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            mChestOpenFullPopUp = new DBUIOneButtonPopup(mDBFacade,Locale.getString("STORAGE_FULL"),Locale.getString("CLEAR_INVENTORY"),Locale.getString("RETURN"),returnFromOpenFullPopUp,true,returnFromOpenFullPopUp);
            MemoryTracker.track(mChestOpenFullPopUp,"DBUIOneButtonPopup - created in UIInventory.openChestDS()");
            mSceneGraphComponent.addChild(mChestOpenFullPopUp.root,(105 : UInt));
            return;
         }
         openChest(param1);
      }
      
      function keepChestDS(param1:ChestInfo) 
      {
         if(mDungeonSummary != null && !mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            mChestOpenFullPopUp = new DBUIOneButtonPopup(mDBFacade,Locale.getString("STORAGE_FULL"),Locale.getString("CLEAR_INVENTORY"),Locale.getString("RETURN"),returnFromOpenFullPopUp,true,returnFromOpenFullPopUp);
            MemoryTracker.track(mChestOpenFullPopUp,"DBUIOneButtonPopup - created in UIInventory.keepChestDS()");
            mSceneGraphComponent.addChild(mChestOpenFullPopUp.root,(105 : UInt));
            return;
         }
         var _loc2_= mDungeonSummary.findSlotForChest(param1.gmChestInfo);
         mDungeonSummary.keepChestFromInventory(_loc2_,true);
      }
      
      function abandonChestFailedPopUp() 
      {
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
      }
      
      function openChestFailedPopUp() 
      {
         mConsumableChestCard.closeChestRevealPopUp();
         mChestCard.closeChestRevealPopUp();
         refresh();
      }
      
      function removeChestFromInventory(param1:UInt) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < mDBFacade.dbAccountInfo.inventoryInfo.chests.length)
         {
            if(mDBFacade.dbAccountInfo.inventoryInfo.chests[_loc2_].gmId == param1)
            {
               mDBFacade.dbAccountInfo.inventoryInfo.chests.splice(_loc2_,(1 : UInt));
               break;
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         takeItemCallback();
      }
      
      function categoryHasAnyNewItems(param1:String) : Bool
      {
         var _loc2_= (mCategorizedItems.itemFor(param1) : Vector<InventoryBaseInfo>);
         if(_loc2_ == null)
         {
            Logger.error("categoryHasAnyNewItems invalid category: " + param1);
         }
         var _loc3_:InventoryBaseInfo;
         if (checkNullIteratee(_loc2_)) for (_tmp_ in _loc2_)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toBool(_loc3_.isNew))
            {
               return true;
            }
         }
         return false;
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            if(mTownHeader != null)
            {
               mTownHeader.rootMovieClip.visible = false;
               mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:brain.clock.GameClock)
               {
                  mTownHeader.animateHeader();
               });
            }
            ASCompat.setProperty((mInventoryRoot : ASAny).grid_widget, "visible", false);
            mLogicalWorkComponent.doLater(0.16666666666666666,function(param1:brain.clock.GameClock)
            {
               UITownTweens.rightPanelTweenSequence(ASCompat.dynamicAs((mInventoryRoot : ASAny).grid_widget, flash.display.MovieClip),mDBFacade);
            });
            if(mCurrentTab != "WEAPON")
            {
               return;
            }
            mHeroWithEquipPicker.root.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:brain.clock.GameClock)
            {
               UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root,mDBFacade);
            });
         }
      }
      
      function buildCategories() 
      {
         var _loc7_:String = null;
         var _loc9_:Vector<InventoryBaseInfo> = /*undefined*/null;
         var _loc10_:InventoryBaseInfo = null;
         var _loc5_:IMapIterator = null;
         mCategorizedItems = new Map();
         final __ax4_iter_14 = CATEGORY_ARRAY;
         if (checkNullIteratee(__ax4_iter_14)) for (_tmp_ in __ax4_iter_14)
         {
            _loc7_  = _tmp_;
            mCategorizedItems.add(_loc7_,new Vector<InventoryBaseInfo>());
         }
         var _loc8_= mDBFacade.dbAccountInfo.inventoryInfo.items;
         var _loc6_= mDBFacade.dbAccountInfo.inventoryInfo.chests;
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.stackables;
         var _loc1_= mDBFacade.dbAccountInfo.inventoryInfo.pets;
         var _loc4_:Map;
         final __ax4_iter_15:Array<ASAny> = [_loc8_,_loc3_,_loc1_];
         if (checkNullIteratee(__ax4_iter_15)) for (_tmp_ in __ax4_iter_15)
         {
            _loc4_ = ASCompat.dynamicAs(_tmp_, org.as3commons.collections.Map);
            _loc5_ = ASCompat.dynamicAs(_loc4_.iterator() , IMapIterator);
            while(_loc5_.hasNext())
            {
               _loc10_ = ASCompat.dynamicAs(_loc5_.next(), account.InventoryBaseInfo);
               if(_loc10_.gmInventoryBase != null)
               {
                  _loc7_ = _loc10_.gmInventoryBase.ItemCategory;
               }
               else
               {
                  _loc7_ = "PET";
               }
               _loc9_ = mCategorizedItems.itemFor(_loc7_);
               if(_loc9_ == null)
               {
                  Logger.error("No inventory category exists for weapon class type: " + _loc7_);
               }
               else
               {
                  _loc9_.push(_loc10_);
               }
            }
         }
         var _loc2_:ChestInfo;
         if (checkNullIteratee(_loc6_)) for (_tmp_ in _loc6_)
         {
            _loc2_ = _tmp_;
            if(ASCompat.toBool(_loc2_.gmChestInfo))
            {
               _loc7_ = "WEAPON";
               _loc9_ = mCategorizedItems.itemFor(_loc7_);
               if(_loc9_ == null)
               {
                  Logger.error("No inventory category exists for weapon class type: " + _loc7_);
               }
               else
               {
                  _loc9_.push(_loc2_);
               }
            }
         }
         sortCategories();
      }
      
      function inventorySortComparator(param1:Vector<String>, param2:InventoryBaseInfo, param3:InventoryBaseInfo) : Int
      {
         var _loc4_:GMWeaponItem = null;
         var _loc5_:GMWeaponItem = null;
         var _loc6_:AvatarInfo = null;
         var _loc11_= false;
         var _loc8_= false;
         var _loc9_= false;
         var _loc7_= false;
         var _loc10_= 0;
         var _loc12_= 0;
         if(param2.isEquipped && !param3.isEquipped)
         {
            return 1;
         }
         if(param3.isEquipped && !param2.isEquipped)
         {
            return -1;
         }
         if(Std.isOfType(param2 , ItemInfo) && Std.isOfType(param3 , ItemInfo))
         {
            _loc4_ = cast(param2, ItemInfo).gmWeaponItem;
            _loc5_ = cast(param3, ItemInfo).gmWeaponItem;
            _loc6_ = this.mHeroWithEquipPicker.currentlySelectedAvatarInfo;
            if(_loc6_ != null)
            {
               _loc11_ = mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(_loc6_,_loc4_.MasterType);
               _loc8_ = mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(_loc6_,_loc5_.MasterType);
               if(_loc11_ && !_loc8_)
               {
                  return -1;
               }
               if(_loc8_ && !_loc11_)
               {
                  return 1;
               }
               _loc9_ = mDBFacade.dbAccountInfo.inventoryInfo.canThisAvatarEquipThisItem(_loc6_,cast(param2, ItemInfo));
               _loc7_ = mDBFacade.dbAccountInfo.inventoryInfo.canThisAvatarEquipThisItem(_loc6_,cast(param3, ItemInfo));
               if(_loc9_ && !_loc7_)
               {
                  return -1;
               }
               if(_loc7_ && !_loc9_)
               {
                  return 1;
               }
            }
            if(param1 != null)
            {
               _loc10_ = param1.indexOf(_loc4_.MasterType);
               _loc12_ = param1.indexOf(_loc5_.MasterType);
               if(_loc10_ != _loc12_)
               {
                  return _loc10_ - _loc12_;
               }
            }
            return (cast(param3, ItemInfo).requiredLevel - cast(param2, ItemInfo).requiredLevel : Int);
         }
         return (param3.gmId - param2.gmId : Int);
      }
      
      function weaponSortComparator(param1:InventoryBaseInfo, param2:InventoryBaseInfo) : Int
      {
         return this.inventorySortComparator(GMWeaponItem.ALL_WEAPON_SORT,param1,param2);
      }
      
      function basicSortComparator(param1:InventoryBaseInfo, param2:InventoryBaseInfo) : Int
      {
         return this.inventorySortComparator(null,param1,param2);
      }
      
      function sortCategories() 
      {
         var _loc4_:String;
         var _loc2_:String = null;
         var _loc3_:Vector<InventoryBaseInfo> = /*undefined*/null;
         var _loc1_= ASCompat.reinterpretAs(mCategorizedItems.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc3_ = _loc1_.next();
            _loc2_ = _loc1_.key;
            _loc4_ = _loc2_;
            if("WEAPON" != _loc4_)
            {
               ASCompat.ASVector.sort(_loc3_, basicSortComparator);
            }
            else
            {
               ASCompat.ASVector.sort(_loc3_, weaponSortComparator);
            }
         }
      }
      
      public function refresh(param1:Bool = false, param2:Bool = false) 
      {
         var currentTabIsValidCategory:Bool;
         var tabButton:UIRadioButton;
         var iter:IMapIterator;
         var gmHero:GMHero;
         var itemInfo:ItemInfo;
         var canEquip:Bool;
         var resync= param1;
         var dontRefreshChestSelection= param2;
         if(resync)
         {
            mBoosterCard.hide();
         }
         if(mTownHeader != null)
         {
            mTownHeader.title = Locale.getString("INVENTORY_HEADER");
            mTownHeader.refreshKeyPanel();
         }
         mHeroWithEquipPicker.refresh(resync);
         mStacksWithEquipPicker.refresh(resync);
         if(mWantPets)
         {
            mPetsWithEquipPicker.refresh(resync);
         }
         mStuffWithEquipPicker.refresh(resync);
         buildCategories();
         if(mDungeonRewardPanel != null)
         {
            mDungeonRewardPanel.refresh();
         }
         currentTabIsValidCategory = ASCompat.toBool(ASCompat.ASArray.some(CATEGORY_ARRAY, function(param1:ASAny, param2:UInt, param3:Array<ASAny>):Bool
         {
            if(mCurrentTab == ASCompat.asString(param1 ))
            {
               return true;
            }
            return false;
         }));
         if(!currentTabIsValidCategory)
         {
            mCurrentTab = "WEAPON";
         }
         if(!dontRefreshChestSelection)
         {
            mSelectedItemInfo = checkIfRevealedWeaponExists();
         }
         if(mSelectedItemInfo != null && Std.isOfType(mSelectedItemInfo , ItemInfo))
         {
            jumpToWeaponOffer(mSelectedItemInfo);
         }
         else
         {
            this.showTab(mCurrentTab,mCurrentPage);
         }
         if(!dontRefreshChestSelection)
         {
            this.populateDetailInfoCard();
            this.populateDetailChestCard();
            this.highLightSelectedItem();
         }
         this.lookForNewEquippedItems();
         iter = ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(iter.hasNext())
         {
            tabButton = ASCompat.dynamicAs(iter.next(), brain.uI.UIRadioButton);
            ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", this.categoryHasAnyNewItems(iter.key));
         }
         if(mSelectedItemInfo != null && !dontRefreshChestSelection)
         {
            itemSelected(mSelectedItemInfo);
            if(mRevealedShowEquip && Std.isOfType(mSelectedItemInfo , ItemInfo))
            {
               gmHero = mDBFacade.gameMaster.Heroes[(mSelectedAvatar : Int)];
               itemInfo = ASCompat.reinterpretAs(mSelectedItemInfo , ItemInfo);
               canEquip = gmHero.AllowedWeapons.hasKey(itemInfo.gmWeaponItem.MasterType);
               if(canEquip)
               {
                  mInfoCard.loadEquipOnAvatarPopup();
               }
               mRevealedShowEquip = false;
            }
         }
      }
      
      public function jumpToWeaponOffer(param1:InventoryBaseInfo) 
      {
         var _loc4_= "WEAPON";
         var _loc5_= (mCategorizedItems.itemFor("WEAPON") : Vector<InventoryBaseInfo>);
         var _loc2_= _loc5_.indexOf(param1);
         if(_loc2_ == -1)
         {
            Logger.warn("Index not found for item in Storage");
         }
         var _loc3_= (Math.floor(_loc2_ / 15) : UInt);
         this.showTab(_loc4_,_loc3_);
      }
      
      function checkIfRevealedWeaponExists() : InventoryBaseInfo
      {
         var __ax4_iter_16:Vector<InventoryBaseInfo>;
         var _loc10_:Int;
         var _loc9_:Vector<GMOfferDetail>;
         var _loc2_:GMOfferDetail;
         var __ax4_iter_17:Vector<InventoryBaseInfo>;
         var _loc6_:InventoryBaseInfo = null;
         var _loc1_:GMWeaponItem = null;
         var _loc4_= 0;
         var _loc5_:GMOffer = null;
         var _loc3_:GMStackable = null;
         if(mRevealedItemType == 0)
         {
            return null;
         }
         if(mRevealedItemType == 1)
         {
            mCurrentTab = "WEAPON";
            mRevealedItemOfferId %= (100000 : UInt);
            _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemOfferId), gameMasterDictionary.GMWeaponItem);
            __ax4_iter_16 = mCategorizedItems.itemFor(mCurrentTab);
            if (checkNullIteratee(__ax4_iter_16)) for (_tmp_ in __ax4_iter_16)
            {
               _loc6_  = _tmp_;
               if(Std.isOfType(_loc6_ , ItemInfo))
               {
                  _loc4_ = (ASCompat.reinterpretAs(_loc6_ , ItemInfo).gmWeaponItem.Id : Int);
                  if((_loc4_ : UInt) == _loc1_.Id && ASCompat.toBool(_loc6_.isNew))
                  {
                     mRevealedItemType = mRevealedItemOfferId = (0 : UInt);
                     return _loc6_;
                  }
               }
            }
         }
         else if(mRevealedItemType == 2)
         {
            _loc5_ = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(mRevealedItemOfferId), gameMasterDictionary.GMOffer);
            _loc10_ = 0;
            _loc9_ = _loc5_.Details;
            if (checkNullIteratee(_loc9_)) for (_tmp_ in _loc9_)
            {
               _loc2_ = _tmp_;
               _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(_loc2_.StackableId), gameMasterDictionary.GMStackable);
            }
            if(_loc3_ != null)
            {
               mCurrentTab = "POWERUP";
               __ax4_iter_17 = mCategorizedItems.itemFor(mCurrentTab);
               if (checkNullIteratee(__ax4_iter_17)) for (_tmp_ in __ax4_iter_17)
               {
                  _loc6_  = _tmp_;
                  if(ASCompat.toNumberField(_loc6_, "gmId") == _loc3_.Id)
                  {
                     mRevealedItemType = mRevealedItemOfferId = (0 : UInt);
                     return _loc6_;
                  }
               }
            }
         }
         mRevealedItemType = mRevealedItemOfferId = (0 : UInt);
         return null;
      }
      
      function lookForNewEquippedItems() 
      {
         var _loc2_:IMapIterator = null;
         var _loc3_:ItemInfo = null;
         var _loc4_:StackableInfo = null;
         var _loc1_:PetInfo = null;
         _loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.items.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc2_.next(), account.ItemInfo);
            if(_loc3_.isEquipped && _loc3_.isNew && mNewItemIds.indexOf(_loc3_.databaseId) == -1)
            {
               mNewItemIds.push(_loc3_.databaseId);
            }
         }
         _loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.stackables.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc2_.next(), account.StackableInfo);
            if(_loc4_.isEquipped && _loc4_.isNew && mNewStackableIds.indexOf(_loc4_.databaseId) == -1)
            {
               mNewStackableIds.push(_loc4_.databaseId);
            }
         }
         _loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.pets.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc2_.next(), account.PetInfo);
            if(_loc1_.isEquipped && _loc1_.isNew && mNewPetIds.indexOf(_loc1_.databaseId) == -1)
            {
               mNewPetIds.push(_loc1_.databaseId);
            }
         }
      }
      
      function markItemsNotNew() 
      {
         if(mNewChestIds.length != 0 || mNewItemIds.length != 0 || mNewStackableIds.length != 0 || mNewPetIds.length != 0)
         {
            mDBFacade.dbAccountInfo.inventoryInfo.markItemsNotNew();
            mNewItemIds.resize(0);
            mNewStackableIds.resize(0);
            mNewPetIds.resize(0);
            mNewChestIds.resize(0);
         }
      }
      
      public function exitState() 
      {
         this.markItemsNotNew();
         this.processChosenAvatar();
      }
      
      function numElementsInCurrentCategory() : UInt
      {
         var _loc1_= (0 : UInt);
         switch(mCurrentTab)
         {
            case "WEAPON":
               _loc1_ = mDBFacade.dbAccountInfo.inventoryLimitWeapons;
               
            case "POWERUP":
               _loc1_ = mDBFacade.dbAccountInfo.stackableCount;
               if(_loc1_ % 15 != 0)
               {
                  _loc1_ += 15 - _loc1_ % 15;
               }
               
            default:
               _loc1_ = (0 : UInt);
         }
         return _loc1_;
      }
      
      function numPagesInCurrentCategory() : UInt
      {
         return (Math.ceil(numElementsInCurrentCategory() / 15) : UInt);
      }
      
      function displayCategoryPage() 
      {
         var _loc11_:InventoryBaseInfo = null;
         var _loc3_:UIInventoryItem = null;
         var _loc7_= 0;
         var _loc4_= 0;
         var _loc9_= 0;
         var _loc10_= (mCategorizedItems.itemFor(mCurrentTab) : Vector<InventoryBaseInfo>);
         if(mDungeonRewardPanel != null)
         {
            mDungeonRewardPanel.hide();
         }
         if(mCurrentTab == "WEAPON")
         {
            mStacksWithEquipPicker.hide();
            if(mWantPets)
            {
               mPetsWithEquipPicker.hide();
            }
            mStuffWithEquipPicker.hide();
            mAddStorageButton.visible = true;
            mHeroWithEquipPicker.refresh(false);
            mHeroWithEquipPicker.show();
            if(mDungeonRewardPanel != null)
            {
               mDungeonRewardPanel.show();
            }
         }
         else if(mCurrentTab == "POWERUP")
         {
            mHeroWithEquipPicker.hide();
            if(mWantPets)
            {
               mPetsWithEquipPicker.hide();
            }
            mStuffWithEquipPicker.hide();
            mAddStorageButton.visible = false;
            mStacksWithEquipPicker.refresh(false);
            mStacksWithEquipPicker.show();
         }
         else if(mWantPets && mCurrentTab == "PET")
         {
            mHeroWithEquipPicker.hide();
            mStacksWithEquipPicker.hide();
            mStuffWithEquipPicker.hide();
            mAddStorageButton.visible = false;
            mPetsWithEquipPicker.refresh(false);
            mPetsWithEquipPicker.show();
         }
         else if(mWantPets && mCurrentTab == "STUFF")
         {
            mHeroWithEquipPicker.hide();
            mStacksWithEquipPicker.hide();
            if(mWantPets)
            {
               mPetsWithEquipPicker.hide();
            }
            mAddStorageButton.visible = false;
            mStuffWithEquipPicker.refresh(false);
            mStuffWithEquipPicker.show();
         }
         _loc7_ = 0;
         while(_loc7_ < 15)
         {
            _loc3_ = mItems[_loc7_];
            _loc3_.deSelect();
            _loc3_.visible = false;
            _loc7_++;
         }
         var _loc1_= mCurrentPage * 15;
         var _loc5_= (0 : UInt);
         var _loc6_= (0 : UInt);
         _loc7_ = 0;
         while(_loc7_ < mInventoryGridElements.length)
         {
            mInventoryGridElements[_loc7_].visible = true;
            _loc7_++;
         }
         var _loc2_= false;
         var _loc8_= numElementsInCurrentCategory();
         if(_loc1_ + 15 > _loc8_ && numElementsInCurrentCategory() != 0)
         {
            _loc4_ = (_loc1_ + 15 - numElementsInCurrentCategory() : Int);
            _loc9_ = mInventoryGridElements.length - _loc4_;
            _loc7_ = mInventoryGridElements.length - 1;
            while(_loc7_ >= _loc9_)
            {
               if(_loc7_ < mInventoryGridElements.length)
               {
                  mInventoryGridElements[_loc7_].visible = false;
               }
               else
               {
                  _loc2_ = true;
               }
               _loc7_--;
            }
         }
         _loc7_ = 0;
         while((_loc7_ : UInt) < _loc1_ && _loc5_ < (_loc10_.length : UInt))
         {
            _loc11_ = _loc10_[(_loc5_ : Int)];
            if(!_loc11_.isEquipped)
            {
               _loc7_++;
            }
            _loc5_++;
         }
         while(_loc6_ < 15 && _loc5_ < (_loc10_.length : UInt))
         {
            _loc11_ = _loc10_[(_loc5_ : Int)];
            if(!_loc11_.isEquipped && _loc11_.hasGMPropertySetup())
            {
               _loc3_ = mItems[(_loc6_ : Int)];
               _loc3_.info = _loc11_;
               _loc3_.root.visible = true;
               if(_loc11_.isNew)
               {
                  if(Std.isOfType(_loc11_ , ChestInfo) && mNewChestIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewChestIds.push(_loc11_.databaseId);
                  }
                  else if(Std.isOfType(_loc11_ , ItemInfo) && mNewItemIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewItemIds.push(_loc11_.databaseId);
                  }
                  else if(Std.isOfType(_loc11_ , StackableInfo) && mNewStackableIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewStackableIds.push(_loc11_.databaseId);
                  }
                  else if(Std.isOfType(_loc11_ , PetInfo) && mNewPetIds.indexOf(_loc11_.databaseId) == -1)
                  {
                     mNewPetIds.push(_loc11_.databaseId);
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
         determineEquippableItems(mHeroWithEquipPicker.currentlySelectedHero);
      }
      
      function showTab(param1:String, param2:UInt = (0 : UInt)) 
      {
         var _loc4_:UIRadioButton = null;
         mCurrentTab = param1;
         var _loc5_= ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(_loc5_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc5_.next(), brain.uI.UIRadioButton);
            _loc4_.enabled = true;
         }
         _loc4_ = ASCompat.dynamicAs(mTabButtons.itemFor(mCurrentTab), brain.uI.UIRadioButton);
         _loc4_.selected = true;
         _loc4_.enabled = false;
         _loc4_.label.visible = true;
         var _loc3_= this.numPagesInCurrentCategory();
         param2 = (Std.int(Math.min(_loc3_,param2)) : UInt);
         mPagination.currentPage = mCurrentPage = param2;
         mPagination.numPages = _loc3_;
         mPagination.visible = _loc3_ > 1;
         displayCategoryPage();
      }
      
      function setCurrentPage(param1:UInt) 
      {
         mCurrentPage = param1;
         displayCategoryPage();
      }
      
      @:isVar public var infoCard(get,never):ItemInfoCard;
public function  get_infoCard() : ItemInfoCard
      {
         return mInfoCard;
      }
      
      @:isVar public var chestCard(get,never):ChestInfoCard;
public function  get_chestCard() : ChestInfoCard
      {
         return mChestCard;
      }
      
      @:isVar public var currentTab(never,set):String;
public function  set_currentTab(param1:String) :String      {
         return mCurrentTab = param1;
      }
      
      function itemSelected(param1:InventoryBaseInfo) 
      {
         var _loc2_:StackableInfo = null;
         mSelectedItemInfo = param1;
         var _loc3_= false;
         if(Std.isOfType(param1 , StackableInfo))
         {
            _loc2_ = ASCompat.reinterpretAs(param1 , StackableInfo);
            if(_loc2_.gmStackable.AccountBooster)
            {
               populateDetailBoosterCard();
               _loc3_ = true;
            }
         }
         if(!_loc3_)
         {
            mBoosterCard.hide();
            if(mSelectedItemInfo.gmChestInfo != null)
            {
               populateDetailChestCard();
            }
            else
            {
               populateDetailInfoCard();
            }
         }
         highLightSelectedItem();
      }
      
      function highLightSelectedItem() 
      {
         if(ASCompat.reinterpretAs(mSelectedItemInfo , ChestInfo) != null)
         {
            highLightSelectedChestItem();
         }
         else if(ASCompat.reinterpretAs(mSelectedItemInfo , ItemInfo) != null)
         {
            highLightSelectedAvatarItem();
         }
         else if(ASCompat.reinterpretAs(mSelectedItemInfo , StackableInfo) != null)
         {
            highLightSelectedAccountItem();
         }
         else if(mWantPets && ASCompat.reinterpretAs(mSelectedItemInfo , PetInfo) != null)
         {
            highLightSelectedPet();
         }
      }
      
      function highLightSelectedChestItem() 
      {
         var _loc2_:UIInventoryItem = null;
         var _loc3_= 0;
         if(mDungeonRewardPanel != null)
         {
            mDungeonRewardPanel.clearHighlights();
         }
         var _loc1_= ASCompat.reinterpretAs(mSelectedItemInfo , ChestInfo);
         if(_loc1_.isFromDungeonSummary())
         {
            _loc3_ = 0;
            while(_loc3_ < 15)
            {
               mItems[_loc3_].deSelect();
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            mDungeonRewardPanel.highlightChest(_loc1_);
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < 15)
         {
            _loc2_ = mItems[_loc3_];
            if(mSelectedItemInfo != null && _loc2_.info == mSelectedItemInfo)
            {
               _loc2_.select();
            }
            else
            {
               _loc2_.deSelect();
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      function highLightSelectedAvatarItem() 
      {
         var _loc2_:GMWeaponItem = null;
         var _loc4_= 0;
         var _loc1_:UIInventoryItem = null;
         var _loc3_= 0;
         if(mDungeonRewardPanel != null)
         {
            mDungeonRewardPanel.clearHighlights();
         }
         var _loc5_= ASCompat.reinterpretAs(mSelectedItemInfo , ItemInfo);
         mHeroWithEquipPicker.deselectEquipment();
         if(mHeroWithEquipPicker.highlightItem(mSelectedItemInfo))
         {
            _loc2_ = _loc5_.gmWeaponItem;
            _loc4_ = (_loc5_.power : Int);
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < 15)
            {
               _loc1_ = mItems[_loc3_];
               if(mSelectedItemInfo != null && _loc1_.info == mSelectedItemInfo)
               {
                  _loc1_.select();
                  if(_loc5_ != null)
                  {
                     _loc2_ = _loc5_.gmWeaponItem;
                     _loc4_ = (_loc5_.power : Int);
                  }
               }
               else
               {
                  _loc1_.deSelect();
               }
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
         }
         if(_loc2_ != null)
         {
            mHeroWithEquipPicker.showWeaponComparison(_loc2_,(_loc4_ : UInt));
         }
      }
      
      function highLightSelectedAccountItem() 
      {
         var _loc4_:GMStackable = null;
         var _loc5_= 0;
         var _loc2_:UIInventoryItem = null;
         var _loc3_= 0;
         var _loc1_= ASCompat.reinterpretAs(mSelectedItemInfo , StackableInfo);
         mStacksWithEquipPicker.deselectEquipment();
         if(mStacksWithEquipPicker.highlightItem(mSelectedItemInfo))
         {
            _loc4_ = _loc1_.gmStackable;
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < 15)
            {
               _loc2_ = mItems[_loc3_];
               if(mSelectedItemInfo != null && _loc2_.info == mSelectedItemInfo)
               {
                  _loc2_.select();
                  if(_loc1_ != null)
                  {
                     _loc4_ = _loc1_.gmStackable;
                  }
               }
               else
               {
                  _loc2_.deSelect();
               }
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
         }
         if(_loc4_ != null)
         {
         }
      }
      
      function highLightSelectedPet() 
      {
         var _loc1_:GMNpc = null;
         var _loc3_:UIInventoryItem = null;
         var _loc4_= 0;
         var _loc2_= ASCompat.reinterpretAs(mSelectedItemInfo , PetInfo);
         mPetsWithEquipPicker.deselectEquipment();
         if(mPetsWithEquipPicker.highlightItem(mSelectedItemInfo))
         {
            _loc1_ = _loc2_.gmNpc;
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < 15)
            {
               _loc3_ = mItems[_loc4_];
               if(mSelectedItemInfo != null && _loc3_.info == mSelectedItemInfo)
               {
                  _loc3_.select();
                  if(_loc2_ != null)
                  {
                     _loc1_ = _loc2_.gmNpc;
                  }
               }
               else
               {
                  _loc3_.deSelect();
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
      }
      
      function populateDetailBoosterCard() 
      {
         mConsumableChestCard.hide();
         mChestCard.hide();
         mInfoCard.visible = false;
         mBoosterCard.info = ASCompat.reinterpretAs(mSelectedItemInfo , StackableInfo);
      }
      
      function populateDetailInfoCard() 
      {
         mConsumableChestCard.hide();
         mChestCard.hide();
         mInfoCard.info = mSelectedItemInfo;
      }
      
      function populateDetailChestCard() 
      {
         mInfoCard.info = null;
         if(mSelectedItemInfo == null)
         {
            mConsumableChestCard.hide();
            mChestCard.hide();
            mChestCard.selectedHeroId = mSelectedAvatar;
            return;
         }
         if(UIHud.isThisAConsumbleChestId((mSelectedItemInfo.gmId : Int)))
         {
            mConsumableChestCard.info = mSelectedItemInfo;
            mChestCard.hide();
            mBoosterCard.hide();
         }
         else
         {
            mChestCard.selectedHeroId = mSelectedAvatar;
            mChestCard.info = mSelectedItemInfo;
            mConsumableChestCard.hide();
            mBoosterCard.hide();
         }
      }
      
      public function destroy() 
      {
         var _loc4_:UIRadioButton = null;
         var _loc1_:UIInventoryItem = null;
         var _loc5_= 0;
         var _loc2_:MovieClip = null;
         var _loc6_= 0;
         mDBFacade = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         mAssetLoadingComponent = null;
         mRoot = null;
         mInventoryRoot = null;
         mSwfAsset = null;
         mTownHeader = null;
         if(mDungeonRewardPanel != null)
         {
            mDungeonRewardPanel.destroy();
         }
         mDungeonRewardPanel = null;
         var _loc3_= ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc3_.next(), brain.uI.UIRadioButton);
            _loc4_.destroy();
         }
         mTabButtons.clear();
         mTabButtons = null;
         if(mPagination != null)
         {
            mPagination.destroy();
         }
         mPagination = null;
         _loc5_ = 0;
         while(_loc5_ < mItems.length)
         {
            _loc1_ = mItems[_loc5_];
            _loc1_.destroy();
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         mItems = null;
         if(mInventoryGridElements != null)
         {
            _loc6_ = 0;
            while(_loc5_ < mInventoryGridElements.length)
            {
               _loc2_ = mInventoryGridElements[_loc6_];
               _loc2_ = null;
               _loc5_ = ASCompat.toInt(_loc5_) + 1;
            }
         }
         mInventoryGridElements.length = 0;
         mInventoryGridElements = null;
         mCategorizedItems.clear();
         mCategorizedItems = null;
         if(mAddStorageButton != null)
         {
            mAddStorageButton.destroy();
         }
         mAddStorageButton = null;
         if(mInfoCard != null)
         {
            mInfoCard.destroy();
         }
         mInfoCard = null;
         if(mDungeonSummary != null)
         {
            mDungeonSummary.loadNextChestPopUp();
         }
         mDungeonSummary = null;
         mNewItemIds.resize(0);
         mNewItemIds = null;
         mNewChestIds.resize(0);
         mNewChestIds = null;
         mNewStackableIds.resize(0);
         mNewStackableIds = null;
         mNewPetIds.resize(0);
         mNewPetIds = null;
         if(mHeroWithEquipPicker != null)
         {
            mHeroWithEquipPicker.destroy();
         }
         mHeroWithEquipPicker = null;
         if(mStacksWithEquipPicker != null)
         {
            mStacksWithEquipPicker.destroy();
         }
         mStacksWithEquipPicker = null;
         if(mPetsWithEquipPicker != null)
         {
            mPetsWithEquipPicker.destroy();
         }
         mPetsWithEquipPicker = null;
         if(mStuffWithEquipPicker != null)
         {
            mStuffWithEquipPicker.destroy();
         }
         mStuffWithEquipPicker = null;
         mSelectedItemInfo = null;
         mSceneGraphComponent = null;
         if(mChestCard != null)
         {
            mChestCard.destroy();
         }
         mChestCard = null;
         if(mAbandonChestPopUp != null)
         {
            mAbandonChestPopUp.destroy();
         }
         mAbandonChestPopUp = null;
         if(mChestOpenFullPopUp != null)
         {
            mChestOpenFullPopUp.destroy();
         }
         mChestOpenFullPopUp = null;
         if(mEventComponent != null)
         {
            mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         }
         mEventComponent = null;
         if(mConsumableChestCard != null)
         {
            mConsumableChestCard.destroy();
         }
         mConsumableChestCard = null;
         if(mBoosterCard != null)
         {
            mBoosterCard.destroy();
         }
         mBoosterCard = null;
      }
      
      function processChosenAvatar() 
      {
         if(mHeroWithEquipPicker.currentlySelectedHero == null)
         {
            return;
         }
         var _loc1_= mHeroWithEquipPicker.currentlySelectedHero.Id;
         if(mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
         }
      }
   }


