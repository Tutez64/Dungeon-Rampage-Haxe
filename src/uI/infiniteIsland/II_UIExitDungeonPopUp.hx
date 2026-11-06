package uI.infiniteIsland;

import brain.assetRepository.SwfAsset;
import brain.event.EventComponent;
import brain.render.MovieClipRenderController;
import brain.utils.TextUtil;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMDoober;
import generatedCode.InfiniteRewardData;
import uI.popup.DBUITwoButtonPopup;
import uI.popup.ExitDungeonOptionsButton;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.text.TextField;

class II_UIExitDungeonPopUp extends DBUITwoButtonPopup {
	static inline final SWF_SCREEN_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	static inline final POPUP_CLASS_NAME = "exitdungeon_infinite_popup";

	static inline final SWF_DOOBER_PATH = "Resources/Art2D/Doobers/db_items_doobers.swf";

	static inline final SWF_ITEM_PATH = "Resources/Art2D/Icons/Items/db_icons_items.swf";

	static inline final CHEST_COMMON_CLASS_NAME = "db_doobers_treasure_chest_basic";

	static inline final CHEST_UNCOMMON_CLASS_NAME = "db_doobers_treasure_chest_uncommon";

	static inline final CHEST_RARE_CLASS_NAME = "db_doobers_treasure_chest_rare";

	static inline final CHEST_LEGENDARY_CLASS_NAME = "db_doobers_treasure_chest_legendary";

	static inline final LOOT_SMALL_CLASS_NAME = "db_doobers_itemBox_small";

	static inline final LOOT_ROYAL_CLASS_NAME = "db_doobers_itemBox_royal";

	static final OPTIONS_BUTTON_POSITION:Point = new Point(140, 172);

	var mOptionsCallback:ASFunction;

	var mOptionsButton:ExitDungeonOptionsButton;

	var mDooberAsset:SwfAsset;

	var mItemAsset:SwfAsset;

	var mCommonChestClass:Dynamic;

	var mUncommonChestClass:Dynamic;

	var mRareChestClass:Dynamic;

	var mLegendaryChestClass:Dynamic;

	var mSmallLootClass:Dynamic;

	var mRoyalLootClass:Dynamic;

	var mCurrentRewardTF:TextField;

	var mCoinTF:TextField;

	var mRewardChests:Vector<MovieClip>;

	var mRewardSlots:Vector<MovieClip>;

	var mEventComponent:EventComponent;

	var mRewards:Vector<InfiniteRewardData>;

	var mTotalGold:Int = 0;

	public function new(dbFacade:DBFacade, leftCallback:ASFunction, rightCallback:ASFunction, optionsCallback:ASFunction = null) {
		mOptionsCallback = optionsCallback;
		super(dbFacade, "EXIT_INFINITE_DUNGEON", Locale.getString("UI_HUD_EXIT_TITLE"), Locale.getString("II_UI_HUD_EXIT_MESSAGE"),
			Locale.getString("UI_HUD_EXIT_CONFIRM"), leftCallback, Locale.getString("UI_HUD_EXIT_CANCEL"), rightCallback);
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var _loc6_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id), HeroGameObjectOwner);
		if (_loc6_ == null || _loc6_.distributedDungeonFloor == null || _loc6_.distributedDungeonFloor.parentArea == null) {
			throw new Error("Infinite exit popup requires an active Infinite Dungeon");
		}
		mRewards = _loc6_.distributedDungeonFloor.parentArea.infiniteRewardData;
		mTotalGold = _loc6_.distributedDungeonFloor.parentArea.infiniteTotalGold;
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		if (mOptionsCallback != null) {
			mOptionsButton = new ExitDungeonOptionsButton(mDBFacade, mAssetLoadingComponent, mPopup, OPTIONS_BUTTON_POSITION, mCloseButton, null,
				mOptionsCallback);
		}
		mEventComponent = new EventComponent(mDBFacade);
		mCurrentRewardTF = ASCompat.coerce((mPopup : ASAny).current_reward.label_currentReward, flash.text.TextField);
		mCoinTF = ASCompat.coerce((mPopup : ASAny).coin_count, flash.text.TextField);
		mRewardSlots = new Vector<MovieClip>();
		mRewardSlots.push(ASCompat.coerce((mPopup : ASAny).current_reward.loot_01, flash.display.MovieClip));
		mRewardSlots.push(ASCompat.coerce((mPopup : ASAny).current_reward.loot_02, flash.display.MovieClip));
		mRewardSlots.push(ASCompat.coerce((mPopup : ASAny).current_reward.loot_03, flash.display.MovieClip));
		mRewardSlots.push(ASCompat.coerce((mPopup : ASAny).current_reward.loot_04, flash.display.MovieClip));
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"), itemsLoaded);
	}

	override function handleInputCalledClosed() {
		if (mDBFacade.hud != null) {
			mDBFacade.hud.suppressNextExitMenuToggle();
		}
		super.handleInputCalledClosed();
	}

	function itemsLoaded(swfAsset:SwfAsset) {
		mItemAsset = swfAsset;
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"), doobersLoaded);
	}

	function doobersLoaded(swfAsset:SwfAsset) {
		mCommonChestClass = swfAsset.getClass("db_doobers_treasure_chest_basic");
		mUncommonChestClass = swfAsset.getClass("db_doobers_treasure_chest_uncommon");
		mRareChestClass = swfAsset.getClass("db_doobers_treasure_chest_rare");
		mLegendaryChestClass = swfAsset.getClass("db_doobers_treasure_chest_legendary");
		mSmallLootClass = swfAsset.getClass("db_doobers_itemBox_small");
		mRoyalLootClass = swfAsset.getClass("db_doobers_itemBox_royal");
		mDooberAsset = swfAsset;
		init();
	}

	function init() {
		var _loc1_:InfiniteRewardData = null;
		var _loc3_ = false;
		var _loc4_:GMDoober = null;
		var _loc8_:GMChest = null;
		var _loc2_:Dynamic = null;
		var _loc9_:Dynamic = null;
		var _loc5_:MovieClip = null;
		var _loc7_:MovieClipRenderController = null;
		Locale.setText(mCurrentRewardTF, "II_DINGELPUS_EXIT_POPUP_CURRENT_REWARD");
		mRewardChests = new Vector<MovieClip>();
		var _loc6_ = 0;
		final __ax4_iter_371 = mRewards;
		if (checkNullIteratee(__ax4_iter_371))
			for (_tmp_ in __ax4_iter_371) {
				_loc1_ = _tmp_;
				if (_loc6_ < mRewardSlots.length) {
					_loc3_ = false;
					if (_loc1_.status == 1) {
						_loc3_ = true;
					} else {
						if (_loc1_.status == 0) {
							break;
						}
						if (_loc1_.status == 3) {
							continue;
						}
					}
					_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(_loc1_.dooberId), gameMasterDictionary.GMDoober);
					_loc8_ = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(_loc4_.ChestId), gameMasterDictionary.GMChest);
					_loc2_ = mDooberAsset.getClass(_loc4_.AssetClassName);
					_loc9_ = mItemAsset.getClass(_loc8_.IconName);
					_loc5_ = ASCompat.coerce(ASCompat.createInstance(_loc9_, []), flash.display.MovieClip);
					if (_loc6_ == 0) {
						_loc5_.scaleY = 0.57;
						_loc5_.scaleX = 0.57;
					} else {
						_loc5_.scaleY = 0.72;
						_loc5_.scaleX = 0.72;
					}
					if (_loc3_) {
						desaturate(_loc5_);
					}
					_loc7_ = new MovieClipRenderController(mDBFacade, _loc5_);
					_loc7_.loop = false;
					_loc7_.stop();
					mRewardSlots[_loc6_].addChild(_loc5_);
					ASCompat.setProperty((mRewardSlots[_loc6_] : ASAny).loot, "visible", false);
					mRewardChests.push(_loc5_);
				}
				_loc6_++;
			}
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).current_reward.coin_count, flash.text.TextField), Std.string(mTotalGold));
	}

	public function desaturate(obj:DisplayObject) {
		var _loc2_:Float = 0.212671;
		var _loc5_:Float = 0.71516;
		var _loc3_:Float = 0.072169;
		var _loc6_:Float = 0.7;
		var _loc4_:Float = 0.6;
		var _loc7_:Float = 0.5;
		var _loc8_:Array<ASAny> = [
			_loc2_ * _loc6_,
			_loc5_ * _loc6_,
			_loc3_ * _loc6_,
			0,
			0,
			_loc2_ * _loc4_,
			_loc5_ * _loc4_,
			_loc3_ * _loc4_,
			0,
			0,
			_loc2_ * _loc7_,
			_loc5_ * _loc7_,
			_loc3_ * _loc7_,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		];
		obj.filters = cast([new ColorMatrixFilter(cast(_loc8_))]);
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_screens.swf";
	}

	override function getClassName():String {
		return "exitdungeon_infinite_popup";
	}

	override public function destroy() {
		if (mDBFacade == null) {
			return;
		}
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		if (mOptionsButton != null) {
			mOptionsButton.destroy();
			mOptionsButton = null;
		}
		mOptionsCallback = null;
		mRewards = null;
		if (mDBFacade.hud != null) {
			mDBFacade.hud.clearExitMenu();
		}
		super.destroy();
	}

	override function setupMenuNavigation() {
		mCloseButton.isAbove(mRightButton);
		mRightButton.isAbove(mLeftButton);
	}
}
