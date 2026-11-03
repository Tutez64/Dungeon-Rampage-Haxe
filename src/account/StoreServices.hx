package account;

import brain.clock.GameClock;
import brain.logger.Logger;
import brain.jsonRPC.JSONRPCService;
import collections.Map;
import facade.DBFacade;
import gameMasterDictionary.GMOffer;

class StoreServices {
	static var mLimitedOffers:Map = new Map();

	public function new() {}

	public static function purchaseOffer(dbFacade:DBFacade, offerId:UInt, successCallback:ASFunction, errorCallback:ASFunction, heroId:UInt = (0 : UInt),
			callRefreshOnceDone:Bool = true) {
		var purchaseFunc:ASFunction;
		var gmOffer = ASCompat.coerce(dbFacade.gameMaster.offerById.itemFor(offerId), gameMasterDictionary.GMOffer);
		var currentAvatarId = (ASCompat.toInt(dbFacade.dbAccountInfo.activeAvatarInfo != null ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0) : UInt);
		Logger.debug("purchaseOffer: " + Std.string(offerId));
		purchaseFunc = JSONRPCService.getFunction("PurchaseOffer", dbFacade.rpcRoot + "store");
		purchaseFunc(dbFacade.dbAccountInfo.id, heroId, offerId, dbFacade.validationToken, dbFacade.demographics, function(param1:ASAny) {
			dbFacade.dbAccountInfo.parseResponse(param1, callRefreshOnceDone);
			recordCoinsSpent(dbFacade, gmOffer);
			if (successCallback != null) {
				successCallback(param1);
			}
		}, errorCallback);
	}

	public static function purchaseAndOpenChest(dbFacade:DBFacade, offerId:UInt, successCallback:ASFunction, errorCallback:ASFunction, forHero:UInt,
			callRefreshOnceDone:Bool = true) {
		var purchaseFunc:ASFunction;
		var gmOffer = ASCompat.coerce(dbFacade.gameMaster.offerById.itemFor(offerId), gameMasterDictionary.GMOffer);
		var currentAvatarId = (ASCompat.toInt(dbFacade.dbAccountInfo.activeAvatarInfo != null ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0) : UInt);
		Logger.debug("purchaseChest: " + Std.string(offerId));
		purchaseFunc = JSONRPCService.getFunction("PurchaseChest", dbFacade.rpcRoot + "store");
		purchaseFunc(dbFacade.dbAccountInfo.id, currentAvatarId, offerId, dbFacade.validationToken, dbFacade.demographics, function(param1:ASAny) {
			dbFacade.dbAccountInfo.parseResponse(param1, callRefreshOnceDone);
			recordCoinsSpent(dbFacade, gmOffer);
			if (successCallback != null) {
				successCallback(param1);
			}
		}, errorCallback);
	}

	public static function sellWeapon(dbFacade:DBFacade, weaponInstanceId:UInt, successCallback:ASFunction, errorCallback:ASFunction) {
		var sellItemFunc = JSONRPCService.getFunction("SellWeapon", dbFacade.rpcRoot + "store");
		sellItemFunc(dbFacade.dbAccountInfo.id, weaponInstanceId, dbFacade.validationToken, function(param1:ASAny) {
			dbFacade.dbAccountInfo.parseResponse(param1);
			recordItemSold(dbFacade);
			if (successCallback != null) {
				successCallback(param1);
			}
		}, errorCallback);
	}

	public static function sellStackable(dbFacade:DBFacade, stackableInstanceId:UInt, successCallback:ASFunction, errorCallback:ASFunction) {
		var sellItemFunc = JSONRPCService.getFunction("SellStackable", dbFacade.rpcRoot + "store");
		sellItemFunc(dbFacade.dbAccountInfo.id, stackableInstanceId, dbFacade.validationToken, function(param1:ASAny) {
			dbFacade.dbAccountInfo.parseResponse(param1);
			recordItemSold(dbFacade);
			if (successCallback != null) {
				successCallback(param1);
			}
		}, errorCallback);
	}

	public static function sellPet(dbFacade:DBFacade, petInstanceId:UInt, successCallback:ASFunction, errorCallback:ASFunction) {
		var sellPetFunc = JSONRPCService.getFunction("SellPet", dbFacade.rpcRoot + "store");
		sellPetFunc(dbFacade.dbAccountInfo.id, petInstanceId, dbFacade.validationToken, function(param1:ASAny) {
			dbFacade.dbAccountInfo.parseResponse(param1);
			recordItemSold(dbFacade);
			if (successCallback != null) {
				successCallback(param1);
			}
		}, errorCallback);
	}

	static function recordCoinsSpent(dbFacade:DBFacade, gmOffer:GMOffer) {
		if (gmOffer != null && gmOffer.CurrencyType == GMOffer.BASIC_CURRENCY) {
			dbFacade.steamAchievementsHelper.addValueToStatInt(gmOffer.Price, "COINS_SPENT");
		}
	}

	static function recordItemSold(dbFacade:DBFacade) {
		dbFacade.steamAchievementsHelper.unlockAchievement("SELL_AN_ITEM");
		dbFacade.steamAchievementsHelper.addValueToStatInt(1, "ITEMS_SOLD");
	}

	public static function useAccountBooster(dbFacade:DBFacade, stackableId:UInt, successCallback:ASFunction, errorCallback:ASFunction) {
		errorCallback = function() {};
		var useAccountBoosterFunc = JSONRPCService.getFunction("UseAccountBooster", dbFacade.rpcRoot + "store");
		useAccountBoosterFunc(dbFacade.dbAccountInfo.id, stackableId, dbFacade.validationToken, dbFacade.demographics, function(param1:ASAny) {
			dbFacade.dbAccountInfo.parseResponse(param1);
			if (successCallback != null) {
				successCallback();
			}
		}, errorCallback);
	}

	public static function getWebServerTimestamp(dbFacade:DBFacade, successCallback:ASFunction, errorCallback:ASFunction) {
		errorCallback = function() {};
		var getWebServerTimestampFunc = JSONRPCService.getFunction("getWebServerTimestamp", dbFacade.rpcRoot + "storeGetWebServerTimestamp");
		getWebServerTimestampFunc(function(param1:Array<ASAny>) {
			GameClock.finishSetWebServerTime(param1);
			dbFacade.regenerateGameMaster();
			if (successCallback != null) {
				successCallback();
			}
		}, errorCallback);
	}

	static function parseLimitedOfferUsage(details:Array<ASAny>) {
		var _loc2_:ASObject = null;
		var _loc3_ = (0 : UInt);
		_loc3_ = (0 : UInt);
		while (_loc3_ < (details.length:UInt)) {
			_loc2_ = details[(_loc3_ : Int)];
			if (mLimitedOffers.hasKey(_loc2_.id)) {
				mLimitedOffers.replaceFor(_loc2_.id, _loc2_.usage_count);
			} else {
				mLimitedOffers.add(_loc2_.id, _loc2_.usage_count);
			}
			_loc3_++;
		}
	}

	public static function getOfferQuantitySold(gmOffer:GMOffer):UInt {
		var _loc2_:ASAny = mLimitedOffers.itemFor(gmOffer.Id);
		return _loc2_ == null ? (0 : UInt) : (ASCompat.toInt(_loc2_) : UInt);
	}

	public static function getLimitedOfferUsage(dbFacade:DBFacade, details:ASAny, successCallback:ASFunction, errorCallback:ASFunction) {
		var limitedOfferUsageFunc:ASFunction;
		Logger.debug("getLimitedOfferUsage");
		limitedOfferUsageFunc = JSONRPCService.getFunction("GetLimitedOfferStatus", dbFacade.rpcRoot + "store");
		limitedOfferUsageFunc(dbFacade.dbAccountInfo.id, function(param1:ASAny) {
			parseLimitedOfferUsage(ASCompat.coerce(param1, Array));
			if (successCallback != null) {
				successCallback(param1);
			}
		}, function(param1:Error) {
			if (errorCallback != null) {
				errorCallback(param1);
			}
		});
	}
}
