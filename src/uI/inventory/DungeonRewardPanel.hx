package uI.inventory;

import account.ChestInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.uI.UIObject;
import distributedObjects.DistributedDungeonSummary;
import facade.DBFacade;
import gameMasterDictionary.GMChest;
import flash.display.MovieClip;

class DungeonRewardPanel {
	var mDungeonSummary:DistributedDungeonSummary;

	var mRewardPanel:MovieClip;

	var mDBFacade:DBFacade;

	var mSelectedCallback:ASFunction;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mDungeonRewardElements:Vector<DungeonRewardElement>;

	public function new(dbFacade:DBFacade, rewardPanelRoot:MovieClip, dungeonSummary:DistributedDungeonSummary, selectedCallback:ASFunction) {
		mDBFacade = dbFacade;
		mRewardPanel = rewardPanelRoot;
		mDungeonSummary = dungeonSummary;
		mSelectedCallback = selectedCallback;
		populateRewardPanel();
	}

	function populateRewardPanel() {
		var _loc2_:DungeonRewardElement = null;
		var _loc3_:ChestInfo = null;
		var _loc5_ = (0 : UInt);
		var _loc4_ = (0 : UInt);
		clearRewardPanel();
		mDungeonRewardElements = new Vector<DungeonRewardElement>();
		var _loc1_ = mDungeonSummary.report[0];
		ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_1, "visible", true);
		ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_2, "visible", true);
		ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_3, "visible", true);
		if (mDungeonSummary.isSingleChestList[0]) {
			ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_1, "visible", false);
			ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_2, "visible", false);
			ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_3.select, "visible", false);
		} else {
			ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_1.select, "visible", false);
			ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_2.select, "visible", false);
			ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_3, "visible", false);
		}
		var _loc6_:Array<ASAny> = [
			_loc1_.chest_type_1,
			_loc1_.chest_type_2,
			_loc1_.chest_type_3,
			_loc1_.chest_type_4
		];
		ASCompat.ASArray.sort(_loc6_, mDungeonSummary.compareChestTypes);
		_loc5_ = _loc1_.chest_type_1;
		_loc4_ = _loc1_.chest_type_2;
		_loc5_ = (ASCompat.toInt(_loc6_[0]) : UInt);
		_loc4_ = (ASCompat.toInt(_loc6_[1]) : UInt);
		if (_loc5_ > 0) {
			_loc3_ = new ChestInfo(mDBFacade, null);
			_loc3_.setParams(_loc5_);
			_loc3_.setFromDungeonSummary();
			if (mDungeonSummary.isSingleChestList[0]) {
				_loc2_ = new DungeonRewardElement(mDBFacade, ASCompat.coerce((mRewardPanel : ASAny).equip_slot_3.graphic, flash.display.MovieClip), _loc3_,
					mSelectedCallback);
			} else {
				_loc2_ = new DungeonRewardElement(mDBFacade, ASCompat.coerce((mRewardPanel : ASAny).equip_slot_1.graphic, flash.display.MovieClip), _loc3_,
					mSelectedCallback);
			}
			mDungeonRewardElements.push(_loc2_);
		}
		if (_loc4_ > 0) {
			_loc3_ = new ChestInfo(mDBFacade, null);
			_loc3_.setParams(_loc4_);
			_loc3_.setFromDungeonSummary();
			_loc2_ = new DungeonRewardElement(mDBFacade, ASCompat.coerce((mRewardPanel : ASAny).equip_slot_2.graphic, flash.display.MovieClip), _loc3_,
				mSelectedCallback);
			mDungeonRewardElements.push(_loc2_);
		}
	}

	public function setChestAsSelected(chestGM:GMChest) {
		var _loc2_ = (0 : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mDungeonRewardElements.length:UInt)) {
			if (mDungeonRewardElements[(_loc2_ : Int)].chestInfo.gmChestInfo == chestGM) {
				mDungeonRewardElements[(_loc2_ : Int)].callSelectedCallback();
				highlightChest(mDungeonRewardElements[(_loc2_ : Int)].chestInfo);
			}
			_loc2_++;
		}
	}

	public function refresh() {
		populateRewardPanel();
	}

	function clearRewardPanel() {
		var _loc1_ = (0 : UInt);
		if (mDungeonRewardElements == null) {
			return;
		}
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mDungeonRewardElements.length:UInt)) {
			mDungeonRewardElements[(_loc1_ : Int)].destroy();
			_loc1_++;
		}
		mDungeonRewardElements = null;
	}

	public function removeChestFromInventory(chestInfo:ChestInfo) {
		var _loc2_ = (0 : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mDungeonRewardElements.length:UInt)) {
			if (mDungeonRewardElements[(_loc2_ : Int)].chestInfo.gmId == chestInfo.gmId) {
				mDungeonRewardElements[(_loc2_ : Int)].empty();
			}
			_loc2_++;
		}
	}

	public function show() {
		mRewardPanel.visible = true;
	}

	public function hide() {
		mRewardPanel.visible = false;
	}

	public function highlightChest(chestInfo:ChestInfo) {
		var _loc2_ = (0 : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mDungeonRewardElements.length:UInt)) {
			if (mDungeonRewardElements[(_loc2_ : Int)].chestInfo.gmId == chestInfo.gmId) {
				mDungeonRewardElements[(_loc2_ : Int)].select();
			} else {
				mDungeonRewardElements[(_loc2_ : Int)].deSelect();
			}
			_loc2_++;
		}
	}

	public function clearHighlights() {
		var _loc1_ = (0 : UInt);
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mDungeonRewardElements.length:UInt)) {
			mDungeonRewardElements[(_loc1_ : Int)].deSelect();
			_loc1_++;
		}
	}

	public function setupChestCardNavigation(abandonButton:UIObject, keepButton:UIObject, selectedChest:ChestInfo):UIObject {
		var _loc4_:DungeonRewardElement = null;
		var _loc5_ = (0 : UInt);
		var _loc6_:DungeonRewardElement = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mDungeonRewardElements.length:UInt)) {
			_loc6_ = mDungeonRewardElements[(_loc5_ : Int)];
			_loc6_.clearNavigationAndInteractions();
			if (_loc5_ == 0) {
				abandonButton.downNavigation = _loc6_;
				_loc6_.upNavigation = abandonButton;
			} else if (_loc5_ == 1) {
				keepButton.downNavigation = _loc6_;
				_loc6_.upNavigation = keepButton;
			}
			if (_loc4_ != null) {
				_loc4_.isToTheLeftOf(_loc6_);
			}
			_loc4_ = _loc6_;
			_loc5_++;
		}
		return getNavigationEntry(selectedChest);
	}

	public function getNavigationEntry(selectedChest:ChestInfo):UIObject {
		var _loc2_:DungeonRewardElement = null;
		var _loc3_:DungeonRewardElement;
		final __ax4_iter_347 = mDungeonRewardElements;
		if (checkNullIteratee(__ax4_iter_347))
			for (_tmp_ in __ax4_iter_347) {
				_loc3_ = _tmp_;
				if (_loc2_ == null) {
					_loc2_ = _loc3_;
				}
				if (selectedChest != null && _loc3_.chestInfo.gmId == selectedChest.gmId) {
					return _loc3_;
				}
			}
		return _loc2_;
	}

	public function setupInventoryChestNavigation(abandonButton:UIObject) {
		var _loc2_:DungeonRewardElement = null;
		var _loc3_ = (0 : UInt);
		var _loc4_:DungeonRewardElement = null;
		_loc3_ = (0 : UInt);
		while (_loc3_ < (mDungeonRewardElements.length:UInt)) {
			_loc4_ = mDungeonRewardElements[(_loc3_ : Int)];
			_loc4_.clearNavigationAndInteractions();
			if (_loc3_ == 0) {
				abandonButton.downNavigation = _loc4_;
				_loc4_.upNavigation = abandonButton;
			}
			if (_loc2_ != null) {
				_loc2_.isToTheLeftOf(_loc4_);
			}
			_loc2_ = _loc4_;
			_loc3_++;
		}
	}

	public function destroy() {
		var _loc1_ = (0 : UInt);
		mDungeonSummary = null;
		mRewardPanel = null;
		mDBFacade = null;
		mSelectedCallback = null;
		mAssetLoadingComponent = null;
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mDungeonRewardElements.length:UInt)) {
			mDungeonRewardElements[(_loc1_ : Int)].destroy();
			_loc1_++;
		}
		mDungeonRewardElements = null;
	}
}
