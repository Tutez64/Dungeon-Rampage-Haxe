package uI.shop;

import account.StoreServices;
import account.StoreServicesController;
import brain.assetRepository.AssetLoadingComponent;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphManager;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMRarity;
import uI.popup.DBUIOneButtonPopup;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.text.TextField;

class UIShopOffer extends UIObject {
	static inline final DEFAULT_SHOP_OFFER_SCALE:Float = 1.8;

	static inline final SHOP_OFFER_SCALE:Float = 1;

	static inline final DEFAULT_ROLL_OVER_SCALE:Float = 1.98;

	static inline final ROLL_OVER_SCALE:Float = 1.1;

	static inline final DAY_THRESHOLD_TO_ENUMERATE_DAYS_LEFT:Float = 8;

	static inline final ONE_DAY_MS:Float = 86400000;

	static inline final ONE_HOUR_MS:Float = 3600000;

	var mWantNewRollOverScale:Bool = false;

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mTitle:TextField;

	var mTitleY:Float = Math.NaN;

	var mRibbon:MovieClip;

	var mLevelStarLabel:TextField;

	var mOriginalPrice:TextField;

	var mStrikePrice:Sprite;

	var mCashIcon:MovieClip;

	var mGemIcon:MovieClip;

	var mCoinIcon:MovieClip;

	@:allow(UI.Shop) var mBuyButton:UIButton;

	@:allow(UI.Shop) var mBuyButtonCoin:UIButton;

	@:allow(UI.Shop) var mBuyButtonCash:UIButton;

	@:allow(UI.Shop) var mExclusiveOfferButton:UIButton;

	@:allow(UI.Shop) var mBuyButtonTimerBasedSale:UIButton;

	var mGiftIcon:MovieClip;

	var mIconParent:UIObject;

	var mIcon:MovieClip;

	var mBgIcon:MovieClip;

	var mBgIconBorder:MovieClip;

	var mBg:MovieClip;

	var mBgGrey:MovieClip;

	var mStar:MovieClip;

	var mRenderer:MovieClipRenderController;

	var mDescriptionLabel:TextField;

	var mLimitLabel:TextField;

	var mSaleLabel:TextField;

	var mRequiresLabel:TextField;

	var mAlreadyOwnedLabel:TextField;

	var mBuySuccessCallback:ASFunction;

	var mHeroRequiredLabel:MovieClip;

	var mGMOffer:GMOffer;

	var mSaleOffer:GMOffer;

	var mCoinOffer:GMOffer;

	var mCoinSaleOffer:GMOffer;

	var mGMHero:GMHero;

	var mNumSold:UInt = 0;

	var mUseIconScaling:Bool = false;

	var mStackCountTF:TextField;

	public function new(dbFacade:DBFacade, templateClass:Dynamic, buySuccessCallback:ASFunction = null, useIconScaling:Bool = true,
			wantNewRollOverScale:Bool = true) {
		mDBFacade = dbFacade;
		super(dbFacade, ASCompat.coerce(ASCompat.createInstance(templateClass, []), flash.display.MovieClip));
		mWantNewRollOverScale = wantNewRollOverScale;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mTitle = ASCompat.coerce((mRoot : ASAny).offer_title, flash.text.TextField);
		mTitleY = mTitle.y;
		mRibbon = ASCompat.coerce((mRoot : ASAny).ribbon, flash.display.MovieClip);
		mLevelStarLabel = ASCompat.coerce((mRoot : ASAny).level_star_label, flash.text.TextField);
		mOriginalPrice = ASCompat.coerce((mRoot : ASAny).buy_button.original_price, flash.text.TextField);
		mStrikePrice = ASCompat.coerce((mRoot : ASAny).buy_button.strike, flash.display.Sprite);
		mCashIcon = ASCompat.coerce((mRoot : ASAny).buy_button.icons_bundle.cash, flash.display.MovieClip);
		mGemIcon = ASCompat.coerce((mRoot : ASAny).buy_button.icons_bundle.gem, flash.display.MovieClip);
		mCoinIcon = ASCompat.coerce((mRoot : ASAny).buy_button.icons_bundle.coin, flash.display.MovieClip);
		mGiftIcon = ASCompat.coerce((mRoot : ASAny).buy_button.icons_bundle.gift_icon, flash.display.MovieClip);
		mStar = ASCompat.coerce((mRoot : ASAny).star, flash.display.MovieClip);
		mBg = ASCompat.coerce((mRoot : ASAny).bg, flash.display.MovieClip);
		mBgGrey = ASCompat.coerce((mRoot : ASAny).bg_grey, flash.display.MovieClip);
		mDescriptionLabel = ASCompat.coerce((mRoot : ASAny).description_label, flash.text.TextField);
		mLimitLabel = ASCompat.coerce((mRoot : ASAny).limit_label, flash.text.TextField);
		mSaleLabel = ASCompat.coerce((mRoot : ASAny).sale_label, flash.text.TextField);
		mRequiresLabel = ASCompat.coerce((mRoot : ASAny).requires_title, flash.text.TextField);
		mUseIconScaling = useIconScaling;
		mStackCountTF = ASCompat.coerce((mRoot : ASAny).number_label, flash.text.TextField);
		if (mStackCountTF != null) {
			mStackCountTF.visible = false;
		}
		mAlreadyOwnedLabel = ASCompat.coerce((mRoot : ASAny).already_owned_label, flash.text.TextField);
		mAlreadyOwnedLabel.visible = false;
		mHeroRequiredLabel = ASCompat.coerce((mRoot : ASAny).shop_herorequired, flash.display.MovieClip);
		Locale.setText(ASCompat.coerce((mHeroRequiredLabel : ASAny).hero_label, flash.text.TextField), "PURCHASE_HERO_BEFORE_BUYING_SYTLE_TAVERN_LABEL");
		mHeroRequiredLabel.visible = false;
		if (ASCompat.toBool((mRoot : ASAny).timer)) {
			ASCompat.setProperty((mRoot : ASAny).timer, "visible", false);
		}
		mBuyButtonCoin = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).buy_button_coins, flash.display.MovieClip));
		mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mBuyButtonCoin.releaseCallback = this.buyButtonCoinCallback;
		ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.cash, "visible", false);
		ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.gem, "visible", false);
		ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.gift_icon, "visible", false);
		ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "visible", false);
		ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "visible", false);
		mBuyButtonCash = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).buy_button_gems, flash.display.MovieClip));
		mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mBuyButtonCash.releaseCallback = this.buyButtonCallback;
		ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.coin, "visible", false);
		ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.cash, "visible", false);
		ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.gift_icon, "visible", false);
		ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "visible", false);
		ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "visible", false);
		mBuyButtonTimerBasedSale = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).buy_button_sale, flash.display.MovieClip));
		mBuyButtonTimerBasedSale.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mBuyButtonTimerBasedSale.releaseCallback = this.buyButtonCallback;
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.coin, "visible", false);
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.cash, "visible", false);
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.gift_icon, "visible", false);
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "visible", false);
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "visible", false);
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "mouseEnabled", false);
		ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "mouseEnabled", false);
		mBuyButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).buy_button, flash.display.MovieClip));
		mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mBuySuccessCallback = buySuccessCallback;
		mBuyButton.releaseCallback = this.buyButtonCallback;
		mExclusiveOfferButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).exclusive_offer, flash.display.MovieClip));
		mExclusiveOfferButton.releaseCallback = buyButtonCallback;
		mIconParent = new UIObject(mDBFacade, ASCompat.coerce((mRoot : ASAny).icon, flash.display.MovieClip));
		mBuyButtonTimerBasedSale.visible = false;
		if (!mDBFacade.dbConfigManager.getConfigBoolean("want_skins", true)) {
			ASCompat.setProperty((mRoot : ASAny).required_text, "visible", false);
			ASCompat.setProperty((mRoot : ASAny).shop_herorequired, "visible", false);
		}
	}

	@:isVar public var navigationButton(get, never):UIButton;

	public function get_navigationButton():UIButton {
		var _loc2_:Array<ASAny> = [
			mBuyButton,
			mBuyButtonCoin,
			mBuyButtonCash,
			mExclusiveOfferButton,
			mBuyButtonTimerBasedSale
		];
		var _loc1_:UIButton;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc1_ = ASCompat.coerce(_tmp_, brain.uI.UIButton);
				if (_loc1_ != null && _loc1_.canBeFocused()) {
					return _loc1_;
				}
			}
		return null;
	}

	function buyButtonCallback() {
		return this.buyButtonInternal(this.offer);
	}

	function buyButtonCoinCallback() {
		return this.buyButtonInternal(this.coinOffer);
	}

	function buyButtonInternal(buyOffer:GMOffer) {
		var popup:DBUIOneButtonPopup;
		var callback = mBuySuccessCallback;
		if (buyOffer == null) {
			return;
		}
		if (mGMOffer.CurrencyType == GMOffer.DLC_CURRENCY) {
			mDBFacade.overlaySteamBasedOnAppId(mGMOffer.SteamAppId);
			return;
		}
		if (IsCashPageExclusiveOffer()) {
			StoreServicesController.showCashPage(mDBFacade, "shopBuyButtonExclusiveOfferDragonKnight");
		} else if (this.canBuyOffer()) {
			StoreServicesController.tryBuyOffer(mDBFacade, buyOffer, function(param1:ASAny) {
				if (mDBFacade != null && buyOffer.Tab != "KEY") {
					showOffer(buyOffer, mGMHero);
				}
				if (callback != null) {
					callback(buyOffer);
				}
			});
		} else if (this.canGiftOffer()) {
			popup = new DBUIOneButtonPopup(mDBFacade, "SHOP_GIFT_CONFIRM_POPUP", Locale.getString("SHOP_GIFT_CONFIRM_TITLE"),
				Locale.getString("SHOP_GIFT_CONFIRM_DESC"), Locale.getString("OK"), null);
			MemoryTracker.track(popup, "DBUIOneButtonPopup - created in UIShopOffer.buyOffer()");
			if (callback != null) {
				callback(buyOffer);
			}
		} else {
			Logger.warn("Offer that you cannot buy or gift: " + Std.string(buyOffer.Id));
		}
	}

	override public function destroy() {
		mDBFacade = null;
		mBuySuccessCallback = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mBuyButton.destroy();
		mBuyButton = null;
		mExclusiveOfferButton.destroy();
		mExclusiveOfferButton = null;
		mBuyButtonCash.destroy();
		mBuyButtonCash = null;
		mBuyButtonCoin.destroy();
		mBuyButtonCoin = null;
		mBuyButtonTimerBasedSale.destroy();
		mBuyButtonTimerBasedSale = null;
		mIconParent.destroy();
		mIconParent = null;
		mBgIcon = null;
		mIcon = null;
		if (mRenderer != null) {
			mRenderer.destroy();
			mRenderer = null;
		}
		super.destroy();
	}

	override function onRollOver(event:MouseEvent) {
		super.onRollOver(event);
		if (mWantNewRollOverScale) {
			mRoot.scaleX = mRoot.scaleY = 1.98;
		} else {
			mRoot.scaleX = mRoot.scaleY = 1.1;
		}
	}

	override function onRollOut(event:MouseEvent) {
		super.onRollOut(event);
		if (mWantNewRollOverScale) {
			mRoot.scaleX = mRoot.scaleY = 1.8;
		} else {
			mRoot.scaleX = mRoot.scaleY = 1;
		}
	}

	function getQuantityString():String {
		var _loc1_ = 0;
		if (this.offer.LimitedQuantity > 0) {
			if (mNumSold >= this.offer.LimitedQuantity) {
				return Locale.getString("SHOP_SOLD_OUT");
			}
			_loc1_ = (this.offer.LimitedQuantity - mNumSold:Int);
			return Std.string(_loc1_) + Locale.getString("SHOP_REMAINING");
		}
		return "";
	}

	function getDateString():String {
		var _loc6_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = getStartDate();
		var _loc3_ = getEndDate();
		var _loc4_ = getSoldOutDate();
		var _loc10_ = GameClock.getWebServerTime();
		if (_loc9_ != null) {
			_loc6_ = _loc9_.getTime();
			if (_loc6_ > _loc10_) {
				return Locale.getString("SHOP_COMING_SOON");
			}
		}
		if (_loc4_ != null) {
			_loc2_ = _loc4_.getTime();
			if (_loc2_ < _loc10_) {
				return Locale.getString("SHOP_SOLD_OUT");
			}
		}
		if (_loc3_ != null) {
			_loc7_ = _loc3_.getTime();
			if (_loc7_ < _loc10_) {
				return Locale.getString("SHOP_SOLD_OUT");
			}
			_loc5_ = _loc7_ - _loc10_;
			_loc1_ = _loc5_ / 86400000;
			if (_loc1_ > 8) {
				return Locale.getString("LIMITED_TIME_OFFER");
			}
			if (_loc1_ > 2) {
				return Std.string(Math.ffloor(_loc1_)) + Locale.getString("SHOP_DAYS_LEFT");
			}
			if (_loc1_ > 1) {
				return Std.string(Math.ffloor(_loc1_)) + Locale.getString("SHOP_DAY_LEFT");
			}
			_loc8_ = _loc5_ / 3600000;
			if (_loc8_ > 2) {
				return Std.string(Math.ffloor(_loc8_)) + Locale.getString("SHOP_HOURS_LEFT");
			}
			if (_loc8_ > 1) {
				return Std.string(Math.ffloor(_loc8_)) + Locale.getString("SHOP_HOUR_LEFT");
			}
			return Locale.getString("SHOP_ALMOST_GONE");
		}
		return "";
	}

	@:isVar var offerDescription(get, never):String;

	function get_offerDescription():String {
		return "";
	}

	@:isVar var offerIconName(get, never):String;

	function get_offerIconName():String {
		return "";
	}

	@:isVar var offerSwfPath(get, never):String;

	function get_offerSwfPath():String {
		return "";
	}

	function getTextRarityColor():UInt {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null && _loc1_.TextColor != 0 ? _loc1_.TextColor : (15463921 : UInt);
	}

	@:isVar var hasColoredBackground(get, never):Bool;

	function get_hasColoredBackground():Bool {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.HasColoredBackground : false;
	}

	@:isVar var backgroundIconName(get, never):String;

	function get_backgroundIconName():String {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundIcon : "";
	}

	@:isVar var backgroundIconBorderName(get, never):String;

	function get_backgroundIconBorderName():String {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundIconBorder : "";
	}

	@:isVar var backgroundSwfPath(get, never):String;

	function get_backgroundSwfPath():String {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundSwf : "";
	}

	function loadOfferIcon() {
		var bgColoredExists:Bool;
		var bgSwfPath:String;
		var bgIconName:String;
		var bgIconBorderName:String;
		var swfPath:String;
		var iconName:String;
		if (mRenderer != null) {
			mRenderer.destroy();
			mRenderer = null;
		}
		if (mBgIcon != null && mBgIcon.parent != null) {
			mBgIcon.parent.removeChild(mBgIcon);
			mBgIcon = null;
		}
		if (mBgIconBorder != null && mBgIconBorder.parent != null) {
			mBgIconBorder.parent.removeChild(mBgIconBorder);
			mBgIconBorder = null;
		}
		if (mIcon != null && mIcon.parent != null) {
			mIcon.parent.removeChild(mIcon);
			mIcon = null;
		}
		bgColoredExists = this.hasColoredBackground;
		bgSwfPath = this.backgroundSwfPath;
		bgIconName = this.backgroundIconName;
		bgIconBorderName = this.backgroundIconBorderName;
		swfPath = this.offerSwfPath;
		iconName = this.offerIconName;
		if (ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName)) {
			if (bgColoredExists) {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath), function(param1:brain.assetRepository.SwfAsset) {
					var _loc3_ = param1.getClass(bgIconBorderName);
					if (_loc3_ != null) {
						mBgIconBorder = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
						mIconParent.root.addChild(mBgIconBorder);
					}
					var _loc2_ = param1.getClass(bgIconName);
					if (_loc2_ != null) {
						mBgIcon = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
						mRenderer = new MovieClipRenderController(mDBFacade, mBgIcon);
						mRenderer.play((0 : UInt), true);
						if (mBgIconBorder != null) {
							mBgIconBorder.addChild(mBgIcon);
						} else {
							mIconParent.root.addChild(mBgIcon);
						}
					}
				});
			}
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath), function(param1:brain.assetRepository.SwfAsset) {
				var _loc2_ = param1.getClass(iconName);
				if (_loc2_ != null) {
					mIcon = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
					mRenderer = new MovieClipRenderController(mDBFacade, mIcon);
					mRenderer.play((0 : UInt), true);
					if (mUseIconScaling) {
						mIcon.scaleX = mIcon.scaleY = 72 / nativeIconSize;
					}
					mIconParent.root.addChild(mIcon);
				}
			});
		}
	}

	@:isVar var nativeIconSize(get, never):Float;

	function get_nativeIconSize():Float {
		return DBGlobal.WEAPON_ICON_NATIVE_SIZE;
	}

	function hasRequirements():Bool {
		return false;
	}

	@:isVar var nodesToGrey(get, never):Vector<DisplayObject>;

	function get_nodesToGrey():Vector<DisplayObject> {
		return Vector.ofArray(([
			mBg,
			mIconParent.root,
			mRibbon,
			mBuyButton.root,
			mBuyButtonCash.root,
			mBuyButtonCoin.root,
			mBuyButtonTimerBasedSale.root,
			mStar
		] : Array<DisplayObject>));
	}

	function greyOffer(value:Bool) {
		var _loc3_:DisplayObject;
		var __ax4_iter_428:Vector<DisplayObject>;
		var _loc2_:ColorMatrixFilter = null;
		if (value) {
			_loc2_ = SceneGraphManager.getGrayScaleSaturationFilter(5);
			__ax4_iter_428 = this.nodesToGrey;
			if (checkNullIteratee(__ax4_iter_428))
				for (_tmp_ in __ax4_iter_428) {
					_loc3_ = _tmp_;
					if (_loc3_ != null) {
						_loc3_.filters = cast([_loc2_]);
					}
				}
			if (mBgGrey != null) {
				mBg.visible = false;
				mBgGrey.visible = true;
				mBgGrey.filters = cast([_loc2_]);
			}
			mLevelStarLabel.textColor = mRequiresLabel.textColor = (15535124 : UInt);
			if (mDescriptionLabel != null) {
				mDescriptionLabel.textColor = (15535124 : UInt);
			}
			mTitle.textColor = (8947848 : UInt);
		}
	}

	function shouldGreyOffer(gmHero:GMHero):Bool {
		return false;
	}

	@:isVar var coinOffer(get, never):GMOffer;

	function get_coinOffer():GMOffer {
		return mCoinSaleOffer != null ? mCoinSaleOffer : mCoinOffer;
	}

	@:isVar var offer(get, set):GMOffer;

	function get_offer():GMOffer {
		return mSaleOffer != null ? mSaleOffer : mGMOffer;
	}

	public function getVisibleDate():Date {
		return mGMOffer.VisibleDate;
	}

	public function getStartDate():Date {
		return mGMOffer.StartDate;
	}

	public function getEndDate():Date {
		return mGMOffer.EndDate;
	}

	public function getSoldOutDate():Date {
		return mGMOffer.SoldOutDate;
	}

	function set_offer(value:GMOffer):GMOffer {
		mGMOffer = value;
		mSaleOffer = mGMOffer.isOnSaleNow;
		mCoinOffer = mGMOffer.CoinOffer;
		mCoinSaleOffer = ASCompat.coerce(mCoinOffer != null ? mCoinOffer.isOnSaleNow : null, gameMasterDictionary.GMOffer);
		return value;
	}

	public function showOffer(gmOffer:GMOffer, gmHero:GMHero) {
		var _loc5_ = false;
		var _loc6_ = false;
		var _loc7_ = false;
		this.offer = gmOffer;
		mGMHero = gmHero;
		var _loc9_:String = null;
		if (gmOffer.Details[0].HeroId != 0 || gmOffer.Details[0].SkinId != 0) {
			_loc9_ = GameMasterLocale.getGameMasterSubString("SKIN_NAME", this.offer.getOfferItemConstant(mDBFacade.gameMaster));
		} else if (gmOffer.Details[0].PetId != 0) {
			_loc9_ = GameMasterLocale.getGameMasterSubString("PET_NAME", this.offer.getOfferItemConstant(mDBFacade.gameMaster));
		} else if (gmOffer.Details[0].WeaponId == 0) {
			if (gmOffer.Details[0].OfferId != 0) {
				_loc9_ = GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_NAME", Std.string(this.offer.Id));
			} else {
				Logger.debug(Std.string(gmOffer.Id));
			}
		}
		if (_loc9_ != null) {
			TextUtil.setText(mTitle, _loc9_, 1.45);
			TextUtil.fitToField(mTitle);
		}
		mTitle.textColor = this.getTextRarityColor();
		var _loc10_ = mTitle.getLineMetrics(0);
		var _loc4_ = mTitle.numLines == 1 ? _loc10_.ascent + _loc10_.descent : mTitle.textHeight;
		mTitle.y = mTitleY + Math.max(0, mTitle.height - (_loc4_ + 4) * mTitle.scaleY) / 2;
		loadOfferIcon();
		if (gmOffer.Details.length > 0) {
			if (gmOffer.Details[0].StackableId != 0) {
				mStackCountTF.visible = true;
				TextUtil.setText(mStackCountTF, "x" + Std.string(gmOffer.Details[0].StackableCount));
			}
		}
		Locale.setText(mRequiresLabel, "REQUIRES");
		mRequiresLabel.visible = this.hasRequirements();
		if (mDescriptionLabel != null) {
			TextUtil.setText(mDescriptionLabel, this.offerDescription, 1.55);
		}
		if (IsCashPageExclusiveOffer()) {
			mBuyButton.visible = false;
			mExclusiveOfferButton.visible = true;
			Locale.setText(mExclusiveOfferButton.label, "UI_SHOP_CASH_PAGE_EXCLUSIVE");
			mBuyButtonCoin.visible = false;
			mBuyButtonCash.visible = false;
			ASCompat.setProperty((mRoot : ASAny).label_or, "visible", false);
		} else if (this.coinOffer != null) {
			mBuyButton.visible = false;
			mBuyButtonCoin.visible = true;
			mBuyButtonCash.visible = true;
			ASCompat.setProperty((mRoot : ASAny).label_or, "visible", true);
			mExclusiveOfferButton.visible = false;
			TextUtil.setText(mBuyButtonCash.label, this.offer.Price > 0 ? Std.string(this.offer.Price) : Locale.getString("SHOP_FREE"));
			TextUtil.setText(mBuyButtonCoin.label, this.coinOffer.Price > 0 ? Std.string(this.coinOffer.Price) : Locale.getString("SHOP_FREE"));
		} else {
			mBuyButton.visible = true;
			mBuyButtonCoin.visible = false;
			mBuyButtonCash.visible = false;
			ASCompat.setProperty((mRoot : ASAny).label_or, "visible", false);
			mExclusiveOfferButton.visible = false;
			TextUtil.setText(mBuyButton.label, this.offer.Price > 0 ? Std.string(this.offer.Price) : Locale.getString("SHOP_FREE"));
			if (this.offer.CurrencyType == GMOffer.DLC_CURRENCY) {
				Locale.setText(mBuyButton.label, "BUY");
			}
		}
		if (mSaleOffer != null) {
			ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", true);
			ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", true);
			ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", false);
			if (mSaleOffer.percentOff != 0) {
				mSaleLabel.visible = true;
				TextUtil.setText(mSaleLabel, Std.string(mSaleOffer.percentOff) + Locale.getString("SHOP_PERCENT_OFF"));
				mOriginalPrice.visible = true;
				TextUtil.setText(mOriginalPrice, Std.string(mGMOffer.Price));
				mStrikePrice.visible = true;
				mStrikePrice.width = mOriginalPrice.textWidth + 4;
			} else {
				mStrikePrice.visible = false;
				mSaleLabel.visible = false;
				mOriginalPrice.visible = false;
			}
			ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "visible", true);
			TextUtil.setText(ASCompat.coerce((mBuyButtonTimerBasedSale.root : ASAny).original_price, flash.text.TextField), Std.string(mGMOffer.Price));
			ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "visible", true);
			ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "width", (mBuyButtonTimerBasedSale.root : ASAny).original_price.textWidth
				+ 4);
			if (mCoinOffer != null && mCoinSaleOffer != null && mCoinOffer.Price != mCoinSaleOffer.Price) {
				ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "visible", true);
				TextUtil.setText(ASCompat.coerce((mBuyButtonCoin.root : ASAny).original_price, flash.text.TextField), Std.string(mCoinOffer.Price));
				ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "visible", true);
				ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "width", (mBuyButtonCoin.root : ASAny).original_price.textWidth + 4);
			}
			ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "visible", true);
			TextUtil.setText(ASCompat.coerce((mBuyButtonCash.root : ASAny).original_price, flash.text.TextField), Std.string(mGMOffer.Price));
			ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "visible", true);
			ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "width", (mBuyButtonCash.root : ASAny).original_price.textWidth + 4);
		} else {
			if (mGMOffer.LimitedQuantity > 0) {
				ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", true);
				ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", false);
				Locale.setText(ASCompat.coerce((mRoot : ASAny).new_ribbon_label, flash.text.TextField), "SHOP_RARE");
				ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", true);
			} else if (mGMOffer.isNew) {
				ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", true);
				ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", false);
				Locale.setText(ASCompat.coerce((mRoot : ASAny).new_ribbon_label, flash.text.TextField), "SHOP_NEW");
				ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", true);
			} else {
				ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", false);
				ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", false);
				ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", false);
			}
			mOriginalPrice.visible = false;
			mStrikePrice.visible = false;
			mSaleLabel.visible = false;
		}
		if (this.offer.LimitedQuantity > 0) {
			mNumSold = StoreServices.getOfferQuantitySold(this.offer);
		}
		var _loc12_ = this.canBuyOffer();
		var _loc11_ = this.canGiftOffer();
		if (_loc11_) {
			mGiftIcon.visible = true;
			mCashIcon.visible = false;
			mGemIcon.visible = false;
			mCoinIcon.visible = false;
		} else {
			mGiftIcon.visible = false;
			_loc5_ = this.offer.Price > 0 && this.offer.CurrencyType == GMOffer.PREMIUM_CURRENCY;
			_loc6_ = this.offer.Price > 0 && this.offer.CurrencyType == GMOffer.BASIC_CURRENCY;
			_loc7_ = this.offer.Price > 0 && this.offer.CurrencyType == GMOffer.DLC_CURRENCY;
			mGemIcon.visible = _loc5_;
			mCoinIcon.visible = _loc6_;
			mCashIcon.visible = _loc7_;
			ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.gem, "visible", _loc5_);
			ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.coin, "visible", _loc6_);
			ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.cash, "visible", _loc7_);
		}
		var _loc8_ = StoreServicesController.getOfferLevelReq(mDBFacade, this.offer);
		TextUtil.setText(mLevelStarLabel, Std.string(_loc8_));
		mLevelStarLabel.visible = mStar.visible = false;
		if (getStartDate() != null || getEndDate() != null) {
			if (ASCompat.toBool((mRoot : ASAny).timer)) {
				ASCompat.setProperty((mRoot : ASAny).timer, "visible", true);
				TextUtil.setText(ASCompat.coerce((mRoot : ASAny).timer, flash.text.TextField), getDateString());
			}
			mBuyButton.visible = false;
			if (this.coinOffer != null) {
				mBuyButtonCoin.visible = true;
				mBuyButtonCash.visible = true;
				mBuyButtonTimerBasedSale.visible = false;
			} else {
				mBuyButtonCoin.visible = false;
				mBuyButtonCash.visible = false;
				mBuyButtonTimerBasedSale.visible = true;
				TextUtil.setText(mBuyButtonTimerBasedSale.label, Std.string(this.offer.Price));
			}
		}
		if (this.offer.LimitedQuantity > 0) {
			if (mLimitLabel != null) {
				mLimitLabel.visible = true;
				TextUtil.setText(mLimitLabel, getQuantityString());
			}
		} else if (mLimitLabel != null) {
			mLimitLabel.visible = false;
		}
		mAlreadyOwnedLabel.visible = !this.requirementsMetForPurchase();
		var _loc3_ = _loc12_ || _loc11_;
		mBuyButton.enabled = _loc3_;
		mBuyButtonCoin.enabled = _loc3_;
		mBuyButtonCash.enabled = _loc3_;
		mBuyButtonTimerBasedSale.enabled = _loc3_;
		this.greyOffer(!_loc12_ && !_loc11_ || this.shouldGreyOffer(mGMHero));
	}

	function requirementsMetForPurchase():Bool {
		return false;
	}

	function isAvailableTime():Bool {
		if (mGMOffer.SaleOffers != null && mGMOffer.SaleOffers.length > 0) {
			return mGMOffer.SaleOffers[0].isAvailableTime();
		}
		return this.offer.isAvailableTime();
	}

	function isAvailableQuantity():Bool {
		if (this.offer.LimitedQuantity != 0 && mNumSold >= this.offer.LimitedQuantity) {
			return false;
		}
		return true;
	}

	function canBuyOffer():Bool {
		if (this.offer.Gift) {
			return false;
		}
		if (!this.isAvailableTime()) {
			return false;
		}
		if (!this.requirementsMetForPurchase()) {
			return false;
		}
		if (!this.isAvailableQuantity()) {
			return false;
		}
		return true;
	}

	function IsCashPageExclusiveOffer():Bool {
		return false;
	}

	function canGiftOffer():Bool {
		if (!this.offer.Gift) {
			return false;
		}
		if (!this.isAvailableTime()) {
			return false;
		}
		if (!this.isAvailableQuantity()) {
			return false;
		}
		return true;
	}

	public function getPrimaryBuyButton():UIButton {
		if (mBuyButton.visible) {
			return mBuyButton;
		}
		if (mBuyButtonCoin.visible) {
			return mBuyButtonCoin;
		}
		if (mBuyButtonCash.visible) {
			return mBuyButtonCash;
		}
		if (mBuyButtonTimerBasedSale.visible) {
			return mBuyButtonTimerBasedSale;
		}
		if (mExclusiveOfferButton.visible) {
			return mExclusiveOfferButton;
		}
		return null;
	}
}
