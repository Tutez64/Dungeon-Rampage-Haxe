package uI.skills;

import account.AvatarInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphManager;
import brain.uI.UIButton;
import brain.utils.ColorMatrix;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.jsonRPC.JSONRPCService;
import collections.Map;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMSkin;
import town.TownHeader;
import uI.popup.DBUIOneButtonPopup;
import uI.popup.DBUITwoButtonPopup;
import flash.display.MovieClip;
import flash.text.TextField;

class UISkills {
	static inline final ASCEND_ERROR_NO_STORAGE_SPACE = -1605;

	static inline final ASCEND_ERROR_REWARD_NO_STORAGE_SPACE = -1606;

	var mDBFacade:DBFacade;

	var mTownHeader:TownHeader;

	var mRootMovieClip:MovieClip;

	var mAscendButton:UIButton;

	var mHeroPic:MovieClip;

	var mLevelText:TextField;

	var mHeroNameLabel:TextField;

	var mAvatarSelector:MovieClip;

	var mSelectorRightScroll:UIButton;

	var mSelectorLeftScroll:UIButton;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mActiveAvatar:AvatarInfo;

	var mAvatarIdToMakeActiveAvatar:UInt = 0;

	var mCurrentChosenIndex:Int = 0;

	var mChosenAvatarID:UInt = 0;

	var mChosenAvatarIDFull:UInt = 0;

	var mAvatarSelectorStartIndex:Int = 0;

	var mSelectedSkin:GMSkin;

	var mChosenSkin:GMSkin;

	var mHeroIds:Vector<UInt>;

	var mHeroSelectionsToFlush:Map;

	var mHeroOffers:Map;

	var mScaledSlotIndex:Int = 0;

	var mHeroSlots:Vector<UIButton>;

	var mIsActive:Bool = false;

	var mAscendRequestPending:Bool = false;

	public function new(dbFacade:DBFacade, root:MovieClip, townHeader:TownHeader) {
		mDBFacade = dbFacade;
		mRootMovieClip = root;
		mTownHeader = townHeader;
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mHeroSlots = new Vector<UIButton>();
		mHeroSelectionsToFlush = new Map();
		mHeroOffers = new Map();
		mHeroIds = new Vector<UInt>();
		mAscendButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).ascend_circle.ascend_button, flash.display.MovieClip));
		mAscendButton.releaseCallback = function() {
			var _loc1_:DBUITwoButtonPopup = null;
			if (mAscendRequestPending) {
				return;
			}
			var _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
			var _loc4_ = (ASCompat.toInt(_loc3_ != null ? _loc3_.mAscensionLevel : 0) : UInt);
			var _loc2_ = mDBFacade.gameMaster.maxAscensionCount;
			if (_loc2_ > 0 && _loc4_ >= _loc2_) {
				_loc1_ = new DBUITwoButtonPopup(mDBFacade, "ASCEND_CONFIRMATION_POPUP", Locale.getString("ASCEND_CONFIRMATION_POPUP_TITLE"),
					Locale.getString("ASCEND_CONFIRMATION_MAX_LEVEL_POPUP_BODY"), Locale.getString("NO"), null, Locale.getString("YES"), attemptAscend);
				MemoryTracker.track(_loc1_, "DBUITwoButtonPopup - created in UISkills ascend button");
			} else {
				_loc1_ = new DBUITwoButtonPopup(mDBFacade, "ASCEND_CONFIRMATION_POPUP", Locale.getString("ASCEND_CONFIRMATION_POPUP_TITLE"),
					Locale.getString("ASCEND_CONFIRMATION_POPUP_BODY"), Locale.getString("NO"), null, Locale.getString("YES"), attemptAscend);
				MemoryTracker.track(_loc1_, "DBUITwoButtonPopup - created in UISkills ascend button");
			}
		};
		Locale.setText(mAscendButton.label, "ASCEND_BUTTON");
		mHeroPic = ASCompat.coerce((mRootMovieClip : ASAny).ascend_circle.avatar, flash.display.MovieClip);
		mLevelText = ASCompat.coerce((mRootMovieClip : ASAny).ascend_circle.level_text, flash.text.TextField);
		mHeroNameLabel = ASCompat.coerce((mRootMovieClip : ASAny).ascend_circle.hero_name_label, flash.text.TextField);
		mChosenAvatarID = (0 : UInt);
		loadHeroOffers();
		loadAvatarChoiceArray();
	}

	public function refresh(resetToActiveAvatar:Bool = true) {
		var _loc3_ = (0 : UInt);
		mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
		var _loc2_ = mChosenAvatarID != 0 && mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID) != null;
		if (resetToActiveAvatar || !_loc2_) {
			_loc3_ = getActiveAvatarIndex();
			mCurrentChosenIndex = (_loc3_ : Int);
		} else {
			_loc3_ = (mCurrentChosenIndex : UInt);
		}
		populateAvatarInfo((_loc3_ : Int));
		populateAvatarSelector();
	}

	public function setupHeaderLinks() {
		mTownHeader.closeButton.isAbove(mAscendButton);
	}

	public function activate() {
		mIsActive = true;
	}

	public function deactivate() {
		mIsActive = false;
	}

	public function processChosenAvatar() {
		var _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mAvatarIdToMakeActiveAvatar);
		if (_loc1_ == null) {
			Logger.error("Trying to set active avatar to an avatar the user does not own.");
			return;
		}
		if (mActiveAvatar == null || mActiveAvatar.id != _loc1_.id) {
			mDBFacade.dbAccountInfo.changeActiveAvatarRPC(mAvatarIdToMakeActiveAvatar);
		}
	}

	public function selectPreviousHero() {
		selectAdjacentHero(-1);
	}

	public function selectNextHero() {
		selectAdjacentHero(1);
	}

	function loadAvatarChoiceArray() {
		var i:Int;
		var makeCallbackFunc:ASFunction;
		var keys:Array<ASAny>;
		var avatarStartIndex:UInt;
		mAvatarSelector = ASCompat.coerce((mRootMovieClip : ASAny).UI_town_tavern_avatar_selector, flash.display.MovieClip);
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_0, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_1, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_2, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_3, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_4, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_5, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_6, flash.display.MovieClip)));
		mHeroSlots.push(new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).slot_7, flash.display.MovieClip)));
		i = 0;
		while (i < mHeroSlots.length) {
			if (ASCompat.toBool((mHeroSlots[i].root : ASAny).chosen)) {
				ASCompat.setProperty((mHeroSlots[i].root : ASAny).chosen, "visible", false);
			}
			mHeroSlots[i].rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			makeCallbackFunc = function(param1:Int):ASFunction {
				var value = param1;
				return function() {
					populateAvatarInfo(value);
				};
			};
			mHeroSlots[i].releaseCallback = ASCompat.coerceFunction(makeCallbackFunc(i));
			i = i + 1;
		}
		mSelectorLeftScroll = new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).moveLeft, flash.display.MovieClip));
		mSelectorRightScroll = new UIButton(mDBFacade, ASCompat.coerce((mAvatarSelector : ASAny).moveRight, flash.display.MovieClip));
		mSelectorLeftScroll.releaseCallback = scrollLeft;
		mSelectorRightScroll.releaseCallback = scrollRight;
		mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
		if (mActiveAvatar == null && mDBFacade.dbAccountInfo.inventoryInfo.avatars.size > 0) {
			keys = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
			mActiveAvatar = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(keys[0]), account.AvatarInfo);
		}
		avatarStartIndex = getActiveAvatarIndex();
		if (mHeroIds.length <= mHeroSlots.length) {
			mSelectorRightScroll.visible = false;
		}
		if (mAvatarSelectorStartIndex == 0) {
			mSelectorLeftScroll.visible = false;
		}
		mCurrentChosenIndex = (avatarStartIndex : Int);
		populateAvatarSelector();
		populateAvatarInfo((avatarStartIndex : Int));
	}

	function scrollLeft() {
		currentChosenIndex = mCurrentChosenIndex + 1;
		avatarSelectorStartIndex = mAvatarSelectorStartIndex - 1;
		handleScaledSlotIndex(1);
	}

	function scrollRight() {
		currentChosenIndex = mCurrentChosenIndex - 1;
		avatarSelectorStartIndex = mAvatarSelectorStartIndex + 1;
		handleScaledSlotIndex(-1);
	}

	function selectAdjacentHero(direction:Int) {
		if (mHeroIds.length == 0) {
			return;
		}
		var _loc2_ = mAvatarSelectorStartIndex + mCurrentChosenIndex;
		_loc2_ = (_loc2_ + direction + mHeroIds.length) % mHeroIds.length;
		if (_loc2_ < mAvatarSelectorStartIndex) {
			avatarSelectorStartIndex = _loc2_;
		} else if (_loc2_ >= mAvatarSelectorStartIndex + mHeroSlots.length) {
			avatarSelectorStartIndex = _loc2_ - mHeroSlots.length + 1;
		}
		populateAvatarInfo(_loc2_ - mAvatarSelectorStartIndex);
	}

	@:isVar public var currentChosenIndex(never, set):Int;

	public function set_currentChosenIndex(value:Int):Int {
		return mCurrentChosenIndex = value;
	}

	function getActiveAvatarIndex():UInt {
		var _loc2_ = 0;
		var _loc1_ = (0 : UInt);
		if (mActiveAvatar != null) {
			_loc2_ = 0;
			while (_loc2_ < mHeroIds.length) {
				if (mHeroIds[_loc2_] == mActiveAvatar.avatarType) {
					_loc1_ = (_loc2_ : UInt);
					if (_loc2_ >= mHeroSlots.length) {
						mAvatarSelectorStartIndex = _loc2_ - mHeroSlots.length + 1;
						_loc1_ = (mHeroSlots.length - 1:UInt);
					}
					break;
				}
				_loc2_++;
			}
		}
		return _loc1_;
	}

	function populateAvatarInfo(index:Int) {
		resizeHeroSlots((index : UInt));
		index += mAvatarSelectorStartIndex;
		if (index >= mHeroIds.length) {
			return;
		}
		var _loc2_ = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[index]), gameMasterDictionary.GMHero);
		chooseThisHero(_loc2_.Id, index - mAvatarSelectorStartIndex);
		TextUtil.setText(mHeroNameLabel, GameMasterLocale.getGameMasterSubString("SKIN_NAME", _loc2_.Constant).toUpperCase());
		var _loc3_ = determineSkinForHero(_loc2_);
		skinSelected(_loc3_);
	}

	function chooseThisHero(avatarID:UInt, index:Int) {
		var _loc4_ = (0 : UInt);
		var _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(avatarID);
		if (_loc3_ != null) {
			if (_loc3_ != null && mCurrentChosenIndex < mHeroSlots.length && mCurrentChosenIndex >= 0) {
				if (ASCompat.toBool((mHeroSlots[mCurrentChosenIndex].root : ASAny).chosen)) {
					ASCompat.setProperty((mHeroSlots[mCurrentChosenIndex].root : ASAny).chosen, "visible", false);
				}
			}
			_loc4_ = (0 : UInt);
			while (_loc4_ < (mHeroSlots.length:UInt)) {
				if (ASCompat.toBool((mHeroSlots[(_loc4_ : Int)].root : ASAny).chosen)) {
					ASCompat.setProperty((mHeroSlots[(_loc4_ : Int)].root : ASAny).chosen, "visible", false);
				}
				_loc4_++;
			}
			mAvatarIdToMakeActiveAvatar = _loc3_.gmHero.Id;
			if (ASCompat.toBool((mHeroSlots[index].root : ASAny).chosen)) {
				ASCompat.setProperty((mHeroSlots[index].root : ASAny).chosen, "visible", true);
			}
			TextUtil.setText(mAscendButton.label, Std.string(_loc3_.mNextAscensionGemCost));
			TextUtil.setText(mLevelText, Std.string(_loc3_.mAscensionLevel));
			mChosenAvatarIDFull = _loc3_.id;
		} else {
			TextUtil.setText(mLevelText, "0");
		}
		setAscendButtonEnabled(_loc3_ != null && _loc3_.canAscend);
		mCurrentChosenIndex = index;
		mChosenAvatarID = avatarID;
	}

	function setAscendButtonEnabled(value:Bool) {
		mAscendButton.enabled = value;
		mAscendButton.root.filters = cast(value ? [] : [SceneGraphManager.getGrayScaleSaturationFilter(5)]);
	}

	function handleScaledSlotIndex(count:Int) {
		mScaledSlotIndex += count;
		if (mScaledSlotIndex < 0) {
			mScaledSlotIndex = 0;
			populateAvatarInfo(0);
		}
		if (mScaledSlotIndex >= mHeroSlots.length) {
			mScaledSlotIndex = mHeroSlots.length - 1;
			populateAvatarInfo(mScaledSlotIndex);
		}
		resizeHeroSlots((mScaledSlotIndex : UInt));
	}

	function resizeHeroSlots(selectedIndex:UInt) {
		var _loc2_ = (0 : UInt);
		mScaledSlotIndex = (selectedIndex : Int);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mHeroSlots.length:UInt)) {
			if (_loc2_ == selectedIndex) {
				select(mHeroSlots[(_loc2_ : Int)].root);
			} else {
				deselect(mHeroSlots[(_loc2_ : Int)].root);
			}
			_loc2_++;
		}
	}

	public function select(root:MovieClip) {
		root.scaleX = 1.25;
		root.scaleY = 1.25;
	}

	public function deselect(root:MovieClip) {
		root.scaleX = 1;
		root.scaleY = 1;
	}

	@:isVar public var avatarSelectorStartIndex(never, set):Int;

	public function set_avatarSelectorStartIndex(value:Int):Int {
		if (value == mAvatarSelectorStartIndex) {
			return value;
		}
		mAvatarSelectorStartIndex = value;
		populateAvatarSelector();
		if (mSelectorRightScroll.visible && mAvatarSelectorStartIndex + mHeroSlots.length >= mHeroIds.length) {
			mSelectorRightScroll.visible = false;
		} else if (!mSelectorRightScroll.visible && mAvatarSelectorStartIndex + mHeroSlots.length < mHeroIds.length) {
			mSelectorRightScroll.visible = true;
		}
		if (mSelectorLeftScroll.visible && mAvatarSelectorStartIndex == 0) {
			mSelectorLeftScroll.visible = false;
		} else if (!mSelectorLeftScroll.visible && mAvatarSelectorStartIndex > 0) {
			mSelectorLeftScroll.visible = true;
		}
		return value;
	}

	function populateAvatarSelector() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mHeroSlots.length) {
			if (mHeroIds.length > _loc1_ + mAvatarSelectorStartIndex) {
				loadAvatarHolderAtPosition(_loc1_ + mAvatarSelectorStartIndex, _loc1_);
			} else {
				ASCompat.setProperty((mHeroSlots[_loc1_].root : ASAny).xp_star, "visible", false);
			}
			_loc1_++;
		}
	}

	function loadAvatarHolderAtPosition(heroIndex:Int, vectorIndex:Int) {
		var gmSkin:GMSkin;
		var iconName:String;
		var swfFilePath:String;
		var gmHero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[heroIndex]), gameMasterDictionary.GMHero);
		var avatarID = gmHero.Id;
		var avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
		if (avatarInfo == null) {
			ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).xp_star, "visible", false);
		} else {
			ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).xp_star, "visible", true);
			TextUtil.setText(ASCompat.coerce((mHeroSlots[vectorIndex].root : ASAny).xp_star.xp_text, flash.text.TextField), Std.string(avatarInfo.cloutLevel));
		}
		gmSkin = mDBFacade.dbAccountInfo.inventoryInfo.getDefaultSkinForHero(gmHero);
		iconName = gmSkin.IconName;
		swfFilePath = gmSkin.UISwfFilepath;
		ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).coming_soon, "visible", false);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfFilePath), function(param1:brain.assetRepository.SwfAsset) {
			var _loc3_:ColorMatrix = null;
			var _loc4_ = param1.getClass(iconName);
			if (_loc4_ == null) {
				return;
			}
			var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
			_loc2_.scaleX *= 0.86;
			_loc2_.scaleY *= 0.86;
			if (ASCompat.toNumberField((mHeroSlots[vectorIndex].root : ASAny).avatar_icon, "numChildren") > 0) {
				(mHeroSlots[vectorIndex].root : ASAny).avatar_icon.removeChildAt(0);
			}
			(mHeroSlots[vectorIndex].root : ASAny).avatar_icon.addChildAt(_loc2_, 0);
			ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).avatar_mask, "visible", false);
			if (mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(avatarID)) {
				ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).avatar_icon, "filters", []);
			} else {
				_loc3_ = new ColorMatrix();
				_loc3_.adjustSaturation(0.1);
				_loc3_.adjustBrightness(-64);
				_loc3_.adjustContrast(-0.5);
				ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).avatar_icon, "filters", [_loc3_.filter]);
			}
		});
	}

	function attemptAscend() {
		var ascendingAvatar:AvatarInfo;
		var ascensionLevelReached:UInt;
		var requestFunc:ASFunction;
		if (mAscendRequestPending) {
			return;
		}
		mAscendRequestPending = true;
		ascendingAvatar = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
		ascensionLevelReached = ascendingAvatar != null ? ascendingAvatar.mAscensionLevel + 1 : (0 : UInt);
		requestFunc = JSONRPCService.getFunction("ascendAvatar", mDBFacade.rpcRoot + "avatarrecord");
		requestFunc(mChosenAvatarIDFull, function(param1:ASAny) {
			mAscendRequestPending = false;
			Logger.log("AscendAvatar:" + Std.string(param1));
			if (mIsActive) {
				showAscendSucceededPopup(ascensionLevelReached);
			}
			askForAccountDetailsRefresh();
		}, function(param1:Error) {
			mAscendRequestPending = false;
			if (mIsActive) {
				showAscendFailedPopup(param1);
			}
		});
	}

	function showAscendSucceededPopup(ascensionLevelReached:UInt) {
		var _loc2_:DBUIOneButtonPopup = null;
		var _loc3_ = mDBFacade.gameMaster.maxAscensionCount;
		if (_loc3_ > 0 && ascensionLevelReached >= _loc3_) {
			_loc2_ = new DBUIOneButtonPopup(mDBFacade, "ASCEND_MAX_LEVEL_POPUP", Locale.getString("ASCEND_MAX_LEVEL_POPUP_TITLE"),
				Locale.getString("ASCEND_MAX_LEVEL_POPUP_BODY"), Locale.getString("OK"), null);
		} else {
			_loc2_ = new DBUIOneButtonPopup(mDBFacade, "ASCEND_CONGRATULATIONS_POPUP", Locale.getString("ASCEND_CONGRATULATIONS_POPUP_TITLE"),
				Locale.getString("ASCEND_CONGRATULATIONS_POPUP_BODY"), Locale.getString("OK"), null);
		}
	}

	function showAscendFailedPopup(error:Error) {
		var _loc5_:String = null;
		var _loc4_:String = null;
		var _loc3_:String = null;
		switch (error.errorID - -1606) {
			case 0:
				_loc5_ = "ASCEND_REWARD_NO_STORAGE_SPACE_POPUP_TITLE";
				_loc4_ = "ASCEND_REWARD_NO_STORAGE_SPACE_POPUP_BODY";
				_loc3_ = "ASCEND_REWARD_NO_STORAGE_SPACE_POPUP";

			case 1:
				_loc5_ = "ASCEND_NO_STORAGE_SPACE_POPUP_TITLE";
				_loc4_ = "ASCEND_NO_STORAGE_SPACE_POPUP_BODY";
				_loc3_ = "ASCEND_NO_STORAGE_SPACE_POPUP";

			default:
				mDBFacade.errorPopup(Locale.getString("ASCEND_PROMPT_GENERAL_ERROR"), Std.string(error), "ASCENSION_GENERAL_ERROR_POPUP");
				return;
		}
		var _loc2_ = new DBUIOneButtonPopup(mDBFacade, _loc3_, Locale.getString(_loc5_), Locale.getString(_loc4_), Locale.getString("OK"), null);
	}

	function askForAccountDetailsRefresh() {
		var useAccountBoosterFunc = JSONRPCService.getFunction("AskForAccountDetails", mDBFacade.rpcRoot + "webMagicWord");
		useAccountBoosterFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, mDBFacade.demographics, function(param1:ASAny) {
			Logger.log("Got new account details");
			mDBFacade.dbAccountInfo.parseResponse(param1);
			mDBFacade.steamAchievementsHelper.updateHeroProgressStats(mDBFacade.dbAccountInfo.inventoryInfo.avatars);
		}, function(param1:Error) {
			Logger.log("PhpTime: ERROR:" + Std.string(param1));
		});
	}

	function determineSkinForHero(gmHero:GMHero):GMSkin {
		return mDBFacade.dbAccountInfo.inventoryInfo.getDefaultSkinForHero(gmHero);
	}

	function skinSelected(gmSkin:GMSkin) {
		mSelectedSkin = gmSkin;
		var _loc4_ = mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(gmSkin.Id);
		var _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
		var _loc2_ = _loc3_ != null;
		if (_loc2_) {
			if (_loc4_) {
				if (mHeroSelectionsToFlush.hasKey(_loc3_.gmHero.Id)) {
					mHeroSelectionsToFlush.replaceFor(_loc3_.gmHero.Id, gmSkin.Id);
				} else {
					mHeroSelectionsToFlush.add(_loc3_.gmHero.Id, gmSkin.Id);
				}
				mChosenSkin = gmSkin;
			}
		} else {
			mChosenSkin = null;
		}
		setupSkin(mSelectedSkin);
	}

	function setupSkin(gmSkin:GMSkin) {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName), function(param1:brain.assetRepository.SwfAsset) {
			var _loc2_ = param1.getClass(gmSkin.PortraitClassName);
			if (_loc2_ == null) {
				return;
			}
			var _loc3_ = new MovieClip();
			_loc3_.addChild(ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.DisplayObject));
			_loc3_.scaleX = _loc3_.scaleY = 0.45;
			if (mHeroPic.numChildren > 0) {
				mHeroPic.removeChildAt(0);
			}
			mHeroPic.addChildAt(_loc3_, 0);
		});
	}

	function loadHeroOffers() {
		var _loc2_:GMOffer = null;
		var _loc3_ = 0;
		var _loc1_ = mDBFacade.gameMaster.Offers;
		var _loc4_:GMHero;
		final __ax4_iter_533 = mDBFacade.gameMaster.Heroes;
		if (checkNullIteratee(__ax4_iter_533))
			for (_tmp_ in __ax4_iter_533) {
				_loc4_ = _tmp_;
				if (!(_loc4_.Hidden && !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes", false))) {
					mHeroIds.push(_loc4_.Id);
					_loc3_ = 0;
					while (_loc3_ < _loc1_.length) {
						_loc2_ = _loc1_[_loc3_];
						if (_loc2_.Tab == "HERO" && _loc2_.Location == "STORE" && !_loc2_.IsBundle && _loc2_.SaleTargetOffer == null && !_loc2_.IsCoinAltOffer) {
							if (_loc2_.Details[0].HeroId == _loc4_.Id) {
								mHeroOffers.add(_loc4_.Id, _loc2_);
								break;
							}
						}
						_loc3_++;
					}
				}
			}
		ASCompat.ASVector.sort(mHeroIds, heroIdSort);
	}

	function heroIdSort(id1:UInt, id2:UInt):Int {
		if (id1 < id2) {
			return -1;
		}
		return 1;
	}

	public function destroy() {
		var _loc1_ = 0;
		mAssetLoadingComponent.destroy();
		_loc1_ = 0;
		while (_loc1_ < mHeroSlots.length) {
			if (mHeroSlots[_loc1_] != null) {
				mHeroSlots[_loc1_].destroy();
			}
			_loc1_++;
		}
		if (mAscendButton != null) {
			mAscendButton.destroy();
		}
		if (mSelectorRightScroll != null) {
			mSelectorRightScroll.destroy();
		}
		if (mSelectorLeftScroll != null) {
			mSelectorLeftScroll.destroy();
		}
		mTownHeader = null;
	}
}
