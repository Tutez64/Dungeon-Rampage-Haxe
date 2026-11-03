package gameMasterDictionary;

import brain.clock.GameClock;
import dBGlobals.As3Compat;
import dBGlobals.DBGlobal;
import flash.Boot;

class GMOffer {
	public static var BASIC_CURRENCY:String = "BASIC";

	public static var PREMIUM_CURRENCY:String = "PREMIUM";

	public static var DLC_CURRENCY:String = "DLC";

	public static var SPECIAL_NEW:String = "NEW";

	public static var SPECIAL_FEATURED:String = "FEATURED";

	public static var SPECIAL_SALE:String = "SALE";

	public var mSpecial:String;

	public var mPrice:UInt = 0;

	public var VisibleDate:Date;

	public var Tab:String;

	public var SteamAppId:UInt = 0;

	public var StartDate:Date;

	public var SoldOutDate:Date;

	public var SaleTargetOfferId:UInt = 0;

	public var SaleTargetOffer:GMOffer;

	public var SaleStartDate:Date;

	public var SalePercentOff:UInt = 0;

	public var SaleOffers:Vector<GMOffer>;

	public var SaleEndDate:Date;

	public var Rarity:String;

	public var OrigPriceA:UInt = 0;

	public var Location:String;

	public var LimitedQuantity:UInt = 0;

	public var IsCoinAltOffer:Bool = false;

	public var IsBundle:Bool = false;

	public var Id:UInt = 0;

	public var Gift:Bool = false;

	public var EndDate:Date;

	public var Details:Vector<GMOfferDetail>;

	public var CurrencyType:String;

	public var CoinOfferId:UInt = 0;

	public var CoinOffer:GMOffer;

	public var BundleSwfFilepath:String;

	public var BundleName:String;

	public var BundleIcon:String;

	public var BundleDescription:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null, splitTests:ASAny = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		BundleDescription = "";
		IsCoinAltOffer = false;
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		CurrencyType = jsonAsset.CurrencyType;
		determinePrice(jsonAsset, splitTests);
		Tab = jsonAsset.Tab;
		Location = jsonAsset.Location;
		CoinOfferId = (ASCompat.toInt(jsonAsset.CoinOfferId) : UInt);
		SaleTargetOfferId = (ASCompat.toInt(jsonAsset.SaleOffer) : UInt);
		IsBundle = ASCompat.toBool(jsonAsset.IsBundle);
		if (IsBundle) {
			BundleName = jsonAsset.BundleName;
			BundleIcon = jsonAsset.BundleIcon;
			BundleSwfFilepath = jsonAsset.BundleSwfFilepath;
			BundleDescription = jsonAsset.BundleDescription;
		}
		Rarity = jsonAsset.Rarity;
		if (As3Compat.truthy(jsonAsset.VisibleDate)) {
			VisibleDate = GameClock.parseW3CDTF(jsonAsset.VisibleDate);
		}
		if (As3Compat.truthy(jsonAsset.StartDate)) {
			StartDate = GameClock.parseW3CDTF(jsonAsset.StartDate);
		}
		if (As3Compat.truthy(jsonAsset.EndDate)) {
			EndDate = GameClock.parseW3CDTF(jsonAsset.EndDate);
		}
		if (As3Compat.truthy(jsonAsset.SoldOutDate)) {
			SoldOutDate = GameClock.parseW3CDTF(jsonAsset.SoldOutDate);
		}
		if (As3Compat.truthy(jsonAsset.SaleStartDate)) {
			SaleStartDate = GameClock.parseW3CDTF(jsonAsset.SaleStartDate);
		}
		if (As3Compat.truthy(jsonAsset.SaleEndDate)) {
			SaleEndDate = GameClock.parseW3CDTF(jsonAsset.SaleEndDate);
		}
		SalePercentOff = (ASCompat.toInt(jsonAsset.SalePercentOff) : UInt);
		LimitedQuantity = (ASCompat.toInt(jsonAsset.LimitedQuantity) : UInt);
		mSpecial = jsonAsset.Special;
		Gift = ASCompat.toBool(jsonAsset.Gift);
		Details = new Vector<GMOfferDetail>();
		SteamAppId = (ASCompat.toInt(jsonAsset.SteamAppId) : UInt);
	}

	public function isVisible():Bool {
		var _loc2_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc1_ = GameClock.getWebServerTime();
		if (VisibleDate != null) {
			_loc2_ = VisibleDate.getTime();
			if (_loc2_ > _loc1_) {
				return false;
			}
			if (SoldOutDate != null) {
				_loc3_ = SoldOutDate.getTime();
				if (_loc3_ < _loc1_) {
					return false;
				}
			} else if (EndDate != null) {
				_loc3_ = EndDate.getTime();
				if (_loc3_ < _loc1_) {
					return false;
				}
			}
			return true;
		}
		if (StartDate != null) {
			_loc2_ = StartDate.getTime();
			if (_loc2_ > _loc1_) {
				return false;
			}
			if (SoldOutDate != null) {
				_loc3_ = SoldOutDate.getTime();
				if (_loc3_ < _loc1_) {
					return false;
				}
			} else if (EndDate != null) {
				_loc3_ = EndDate.getTime();
				if (_loc3_ < _loc1_) {
					return false;
				}
			}
			return true;
		}
		return true;
	}

	public function isAvailableTime():Bool {
		var _loc2_ = Math.NaN;
		var _loc1_ = GameClock.getWebServerTime();
		if (StartDate != null) {
			_loc2_ = StartDate.getTime();
			if (_loc2_ > _loc1_) {
				return false;
			}
		}
		if (EndDate != null) {
			_loc2_ = EndDate.getTime();
			if (_loc2_ < _loc1_) {
				return false;
			}
		}
		return true;
	}

	public function get_percentOff():UInt {
		if (SaleTargetOffer != null && SalePercentOff != 0) {
			return SalePercentOff;
		}
		return (0 : UInt);
	}

	@:isVar public var percentOff(get, never):UInt;

	public function get_percentOff():UInt {
		return get_percentOff();
	}

	public function get_isSale():Bool {
		if (mSpecial != GMOffer.SPECIAL_SALE) {
			return mSpecial == GMOffer.SPECIAL_FEATURED;
		}
		return true;
	}

	@:isVar public var isSale(get, never):Bool;

	public function get_isSale():Bool {
		return get_isSale();
	}

	public function get_isOnSaleNow():GMOffer {
		var _loc4_ = 0;
		var _loc5_ = ASCompat.dynamicAs(null, GMOffer);
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		if (SaleOffers == null) {
			return null;
		}
		var _loc1_ = GameClock.getWebServerTime();
		var _loc2_ = 0;
		var _loc3_ = SaleOffers.length;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			_loc5_ = SaleOffers[_loc4_];
			if (!(_loc5_.SaleStartDate != null && _loc5_.SaleEndDate != null)) {
				return _loc5_;
			}
			_loc6_ = ASCompat.toNumber(_loc5_.SaleStartDate.getTime());
			_loc7_ = ASCompat.toNumber(_loc5_.SaleEndDate.getTime());
			if (_loc6_ < _loc1_ && _loc1_ < _loc7_) {
				return _loc5_;
			}
		}
		return null;
	}

	@:isVar public var isOnSaleNow(get, never):GMOffer;

	public function get_isOnSaleNow():GMOffer {
		return get_isOnSaleNow();
	}

	public function get_isNew():Bool {
		return mSpecial == GMOffer.SPECIAL_NEW;
	}

	@:isVar public var isNew(get, never):Bool;

	public function get_isNew():Bool {
		return get_isNew();
	}

	public function get_isFeatured():Bool {
		var _loc1_ = get_isOnSaleNow();
		if (_loc1_ != null && _loc1_.mSpecial == GMOffer.SPECIAL_FEATURED) {
			return true;
		}
		return mSpecial == GMOffer.SPECIAL_FEATURED;
	}

	@:isVar public var isFeatured(get, never):Bool;

	public function get_isFeatured():Bool {
		return get_isFeatured();
	}

	public function get_Special():Bool {
		var _loc1_ = ASCompat.asString(null);
		if (get_isFeatured()) {
			return true;
		}
		if (get_isOnSaleNow() != null && get_isSale()) {
			return true;
		}
		_loc1_ = mSpecial;
		if (_loc1_ != null) {
			return ASCompat.toNumberField(_loc1_, "length") > 0;
		}
		return false;
	}

	@:isVar public var Special(get, never):Bool;

	public function get_Special():Bool {
		return get_Special();
	}

	public function get_Price():Float {
		return mPrice;
	}

	@:isVar public var Price(get, never):Float;

	public function get_Price():Float {
		return get_Price();
	}

	public function getOfferItemConstant(gameMaster:GameMaster, defaultName:String = /*undefined*/ null, isLegendary:Bool = false):String {
		var _loc5_ = ASCompat.dynamicAs(null, GMOfferDetail);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, GMHero);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, GMWeaponItem);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, GMWeaponAesthetic);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, GMNpc);
		var _loc10_ = ASCompat.dynamicAs(null, GMSkin);
		var _loc11_ = false;
		if (defaultName == null) {
			defaultName = "";
		}
		var _loc4_ = defaultName;
		if (IsBundle) {
			_loc4_ = BundleName.toUpperCase();
		} else {
			_loc5_ = Details[0];
			if (ASCompat.toNumberField(_loc5_, "HeroId") != 0) {
				_loc6_ = gameMaster.heroById.itemFor(_loc5_.HeroId);
				if (_loc6_ != null) {
					_loc4_ = _loc6_.Constant;
				}
			} else if (ASCompat.toNumberField(_loc5_, "WeaponId") != 0) {
				_loc7_ = gameMaster.weaponItemById.itemFor(_loc5_.WeaponId);
				_loc8_ = _loc7_.getWeaponAesthetic(_loc5_.Level, isLegendary);
				_loc4_ = _loc8_.Constant;
			} else if (ASCompat.toNumberField(_loc5_, "PetId") != 0) {
				_loc9_ = gameMaster.npcById.itemFor(_loc5_.PetId);
				if (_loc9_ != null) {
					_loc4_ = _loc9_.Constant;
				}
			} else if (ASCompat.toNumberField(_loc5_, "SkinId") != 0) {
				_loc10_ = gameMaster.getSkinByType((ASCompat.toInt(_loc5_.SkinId) : UInt));
				if (_loc10_ != null) {
					_loc4_ = _loc10_.Constant;
				}
			} else {
				_loc11_ = ASCompat.toNumberField(_loc5_, "StackableId") != 0;
			}
		}
		return _loc4_;
	}

	public function getDisplayName(gameMaster:GameMaster, defaultName:String = /*undefined*/ null, isLegendary:Bool = false):String {
		var _loc5_ = ASCompat.dynamicAs(null, GMOfferDetail);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, GMHero);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, GMWeaponItem);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, GMWeaponAesthetic);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, GMNpc);
		var _loc10_ = ASCompat.dynamicAs(null, GMSkin);
		if (defaultName == null) {
			defaultName = "";
		}
		var _loc4_ = defaultName;
		if (IsBundle) {
			_loc4_ = BundleName.toUpperCase();
		} else {
			_loc5_ = Details[0];
			if (ASCompat.toNumberField(_loc5_, "HeroId") != 0) {
				_loc6_ = gameMaster.heroById.itemFor(_loc5_.HeroId);
				if (_loc6_ != null) {
					_loc4_ = Std.string(_loc6_.get_Name()).toUpperCase();
				}
			} else if (ASCompat.toNumberField(_loc5_, "WeaponId") != 0) {
				_loc7_ = gameMaster.weaponItemById.itemFor(_loc5_.WeaponId);
				_loc8_ = _loc7_.getWeaponAesthetic(_loc5_.Level, isLegendary);
				_loc4_ = Std.string(_loc8_.Name).toUpperCase();
			} else if (ASCompat.toNumberField(_loc5_, "PetId") != 0) {
				_loc9_ = gameMaster.npcById.itemFor(_loc5_.PetId);
				if (_loc9_ != null) {
					_loc4_ = Std.string(_loc9_.get_Name()).toUpperCase();
				}
			} else if (ASCompat.toNumberField(_loc5_, "SkinId") != 0) {
				_loc10_ = gameMaster.getSkinByType((ASCompat.toInt(_loc5_.SkinId) : UInt));
				if (_loc10_ != null) {
					_loc4_ = Std.string(_loc10_.get_Name()).toUpperCase();
				}
			}
		}
		return _loc4_;
	}

	public function determinePrice(jsonAsset:ASObject, splitTests:ASAny) {
		var _loc3_ = 0;
		var _loc4_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc5_:ASAny = null;
		OrigPriceA = (ASCompat.toInt(jsonAsset.Price) : UInt);
		mPrice = OrigPriceA;
		_loc3_ = 0;
		_loc4_ = As3Compat.values(splitTests);
		while (_loc3_ < ASCompat.toInt(_loc4_.length)) {
			_loc5_ = _loc4_[_loc3_];
			_loc3_++;
			if (_loc5_.name == "GemValue1" && CurrencyType == GMOffer.PREMIUM_CURRENCY) {
				mPrice = (ASCompat.floatToInt(Math.fceil(mPrice * As3Compat.toFloat(_loc5_.value))) : UInt);
			}
		}
		if (CurrencyType == GMOffer.PREMIUM_CURRENCY) {
			_loc3_ = 0;
			_loc4_ = As3Compat.values(splitTests);
			while (_loc3_ < ASCompat.toInt(_loc4_.length)) {
				_loc5_ = _loc4_[_loc3_];
				_loc3_++;
				if (_loc5_.name == "InDungeonHealthBombSale" && Id == DBGlobal.RESSURECTION_POTION_OFFER_ID) {
					mPrice = (ASCompat.floatToInt(Math.fceil(mPrice * As3Compat.toFloat(_loc5_.value))) : UInt);
				}
			}
		}
	}
}
