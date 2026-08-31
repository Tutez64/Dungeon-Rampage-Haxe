package account;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMOfferDetail;
import gameMasterDictionary.GMStackable;
import gameMasterDictionary.GMWeaponItem;
import uI.inventory.UIPurchaseOfferPopup;
import uI.inventory.UISellItemPopup;
import uI.popup.DBUIOneButtonPopup;
import uI.popup.DBUIPopup;
import uI.popup.DBUITwoButtonPopup;
import uI.popup.UICashPage;
import uI.popup.UICoinPage;
import uI.popup.UIGiftPage;
import uI.popup.UIOfferPopup;
import uI.popup.UIStorageFullPopup;
import org.as3commons.collections.Map;

class StoreServicesController {
	public static inline final MAX_INVENTORY_SLOTS = (120 : UInt);

	public static inline final CONFIRM_PREMIUM_PURCHASES = false;

	public static inline final CONFIRM_BASIC_PURCHASES = false;

	public static inline final CONFIRM_ALREADY_OWN = true;

	public static final BASIC_KEY_OFFERS:Vector<UInt> = Vector.ofArray(([(51201 : UInt), (51203 : UInt), (51205 : UInt)] : Array<UInt>));

	public static final PREMIUM_KEY_OFFERS:Vector<UInt> = Vector.ofArray(([(51211 : UInt), (51212 : UInt), (51213 : UInt)] : Array<UInt>));

	public static final COIN_OFFERS:Vector<UInt> = Vector.ofArray(([(51102 : UInt), (51103 : UInt), (51104 : UInt)] : Array<UInt>));

	public static final STORAGE_OFFERS:Vector<UInt> = Vector.ofArray(([(51401 : UInt), (51402 : UInt), (51403 : UInt)] : Array<UInt>));

	public static final GIFT_OFFERS:Vector<UInt> = Vector.ofArray(([(51301 : UInt), (51399 : UInt), (51398 : UInt)] : Array<UInt>));

	public static final HERO_OFFERS:Vector<UInt> = Vector.ofArray(([(51012 : UInt), (51013 : UInt), (51014 : UInt), (51015 : UInt)] : Array<UInt>));

	public function new() {}

	public static function getOfferMetrics(dbFacade:DBFacade, gmOffer:GMOffer):ASObject {
		var _loc3_:ASObject = {};
		ASCompat.setProperty(_loc3_, "offerId", gmOffer.Id);
		ASCompat.setProperty(_loc3_, "offerName", gmOffer.getDisplayName(dbFacade.gameMaster, Locale.getString("SHOP_UNKNOWN_NAME")));
		ASCompat.setProperty(_loc3_, "price", gmOffer.Price);
		ASCompat.setProperty(_loc3_, "currencyType", gmOffer.CurrencyType);
		return _loc3_;
	}

	static function getSellMetrics(dbFacade:DBFacade, info:InventoryBaseInfo):ASObject {
		var _loc3_:ASObject = {};
		ASCompat.setProperty(_loc3_, "itemId", info.gmId);
		ASCompat.setProperty(_loc3_, "itemName", info.Name.toUpperCase());
		ASCompat.setProperty(_loc3_, "price", info.sellCoins);
		ASCompat.setProperty(_loc3_, "currencyType", "BASIC");
		return _loc3_;
	}

	public static function tryBuyOffer(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:ASFunction, forHeroId:UInt = (0 : UInt)) {
		dbFacade.metrics.log("ShopPurchaseTry", getOfferMetrics(dbFacade, gmOffer));
		if (StoreServicesController.stackableLimitWouldOverflow(dbFacade, gmOffer)) {
			StoreServicesController.stackableLimitPopup(dbFacade, gmOffer);
		} else if (StoreServicesController.weaponInventoryWouldOverflow(dbFacade, gmOffer)) {
			StoreServicesController.weaponInventoryFullPopup(dbFacade, gmOffer);
		} else if (StoreServicesController.weaponStorageWouldOverflow(dbFacade, gmOffer)) {
			StoreServicesController.weaponStorageLimitPopup(dbFacade, gmOffer);
		} else if (alreadyOwns(dbFacade, gmOffer)) {
			StoreServicesController.confirmAlreadyOwnsPopup(dbFacade, gmOffer, buySuccessCallback, forHeroId);
		} else if (StoreServicesController.getOfferLevelReq(dbFacade, gmOffer) > dbFacade.dbAccountInfo.highestAvatarLevel) {
			StoreServicesController.notHighEnoughLevelPopup(dbFacade, gmOffer);
		} else if (weaponRestrictedAndHeroNotOwned(dbFacade, gmOffer)) {
			StoreServicesController.doesntOwnHeroPopup(dbFacade, gmOffer);
		} else if (gmOffer.CurrencyType == "PREMIUM" && dbFacade.dbAccountInfo.premiumCurrency < gmOffer.Price) {
			StoreServicesController.showCashPage(dbFacade, "tryBuyOffer", gmOffer, buySuccessCallback, null, forHeroId);
		} else if (gmOffer.CurrencyType == "BASIC" && dbFacade.dbAccountInfo.basicCurrency < gmOffer.Price) {
			StoreServicesController.notEnoughCoinsPopup(dbFacade, gmOffer);
		} else if (false && gmOffer.CurrencyType == "PREMIUM") {
			StoreServicesController.confirmPurchasePopup(dbFacade, gmOffer, buySuccessCallback, forHeroId);
		} else if (false && gmOffer.CurrencyType == "BASIC") {
			StoreServicesController.confirmPurchasePopup(dbFacade, gmOffer, buySuccessCallback, forHeroId);
		} else {
			StoreServicesController.buyOffer(dbFacade, gmOffer, buySuccessCallback, forHeroId);
		}
	}

	public static function trySellItem(dbFacade:DBFacade, info:InventoryBaseInfo, successCallback:ASFunction = null, errorCallback:ASFunction = null) {
		dbFacade.metrics.log("TrySell", StoreServicesController.getSellMetrics(dbFacade, info));
		if (info.isEquipped) {
			StoreServicesController.itemIsEquippedPopup(dbFacade, info, successCallback, errorCallback);
		} else {
			StoreServicesController.confirmSell(dbFacade, info, successCallback, errorCallback);
		}
	}

	public static function getOfferLevelReq(dbFacade:DBFacade, gmOffer:GMOffer):UInt {
		if (gmOffer.IsBundle) {
			return (0 : UInt);
		}
		var _loc3_ = gmOffer.Details[0];
		if (_loc3_.Level != 0) {
			return _loc3_.Level;
		}
		return (0 : UInt);
	}

	public static function getWeaponMastertype(dbFacade:DBFacade, gmOffer:GMOffer):String {
		var _loc3_:GMWeaponItem = null;
		if (gmOffer.IsBundle) {
			return null;
		}
		var _loc4_ = gmOffer.Details[0];
		if (_loc4_.WeaponId != 0) {
			_loc3_ = ASCompat.dynamicAs(dbFacade.gameMaster.weaponItemById.itemFor(_loc4_.WeaponId), gameMasterDictionary.GMWeaponItem);
			return _loc3_.MasterType;
		}
		return null;
	}

	public static function getHeroId(dbFacade:DBFacade, gmOffer:GMOffer):UInt {
		if (gmOffer.IsBundle) {
			return (0 : UInt);
		}
		var _loc3_ = gmOffer.Details[0];
		return _loc3_.HeroId;
	}

	public static function getSkinId(dbFacade:DBFacade, gmOffer:GMOffer):UInt {
		if (gmOffer.IsBundle) {
			return (0 : UInt);
		}
		var _loc3_ = gmOffer.Details[0];
		return _loc3_.SkinId;
	}

	public static function alreadyOwns(dbFacade:DBFacade, gmOffer:GMOffer):Bool {
		var _loc3_ = dbFacade.dbAccountInfo.inventoryInfo;
		var _loc4_:GMOfferDetail;
		final __ax4_iter_3 = gmOffer.Details;
		if (checkNullIteratee(__ax4_iter_3))
			for (_tmp_ in __ax4_iter_3) {
				_loc4_ = _tmp_;
				if (_loc4_.HeroId != 0 && _loc3_.ownsItem(_loc4_.HeroId)) {
					return true;
				}
				if (_loc4_.PetId != 0 && _loc3_.ownsItem(_loc4_.PetId)) {
					return true;
				}
				if (_loc4_.WeaponId != 0 && _loc3_.ownsExactWeapon(_loc4_)) {
					return true;
				}
				if (_loc4_.SkinId != 0 && _loc3_.ownsItem(_loc4_.SkinId)) {
					return true;
				}
			}
		return false;
	}

	public static function weaponRestrictedAndHeroNotOwned(dbFacade:DBFacade, gmOffer:GMOffer):Bool {
		var _loc3_ = requiredHeroForWeapon(dbFacade, gmOffer);
		if (_loc3_ != 0 && !dbFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc3_)) {
			return true;
		}
		return false;
	}

	public static function weaponInventoryWouldOverflow(dbFacade:DBFacade, gmOffer:GMOffer):Bool {
		var _loc4_ = (0 : UInt);
		var _loc5_:GMOfferDetail;
		final __ax4_iter_4 = gmOffer.Details;
		if (checkNullIteratee(__ax4_iter_4))
			for (_tmp_ in __ax4_iter_4) {
				_loc5_ = _tmp_;
				if (_loc5_.WeaponId != 0) {
					_loc4_++;
				} else if (_loc5_.ChestId != 0 && (_loc5_.ChestId != 60005 && _loc5_.ChestId != 60006)) {
					_loc4_++;
				}
			}
		return _loc4_ != 0 && _loc4_ + dbFacade.dbAccountInfo.unequippedWeaponCount > dbFacade.dbAccountInfo.inventoryLimitWeapons;
	}

	public static function stackableLimitWouldOverflow(dbFacade:DBFacade, gmOffer:GMOffer):Bool {
		var _loc8_:GMOfferDetail = null;
		var _loc4_:ASAny = 0;
		var _loc9_ = 0;
		var _loc5_ = 0;
		var _loc3_ = 0;
		var _loc6_:GMStackable = null;
		var _loc7_ = new Map();
		final __ax4_iter_5 = gmOffer.Details;
		if (checkNullIteratee(__ax4_iter_5))
			for (_tmp_ in __ax4_iter_5) {
				_loc8_ = _tmp_;
				_loc4_ = _loc8_.StackableId;
				if (ASCompat.toBool(_loc4_)) {
					if (_loc7_.hasKey(_loc4_)) {
						_loc9_ = ASCompat.toInt(_loc7_.itemFor(_loc4_));
						_loc7_.replaceFor(_loc4_, _loc9_ + _loc8_.StackableCount);
					} else {
						_loc7_.add(_loc4_, _loc8_.StackableCount);
					}
				}
			}
		final __ax4_iter_6 = gmOffer.Details;
		if (checkNullIteratee(__ax4_iter_6))
			for (_tmp_ in __ax4_iter_6) {
				_loc8_ = _tmp_;
				_loc4_ = _loc8_.StackableId;
				if (ASCompat.toBool(_loc4_)) {
					_loc5_ = (dbFacade.dbAccountInfo.inventoryInfo.getStackCount((ASCompat.toInt(_loc4_) : UInt)) : Int);
					_loc3_ = ASCompat.toInt(_loc7_.itemFor(_loc4_));
					_loc6_ = ASCompat.dynamicAs(dbFacade.gameMaster.stackableById.itemFor(_loc4_), gameMasterDictionary.GMStackable);
					if (ASCompat.toNumber(_loc5_ + _loc3_) > _loc6_.StackLimit) {
						return true;
					}
				}
			}
		return false;
	}

	public static function weaponStorageWouldOverflow(dbFacade:DBFacade, gmOffer:GMOffer):Bool {
		var _loc5_ = (0 : UInt);
		var _loc4_:GMOfferDetail;
		final __ax4_iter_7 = gmOffer.Details;
		if (checkNullIteratee(__ax4_iter_7))
			for (_tmp_ in __ax4_iter_7) {
				_loc4_ = _tmp_;
				_loc5_ += _loc4_.WeaponSlots;
			}
		if (_loc5_ == 0) {
			return false;
		}
		return _loc5_ + dbFacade.dbAccountInfo.inventoryLimitWeapons > 120;
	}

	public static function requiredHeroForWeapon(dbFacade:DBFacade, gmOffer:GMOffer):UInt {
		return (0 : UInt);
	}

	public static function itemIsEquippedPopup(dbFacade:DBFacade, info:InventoryBaseInfo, buySuccessCallback:ASFunction, errorCallback:ASFunction) {
		var popup:UISellItemPopup;
		dbFacade.metrics.log("ItemEquippedDuringSell", StoreServicesController.getSellMetrics(dbFacade, info));
		popup = new UISellItemPopup(dbFacade, Locale.getString("ITEM_CONFIRM_SELL"), info, Locale.getString("CANCEL"), null,
			Locale.getString("ITEM_SELL_BUTTON"), function() {
				sellItem(dbFacade, info, buySuccessCallback, errorCallback);
		});
		MemoryTracker.track(popup, "UISellItemPopup - created in StoreServicesController.itemIsEquippedPopup()");
	}

	public static function confirmSell(dbFacade:DBFacade, info:InventoryBaseInfo, buySuccessCallback:ASFunction, errorCallback:ASFunction) {
		var popup:UISellItemPopup;
		dbFacade.metrics.log("ConfirmSell", StoreServicesController.getSellMetrics(dbFacade, info));
		popup = new UISellItemPopup(dbFacade, Locale.getString("ITEM_CONFIRM_SELL"), info, Locale.getString("CANCEL"), null,
			Locale.getString("ITEM_SELL_BUTTON"), function() {
				sellItem(dbFacade, info, buySuccessCallback, errorCallback);
		});
		MemoryTracker.track(popup, "UISellItemPopup - created in StoreServicesController.confirmSell()");
	}

	public static function notEnoughCashPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		var popup:DBUITwoButtonPopup;
		dbFacade.metrics.log("ShopPurchaseNotEnoughCash", getOfferMetrics(dbFacade, gmOffer));
		popup = new DBUITwoButtonPopup(dbFacade, Locale.getString("SHOP_NOT_ENOUGH_CASH_TITLE"), Locale.getString("SHOP_NOT_ENOUGH_CASH_MESSAGE"),
			Locale.getString("SHOP_GET_CASH"), function() {
				showCashPage(dbFacade, "notEnoughGemsPopup");
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "DBUITwoButtonPopup - created in StoreServicesController.notEnoughCashPopup()");
	}

	public static function notEnoughCoinsPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		var popup:DBUITwoButtonPopup;
		dbFacade.metrics.log("ShopPurchaseNotEnoughCoins", getOfferMetrics(dbFacade, gmOffer));
		popup = new DBUITwoButtonPopup(dbFacade, Locale.getString("SHOP_NOT_ENOUGH_COINS_TITLE"), Locale.getString("SHOP_NOT_ENOUGH_COINS_MESSAGE"),
			Locale.getString("SHOP_GET_COINS"), function() {
				showCoinPage(dbFacade);
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "DBUITwoButtonPopup - created in StoreServicesController.notEnoughCoinsPopup()");
	}

	public static function notHighEnoughLevelPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		var popup:DBUITwoButtonPopup;
		dbFacade.metrics.log("ShopPurchaseNotHighLevel", getOfferMetrics(dbFacade, gmOffer));
		popup = new DBUITwoButtonPopup(dbFacade, Locale.getString("SHOP_NOT_HIGH_LEVEL_TITLE"), Locale.getString("SHOP_NOT_HIGH_LEVEL_MESSAGE"),
			Locale.getString("SHOP_BUY_ANYWAYS"), function() {
				buyOffer(dbFacade, gmOffer, null);
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "DBUITwoButtonPopup - created in StoreServicesController.notHighEnoughLevelPopup()");
	}

	public static function weaponInventoryFullPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		var popup:DBUITwoButtonPopup;
		dbFacade.metrics.log("ShopPurchaseWeaponInventoryFull", getOfferMetrics(dbFacade, gmOffer));
		popup = new UIStorageFullPopup(dbFacade, Locale.getString("SHOP_WEAPON_INVENTORY_FULL_TITLE"), Locale.getString("SHOP_WEAPON_INVENTORY_FULL_MESSAGE"),
			Locale.getString("SHOP_GET_STORAGE"), function() {
				showStoragePage(dbFacade);
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "UIStorageFullPopup - created in StoreServicesController.weaponInventoryFullPopup()");
	}

	public static function stackableLimitPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		dbFacade.metrics.log("ShopPurchaseStackLimit", getOfferMetrics(dbFacade, gmOffer));
		var _loc3_ = new DBUIOneButtonPopup(dbFacade, Locale.getString("SHOP_STACK_LIMIT_TITLE"), Locale.getString("SHOP_STACK_LIMIT_MESSAGE"),
			Locale.getString("CANCEL"), null);
		MemoryTracker.track(_loc3_, "DBUIOneButtonPopup - created in StoreServicesController.stackableLimitPopup()");
	}

	public static function weaponStorageLimitPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		dbFacade.metrics.log("ShopPurchaseWeaponStorageLimit", getOfferMetrics(dbFacade, gmOffer));
		var _loc3_ = new DBUIOneButtonPopup(dbFacade, Locale.getString("SHOP_WEAPON_STORAGE_LIMIT_TITLE"),
			Locale.getString("SHOP_WEAPON_STORAGE_LIMIT_MESSAGE"), Locale.getString("CANCEL"), null);
		MemoryTracker.track(_loc3_, "DBUIOneButtonPopup - created in StoreServicesController.weaponStorageLimitPopup()");
	}

	public static function doesntOwnHeroPopup(dbFacade:DBFacade, gmOffer:GMOffer) {
		var popup:DBUITwoButtonPopup;
		dbFacade.metrics.log("ShopPurchaseDoesntOwnHero", getOfferMetrics(dbFacade, gmOffer));
		popup = new DBUITwoButtonPopup(dbFacade, Locale.getString("SHOP_HERO_NOT_OWNED"), null, Locale.getString("SHOP_BUY_ANYWAYS"), function() {
			buyOffer(dbFacade, gmOffer, null);
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "DBUITwoButtonPopup - created in StoreServicesController.doesntOwnHeroPopup()");
	}

	public static function confirmPurchasePopup(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:ASFunction, forHeroId:UInt = (0 : UInt)) {
		var popup:UIPurchaseOfferPopup;
		dbFacade.metrics.log("ShopPurchaseConfirm", getOfferMetrics(dbFacade, gmOffer));
		popup = new UIPurchaseOfferPopup(dbFacade, "purchase_popup", Locale.getString("SHOP_CONFIRM_BUY"), gmOffer, Locale.getString("SHOP_BUY"), function() {
			buyOffer(dbFacade, gmOffer, buySuccessCallback, forHeroId);
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "UIPurchaseOfferPopup - created in StoreServicesController.confirmPurchasePopup()");
	}

	public static function confirmAlreadyOwnsPopup(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:ASFunction, forHeroId:UInt = (0 : UInt)) {
		var popup:UIPurchaseOfferPopup;
		dbFacade.metrics.log("ShopPurchaseConfirmAlreadyOwns", getOfferMetrics(dbFacade, gmOffer));
		popup = new UIPurchaseOfferPopup(dbFacade, "purchase_popup", Locale.getString("SHOP_CONFIRM_DUPLICATE_BUY"), gmOffer,
			Locale.getString("SHOP_BUY_ANOTHER"), function() {
				buyOffer(dbFacade, gmOffer, buySuccessCallback, forHeroId);
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(popup, "UIPurchaseOfferPopup - created in StoreServicesController.confirmAlreadyOwnsPopup()");
	}

	public static function waitForPurchaseServicePopup(dbFacade:DBFacade):DBUIPopup {
		var _loc2_ = new DBUIPopup(dbFacade, Locale.getString("SHOP_PURCHASING"), null, false);
		MemoryTracker.track(_loc2_, "DBUIPopup - created in StoreServicesController.waitForPurchaseServicePopup()");
		return _loc2_;
	}

	public static function waitForSellServicePopup(dbFacade:DBFacade):DBUIPopup {
		var _loc2_ = new DBUIPopup(dbFacade, Locale.getString("SHOP_SELLING"), null, false);
		MemoryTracker.track(_loc2_, "DBUIPopup - created in StoreServicesController.waitForSellServicePopup()");
		return _loc2_;
	}

	public static function buyOffer(dbFacade:DBFacade, gmOffer:GMOffer, buySuccessCallback:ASFunction, forHeroId:UInt = (0 : UInt)) {
		var popup:DBUIPopup;
		var previousBucketsWeapon:Int;
		dbFacade.metrics.log("ShopPurchase", getOfferMetrics(dbFacade, gmOffer));
		popup = StoreServicesController.waitForPurchaseServicePopup(dbFacade);
		previousBucketsWeapon = dbFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon;
		StoreServices.purchaseOffer(dbFacade, gmOffer.Id, function(param1:ASAny) {
			var _loc2_ = 0;
			popup.destroy();
			if (dbFacade.steamAchievementsManager != null) {
				if (gmOffer.CurrencyType == "BASIC") {
					dbFacade.steamAchievementsManager.addToStatInt("SPEND_COINS_INT", Std.int(gmOffer.Price));
				}
				if (gmOffer.Tab == "WEAPON") {
					dbFacade.steamAchievementsManager.setAchievement("PURCHASE_WEAPON_FIRST_TIME");
				}
			}
			StoreServices.getLimitedOfferUsage(dbFacade, param1, null, null);
			if (buySuccessCallback != null) {
				buySuccessCallback(param1);
				_loc2_ = dbFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon;
				if (previousBucketsWeapon < _loc2_ && dbFacade.steamAchievementsManager != null) {
					dbFacade.steamAchievementsManager.setAchievement("STORAGE_EXPAND_FIRST_TIME");
					dbFacade.steamAchievementsManager.setMaxStorageStat(previousBucketsWeapon, _loc2_);
				}
			}
		}, function(param1:Error) {
			popup.destroy();
			showErrorPopup(dbFacade, param1);
		}, forHeroId);
	}

	public static function sellItem(dbFacade:DBFacade, info:InventoryBaseInfo, buySuccessCallback:ASFunction = null, errorCallback:ASFunction = null) {
		var popup:DBUIPopup;
		var sellFunc:ASFunction;
		dbFacade.metrics.log("SellItem", StoreServicesController.getSellMetrics(dbFacade, info));
		popup = StoreServicesController.waitForSellServicePopup(dbFacade);
		if (Std.isOfType(info, ItemInfo)) {
			sellFunc = StoreServices.sellWeapon;
		} else if (Std.isOfType(info, StackableInfo)) {
			sellFunc = StoreServices.sellStackable;
		} else {
			if (!Std.isOfType(info, PetInfo)) {
				Logger.error("Unknown item type in SellItem");
				return;
			}
			sellFunc = StoreServices.sellPet;
		}
		sellFunc(dbFacade, info.databaseId, function(param1:ASAny) {
			popup.destroy();
			if (buySuccessCallback != null) {
				buySuccessCallback(param1);
			}
		}, function(param1:Error) {
			popup.destroy();
			showErrorPopup(dbFacade, param1);
			if (errorCallback != null) {
				errorCallback();
			}
		});
	}

	public static function useAccountBooster(dbFacade:DBFacade, info:InventoryBaseInfo, useSuccessCallback:ASFunction = null, errorCallback:ASFunction = null) {
		StoreServices.useAccountBooster(dbFacade, info.gmId, useSuccessCallback, errorCallback);
	}

	public static function getWebServerTimestamp(dbFacade:DBFacade, useSuccessCallback:ASFunction = null, errorCallback:ASFunction = null) {
		trace("getWebServerTimestamp");
		StoreServices.getWebServerTimestamp(dbFacade, useSuccessCallback, errorCallback);
	}

	public static function showErrorPopup(dbFacade:DBFacade, error:Error) {
		dbFacade.metrics.log("ShopError", {"error": error.errorID});
		dbFacade.errorPopup(Locale.getString("SHOP_ERROR") + ": " + error.errorID, error.message);
	}

	public static function showCashPage(dbFacade:DBFacade, openedFrom:String, attemptedOffer:GMOffer = null, successCallback:ASFunction = null,
			closeCallback:ASFunction = null, forHeroId:UInt = (0 : UInt)) {
		var _loc7_:ASObject = {};
		ASCompat.setProperty(_loc7_, "openedFrom", openedFrom);
		dbFacade.metrics.log("ShopCashPagePresented", _loc7_);
		var _loc8_ = new UICashPage(dbFacade);
		MemoryTracker.track(_loc8_, "UICashPage - created in StoreServicesController.showCashPage()");
	}

	public static function showCoinPage(dbFacade:DBFacade) {
		dbFacade.metrics.log("ShopCoinPagePresented");
		var _loc2_ = new UICoinPage(dbFacade);
		MemoryTracker.track(_loc2_, "UICoinPage - created in StoreServicesController.showCoinPage()");
	}

	public static function showStoragePage(dbFacade:DBFacade) {
		dbFacade.metrics.log("ShopStoragePagePresented");
		var _loc2_ = new UIOfferPopup(dbFacade, Locale.getString("SHOP_STORAGE_PAGE_TITLE"), STORAGE_OFFERS, null, null, true, false);
		MemoryTracker.track(_loc2_, "UIOfferPopup - created in StoreServicesController.showStoragePage()");
	}

	public static function showGiftPage(dbFacade:DBFacade, buyCallback:ASFunction) {
		dbFacade.metrics.log("ShopGiftPagePresented");
		var _loc3_ = new UIGiftPage(dbFacade, buyCallback, null);
		MemoryTracker.track(_loc3_, "UIGiftPage - created in StoreServicesController.showGiftPage()");
	}
}
