package uI.training;

import account.AvatarInfo;
import account.StoreServicesController;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.sceneGraph.SceneGraphManager;
import brain.uI.UIButton;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import dBGlobals.DBGlobal;
import events.DBAccountResponseEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMSkin;
import town.TownHeader;
import uI.equipPicker.HeroWithEquipPicker;
import uI.popup.UIRetrainPopup;
import uI.UITownTweens;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

class UIHeroTraining {
	static var RESPEC_OFFER_ID:UInt = (51303 : UInt);

	var mDBFacade:DBFacade;

	var mLastHeroId:UInt = 0;

	var mFakeHeroInfo:AvatarInfo;

	var mHeroInfo:AvatarInfo;

	var mSelectedHero:GMHero;

	var mHeroWithEquipPicker:HeroWithEquipPicker;

	var mSceneGraphComponent:SceneGraphComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mAssetsLoaded:Bool = false;

	var mIconSwfAsset:SwfAsset;

	var mUIRoot:MovieClip;

	var mTownHeader:TownHeader;

	var mHeroPortrait:MovieClip;

	var mHeroPortraitText:TextField;

	var mHeroLevelText:TextField;

	var mHeroPortraitBounds:Rectangle;

	var mStatHelpers:Vector<UIStatHelper>;

	var mStatLevelPlusButtons:Vector<UIStatUpgradeButton>;

	var mStatLevelPlusTooltips:Vector<UIStatUpgradeTooltip>;

	var mStatUpgradeDifferenceHelpers:Vector<UIStatUpgradeDifferenceHelper>;

	var mHeroLevel:UInt = 0;

	var mBasicCurrencyText:TextField;

	var mPremiumCurrencyText:TextField;

	var mSpendButton:UIButton;

	var mSpendAmount:Int = 0;

	var mPendingDBWrite:Bool = false;

	var mResetButton:UIButton;

	var mGMOffer:GMOffer;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, rootClip:MovieClip, townHeader:TownHeader, isActiveCallback:ASFunction = null) {
		mDBFacade = dbFacade;
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIHeroTraining");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "UIHeroTraining");
		mEventComponent = new EventComponent(mDBFacade);
		mTownHeader = townHeader;
		var _loc7_ = swfAsset.getClass("DR_weapon_tooltip");
		var _loc8_ = swfAsset.getClass("avatar_tooltip");
		mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade, ASCompat.coerce((rootClip : ASAny).hero_picker, flash.display.MovieClip), _loc7_, _loc8_,
			heroSelected, null, null, null, null, false, true, isActiveCallback);
		var _loc6_:ASObject = {"avatar_id": 103};
		mFakeHeroInfo = new AvatarInfo(mDBFacade, _loc6_, null);
		this.setupUI(rootClip, swfAsset.getClass("stat_tooltip"));
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Stats/db_icon_stats.swf"), setupIcons);
		mGMOffer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(RESPEC_OFFER_ID), gameMasterDictionary.GMOffer);
	}

	function setupUI(rootClip:MovieClip, tooltipClass:Dynamic) {
		var createFunc:ASFunction;
		var listOfStatUpgrades:Array<ASAny>;
		var listOfStatPlusButtons:Array<ASAny>;
		var i:Int;
		var buttonBounds:Rectangle;
		mUIRoot = ASCompat.coerce((rootClip : ASAny).training_main, flash.display.MovieClip);
		mHeroPortrait = ASCompat.coerce((rootClip : ASAny).training_avatar, flash.display.MovieClip);
		mHeroPortraitText = ASCompat.coerce((rootClip : ASAny).hero_text, flash.text.TextField);
		mHeroLevelText = ASCompat.coerce((rootClip : ASAny).xp_label.level_label, flash.text.TextField);
		mHeroPortraitBounds = ASCompat.coerce((rootClip : ASAny).skin_frame.getBounds(mHeroPortrait), flash.geom.Rectangle);
		mHeroPortraitBounds.inflate(0, -6);
		mHeroPortraitBounds.bottom -= 1;
		mStatHelpers = new Vector<UIStatHelper>();
		mStatLevelPlusButtons = new Vector<UIStatUpgradeButton>();
		mStatLevelPlusTooltips = new Vector<UIStatUpgradeTooltip>();
		mStatUpgradeDifferenceHelpers = new Vector<UIStatUpgradeDifferenceHelper>();
		createFunc = function(param1:Int):ASFunction {
			var i = param1;
			return function() {
				statPlusReleased(i);
			};
		};
		listOfStatUpgrades = [
			(mUIRoot : ASAny)
			.UI_statupgrade1,
			(mUIRoot : ASAny)
			.UI_statupgrade2,
			(mUIRoot : ASAny)
			.UI_statupgrade3,
			(mUIRoot : ASAny)
			.UI_statupgrade4
		];
		listOfStatPlusButtons = [
			(mUIRoot : ASAny)
			.statupgrade1_plus_button,
			(mUIRoot : ASAny)
			.statupgrade2_plus_button,
			(mUIRoot : ASAny)
			.statupgrade3_plus_button,
			(mUIRoot : ASAny)
			.statupgrade4_plus_button
		];
		i = 0;
		while (i < 4) {
			mStatHelpers.push(new UIStatHelper(mDBFacade, tooltipClass, ASCompat.coerce(listOfStatUpgrades[i], flash.display.MovieClip)));
			mStatLevelPlusButtons.push(new UIStatUpgradeButton(mDBFacade, ASCompat.coerce(listOfStatPlusButtons[i], flash.display.MovieClip)));
			mStatLevelPlusTooltips.push(new UIStatUpgradeTooltip(tooltipClass));
			mStatUpgradeDifferenceHelpers.push(new UIStatUpgradeDifferenceHelper(mDBFacade));
			mStatLevelPlusButtons[i].tooltip = mStatLevelPlusTooltips[i];
			buttonBounds = ASCompat.coerce(listOfStatPlusButtons[i].getBounds(listOfStatPlusButtons[i]), flash.geom.Rectangle);
			mStatLevelPlusButtons[i].tooltipPos = new Point((buttonBounds.left + buttonBounds.right) * 0.5, buttonBounds.top);
			mStatLevelPlusButtons[i].releaseCallback = ASCompat.coerceFunction(createFunc(i));
			i = i + 1;
		}
		mSpendButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).spend_button, flash.display.MovieClip));
		mSpendButton.enabled = false;
		Locale.setText(ASCompat.coerce((mSpendButton.root : ASAny).button_text, flash.text.TextField), "TRAINING_POINTS");
		mResetButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).reset_button, flash.display.MovieClip));
		Locale.setText(mResetButton.label, "RETRAIN");
		mResetButton.releaseCallback = function() {
			resetReleased();
		};
		disableHud();
	}

	public function animateEntry() {
		if (mDBFacade.featureFlags.getFlagValue("want-town-animations")) {
			UITownTweens.avatarFadeInTweenSequence(mHeroPortrait, mDBFacade);
			mTownHeader.rootMovieClip.visible = false;
			mLogicalWorkComponent.doLater(0.20833333333333334, function(param1:brain.clock.GameClock) {
				mTownHeader.animateHeader();
			});
			mUIRoot.visible = false;
			mLogicalWorkComponent.doLater(0.16666666666666666, function(param1:brain.clock.GameClock) {
				UITownTweens.rightPanelTweenSequence(mUIRoot, mDBFacade);
			});
			mHeroWithEquipPicker.visible = false;
			mLogicalWorkComponent.doLater(0.5, function(param1:brain.clock.GameClock) {
				UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root, mDBFacade);
			});
		}
		setupMenuNavigation();
		setButtonNavigationFilters();
	}

	public function setupIcons(swfAsset:SwfAsset) {
		mAssetsLoaded = true;
		mIconSwfAsset = swfAsset;
	}

	public function destroy() {
		var _loc1_ = 0;
		mDBFacade = null;
		mFakeHeroInfo.destroy();
		_loc1_ = 0;
		while (_loc1_ < 4) {
			mStatHelpers[_loc1_].destroy();
			mStatLevelPlusButtons[_loc1_].destroy();
			mStatLevelPlusTooltips[_loc1_].destroy();
			mStatUpgradeDifferenceHelpers[_loc1_].destroy();
			_loc1_++;
		}
		mSpendButton.destroy();
		mResetButton.destroy();
		mHeroWithEquipPicker.destroy();
		mLogicalWorkComponent.destroy();
		mSceneGraphComponent.destroy();
		mAssetLoadingComponent.destroy();
		mEventComponent.destroy();
		mTownHeader = null;
	}

	public function enableHud() {
		mTownHeader.title = Locale.getString("TRAINING_HEADER");
		mPendingDBWrite = false;
		mEventComponent.removeAllListeners();
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", dbAccountInfoUpdate);
		mHeroWithEquipPicker.refresh(true);
		mHeroInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
		mSelectedHero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mHeroInfo.avatarType), gameMasterDictionary.GMHero);
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mSelectedHero.Id);
		this.heroSelected(mSelectedHero, _loc2_);
		mUIRoot.visible = true;
		mHeroPortrait.visible = true;
		var _loc1_:UIStatHelper;
		final __ax4_iter_0 = mStatHelpers;
		if (checkNullIteratee(__ax4_iter_0))
			for (_tmp_ in __ax4_iter_0) {
				_loc1_ = _tmp_;
				mDBFacade.steamAchievementsHelper.unlockUpgradeStat(_loc1_.amount);
			}
	}

	public function disableHud() {
		mEventComponent.removeAllListeners();
		mUIRoot.visible = false;
		mHeroPortrait.visible = false;
		mHeroWithEquipPicker.setAvatarAlert(false);
		resetMenuNavigation();
	}

	function greyHero(value:Bool) {
		var _loc4_ = Vector.ofArray(([mUIRoot] : Array<DisplayObject>));
		var _loc2_ = SceneGraphManager.getGrayScaleSaturationFilter(5);
		var _loc3_:DisplayObject;
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc3_ = _tmp_;
				_loc3_.filters = cast(value ? [_loc2_] : []);
			}
	}

	function shouldGreyHero(gmHero:GMHero):Bool {
		return false;
	}

	function writeStatsToDatabase() {
		mHeroInfo.RPC_updateAvatarSlots(mStatHelpers[0].amount, mStatHelpers[1].amount, mStatHelpers[2].amount, mStatHelpers[3].amount, null, null);
		mPendingDBWrite = false;
	}

	function heroSelected(gmHero:GMHero, owned:Bool) {
		var gmSkin:GMSkin;
		var avatarJson:ASObject;
		if (gmHero == null) {
			return;
		}
		if (mPendingDBWrite) {
			writeStatsToDatabase();
		}
		greyHero(!owned);
		mSelectedHero = gmHero;
		mHeroInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id);
		if (mHeroInfo == null) {
			avatarJson = {"avatar_id": mSelectedHero.Id};
			mFakeHeroInfo.init(avatarJson);
			mHeroInfo = mFakeHeroInfo;
			gmSkin = mDBFacade.gameMaster.getSkinByConstant(mSelectedHero.DefaultSkin);
		} else {
			gmSkin = mDBFacade.gameMaster.getSkinByType(mHeroInfo.skinId);
		}
		mHeroLevel = mSelectedHero.getLevelFromExp(mHeroInfo.experience, mHeroInfo.mAscensionLevel);
		if (gmSkin == null) {
			Logger.error("Unable to find gmSkin for ID: " + mHeroInfo.skinId);
		} else {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName), function(param1:SwfAsset) {
				var _loc7_ = param1.getClass(gmSkin.BackgroundClassName);
				var _loc5_ = param1.getClass(gmSkin.PortraitClassName);
				if (_loc7_ == null || _loc5_ == null) {
					return;
				}
				var _loc6_ = new MovieClip();
				_loc6_.addChild(ASCompat.coerce(ASCompat.createInstance(_loc7_, []), flash.display.DisplayObject));
				_loc6_.addChild(ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.DisplayObject));
				var _loc3_ = _loc6_.getBounds(_loc6_);
				var _loc4_ = Math.min(mHeroPortraitBounds.width / _loc3_.width, mHeroPortraitBounds.height / _loc3_.height);
				_loc6_.scaleX = _loc6_.scaleY = _loc4_;
				_loc6_.x = mHeroPortraitBounds.x + (mHeroPortraitBounds.width - _loc3_.width * _loc4_) * 0.5 - _loc3_.x * _loc4_;
				_loc6_.y = mHeroPortraitBounds.y + (mHeroPortraitBounds.height - _loc3_.height * _loc4_) * 0.5 - _loc3_.y * _loc4_;
				var _loc2_ = new MovieClipRenderController(mDBFacade, _loc6_);
				_loc2_.play();
				if (mHeroPortrait.numChildren > 0) {
					mHeroPortrait.removeChildAt(0);
				}
				mHeroPortrait.addChildAt(_loc6_, 0);
			});
		}
		readSelectedHeroInfo();
		mHeroWithEquipPicker.setAvatarAlert(true);
		updateUIFromDB();
	}

	function dbAccountInfoUpdate(event:DBAccountResponseEvent) {
		mHeroInfo = event.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id);
		mHeroWithEquipPicker.setAvatarAlert(true);
		updateUIFromDB();
	}

	@:isVar var spendAmount(get, never):Int;

	function get_spendAmount():Int {
		if (mHeroInfo == mFakeHeroInfo) {
			return 0;
		}
		return mHeroInfo.skillPointsAvailable;
	}

	@:isVar var spendAmountClient(get, never):Int;

	function get_spendAmountClient():Int {
		if (mHeroInfo == mFakeHeroInfo) {
			return 0;
		}
		return ASCompat.floatToInt(Math.max((mHeroInfo.skillPointsEarned : Float)
			- ((mStatHelpers[0].amount + mStatHelpers[1].amount + mStatHelpers[2].amount + mStatHelpers[3].amount) : Float),
			0));
	}

	function updateResetButton() {
		var _loc1_ = mStatHelpers[0].amount + mStatHelpers[1].amount + mStatHelpers[2].amount + mStatHelpers[3].amount;
		mResetButton.enabled = false;
		if (mHeroInfo != mFakeHeroInfo && _loc1_ > 0) {
			mResetButton.enabled = true;
		}
	}

	public function readSelectedHeroInfo() {
		var _loc2_ = 0;
		TextUtil.setText(mHeroPortraitText, GameMasterLocale.getGameMasterSubString("SKIN_NAME", mSelectedHero.Constant).toUpperCase());
		var _loc1_:Array<ASAny> = [
			mSelectedHero.StatUpgrade1,
			mSelectedHero.StatUpgrade2,
			mSelectedHero.StatUpgrade3,
			mSelectedHero.StatUpgrade4
		];
		var _loc3_:Array<ASAny> = [
			mSelectedHero.AmtStat1,
			mSelectedHero.AmtStat2,
			mSelectedHero.AmtStat3,
			mSelectedHero.AmtStat4
		];
		_loc2_ = 0;
		while (_loc2_ < 4) {
			mStatHelpers[_loc2_].statName = _loc1_[_loc2_];
			mStatUpgradeDifferenceHelpers[_loc2_].configure(_loc1_[_loc2_], ASCompat.toNumber(_loc3_[_loc2_]));
			mStatHelpers[_loc2_].refresh(mIconSwfAsset);
			_loc2_++;
		}
		Locale.setText(ASCompat.coerce((mUIRoot : ASAny).training_db_label, flash.text.TextField), "DUNGEON_BUSTER");
		TextUtil.setText(ASCompat.coerce((mUIRoot : ASAny).training_db_name, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME", mDBFacade.gameMaster.attackByConstant.itemFor(mSelectedHero.DBuster1).Constant)
				.toUpperCase());
		TextUtil.setText(ASCompat.coerce((mUIRoot : ASAny).training_db_description, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_DESCRIPTION",
				mDBFacade.gameMaster.attackByConstant.itemFor(mSelectedHero.DBuster1).Constant));
		TextUtil.setText(mHeroLevelText, Std.string(mHeroLevel));
	}

	function updateUIClient() {
		var _loc4_ = 0;
		var _loc3_ = (25 : UInt);
		var _loc2_ = (50 : UInt);
		var _loc1_ = (75 : UInt);
		mPendingDBWrite = true;
		mSpendAmount = spendAmountClient;
		_loc4_ = 0;
		while (_loc4_ < 4) {
			mStatHelpers[_loc4_].updateUI();
			updateStatUpgradeTooltip(_loc4_);
			mStatLevelPlusButtons[_loc4_].upgradeEnabled = false;
			_loc4_++;
		}
		TextUtil.setText(ASCompat.coerce((mSpendButton.root : ASAny).spend_amount_text, flash.text.TextField), Std.string(mSpendAmount));
		if (mSpendAmount <= 0) {
			mSpendAmount = 0;
			mHeroWithEquipPicker.disableAvatarAlertOnSelectedHero();
		} else {
			_loc4_ = 0;
			while (_loc4_ < 4) {
				if (mStatHelpers[_loc4_].statAmount < _loc1_) {
					mStatLevelPlusButtons[_loc4_].upgradeEnabled = true;
				}
				_loc4_++;
			}
		}
		updateResetButton();
	}

	function updateUIFromDB() {
		var _loc4_ = 0;
		var _loc3_ = (25 : UInt);
		var _loc2_ = (50 : UInt);
		var _loc1_ = (75 : UInt);
		var _loc5_:Array<ASAny> = [
			mHeroInfo.statUpgrade1,
			mHeroInfo.statUpgrade2,
			mHeroInfo.statUpgrade3,
			mHeroInfo.statUpgrade4
		];
		_loc4_ = 0;
		while (_loc4_ < 4) {
			mStatHelpers[_loc4_].statAmount = (ASCompat.toInt(_loc5_[_loc4_]) : UInt);
			_loc4_++;
		}
		mHeroLevel = mSelectedHero.getLevelFromExp(mHeroInfo.experience, mHeroInfo.mAscensionLevel);
		mSpendAmount = spendAmount;
		_loc4_ = 0;
		while (_loc4_ < 4) {
			mStatHelpers[_loc4_].updateUI();
			updateStatUpgradeTooltip(_loc4_);
			mStatLevelPlusButtons[_loc4_].upgradeEnabled = false;
			_loc4_++;
		}
		TextUtil.setText(ASCompat.coerce((mSpendButton.root : ASAny).spend_amount_text, flash.text.TextField), Std.string(mSpendAmount));
		if (mSpendAmount <= 0) {
			mSpendAmount = 0;
		} else {
			_loc4_ = 0;
			while (_loc4_ < 4) {
				if (mStatHelpers[_loc4_].statAmount < _loc1_) {
					mStatLevelPlusButtons[_loc4_].upgradeEnabled = true;
				}
				_loc4_++;
			}
		}
		updateResetButton();
	}

	function updateStatUpgradeTooltip(index:Int) {
		mStatUpgradeDifferenceHelpers[index].statAmount = mStatHelpers[index].statAmount;
		mStatLevelPlusTooltips[index].update(mStatUpgradeDifferenceHelpers[index].statName, mStatUpgradeDifferenceHelpers[index].description);
	}

	public function setCurrency(basicCurrency:Int, premiumCurrency:Int) {
		if (!mAssetsLoaded) {
			return;
		}
		TextUtil.setText(mBasicCurrencyText, Std.string(basicCurrency));
		TextUtil.setText(mPremiumCurrencyText, Std.string(premiumCurrency));
	}

	public function setBasicCurrency(basicCurrency:Int) {
		if (!mAssetsLoaded) {
			return;
		}
		TextUtil.setText(mBasicCurrencyText, Std.string(basicCurrency));
	}

	public function setPremiumCurrency(premiumCurrency:Int) {
		if (!mAssetsLoaded) {
			return;
		}
		TextUtil.setText(mPremiumCurrencyText, Std.string(premiumCurrency));
	}

	function statPlusReleased(num:Int) {
		mStatHelpers[num].statAmount = mStatHelpers[num].amount + 1;
		updateUIClient();
		mDBFacade.steamAchievementsHelper.unlockUpgradeStat(mStatHelpers[num].amount);
	}

	function resetReleased() {
		var popup:UIRetrainPopup;
		if (mGMOffer != null) {
			popup = new UIRetrainPopup(mDBFacade, function() {
				StoreServicesController.tryBuyOffer(mDBFacade, mGMOffer, function(param1:ASAny) {
					var _loc2_ = 0;
					_loc2_ = 0;
					while (_loc2_ < 4) {
						mStatHelpers[_loc2_].statAmount = (0 : UInt);
						_loc2_++;
					}
					mDBFacade.steamAchievementsHelper.addValueToStatInt(1, "HEROES_RETRAINED");
					mDBFacade.steamAchievementsHelper.unlockAchievement("RETRAIN_CHARACTER");
					updateUIClient();
				});
			}, (ASCompat.floatToInt(mGMOffer.Price) : UInt));
			MemoryTracker.track(popup, "UIRetrainPopup - created in UIHeroTraining.resetReleased()");
		}
	}

	public function processChosenAvatar() {
		if (mHeroWithEquipPicker.currentlySelectedHero == null) {
			return;
		}
		if (mPendingDBWrite) {
			writeStatsToDatabase();
		}
		var _loc1_ = mHeroWithEquipPicker.currentlySelectedHero.Id;
		if (mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_) {
			mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
		}
	}

	public function selectPreviousHero() {
		mHeroWithEquipPicker.selectPreviousHero();
	}

	public function selectNextHero() {
		mHeroWithEquipPicker.selectNextHero();
	}

	function setupMenuNavigation() {
		mTownHeader.closeButton.isAbove(mStatLevelPlusButtons[0]);
		mStatLevelPlusButtons[0].isAbove(mStatLevelPlusButtons[1]);
		mStatLevelPlusButtons[1].isAbove(mStatLevelPlusButtons[2]);
		mStatLevelPlusButtons[2].isAbove(mStatLevelPlusButtons[3]);
		mStatLevelPlusButtons[3].isAbove(mResetButton);
		mResetButton.downNavigation = mHeroWithEquipPicker.getFirstHeroSlotUIObject();
		mHeroWithEquipPicker.setupHeroWithEquipPickerMenuNavigation(mResetButton);
	}

	function resetMenuNavigation() {
		mStatLevelPlusButtons[0].clearNavigationAndInteractions();
		mStatLevelPlusButtons[1].clearNavigationAndInteractions();
		mStatLevelPlusButtons[2].clearNavigationAndInteractions();
		mStatLevelPlusButtons[3].clearNavigationAndInteractions();
		mStatLevelPlusButtons[0].setFocused(false);
		mStatLevelPlusButtons[1].setFocused(false);
		mStatLevelPlusButtons[2].setFocused(false);
		mStatLevelPlusButtons[3].setFocused(false);
		mResetButton.clearNavigationAndInteractions();
		mHeroWithEquipPicker.resetHeroWithEquipPickerMenuNavigation();
	}

	function setButtonNavigationFilters() {
		mStatLevelPlusButtons[0].navigationSelectedInteraction = function() {
			if (mStatLevelPlusButtons[0].upgradeEnabled) {
				DBGlobal.highlightButton(mStatLevelPlusButtons[0]);
			}
		};
		mStatLevelPlusButtons[1].navigationSelectedInteraction = function() {
			if (mStatLevelPlusButtons[1].upgradeEnabled) {
				DBGlobal.highlightButton(mStatLevelPlusButtons[1]);
			}
		};
		mStatLevelPlusButtons[2].navigationSelectedInteraction = function() {
			if (mStatLevelPlusButtons[2].upgradeEnabled) {
				DBGlobal.highlightButton(mStatLevelPlusButtons[2]);
			}
		};
		mStatLevelPlusButtons[3].navigationSelectedInteraction = function() {
			if (mStatLevelPlusButtons[3].upgradeEnabled) {
				DBGlobal.highlightButton(mStatLevelPlusButtons[3]);
			}
		};
		mStatLevelPlusButtons[0].navigationSetToUnselectedInteraction = function() {
			DBGlobal.unHighlightButton(mStatLevelPlusButtons[0]);
		};
		mStatLevelPlusButtons[1].navigationSetToUnselectedInteraction = function() {
			DBGlobal.unHighlightButton(mStatLevelPlusButtons[1]);
		};
		mStatLevelPlusButtons[2].navigationSetToUnselectedInteraction = function() {
			DBGlobal.unHighlightButton(mStatLevelPlusButtons[2]);
		};
		mStatLevelPlusButtons[3].navigationSetToUnselectedInteraction = function() {
			DBGlobal.unHighlightButton(mStatLevelPlusButtons[3]);
		};
	}
}
