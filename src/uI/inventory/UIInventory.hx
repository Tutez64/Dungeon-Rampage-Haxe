package uI.inventory;

import account.AvatarInfo;
import account.ChestInfo;
import account.DBInventoryInfo;
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
import brain.uI.UIObject;
import brain.uI.UIRadioButton;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import collections.IMapIterator;
import collections.Map;
import dBGlobals.DBGlobal;
import distributedObjects.DistributedDungeonSummary;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMInventoryBase;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMOfferDetail;
import gameMasterDictionary.GMStackable;
import gameMasterDictionary.GMWeaponItem;
import town.TownHeader;
import uI.equipPicker.HeroWithEquipPicker;
import uI.equipPicker.PetsWithEquipPicker;
import uI.equipPicker.StacksWithEquipPicker;
import uI.equipPicker.StuffWithEquipPicker;
import uI.hud.UIHud;
import uI.inventory.chests.ChestInfoCard;
import uI.popup.DBUIOneButtonPopup;
import uI.UIPagingPanel;
import uI.UITownTweens;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

class UIInventory {
	static inline final SELECTED_TAB_SCALE:Float = 1.15;

	static inline final NUM_GRID_ELEMENTS = (15 : UInt);

	static inline final INV_SLOT_CLASS_NAME = "inv_slot";

	static inline final WEAPON_TOOLTIP_CLASS_NAME = "DR_weapon_tooltip";

	public static inline final CHARGE_TOOLTIP_CLASS_NAME = "DR_charge_tooltip";

	public static inline final EQUIPPABLE_TRUE = (1 : UInt);

	public static inline final EQUIPPABLE_NOT_YET = (2 : UInt);

	public static inline final EQUIPPABLE_NEVER = (3 : UInt);

	static final CATEGORY_ARRAY:Array<ASAny> = [
		GMInventoryBase.WEAPON_CATEGORY,
		GMInventoryBase.POWERUP_CATEGORY,
		GMInventoryBase.PET_CATEGORY,
		GMInventoryBase.STUFF_CATEGORY
	];

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

	var mNextTab:String;

	var mWantPets:Bool = false;

	var mItems:Vector<UIInventoryItem>;

	var mInventoryGridElements:Vector<MovieClip>;

	var mCategorizedItems:Map;

	var mAddStorageButton:UIButton;

	var mInfoCard:ItemInfoCard;

	var mDungeonSummary:DistributedDungeonSummary;

	var mDungeonSummaryInitialFocusSet:Bool = false;

	var mNewItemIds:Array<ASAny>;

	var mNewChestIds:Array<ASAny>;

	var mLastActedChestGmId:UInt = (0 : UInt);

	var mNewStackableIds:Array<ASAny>;

	var mNewPetIds:Array<ASAny>;

	var mHeroWithEquipPicker:HeroWithEquipPicker;

	var mStacksWithEquipPicker:StacksWithEquipPicker;

	var mPetsWithEquipPicker:PetsWithEquipPicker;

	var mStuffWithEquipPicker:StuffWithEquipPicker;

	var mSelectedItemInfo:InventoryBaseInfo;

	var mSelectedItemNavigationSource:UIObject;

	var mBoosterNavigationItem:UIInventoryItem;

	var mSelectedAvatar:UInt = 0;

	var mSceneGraphComponent:SceneGraphComponent;

	var mChestCard:ChestInfoCard;

	var mAbandonChestPopUp:UIAbandonChestPopup;

	var mChestOpenFullPopUp:DBUIOneButtonPopup;

	var mEventComponent:EventComponent;

	var mRevealedItemType:UInt = 0;

	var mRevealedItemOfferId:UInt = 0;

	var mRevealedShowEquip:Bool = false;

	var mConsumableChestCard:ChestInfoCard;

	var mBoosterCard:BoosterInfoCard;

	var mWeaponTabButton:UIRadioButton;

	var mPotionsTabButton:UIRadioButton;

	var mPetsTabButton:UIRadioButton;

	var mStuffTabButton:UIRadioButton;

	var mIsActiveCallback:ASFunction;

	public function new(dbFacade:DBFacade, townHeader:TownHeader = null, dungeonSummary:DistributedDungeonSummary = null, isActiveCallback:ASFunction = null) {
		mDBFacade = dbFacade;
		mTownHeader = townHeader;
		mDungeonSummary = dungeonSummary;
		mIsActiveCallback = isActiveCallback;
		mRevealedItemType = (0 : UInt);
		mRevealedItemOfferId = (0 : UInt);
		mRoot = new Sprite();
		if (mDBFacade.dbConfigManager.getConfigBoolean("want_pets", true)) {
			mWantPets = true;
		}
		mTabButtons = new Map();
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "UIInventory");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIInventory");
		mInventoryGridElements = new Vector<MovieClip>();
		mItems = new Vector<UIInventoryItem>();
		mNewItemIds = [];
		mNewChestIds = [];
		mNewStackableIds = [];
		mNewPetIds = [];
		mEventComponent = new EventComponent(mDBFacade);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), swfLoaded);
	}

	public function setRevealedState(type:UInt, offerId:UInt, showEquipOption:Bool = false) {
		mRevealedItemType = type;
		mRevealedItemOfferId = offerId;
		mRevealedShowEquip = showEquipOption;
	}

	function setSelectedAvatar(val:Int) {
		mSelectedAvatar = (val : UInt);
	}

	function getSelectedAvatar():Int {
		return (mSelectedAvatar : Int);
	}

	@:isVar public var root(get, never):Sprite;

	public function get_root():Sprite {
		return mRoot;
	}

	function swfLoaded(swfAsset:SwfAsset) {
		mSwfAsset = swfAsset;
		var _loc2_ = mSwfAsset.getClass("DR_UI_town_inventory");
		mInventoryRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
		mRoot.addChild(mInventoryRoot);
		var _loc3_ = swfAsset.getClass("DR_weapon_tooltip");
		var _loc4_ = swfAsset.getClass("avatar_tooltip");
		ASCompat.setProperty((mInventoryRoot : ASAny).pet_picker, "visible", false);
		ASCompat.setProperty((mInventoryRoot : ASAny).potion_picker, "visible", false);
		ASCompat.setProperty((mInventoryRoot : ASAny).stuff_picker, "visible", false);
		mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).weapon_picker, flash.display.MovieClip), _loc3_,
			_loc4_, heroSelected, itemSelected, getSelectedAvatar, setSelectedAvatar, refresh, true, true, mIsActiveCallback);
		mStacksWithEquipPicker = new StacksWithEquipPicker(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).potion_picker, flash.display.MovieClip),
			_loc3_, _loc4_, itemSelected, refresh, true, getSelectedAvatar, setSelectedAvatar, mIsActiveCallback);
		if (mWantPets) {
			mPetsWithEquipPicker = new PetsWithEquipPicker(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).pet_picker, flash.display.MovieClip), _loc3_,
				_loc4_, itemSelected, getSelectedAvatar, setSelectedAvatar, refresh, true, mIsActiveCallback);
		}
		mStuffWithEquipPicker = new StuffWithEquipPicker(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).stuff_picker, flash.display.MovieClip), _loc4_,
			getSelectedAvatar, setSelectedAvatar, mIsActiveCallback);
		ASCompat.setProperty((mInventoryRoot : ASAny).close, "visible", false);
		var _loc5_ = ASCompat.coerce((mInventoryRoot : ASAny).treasure, flash.display.MovieClip);
		if (mDungeonSummary != null) {
			mDungeonRewardPanel = new DungeonRewardPanel(mDBFacade, _loc5_, mDungeonSummary, itemSelected);
			Locale.setText(ASCompat.coerce((_loc5_ : ASAny).label, flash.text.TextField), "LOOT");
		} else {
			_loc5_.visible = false;
		}
		buildCategories();
		setupUI(mInventoryRoot);
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", accountInfoUpdated);
	}

	function accountInfoUpdated(evt:Event) {
		if (mIsActiveCallback == null || ASCompat.toBool(mIsActiveCallback())) {
			refresh(false);
		}
	}

	public function hide() {
		mRoot.visible = false;
	}

	public function show(chestGM:GMChest) {
		mRoot.visible = true;
		mBoosterCard.hide();
		refresh(true);
		if (mDungeonSummary != null) {
			mDungeonRewardPanel.setChestAsSelected(chestGM);
		}
	}

	function heroSelected(gmHero:GMHero, owned:Bool) {
		if (gmHero == null) {
			return;
		}
		var _loc3_ = mDBFacade.gameMaster.Heroes[(mSelectedAvatar : Int)];
		if (_loc3_.Id != gmHero.Id) {
			mDBFacade.dbAccountInfo.changeActiveAvatarRPC(gmHero.Id);
		}
		var _loc4_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
		if (_loc4_ != null && Std.isOfType(mSelectedItemInfo, ChestInfo)) {
			mChestCard.selectedHeroId = mSelectedAvatar;
			mChestCard.refreshHeroInfoUI();
			refresh(false, true);
		} else {
			refresh(false);
		}
	}

	function determineEquippableItems(gmHero:GMHero) {
		var _loc7_:InventoryBaseInfo = null;
		var _loc6_:ItemInfo = null;
		var _loc3_ = (0 : UInt);
		var _loc4_ = (0 : UInt);
		var _loc5_ = mDBFacade.dbAccountInfo.inventoryInfo;
		var _loc2_ = _loc5_.getAvatarInfoForHeroType(gmHero.Id);
		_loc4_ = (0 : UInt);
		while (_loc4_ < (mItems.length:UInt)) {
			_loc7_ = mItems[(_loc4_ : Int)].info;
			_loc6_ = ASCompat.reinterpretAs(_loc7_, ItemInfo);
			if (_loc7_ != null && _loc6_ != null && _loc6_.gmWeaponItem != null) {
				_loc3_ = (1 : UInt);
				if (_loc2_ == null) {
					_loc3_ = (3 : UInt);
				} else if (!_loc5_.canAvatarEquipThisMasterType(_loc2_, _loc6_.gmWeaponItem.MasterType)) {
					_loc3_ = (3 : UInt);
				} else if (_loc2_.levelForWeaponComparison < _loc6_.requiredLevel) {
					_loc3_ = (2 : UInt);
				}
				mItems[(_loc4_ : Int)].equippable = _loc3_;
			}
			_loc4_++;
		}
	}

	function sellItem(info:InventoryBaseInfo) {
		if (info != null) {
			if (Std.isOfType(info, ItemInfo) || Std.isOfType(info, StackableInfo) || Std.isOfType(info, PetInfo)) {
				StoreServicesController.trySellItem(mDBFacade, info, function() {
					var _loc1_ = 0;
					if (Std.isOfType(info, ItemInfo)) {
						_loc1_ = mNewItemIds.indexOf(info.databaseId);
						if (_loc1_ != -1) {
							mNewItemIds.splice(_loc1_, (1 : UInt));
						}
					} else if (Std.isOfType(info, StackableInfo)) {
						_loc1_ = mNewStackableIds.indexOf(info.databaseId);
						if (_loc1_ != -1) {
							mNewStackableIds.splice(_loc1_, (1 : UInt));
						}
					} else if (Std.isOfType(info, PetInfo)) {
						_loc1_ = mNewPetIds.indexOf(info.databaseId);
						if (_loc1_ != -1) {
							mNewPetIds.splice(_loc1_, (1 : UInt));
						}
					}
					refresh();
					focusFirstInventoryItem();
				});
			}
			mSelectedItemInfo = null;
		} else {
			Logger.error("Trying to sell null item info.");
		}
	}

	function takeItemCallback() {
		mSelectedItemInfo = null;
	}

	function setupUI(root:MovieClip) {
		var chargeTooltipClass:Dynamic;
		var group:String;
		var tabButton:UIRadioButton;
		var iter:IMapIterator;
		var itemTemplateClass:Dynamic;
		var weaponTooltipClass:Dynamic;
		var uiInventoryItem:UIInventoryItem;
		var i:UInt;
		mInventoryRoot = root;
		if (mPagination != null) {
			mPagination.destroy();
			mPagination = null;
		}
		mPagination = new UIPagingPanel(mDBFacade, this.numPagesInCurrentCategory(),
			ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.pagination, flash.display.MovieClip), mSwfAsset.getClass("pagination_button"),
			this.setCurrentPage);
		chargeTooltipClass = mSwfAsset.getClass("DR_charge_tooltip");
		mInfoCard = new ItemInfoCard(mDBFacade, ASCompat.coerce((root : ASAny).item_card, flash.display.MovieClip), chargeTooltipClass, mHeroWithEquipPicker,
			mPetsWithEquipPicker, refresh, mDungeonSummary, false, sellItem, takeItemCallback);
		mInfoCard.visible = false;
		if (mChestCard != null) {
			mChestCard.destroy();
			mChestCard = null;
		}
		mChestCard = new ChestInfoCard(mDBFacade, mSceneGraphComponent, ASCompat.coerce((root : ASAny).inv_chests, flash.display.MovieClip), abandonChest,
			openChest, abandonChestDS, openChestDS, keepChestDS, mIsActiveCallback);
		if (mConsumableChestCard != null) {
			mConsumableChestCard.destroy();
			mConsumableChestCard = null;
		}
		mConsumableChestCard = new ChestInfoCard(mDBFacade, mSceneGraphComponent, ASCompat.coerce((root : ASAny).inv_consumable, flash.display.MovieClip),
			abandonChest, openChest, abandonChestDS, openChestDS, keepChestDS, mIsActiveCallback);
		if (mBoosterCard != null) {
			mBoosterCard.destroy();
			mBoosterCard = null;
		}
		mBoosterCard = new BoosterInfoCard(mDBFacade, mSceneGraphComponent, ASCompat.coerce((root : ASAny).booster_card, flash.display.MovieClip),
			focusAfterBoosterActivation);
		group = "UIInventoryTabGroup";
		mWeaponTabButton = new UIRadioButton(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_weapons, flash.display.MovieClip), group);
		mPotionsTabButton = new UIRadioButton(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_potions, flash.display.MovieClip), group);
		mPetsTabButton = new UIRadioButton(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_pets, flash.display.MovieClip), group);
		mStuffTabButton = new UIRadioButton(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_stuff, flash.display.MovieClip), group);
		mTabButtons.add(GMInventoryBase.WEAPON_CATEGORY, mWeaponTabButton);
		Locale.setText(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_weapons.label, flash.text.TextField), "TAB_LOOT");
		mTabButtons.add(GMInventoryBase.POWERUP_CATEGORY, mPotionsTabButton);
		Locale.setText(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_potions.label, flash.text.TextField), "TAB_POWERUPS");
		if (mWantPets) {
			mTabButtons.add(GMInventoryBase.PET_CATEGORY, mPetsTabButton);
			Locale.setText(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_pets.label, flash.text.TextField), "TAB_PETS");
		}
		mTabButtons.add(GMInventoryBase.STUFF_CATEGORY, mStuffTabButton);
		Locale.setText(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.tab_stuff.label, flash.text.TextField), "TAB_STUFF");
		iter = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (iter.hasNext()) {
			tabButton = ASCompat.coerce(iter.next(), brain.uI.UIRadioButton);
			Locale.setText(ASCompat.coerce((tabButton.root : ASAny).new_label, flash.text.TextField), "INV_NEW");
			ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", this.categoryHasAnyNewItems(iter.key));
			ASCompat.setProperty(tabButton.root, "category", iter.key);
			tabButton.releaseCallbackThis = function(param1:UIButton) {
				showTab((param1.root : ASAny).category);
			};
			tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
		}
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_0, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_1, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_2, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_3, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_4, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_5, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_6, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_7, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_8, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_9, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_10, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_11, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_12, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_13, flash.display.MovieClip));
		mInventoryGridElements.push(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.slot_14, flash.display.MovieClip));
		itemTemplateClass = mSwfAsset.getClass("inv_slot");
		weaponTooltipClass = mSwfAsset.getClass("DR_weapon_tooltip");
		i = (0 : UInt);
		while (i < (mItems.length:UInt)) {
			mItems[(i : Int)].destroy();
			i = i + 1;
		}
		mItems.splice(0, (mItems.length : UInt));
		i = (0 : UInt);
		while (i < 15) {
			uiInventoryItem = new UIInventoryItem(mDBFacade, mInventoryGridElements[(i : Int)], itemTemplateClass, weaponTooltipClass, itemSelected);
			mItems.push(uiInventoryItem);
			uiInventoryItem.visible = false;
			i = i + 1;
		}
		mAddStorageButton = new UIButton(mDBFacade, ASCompat.coerce((mInventoryRoot : ASAny).grid_widget.add_storage_button, flash.display.MovieClip));
		mAddStorageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		Locale.setText(mAddStorageButton.label, "INV_ADD_STORAGE");
		mAddStorageButton.releaseCallback = function() {
			StoreServicesController.showStoragePage(mDBFacade);
		};
		mAddStorageButton.visible = false;
	}

	function closeEquipButton() {}

	function currentChestStack(chestInfo:ChestInfo):ChestInfo {
		if (chestInfo == null || chestInfo.isFromDungeonSummary()) {
			return chestInfo;
		}
		var _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo;
		var _loc2_:ChestInfo;
		final __ax4_iter_359 = _loc3_.chests;
		if (checkNullIteratee(__ax4_iter_359))
			for (_tmp_ in __ax4_iter_359) {
				_loc2_ = _tmp_;
				if (_loc2_.containsDatabaseId(chestInfo.databaseId)) {
					return _loc2_;
				}
			}
		return _loc3_.getChestStack(chestInfo.gmId);
	}

	function abandonChest(chestInfo:ChestInfo) {
		var index:Int;
		chestInfo = currentChestStack(chestInfo);
		if (chestInfo == null) {
			return;
		}
		if (mDBFacade.dbAccountInfo.inventoryInfo.isChestRequestPending(chestInfo.databaseId)) {
			return;
		}
		if (!chestInfo.isFromDungeonSummary()) {
			mLastActedChestGmId = chestInfo.gmId;
		}
		mAbandonChestPopUp = new UIAbandonChestPopup(mDBFacade, closeAbandonChestPopUp, function() {
			mDBFacade.metrics.log("ChestAbandoned", {
				"chestId": chestInfo.gmChestInfo.Id,
				"rarity": chestInfo.rarity,
				"category": "storage"
			});
			mDBFacade.dbAccountInfo.inventoryInfo.dropChest(chestInfo.databaseId, dropChestSuccessfullCallback, abandonChestFailedPopUp);
			closeAbandonChestPopUp();
		});
		MemoryTracker.track(mAbandonChestPopUp, "UIAbandonChestPopup - created in UIInventory.abandonChest()");
		index = mNewChestIds.indexOf(chestInfo.databaseId);
		if (index != -1) {
			mNewChestIds.splice(index, (1 : UInt));
		}
	}

	function closeAbandonChestPopUp() {
		mAbandonChestPopUp = null;
	}

	function dropChestSuccessfullCallback(chestInstanceId:UInt, details:ASAny) {
		removeChestFromInventory(chestInstanceId);
		refresh(true);
		focusFirstInventoryItem();
	}

	function returnFromOpenFullPopUp() {
		if (mChestOpenFullPopUp != null) {
			mChestOpenFullPopUp.destroy();
			mChestOpenFullPopUp = null;
		}
	}

	function openChest(chestInfo:ChestInfo) {
		var _loc2_:DBInventoryInfo = null;
		var _loc5_ = (0 : UInt);
		var _loc7_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		chestInfo = currentChestStack(chestInfo);
		if (chestInfo == null) {
			return;
		}
		if (!chestInfo.isFromDungeonSummary()) {
			_loc2_ = mDBFacade.dbAccountInfo.inventoryInfo;
			if (_loc2_.isChestRequestPending(chestInfo.databaseId)) {
				return;
			}
			if (!_loc2_.hasRoomToOpenChest(chestInfo.gmId)) {
				showChestOpenFullPopUp("UIInventory.openChest()");
				return;
			}
			mLastActedChestGmId = chestInfo.gmId;
		}
		var _loc4_ = mChestCard;
		if (UIHud.isThisAConsumbleChestId((chestInfo.gmChestInfo.Id : Int))) {
			_loc4_ = mConsumableChestCard;
		}
		if (_loc4_.canChestBeOpened()) {
			if (chestInfo.isFromDungeonSummary()) {
				mDungeonSummary.openChestFromInventory(chestInfo.gmChestInfo, true);
			} else {
				_loc4_.createRevealPopUp(closeRevealPopUp, goToStorage);
				_loc5_ = mHeroWithEquipPicker.currentlySelectedHero.Id;
				_loc7_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc5_).id;
				_loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc5_).skinId;
				mDBFacade.dbAccountInfo.inventoryInfo.openChest(chestInfo.databaseId, _loc7_, _loc3_, updateRevealLoot, openChestFailedPopUp);
			}
		} else {
			_loc4_.showBuyKeysPopUp();
		}
		var _loc6_ = mNewChestIds.indexOf(chestInfo.databaseId);
		if (_loc6_ != -1) {
			mNewChestIds.splice(_loc6_, (1 : UInt));
		}
	}

	public function goToStorage(itemType:UInt, itemOfferId:UInt, callEquip:Bool) {
		mConsumableChestCard.closeChestRevealPopUp();
		mChestCard.closeChestRevealPopUp();
		mRevealedItemType = itemType;
		mRevealedItemOfferId = itemOfferId;
		mRevealedShowEquip = callEquip;
		refresh();
	}

	function closeRevealPopUp(itemType:UInt, itemOfferId:UInt, keptItem:Bool) {
		mRevealedItemType = itemType;
		mRevealedItemOfferId = itemOfferId;
		mConsumableChestCard.closeChestRevealPopUp();
		mChestCard.closeChestRevealPopUp();
		refresh();
		focusAfterChestReveal(itemType, keptItem);
	}

	function focusAfterChestReveal(itemType:UInt, keptItem:Bool) {
		var _loc3_:UIInventoryItem;
		var __ax4_iter_360:Vector<UIInventoryItem>;
		var _loc4_:UIObject = null;
		if (keptItem && itemType == 1) {
			__ax4_iter_360 = mItems;
			if (checkNullIteratee(__ax4_iter_360))
				for (_tmp_ in __ax4_iter_360) {
					_loc3_ = _tmp_;
					if (_loc3_.info == mSelectedItemInfo && _loc3_.canBeFocused()) {
						_loc4_ = _loc3_;
						break;
					}
				}
		}
		if (_loc4_ == null) {
			_loc4_ = getFirstFocusableInventoryItem();
		}
		if (_loc4_ != null) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc4_);
		}
	}

	function updateRevealLoot(chestInstanceId:UInt, details:ASAny) {
		mConsumableChestCard.updateRevealLoot(details);
		mChestCard.updateRevealLoot(details);
		removeChestFromInventory(chestInstanceId);
	}

	function abandonChestDS(chestInfo:ChestInfo) {
		mAbandonChestPopUp = new UIAbandonChestPopup(mDBFacade, closeAbandonChestPopUp, function() {
			mDBFacade.metrics.log("ChestAbandoned", {
				"chestId": chestInfo.gmChestInfo.Id,
				"rarity": chestInfo.rarity,
				"category": "storageFromDungeonSummary"
			});
			var _loc1_ = mDungeonSummary.findSlotForChest(chestInfo.gmChestInfo);
			mDungeonSummary.abandonChestFromInventory(_loc1_);
			focusFirstInventoryItem();
			closeAbandonChestPopUp();
		});
		MemoryTracker.track(mAbandonChestPopUp, "UIAbandonChestPopup - created in UIInventory.abandonChestDS()");
	}

	function openChestDS(chestInfo:ChestInfo) {
		if (mDungeonSummary != null && !mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage()) {
			showChestOpenFullPopUp("UIInventory.openChestDS()");
			return;
		}
		openChest(chestInfo);
	}

	function showChestOpenFullPopUp(createdIn:String) {
		if (mChestOpenFullPopUp != null) {
			return;
		}
		mChestOpenFullPopUp = new DBUIOneButtonPopup(mDBFacade, "POPUP_STORAGE_FULL", Locale.getString("STORAGE_FULL"), Locale.getString("CLEAR_INVENTORY"),
			Locale.getString("RETURN"), returnFromOpenFullPopUp, true, returnFromOpenFullPopUp);
		MemoryTracker.track(mChestOpenFullPopUp, "DBUIOneButtonPopup - created in " + createdIn);
		mSceneGraphComponent.addChild(mChestOpenFullPopUp.root, (105 : UInt));
	}

	function keepChestDS(chestInfo:ChestInfo) {
		if (mDungeonSummary != null && !mDBFacade.dbAccountInfo.inventoryInfo.hasRoomForChest(chestInfo.gmId)) {
			mChestOpenFullPopUp = new DBUIOneButtonPopup(mDBFacade, "POPUP_STORAGE_FULL", Locale.getString("STORAGE_FULL"),
				Locale.getString("CLEAR_INVENTORY"), Locale.getString("RETURN"), returnFromOpenFullPopUp, true, returnFromOpenFullPopUp);
			MemoryTracker.track(mChestOpenFullPopUp, "DBUIOneButtonPopup - created in UIInventory.keepChestDS()");
			mSceneGraphComponent.addChild(mChestOpenFullPopUp.root, (105 : UInt));
			return;
		}
		var _loc2_ = mDungeonSummary.findSlotForChest(chestInfo.gmChestInfo);
		mDungeonSummary.keepChestFromInventory(_loc2_, true);
	}

	function abandonChestFailedPopUp() {
		mConsumableChestCard.closeChestRevealPopUp();
		mChestCard.closeChestRevealPopUp();
	}

	function openChestFailedPopUp() {
		mConsumableChestCard.closeChestRevealPopUp();
		mChestCard.closeChestRevealPopUp();
		refresh();
	}

	function removeChestFromInventory(chestInstanceId:UInt) {
		mDBFacade.dbAccountInfo.inventoryInfo.removeChestRow(chestInstanceId);
		takeItemCallback();
	}

	function categoryHasAnyNewItems(category:String):Bool {
		var _loc2_ = (mCategorizedItems.itemFor(category) : Vector<InventoryBaseInfo>);
		if (_loc2_ == null) {
			Logger.error("categoryHasAnyNewItems invalid category: " + category);
		}
		var _loc3_:InventoryBaseInfo;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc3_ = _tmp_;
				if (_loc3_.isNew) {
					return true;
				}
			}
		return false;
	}

	public function animateEntry() {
		if (mDBFacade.featureFlags.getFlagValue("want-town-animations")) {
			if (mTownHeader != null) {
				mTownHeader.rootMovieClip.visible = false;
				mLogicalWorkComponent.doLater(0.20833333333333334, function(param1:brain.clock.GameClock) {
					mTownHeader.animateHeader();
				});
			}
			ASCompat.setProperty((mInventoryRoot : ASAny).grid_widget, "visible", false);
			mLogicalWorkComponent.doLater(0.16666666666666666, function(param1:brain.clock.GameClock) {
				UITownTweens.rightPanelTweenSequence(ASCompat.coerce((mInventoryRoot : ASAny).grid_widget, flash.display.MovieClip), mDBFacade);
			});
			if (mCurrentTab != GMInventoryBase.WEAPON_CATEGORY) {
				return;
			}
			mHeroWithEquipPicker.root.visible = false;
			mLogicalWorkComponent.doLater(0.5, function(param1:brain.clock.GameClock) {
				UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root, mDBFacade);
			});
		}
	}

	function buildCategories() {
		var _loc7_:String = null;
		var _loc9_:Vector<InventoryBaseInfo> = /*undefined*/ null;
		var _loc10_:InventoryBaseInfo = null;
		var _loc5_:IMapIterator = null;
		mCategorizedItems = new Map();
		final __ax4_iter_361 = CATEGORY_ARRAY;
		if (checkNullIteratee(__ax4_iter_361))
			for (_tmp_ in __ax4_iter_361) {
				_loc7_ = _tmp_;
				mCategorizedItems.add(_loc7_, new Vector<InventoryBaseInfo>());
			}
		var _loc8_ = mDBFacade.dbAccountInfo.inventoryInfo.items;
		var _loc6_ = mDBFacade.dbAccountInfo.inventoryInfo.chests;
		var _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.stackables;
		var _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.pets;
		var _loc4_:Map;
		final __ax4_iter_362:Array<ASAny> = [_loc8_, _loc3_, _loc1_];
		if (checkNullIteratee(__ax4_iter_362))
			for (_tmp_ in __ax4_iter_362) {
				_loc4_ = ASCompat.coerce(_tmp_, collections.Map);
				_loc5_ = ASCompat.reinterpretAs(_loc4_.iterator(), IMapIterator);
				while (_loc5_.hasNext()) {
					_loc10_ = ASCompat.coerce(_loc5_.next(), account.InventoryBaseInfo);
					if (_loc10_.gmInventoryBase != null) {
						_loc7_ = _loc10_.gmInventoryBase.ItemCategory;
					} else {
						_loc7_ = "PET";
					}
					_loc9_ = (mCategorizedItems.itemFor(_loc7_) : Vector<InventoryBaseInfo>);
					if (_loc9_ == null) {
						Logger.error("No inventory category exists for weapon class type: " + _loc7_);
					} else {
						_loc9_.push(_loc10_);
					}
				}
			}
		var _loc2_:ChestInfo;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc2_ = _tmp_;
				if (_loc2_.gmChestInfo != null) {
					_loc7_ = GMInventoryBase.WEAPON_CATEGORY;
					_loc9_ = (mCategorizedItems.itemFor(_loc7_) : Vector<InventoryBaseInfo>);
					if (_loc9_ == null) {
						Logger.error("No inventory category exists for weapon class type: " + _loc7_);
					} else {
						_loc9_.push(_loc2_);
					}
				}
			}
		sortCategories();
	}

	function inventorySortComparator(sortKeyVector:Vector<String>, infoA:InventoryBaseInfo, infoB:InventoryBaseInfo):Int {
		var _loc4_:GMWeaponItem = null;
		var _loc5_:GMWeaponItem = null;
		var _loc6_:AvatarInfo = null;
		var _loc11_ = false;
		var _loc8_ = false;
		var _loc9_ = false;
		var _loc7_ = false;
		var _loc10_ = 0;
		var _loc12_ = 0;
		if (infoA.isEquipped && !infoB.isEquipped) {
			return 1;
		}
		if (infoB.isEquipped && !infoA.isEquipped) {
			return -1;
		}
		if (Std.isOfType(infoA, ItemInfo) && Std.isOfType(infoB, ItemInfo)) {
			_loc4_ = cast(infoA, ItemInfo).gmWeaponItem;
			_loc5_ = cast(infoB, ItemInfo).gmWeaponItem;
			_loc6_ = this.mHeroWithEquipPicker.currentlySelectedAvatarInfo;
			if (_loc6_ != null) {
				_loc11_ = mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(_loc6_, _loc4_.MasterType);
				_loc8_ = mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(_loc6_, _loc5_.MasterType);
				if (_loc11_ && !_loc8_) {
					return -1;
				}
				if (_loc8_ && !_loc11_) {
					return 1;
				}
				_loc9_ = mDBFacade.dbAccountInfo.inventoryInfo.canThisAvatarEquipThisItem(_loc6_, cast(infoA, ItemInfo));
				_loc7_ = mDBFacade.dbAccountInfo.inventoryInfo.canThisAvatarEquipThisItem(_loc6_, cast(infoB, ItemInfo));
				if (_loc9_ && !_loc7_) {
					return -1;
				}
				if (_loc7_ && !_loc9_) {
					return 1;
				}
			}
			if (sortKeyVector != null) {
				_loc10_ = sortKeyVector.indexOf(_loc4_.MasterType);
				_loc12_ = sortKeyVector.indexOf(_loc5_.MasterType);
				if (_loc10_ != _loc12_) {
					return _loc10_ - _loc12_;
				}
			}
			return (cast(infoB, ItemInfo).requiredLevel - cast(infoA, ItemInfo).requiredLevel:Int);
		}
		if (infoA.gmId != infoB.gmId) {
			return (infoB.gmId - infoA.gmId:Int);
		}
		if (Std.isOfType(infoA, ChestInfo) && Std.isOfType(infoB, ChestInfo)) {
			return infoA.databaseId < infoB.databaseId ? -1 : (infoA.databaseId > infoB.databaseId ? 1 : 0);
		}
		return 0;
	}

	function weaponSortComparator(infoA:InventoryBaseInfo, infoB:InventoryBaseInfo):Int {
		return this.inventorySortComparator(GMWeaponItem.ALL_WEAPON_SORT, infoA, infoB);
	}

	function basicSortComparator(infoA:InventoryBaseInfo, infoB:InventoryBaseInfo):Int {
		return this.inventorySortComparator(null, infoA, infoB);
	}

	function sortCategories() {
		var _loc4_:String;
		var _loc2_:String = null;
		var _loc3_:Vector<InventoryBaseInfo> = /*undefined*/ null;
		var _loc1_ = ASCompat.reinterpretAs(mCategorizedItems.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc3_ = (_loc1_.next() : Vector<InventoryBaseInfo>);
			_loc2_ = _loc1_.key;
			_loc4_ = _loc2_;
			if (GMInventoryBase.WEAPON_CATEGORY != _loc4_) {
				ASCompat.ASVector.sort(_loc3_, basicSortComparator);
			} else {
				ASCompat.ASVector.sort(_loc3_, weaponSortComparator);
			}
		}
	}

	public function refresh(resync:Bool = false, dontRefreshChestSelection:Bool = false) {
		var currentTabIsValidCategory:Bool;
		var tabButton:UIRadioButton;
		var iter:IMapIterator;
		var gmHero:GMHero;
		var itemInfo:ItemInfo;
		var canEquip:Bool;
		if (resync) {
			mBoosterCard.hide();
		}
		if (mTownHeader != null) {
			mTownHeader.title = Locale.getString("INVENTORY_HEADER");
		}
		mHeroWithEquipPicker.refresh(resync);
		mStacksWithEquipPicker.refresh(resync);
		if (mWantPets) {
			mPetsWithEquipPicker.refresh(resync);
		}
		mStuffWithEquipPicker.refresh(resync);
		buildCategories();
		if (mDungeonRewardPanel != null) {
			mDungeonRewardPanel.refresh();
		}
		currentTabIsValidCategory = ASCompat.ASArray.some(CATEGORY_ARRAY, function(param1:ASAny, param2:UInt, param3:Array<ASAny>):Bool {
			if (mCurrentTab == ASCompat.asString(param1)) {
				return true;
			}
			return false;
		});
		if (!currentTabIsValidCategory) {
			mCurrentTab = GMInventoryBase.WEAPON_CATEGORY;
		}
		if (!dontRefreshChestSelection) {
			mSelectedItemInfo = checkIfRevealedWeaponExists();
			if (mSelectedItemInfo != null) {
				mLastActedChestGmId = (0 : UInt);
			} else if (mLastActedChestGmId != 0) {
				mSelectedItemInfo = mDBFacade.dbAccountInfo.inventoryInfo.getChestStack(mLastActedChestGmId);
				if (mSelectedItemInfo == null) {
					mLastActedChestGmId = (0 : UInt);
				}
			}
		}
		if (mSelectedItemInfo != null && Std.isOfType(mSelectedItemInfo, ItemInfo)) {
			jumpToWeaponOffer(mSelectedItemInfo);
		} else {
			this.showTab(mCurrentTab, mCurrentPage);
		}
		if (!dontRefreshChestSelection) {
			this.populateDetailInfoCard();
			this.populateDetailChestCard();
			this.highLightSelectedItem();
		}
		this.lookForNewEquippedItems();
		iter = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (iter.hasNext()) {
			tabButton = ASCompat.coerce(iter.next(), brain.uI.UIRadioButton);
			ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", this.categoryHasAnyNewItems(iter.key));
		}
		if (mSelectedItemInfo != null && !dontRefreshChestSelection) {
			itemSelected(mSelectedItemInfo);
			if (mRevealedShowEquip && Std.isOfType(mSelectedItemInfo, ItemInfo)) {
				gmHero = mDBFacade.gameMaster.Heroes[(mSelectedAvatar : Int)];
				itemInfo = ASCompat.reinterpretAs(mSelectedItemInfo, ItemInfo);
				canEquip = gmHero.AllowedWeapons.hasKey(itemInfo.gmWeaponItem.MasterType);
				if (canEquip) {
					mInfoCard.loadEquipOnAvatarPopup();
				}
				mRevealedShowEquip = false;
			}
		}
	}

	public function jumpToWeaponOffer(info:InventoryBaseInfo) {
		var _loc4_ = GMInventoryBase.WEAPON_CATEGORY;
		var _loc5_ = (mCategorizedItems.itemFor(GMInventoryBase.WEAPON_CATEGORY) : Vector<InventoryBaseInfo>);
		var _loc2_ = _loc5_.indexOf(info);
		if (_loc2_ == -1) {
			Logger.warn("Index not found for item in Storage");
		}
		var _loc3_ = (Math.floor(_loc2_ / 15) : UInt);
		this.showTab(_loc4_, _loc3_);
	}

	function checkIfRevealedWeaponExists():InventoryBaseInfo {
		var __ax4_iter_363:ASAny;
		var _loc10_:Int;
		var _loc9_:Vector<GMOfferDetail>;
		var _loc2_:GMOfferDetail;
		var __ax4_iter_364:ASAny;
		var _loc6_:InventoryBaseInfo = null;
		var _loc1_:GMWeaponItem = null;
		var _loc4_ = (0 : UInt);
		var _loc5_:GMOffer = null;
		var _loc3_:GMStackable = null;
		if (mRevealedItemType == 0) {
			return null;
		}
		if (mRevealedItemType == 1) {
			mCurrentTab = GMInventoryBase.WEAPON_CATEGORY;
			mRevealedItemOfferId %= (100000 : UInt);
			_loc1_ = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemOfferId), gameMasterDictionary.GMWeaponItem);
			__ax4_iter_363 = mCategorizedItems.itemFor(mCurrentTab);
			if (checkNullIteratee(__ax4_iter_363))
				for (_tmp_ in __ax4_iter_363) {
					_loc6_ = ASCompat.coerce(_tmp_, account.InventoryBaseInfo);
					if (Std.isOfType(_loc6_, ItemInfo)) {
						_loc4_ = ASCompat.reinterpretAs(_loc6_, ItemInfo).gmWeaponItem.Id;
						if (_loc4_ == _loc1_.Id && _loc6_.isNew) {
							mRevealedItemType = mRevealedItemOfferId = (0 : UInt);
							return _loc6_;
						}
					}
				}
		} else if (mRevealedItemType == 2) {
			_loc5_ = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(mRevealedItemOfferId), gameMasterDictionary.GMOffer);
			_loc10_ = 0;
			_loc9_ = _loc5_.Details;
			if (checkNullIteratee(_loc9_))
				for (_tmp_ in _loc9_) {
					_loc2_ = _tmp_;
					_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.stackableById.itemFor(_loc2_.StackableId), gameMasterDictionary.GMStackable);
				}
			if (_loc3_ != null) {
				mCurrentTab = GMInventoryBase.POWERUP_CATEGORY;
				__ax4_iter_364 = mCategorizedItems.itemFor(mCurrentTab);
				if (checkNullIteratee(__ax4_iter_364))
					for (_tmp_ in __ax4_iter_364) {
						_loc6_ = ASCompat.coerce(_tmp_, account.InventoryBaseInfo);
						if (_loc6_.gmId == _loc3_.Id) {
							mRevealedItemType = mRevealedItemOfferId = (0 : UInt);
							return _loc6_;
						}
					}
			}
		}
		mRevealedItemType = mRevealedItemOfferId = (0 : UInt);
		return null;
	}

	function lookForNewEquippedItems() {
		var _loc2_:IMapIterator = null;
		var _loc3_:ItemInfo = null;
		var _loc4_:StackableInfo = null;
		var _loc1_:PetInfo = null;
		_loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.items.iterator(), IMapIterator);
		while (_loc2_.hasNext()) {
			_loc3_ = ASCompat.coerce(_loc2_.next(), account.ItemInfo);
			if (_loc3_.isEquipped && _loc3_.isNew && mNewItemIds.indexOf(_loc3_.databaseId) == -1) {
				mNewItemIds.push(_loc3_.databaseId);
			}
		}
		_loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.stackables.iterator(), IMapIterator);
		while (_loc2_.hasNext()) {
			_loc4_ = ASCompat.coerce(_loc2_.next(), account.StackableInfo);
			if (_loc4_.isEquipped && _loc4_.isNew && mNewStackableIds.indexOf(_loc4_.databaseId) == -1) {
				mNewStackableIds.push(_loc4_.databaseId);
			}
		}
		_loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.pets.iterator(), IMapIterator);
		while (_loc2_.hasNext()) {
			_loc1_ = ASCompat.coerce(_loc2_.next(), account.PetInfo);
			if (_loc1_.isEquipped && _loc1_.isNew && mNewPetIds.indexOf(_loc1_.databaseId) == -1) {
				mNewPetIds.push(_loc1_.databaseId);
			}
		}
	}

	function markItemsNotNew() {
		if (mNewChestIds.length != 0 || mNewItemIds.length != 0 || mNewStackableIds.length != 0 || mNewPetIds.length != 0) {
			mDBFacade.dbAccountInfo.inventoryInfo.markItemsNotNew();
			mNewItemIds.resize(0);
			mNewStackableIds.resize(0);
			mNewPetIds.resize(0);
			mNewChestIds.resize(0);
		}
	}

	public function exitState() {
		this.markItemsNotNew();
		this.processChosenAvatar();
	}

	function numElementsInCurrentCategory():UInt {
		var _loc1_ = (0 : UInt);
		switch (mCurrentTab) {
			case(_ == GMInventoryBase.WEAPON_CATEGORY => true):
				_loc1_ = mDBFacade.dbAccountInfo.inventoryLimitWeapons;

			case(_ == GMInventoryBase.POWERUP_CATEGORY => true):
				_loc1_ = mDBFacade.dbAccountInfo.stackableCount;
				if (_loc1_ % 15 != 0) {
					_loc1_ += 15 - _loc1_ % 15;
				}

			default:
				_loc1_ = (0 : UInt);
		}
		return _loc1_;
	}

	function numPagesInCurrentCategory():UInt {
		return (Math.ceil(numElementsInCurrentCategory() / 15) : UInt);
	}

	function displayCategoryPage() {
		var _loc11_:InventoryBaseInfo = null;
		var _loc3_:UIInventoryItem = null;
		var _loc7_ = 0;
		var _loc4_ = 0;
		var _loc9_ = 0;
		resetItemGridMenuNavigation();
		var _loc10_ = (mCategorizedItems.itemFor(mCurrentTab) : Vector<InventoryBaseInfo>);
		if (mDungeonRewardPanel != null) {
			mDungeonRewardPanel.hide();
		}
		if (mCurrentTab == GMInventoryBase.WEAPON_CATEGORY) {
			mStacksWithEquipPicker.hide();
			if (mWantPets) {
				mPetsWithEquipPicker.hide();
			}
			mStuffWithEquipPicker.hide();
			mAddStorageButton.visible = true;
			mHeroWithEquipPicker.refresh(false);
			mHeroWithEquipPicker.show();
			if (mDungeonRewardPanel != null) {
				mDungeonRewardPanel.show();
			}
		} else if (mCurrentTab == GMInventoryBase.POWERUP_CATEGORY) {
			mHeroWithEquipPicker.hide();
			if (mWantPets) {
				mPetsWithEquipPicker.hide();
			}
			mStuffWithEquipPicker.hide();
			mAddStorageButton.visible = false;
			mStacksWithEquipPicker.refresh(false);
			mStacksWithEquipPicker.show();
		} else if (mWantPets && mCurrentTab == GMInventoryBase.PET_CATEGORY) {
			mHeroWithEquipPicker.hide();
			mStacksWithEquipPicker.hide();
			mStuffWithEquipPicker.hide();
			mAddStorageButton.visible = false;
			mPetsWithEquipPicker.refresh(false);
			mPetsWithEquipPicker.show();
		} else if (mWantPets && mCurrentTab == GMInventoryBase.STUFF_CATEGORY) {
			mHeroWithEquipPicker.hide();
			mStacksWithEquipPicker.hide();
			if (mWantPets) {
				mPetsWithEquipPicker.hide();
			}
			mAddStorageButton.visible = false;
			mStuffWithEquipPicker.refresh(false);
			mStuffWithEquipPicker.show();
		}
		_loc7_ = 0;
		while (_loc7_ < 15) {
			_loc3_ = mItems[_loc7_];
			_loc3_.deSelect();
			_loc3_.visible = false;
			_loc7_++;
		}
		var _loc1_ = mCurrentPage * 15;
		var _loc5_ = (0 : UInt);
		var _loc6_ = (0 : UInt);
		_loc7_ = 0;
		while (_loc7_ < mInventoryGridElements.length) {
			mInventoryGridElements[_loc7_].visible = true;
			_loc7_++;
		}
		var _loc2_ = false;
		var _loc8_ = numElementsInCurrentCategory();
		if (_loc1_ + 15 > _loc8_ && numElementsInCurrentCategory() != 0) {
			_loc4_ = (_loc1_ + 15 - numElementsInCurrentCategory() : Int);
			_loc9_ = mInventoryGridElements.length - _loc4_;
			_loc7_ = mInventoryGridElements.length - 1;
			while (_loc7_ >= _loc9_) {
				if (_loc7_ < mInventoryGridElements.length) {
					mInventoryGridElements[_loc7_].visible = false;
				} else {
					_loc2_ = true;
				}
				_loc7_--;
			}
		}
		_loc7_ = 0;
		while ((_loc7_ : UInt) < _loc1_ && _loc5_ < (_loc10_.length:UInt)) {
			_loc11_ = _loc10_[(_loc5_ : Int)];
			if (!_loc11_.isEquipped) {
				_loc7_++;
			}
			_loc5_++;
		}
		while (_loc6_ < 15 && _loc5_ < (_loc10_.length:UInt)) {
			_loc11_ = _loc10_[(_loc5_ : Int)];
			if (!_loc11_.isEquipped && _loc11_.hasGMPropertySetup()) {
				_loc3_ = mItems[(_loc6_ : Int)];
				_loc3_.info = _loc11_;
				_loc3_.root.visible = true;
				if (_loc11_.isNew) {
					if (Std.isOfType(_loc11_, ChestInfo) && mNewChestIds.indexOf(_loc11_.databaseId) == -1) {
						mNewChestIds.push(_loc11_.databaseId);
					} else if (Std.isOfType(_loc11_, ItemInfo) && mNewItemIds.indexOf(_loc11_.databaseId) == -1) {
						mNewItemIds.push(_loc11_.databaseId);
					} else if (Std.isOfType(_loc11_, StackableInfo) && mNewStackableIds.indexOf(_loc11_.databaseId) == -1) {
						mNewStackableIds.push(_loc11_.databaseId);
					} else if (Std.isOfType(_loc11_, PetInfo) && mNewPetIds.indexOf(_loc11_.databaseId) == -1) {
						mNewPetIds.push(_loc11_.databaseId);
					}
				}
				_loc6_++;
			}
			_loc5_++;
		}
		determineEquippableItems(mHeroWithEquipPicker.currentlySelectedHero);
		setupNavigationLinks();
	}

	function showTab(category:String, page:UInt = (0 : UInt)) {
		var _loc4_:UIRadioButton = null;
		setNextTab(category);
		mCurrentTab = category;
		var _loc5_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc5_.hasNext()) {
			_loc4_ = ASCompat.coerce(_loc5_.next(), brain.uI.UIRadioButton);
			_loc4_.enabled = true;
		}
		_loc4_ = ASCompat.coerce(mTabButtons.itemFor(mCurrentTab), brain.uI.UIRadioButton);
		_loc4_.selected = true;
		_loc4_.enabled = false;
		_loc4_.label.visible = true;
		var _loc3_ = this.numPagesInCurrentCategory();
		page = (ASCompat.floatToInt(_loc3_ == 0 ? (0 : UInt) : (ASCompat.floatToInt(Math.min((_loc3_ : Float) - 1, page)) : UInt)) : UInt);
		mPagination.numPages = _loc3_;
		mPagination.currentPage = mCurrentPage = page;
		mPagination.visible = _loc3_ > 1;
		displayCategoryPage();
	}

	function setCurrentPage(value:UInt) {
		mCurrentPage = value;
		displayCategoryPage();
		focusNextPageButton();
	}

	function focusNextPageButton() {
		var _loc1_ = mPagination.getNextPageButton();
		if (_loc1_ != null) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc1_);
		}
	}

	@:isVar public var infoCard(get, never):ItemInfoCard;

	public function get_infoCard():ItemInfoCard {
		return mInfoCard;
	}

	@:isVar public var chestCard(get, never):ChestInfoCard;

	public function get_chestCard():ChestInfoCard {
		return mChestCard;
	}

	@:isVar public var currentTab(never, set):String;

	public function set_currentTab(category:String):String {
		return mCurrentTab = category;
	}

	function itemSelected(info:InventoryBaseInfo, navigationSource:UIObject = null) {
		var _loc3_:StackableInfo = null;
		restoreBoosterItemNavigation();
		mSelectedItemInfo = info;
		mSelectedItemNavigationSource = navigationSource;
		if (!Std.isOfType(info, ChestInfo) || info.gmId != mLastActedChestGmId) {
			mLastActedChestGmId = (0 : UInt);
		}
		var _loc4_ = false;
		if (Std.isOfType(info, StackableInfo)) {
			_loc3_ = ASCompat.reinterpretAs(info, StackableInfo);
			if (_loc3_.gmStackable.AccountBooster) {
				populateDetailBoosterCard();
				_loc4_ = true;
			}
		}
		if (!_loc4_) {
			mBoosterCard.hide();
			if (mSelectedItemInfo.gmChestInfo != null) {
				populateDetailChestCard();
			} else {
				populateDetailInfoCard();
			}
		}
		highLightSelectedItem();
	}

	function highLightSelectedItem() {
		if (ASCompat.reinterpretAs(mSelectedItemInfo, ChestInfo) != null) {
			highLightSelectedChestItem();
		} else if (ASCompat.reinterpretAs(mSelectedItemInfo, ItemInfo) != null) {
			highLightSelectedAvatarItem();
		} else if (ASCompat.reinterpretAs(mSelectedItemInfo, StackableInfo) != null) {
			highLightSelectedAccountItem();
		} else if (mWantPets && ASCompat.reinterpretAs(mSelectedItemInfo, PetInfo) != null) {
			highLightSelectedPet();
		}
	}

	function highLightSelectedChestItem() {
		var _loc2_:UIInventoryItem = null;
		var _loc3_ = (0 : UInt);
		if (mDungeonRewardPanel != null) {
			mDungeonRewardPanel.clearHighlights();
		}
		var _loc1_ = ASCompat.reinterpretAs(mSelectedItemInfo, ChestInfo);
		if (_loc1_.isFromDungeonSummary()) {
			_loc3_ = (0 : UInt);
			while (_loc3_ < 15) {
				mItems[(_loc3_ : Int)].deSelect();
				_loc3_++;
			}
			mDungeonRewardPanel.highlightChest(_loc1_);
			return;
		}
		_loc3_ = (0 : UInt);
		while (_loc3_ < 15) {
			_loc2_ = mItems[(_loc3_ : Int)];
			if (mSelectedItemInfo != null && _loc2_.info == mSelectedItemInfo) {
				_loc2_.select();
			} else {
				_loc2_.deSelect();
			}
			_loc3_++;
		}
	}

	function highLightSelectedAvatarItem() {
		var _loc2_:GMWeaponItem = null;
		var _loc4_ = (0 : UInt);
		var _loc1_:UIInventoryItem = null;
		var _loc3_ = (0 : UInt);
		if (mDungeonRewardPanel != null) {
			mDungeonRewardPanel.clearHighlights();
		}
		var _loc5_ = ASCompat.reinterpretAs(mSelectedItemInfo, ItemInfo);
		mHeroWithEquipPicker.deselectEquipment();
		if ({
			mHeroWithEquipPicker.highlightItem(mSelectedItemInfo);
			false;
		}) {
			_loc2_ = _loc5_.gmWeaponItem;
			_loc4_ = _loc5_.power;
		} else {
			_loc3_ = (0 : UInt);
			while (_loc3_ < 15) {
				_loc1_ = mItems[(_loc3_ : Int)];
				if (mSelectedItemInfo != null && _loc1_.info == mSelectedItemInfo) {
					_loc1_.select();
					if (_loc5_ != null) {
						_loc2_ = _loc5_.gmWeaponItem;
						_loc4_ = _loc5_.power;
					}
				} else {
					_loc1_.deSelect();
				}
				_loc3_++;
			}
		}
		if (_loc2_ != null) {
			mHeroWithEquipPicker.showWeaponComparison(_loc2_, _loc4_);
		}
	}

	function highLightSelectedAccountItem() {
		var _loc4_:GMStackable = null;
		var _loc5_ = 0;
		var _loc2_:UIInventoryItem = null;
		var _loc3_ = (0 : UInt);
		var _loc1_ = ASCompat.reinterpretAs(mSelectedItemInfo, StackableInfo);
		mStacksWithEquipPicker.deselectEquipment();
		if ({
			mStacksWithEquipPicker.highlightItem(mSelectedItemInfo);
			false;
		}) {
			_loc4_ = _loc1_.gmStackable;
		} else {
			_loc3_ = (0 : UInt);
			while (_loc3_ < 15) {
				_loc2_ = mItems[(_loc3_ : Int)];
				if (mSelectedItemInfo != null && _loc2_.info == mSelectedItemInfo) {
					_loc2_.select();
					if (_loc1_ != null) {
						_loc4_ = _loc1_.gmStackable;
					}
				} else {
					_loc2_.deSelect();
				}
				_loc3_++;
			}
		}
		if (_loc4_ != null) {}
	}

	function highLightSelectedPet() {
		var _loc1_:GMNpc = null;
		var _loc3_:UIInventoryItem = null;
		var _loc4_ = (0 : UInt);
		var _loc2_ = ASCompat.reinterpretAs(mSelectedItemInfo, PetInfo);
		mPetsWithEquipPicker.deselectEquipment();
		if ({
			mPetsWithEquipPicker.highlightItem(mSelectedItemInfo);
			false;
		}) {
			_loc1_ = _loc2_.gmNpc;
		} else {
			_loc4_ = (0 : UInt);
			while (_loc4_ < 15) {
				_loc3_ = mItems[(_loc4_ : Int)];
				if (mSelectedItemInfo != null && _loc3_.info == mSelectedItemInfo) {
					_loc3_.select();
					if (_loc2_ != null) {
						_loc1_ = _loc2_.gmNpc;
					}
				} else {
					_loc3_.deSelect();
				}
				_loc4_++;
			}
		}
	}

	function populateDetailBoosterCard() {
		mConsumableChestCard.hide();
		mChestCard.hide();
		mInfoCard.visible = false;
		mBoosterCard.info = ASCompat.reinterpretAs(mSelectedItemInfo, StackableInfo);
		setupBoosterCardMenuNavigation();
	}

	function setupBoosterCardMenuNavigation() {
		restoreBoosterItemNavigation();
		var _loc2_ = mBoosterCard.visibleActivationButton;
		if (_loc2_ == null) {
			return;
		}
		_loc2_.clearNavigationAndInteractions();
		if (mSelectedItemNavigationSource != null && mSelectedItemNavigationSource.canBeFocused()) {
			mSelectedItemNavigationSource.clearUpNavigation();
			mSelectedItemNavigationSource.upNavigation = _loc2_;
			_loc2_.downNavigation = mSelectedItemNavigationSource;
			return;
		}
		var _loc1_ = ASCompat.reinterpretAs(getFirstFocusableInventoryItem(), UIInventoryItem);
		if (_loc1_ == null) {
			return;
		}
		mBoosterNavigationItem = _loc1_;
		_loc2_.rightNavigation = _loc1_;
		_loc1_.clearLeftNavigation();
		_loc1_.leftNavigation = _loc2_;
	}

	function focusAfterBoosterActivation() {
		if (mLogicalWorkComponent == null) {
			return;
		}
		mLogicalWorkComponent.doLater(0, function(param1:brain.clock.GameClock) {
			completeBoosterActivationFocus();
		});
	}

	function completeBoosterActivationFocus() {
		var _loc1_:UIButton = null;
		if (mBoosterCard != null && mBoosterCard.isShowing()) {
			setupBoosterCardMenuNavigation();
			_loc1_ = mBoosterCard.visibleActivationButton;
			if (_loc1_ != null && _loc1_.canBeFocused()) {
				mDBFacade.menuNavigationController.setFocusedUiObject(_loc1_);
				return;
			}
		}
		focusFirstInventoryItem();
	}

	function restoreBoosterItemNavigation() {
		if (mBoosterNavigationItem == null) {
			return;
		}
		var _loc1_ = mItems.indexOf(mBoosterNavigationItem);
		mBoosterNavigationItem.clearLeftNavigation();
		if (_loc1_ > 0 && _loc1_ % 5 != 0) {
			mBoosterNavigationItem.leftNavigation = mItems[_loc1_ - 1];
		}
		mBoosterNavigationItem = null;
	}

	function populateDetailInfoCard() {
		mConsumableChestCard.hide();
		mChestCard.hide();
		mInfoCard.info = mSelectedItemInfo;
		if (mSelectedItemInfo != null) {
			setupInfoCardMenuNavigation();
		}
	}

	function populateDetailChestCard() {
		var _loc1_ = ASCompat.reinterpretAs(mSelectedItemInfo, ChestInfo);
		if (_loc1_ == null) {
			mConsumableChestCard.hide();
			mChestCard.hide();
			mChestCard.selectedHeroId = mSelectedAvatar;
			return;
		}
		mInfoCard.info = null;
		if (UIHud.isThisAConsumbleChestId((_loc1_.gmId : Int))) {
			mConsumableChestCard.info = _loc1_;
			mChestCard.hide();
			mBoosterCard.hide();
			setupChestInfoCardMenuNavigation(mConsumableChestCard);
		} else {
			mChestCard.selectedHeroId = mSelectedAvatar;
			mChestCard.info = _loc1_;
			mConsumableChestCard.hide();
			mBoosterCard.hide();
			setupChestInfoCardMenuNavigation(mChestCard);
		}
	}

	function getSelectedItemPosition():Int {
		var _loc1_:UIInventoryItem = null;
		var _loc2_ = 0;
		_loc2_ = 0;
		while (_loc2_ < 15) {
			_loc1_ = mItems[_loc2_];
			if (mSelectedItemInfo != null && _loc1_.info == mSelectedItemInfo) {
				return _loc2_;
			}
			_loc2_++;
		}
		return -1;
	}

	public function destroy() {
		var _loc4_:UIRadioButton = null;
		var _loc1_:UIInventoryItem = null;
		var _loc5_ = (0 : UInt);
		var _loc2_:MovieClip = null;
		var _loc6_ = (0 : UInt);
		mDBFacade = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
		}
		mLogicalWorkComponent = null;
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
		}
		mAssetLoadingComponent = null;
		mRoot = null;
		mInventoryRoot = null;
		mSwfAsset = null;
		resetMenuNavigation();
		mTownHeader = null;
		if (mDungeonRewardPanel != null) {
			mDungeonRewardPanel.destroy();
		}
		mDungeonRewardPanel = null;
		var _loc3_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc3_.hasNext()) {
			_loc4_ = ASCompat.coerce(_loc3_.next(), brain.uI.UIRadioButton);
			_loc4_.destroy();
		}
		mTabButtons.clear();
		mTabButtons = null;
		if (mPagination != null) {
			mPagination.destroy();
		}
		mPagination = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mItems.length:UInt)) {
			_loc1_ = mItems[(_loc5_ : Int)];
			_loc1_.destroy();
			_loc5_++;
		}
		mItems = null;
		if (mInventoryGridElements != null) {
			_loc6_ = (0 : UInt);
			while (_loc5_ < (mInventoryGridElements.length:UInt)) {
				_loc2_ = mInventoryGridElements[(_loc6_ : Int)];
				_loc2_ = null;
				_loc5_++;
			}
		}
		mInventoryGridElements.length = 0;
		mInventoryGridElements = null;
		mCategorizedItems.clear();
		mCategorizedItems = null;
		if (mAddStorageButton != null) {
			mAddStorageButton.destroy();
		}
		mAddStorageButton = null;
		if (mInfoCard != null) {
			mInfoCard.destroy();
		}
		mInfoCard = null;
		if (mDungeonSummary != null) {
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
		if (mHeroWithEquipPicker != null) {
			mHeroWithEquipPicker.destroy();
		}
		mHeroWithEquipPicker = null;
		if (mStacksWithEquipPicker != null) {
			mStacksWithEquipPicker.destroy();
		}
		mStacksWithEquipPicker = null;
		if (mPetsWithEquipPicker != null) {
			mPetsWithEquipPicker.destroy();
		}
		mPetsWithEquipPicker = null;
		if (mStuffWithEquipPicker != null) {
			mStuffWithEquipPicker.destroy();
		}
		mStuffWithEquipPicker = null;
		mSelectedItemInfo = null;
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
		}
		mSceneGraphComponent = null;
		if (mChestCard != null) {
			mChestCard.destroy();
		}
		mChestCard = null;
		if (mAbandonChestPopUp != null) {
			mAbandonChestPopUp.destroy();
		}
		mAbandonChestPopUp = null;
		if (mChestOpenFullPopUp != null) {
			mChestOpenFullPopUp.destroy();
		}
		mChestOpenFullPopUp = null;
		if (mEventComponent != null) {
			mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
			mEventComponent.destroy();
		}
		mEventComponent = null;
		if (mConsumableChestCard != null) {
			mConsumableChestCard.destroy();
		}
		mConsumableChestCard = null;
		if (mBoosterCard != null) {
			mBoosterCard.destroy();
		}
		mBoosterCard = null;
	}

	function processChosenAvatar() {
		if (mHeroWithEquipPicker.currentlySelectedHero == null) {
			return;
		}
		var _loc1_ = mHeroWithEquipPicker.currentlySelectedHero.Id;
		if (mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_) {
			mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
		}
	}

	function setNextTab(category:String) {
		if (category == GMInventoryBase.WEAPON_CATEGORY) {
			mNextTab = GMInventoryBase.POWERUP_CATEGORY;
		} else if (category == GMInventoryBase.POWERUP_CATEGORY) {
			mNextTab = mWantPets ? GMInventoryBase.PET_CATEGORY : GMInventoryBase.STUFF_CATEGORY;
		} else if (category == GMInventoryBase.PET_CATEGORY) {
			mNextTab = GMInventoryBase.STUFF_CATEGORY;
		} else if (category == GMInventoryBase.STUFF_CATEGORY) {
			mNextTab = GMInventoryBase.WEAPON_CATEGORY;
		}
	}

	public function setupCategoryNavigation(ownerLayer:String) {
		mDBFacade.menuNavigationController.setLayerCategoryCallbacks(selectPreviousHero, selectNextHero, ownerLayer);
		mWeaponTabButton.clearNavigationAndInteractions();
		mPotionsTabButton.clearNavigationAndInteractions();
		mPetsTabButton.clearNavigationAndInteractions();
		mStuffTabButton.clearNavigationAndInteractions();
		if (mTownHeader != null) {
			mTownHeader.addCoinButton.clearDownNavigation();
			mTownHeader.addGemButton.clearDownNavigation();
			mTownHeader.closeButton.clearDownNavigation();
			mTownHeader.addCoinButton.downNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
			mTownHeader.addGemButton.downNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
			mTownHeader.closeButton.downNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
			mWeaponTabButton.upNavigation = mTownHeader.addCoinButton;
			mPotionsTabButton.upNavigation = mTownHeader.addCoinButton;
			mStuffTabButton.upNavigation = mTownHeader.addCoinButton;
			if (mWantPets) {
				mPetsTabButton.upNavigation = mTownHeader.addCoinButton;
			}
		}
		mWeaponTabButton.isToTheLeftOf(mPotionsTabButton);
		if (mWantPets) {
			mPotionsTabButton.isToTheLeftOf(mPetsTabButton);
			mPetsTabButton.isToTheLeftOf(mStuffTabButton);
			mPetsTabButton.downNavigation = mItems[0];
		} else {
			mPotionsTabButton.isToTheLeftOf(mStuffTabButton);
		}
		mStuffTabButton.isToTheLeftOf(mWeaponTabButton);
		mWeaponTabButton.downNavigation = mItems[0];
		mPotionsTabButton.downNavigation = mItems[0];
		mStuffTabButton.downNavigation = mItems[0];
	}

	function selectPreviousHero() {
		selectAdjacentHero(-1);
	}

	function selectNextHero() {
		selectAdjacentHero(1);
	}

	function selectAdjacentHero(direction:Int) {
		var _loc3_ = mDBFacade.gameMaster.Heroes;
		if (_loc3_.length == 0) {
			return;
		}
		var _loc2_ = ASCompat.toInt(mSelectedAvatar < (_loc3_.length:UInt) ? mSelectedAvatar : 0);
		var _loc4_ = _loc2_;
		do {
			_loc4_ = (_loc4_ + direction + _loc3_.length) % _loc3_.length;
		} while (_loc3_[_loc4_].Hidden
			&& !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes", false)
			&& _loc4_ != _loc2_);
		if ((_loc4_ : UInt) == mSelectedAvatar) {
			return;
		}
		mSelectedAvatar = (_loc4_ : UInt);
		heroSelected(_loc3_[_loc4_], mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc3_[_loc4_].Id));
	}

	function resetMenuNavigation() {
		if (mTownHeader == null) {
			return;
		}
		mTownHeader.addCoinButton.clearDownNavigation();
		mTownHeader.addGemButton.clearDownNavigation();
		mTownHeader.closeButton.clearDownNavigation();
	}

	function resetItemGridMenuNavigation() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < 15) {
			mItems[_loc1_].clearNavigationAndInteractions();
			_loc1_++;
		}
	}

	function setupNavigationLinks() {
		var _loc4_ = 0;
		var _loc1_ = 0;
		var _loc2_ = mPagination.getNextPageButton();
		var _loc3_ = getFirstFocusableInventoryItem();
		mAddStorageButton.clearUpNavigation();
		mAddStorageButton.clearDownNavigation();
		mItems[0].clearUpNavigation();
		mItems[1].clearUpNavigation();
		mItems[2].clearUpNavigation();
		mItems[3].clearUpNavigation();
		mItems[4].clearUpNavigation();
		mItems[0].upNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
		mItems[1].upNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
		mItems[2].upNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
		mItems[3].upNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
		mItems[4].upNavigation = ASCompat.coerce(mTabButtons.itemFor(mNextTab), brain.uI.UIObject);
		resetEquipPickerMenuNavigation();
		setupCurrentEquipPickerMenuNavigation();
		_loc4_ = 0;
		while (_loc4_ < 15) {
			if (_loc4_ % 5 < 4 && _loc4_ + 1 < 15) {
				mItems[_loc4_].isToTheLeftOf(mItems[_loc4_ + 1]);
			}
			if (_loc4_ + 5 < 15) {
				mItems[_loc4_].isAbove(mItems[_loc4_ + 5]);
			}
			if (_loc4_ >= 10) {
				mItems[_loc4_].downNavigation = _loc2_ ?? mAddStorageButton;
				if (_loc2_ != null) {
					mItems[_loc4_].downNavigationAdditionalInteraction = createPaginationReturnCallback(mItems[_loc4_]);
				}
			}
			_loc4_++;
		}
		if (mPagination.numPages > 1) {
			_loc1_ = 0;
			while ((_loc1_ : UInt) < mPagination.numPageButtons) {
				if (_loc1_ > 0) {
					mPagination.getPageButton(_loc1_ - 1).isToTheLeftOf(mPagination.getPageButton(_loc1_));
				}
				if (_loc3_ != null) {
					mPagination.getPageButton(_loc1_).upNavigation = _loc3_;
				}
				mPagination.getPageButton(_loc1_).downNavigation = mAddStorageButton;
				_loc1_++;
			}
			mAddStorageButton.upNavigation = _loc2_;
		} else {
			mAddStorageButton.upNavigation = mItems[15 - 1];
		}
	}

	function getFirstFocusableInventoryItem():UIObject {
		var _loc1_:UIInventoryItem;
		final __ax4_iter_365 = mItems;
		if (checkNullIteratee(__ax4_iter_365))
			for (_tmp_ in __ax4_iter_365) {
				_loc1_ = _tmp_;
				if (_loc1_.canBeFocused()) {
					return _loc1_;
				}
			}
		return null;
	}

	function focusFirstInventoryItem() {
		var _loc1_ = getFirstFocusableInventoryItem();
		if (_loc1_ == null && mTownHeader != null) {
			_loc1_ = mTownHeader.closeButton;
		}
		if (_loc1_ != null && _loc1_.canBeFocused()) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc1_);
		}
	}

	function resetEquipPickerMenuNavigation() {
		mHeroWithEquipPicker.resetHeroWithEquipPickerMenuNavigation();
		mStacksWithEquipPicker.resetMenuNavigation();
		if (mWantPets) {
			mPetsWithEquipPicker.resetMenuNavigation();
		}
		mStuffWithEquipPicker.resetMenuNavigation();
	}

	function setupCurrentEquipPickerMenuNavigation() {
		var _loc1_:UIObject = null;
		if (mCurrentTab == GMInventoryBase.POWERUP_CATEGORY) {
			mStacksWithEquipPicker.setupMenuNavigation(mAddStorageButton);
			_loc1_ = mStacksWithEquipPicker.getFirstUIObject();
		} else if (mWantPets && mCurrentTab == GMInventoryBase.PET_CATEGORY) {
			mPetsWithEquipPicker.setupMenuNavigation(mAddStorageButton);
			_loc1_ = mPetsWithEquipPicker.getFirstUIObject();
		} else if (mCurrentTab == GMInventoryBase.STUFF_CATEGORY) {
			mStuffWithEquipPicker.setupMenuNavigation(mAddStorageButton);
			_loc1_ = mStuffWithEquipPicker.getFirstUIObject();
		} else {
			mHeroWithEquipPicker.setupHeroWithEquipPickerMenuNavigation(mAddStorageButton);
			_loc1_ = mHeroWithEquipPicker.getFirstHeroSlotUIObject();
		}
		mAddStorageButton.downNavigation = _loc1_;
	}

	function createPaginationReturnCallback(returnObject:UIObject):ASFunction {
		return function() {
			setPaginationReturnObject(returnObject);
		};
	}

	function setPaginationReturnObject(returnObject:UIObject) {
		var _loc3_ = (0 : UInt);
		var _loc2_:UIButton = null;
		_loc3_ = (0 : UInt);
		while (_loc3_ < mPagination.numPageButtons) {
			_loc2_ = mPagination.getPageButton((_loc3_ : Int));
			_loc2_.clearUpNavigation();
			_loc2_.upNavigation = returnObject;
			_loc3_++;
		}
	}

	function setupInfoCardMenuNavigation() {
		mItems[0].clearLeftNavigation();
		mItems[5].clearLeftNavigation();
		mItems[10].clearLeftNavigation();
		mInfoCard.mEquipButton.clearRightNavigation();
		mInfoCard.setupMenuNavigation();
		if (mSelectedItemNavigationSource != null && mSelectedItemNavigationSource.canBeFocused()) {
			mSelectedItemNavigationSource.clearUpNavigation();
			mSelectedItemNavigationSource.upNavigation = mInfoCard.mEquipButton;
			mInfoCard.mEquipButton.downNavigation = mSelectedItemNavigationSource;
			return;
		}
		var _loc1_ = getSelectedItemPosition();
		if (_loc1_ != -1) {
			mInfoCard.mEquipButton.rightNavigation = mItems[_loc1_];
		}
		mItems[0].leftNavigation = mInfoCard.mEquipButton;
		mItems[5].leftNavigation = mInfoCard.mEquipButton;
		mItems[10].leftNavigation = mInfoCard.mEquipButton;
	}

	function setupChestInfoCardMenuNavigation(chestCard:ChestInfoCard) {
		var _loc3_:UIObject = null;
		var _loc4_ = 0;
		var _loc2_:UIObject = null;
		mItems[0].clearLeftNavigation();
		mItems[5].clearLeftNavigation();
		mItems[10].clearLeftNavigation();
		var _loc5_ = ASCompat.reinterpretAs(mSelectedItemInfo, ChestInfo);
		if (_loc5_.isFromDungeonSummary() && mDungeonRewardPanel != null) {
			_loc3_ = mDungeonRewardPanel.getNavigationEntry(_loc5_);
		} else {
			_loc4_ = getSelectedItemPosition();
			if (_loc4_ != -1) {
				_loc3_ = mItems[_loc4_];
			}
		}
		chestCard.setupMenuNavigation(_loc3_);
		if (_loc5_.isFromDungeonSummary()) {
			_loc2_ = getFirstFocusableInventoryItem();
			mDungeonRewardPanel.setupChestCardNavigation(chestCard.dungeonSummaryAbandonButton, chestCard.dungeonSummaryKeepButton, _loc5_);
			if (_loc2_ != null) {
				chestCard.dungeonSummaryUnlockButton.rightNavigation = _loc2_;
				_loc2_.clearLeftNavigation();
				_loc2_.leftNavigation = chestCard.dungeonSummaryUnlockButton;
			}
			mItems[5].leftNavigation = chestCard.dungeonSummaryUnlockButton;
			mItems[10].leftNavigation = chestCard.dungeonSummaryUnlockButton;
			if (!mDungeonSummaryInitialFocusSet && chestCard.dungeonSummaryUnlockButton.canBeFocused()) {
				mDungeonSummaryInitialFocusSet = true;
				mDBFacade.menuNavigationController.setFocusedUiObject(chestCard.dungeonSummaryUnlockButton);
			}
		} else {
			mItems[0].leftNavigation = chestCard.menuEntryButton;
			mItems[5].leftNavigation = chestCard.menuEntryButton;
			mItems[10].leftNavigation = chestCard.menuEntryButton;
			if (mDungeonSummary != null && mDungeonRewardPanel != null) {
				mDungeonRewardPanel.setupInventoryChestNavigation(chestCard.inventoryAbandonButton);
			}
		}
	}
}
