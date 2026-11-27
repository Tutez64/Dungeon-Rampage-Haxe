package uI.popup;

import account.MapnodeInfo;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphManager;
import brain.uI.UIButton;
import brain.utils.TextUtil;
import collections.Map;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMMapNode;
import flash.display.MovieClip;
import flash.text.TextField;

class UIDistributedDungeonNextFloorSection {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_score_report.swf";

	static inline final POPUP_CLASS_NAME = "next_dungeon_popup";

	public static inline final FLOOR_VICTORY = "VICTORY";

	public static inline final FLOOR_DEFEAT = "DEFEAT";

	public static inline final FLOOR_ULTIMATE_RAMPAGE = "ULTIMATE_RAMPAGE";

	var mDBFacade:DBFacade;

	var mCurrentDungeon:GMMapNode;

	var mTypeOfPopup:String;

	var mPopup:MovieClip;

	var mBattleButton:UIButton;

	var mCallback:ASFunction;

	var mNextDungeon:GMMapNode;

	var mNextDungeonIsUltimateRampage:Bool = false;

	public function new(dbFacade:DBFacade, root:MovieClip, currentMapNode:GMMapNode, typeOfPopup:String, callback:ASFunction) {
		mDBFacade = dbFacade;
		mCurrentDungeon = currentMapNode;
		mTypeOfPopup = typeOfPopup;
		mPopup = root;
		mCallback = callback;
		mBattleButton = new UIButton(dbFacade, ASCompat.coerce((mPopup : ASAny).button_center, flash.display.MovieClip));
		mBattleButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mBattleButton.releaseCallback = buttonCallback;
		mBattleButton.enabled = false;
		mBattleButton.root.filters = cast([SceneGraphManager.getGrayScaleSaturationFilter(5)]);
		findNextDungeon();
		if (typeOfPopup == "VICTORY") {
			setDungeonName(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", mNextDungeon.Constant));
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).dungeonXp_label, flash.text.TextField),
				Std.string(mNextDungeon.CompletionXPBonus) + Locale.getString("WORLD_MAP_BONUS_XP"));
			Locale.setText(ASCompat.coerce((mPopup : ASAny).button_center.battle_text.battle_text, flash.text.TextField), "NEXT");
		}
		if (typeOfPopup == "DEFEAT") {
			setDungeonName(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", currentMapNode.Constant));
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).dungeonXp_label, flash.text.TextField),
				Std.string(mCurrentDungeon.CompletionXPBonus) + Locale.getString("WORLD_MAP_BONUS_XP"));
			Locale.setText(ASCompat.coerce((mPopup : ASAny).button_center.battle_text.battle_text, flash.text.TextField), "RETRY");
		}
		if (typeOfPopup == "ULTIMATE_RAMPAGE") {
			setDungeonName(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", currentMapNode.Constant));
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).dungeonXp_label, flash.text.TextField),
				Std.string(mCurrentDungeon.CompletionXPBonus) + Locale.getString("WORLD_MAP_BONUS_XP"));
			Locale.setText(ASCompat.coerce((mPopup : ASAny).button_center.battle_text.battle_text, flash.text.TextField), "RETRY");
		}
	}

	static function breakAtSpace(field:TextField, name:String):String {
		var _loc5_ = 0;
		var _loc6_:String = null;
		var _loc7_:String = null;
		field.text = name;
		if (field.numLines <= 1) {
			return name;
		}
		var _loc4_:Array<ASAny> = (cast name.split(" "));
		var _loc3_ = name;
		_loc5_ = _loc4_.length - 1;
		while (_loc5_ > 0) {
			_loc6_ = _loc4_.slice(0, _loc5_).join(" ");
			_loc7_ = _loc4_.slice(_loc5_).join(" ");
			if (!(_loc6_ == "" || _loc7_ == "")) {
				_loc3_ = _loc6_ + "\n" + _loc7_;
				field.text = _loc6_;
				if (field.numLines == 1) {
					return _loc3_;
				}
			}
			_loc5_--;
		}
		return _loc3_;
	}

	static function centerNameVertically(field:TextField) {
		var _loc2_ = field.height - (field.textHeight + 4) * field.scaleY;
		if (_loc2_ > 0) {
			field.y += _loc2_ / 2;
		}
	}

	public static function nextDungeonAfterWin(dbFacade:DBFacade, mapNode:GMMapNode, openNodes:Map):GMMapNode {
		var _loc5_:MapnodeInfo = null;
		if (mapNode.InfiniteDungeon != null) {
			return mapNode;
		}
		var _loc4_:GMMapNode = null;
		var _loc6_:GMMapNode;
		final __ax4_iter_30 = childNodesInPlayOrder(mapNode);
		if (checkNullIteratee(__ax4_iter_30))
			for (_tmp_ in __ax4_iter_30) {
				_loc6_ = ASCompat.coerce(_tmp_, gameMasterDictionary.GMMapNode);
				if (isPlayableAfterWin(dbFacade, _loc6_, openNodes)) {
					if (_loc4_ == null) {
						_loc4_ = _loc6_;
					}
					_loc5_ = ASCompat.coerce(openNodes.itemFor(_loc6_.Id), account.MapnodeInfo);
					if (_loc5_ == null || _loc5_.MapnodeState != 1) {
						_loc4_ = _loc6_;
						break;
					}
				}
			}
		return _loc4_ ?? mapNode;
	}

	static function childNodesInPlayOrder(mapNode:GMMapNode):Array<ASAny> {
		var _loc4_:GMMapNode = null;
		var _loc3_:Array<ASAny> = [];
		var _loc2_:ASObject;
		final __ax4_iter_31 = mapNode.ChildNodes;
		if (checkNullIteratee(__ax4_iter_31))
			for (_tmp_ in __ax4_iter_31) {
				_loc2_ = _tmp_;
				_loc4_ = ASCompat.dynamicAs(_loc2_, GMMapNode);
				if (_loc4_ != null) {
					_loc3_.push(_loc4_);
				}
			}
		ASCompat.ASArray.sortOn(_loc3_, "BitIndex", 16);
		return _loc3_;
	}

	static function isPlayableAfterWin(dbFacade:DBFacade, node:GMMapNode, openNodes:Map):Bool {
		if (openNodes.itemFor(node.Id) != null) {
			return true;
		}
		return node.LevelRequirement <= dbFacade.dbAccountInfo.activeAvatarInfo.ogLevel
			&& node.TrophyRequirement <= dbFacade.dbAccountInfo.trophies;
	}

	function setDungeonName(name:String) {
		var _loc2_ = ASCompat.coerce((mPopup : ASAny).message_label, flash.text.TextField);
		name = name.toUpperCase();
		TextUtil.setText(_loc2_, breakAtSpace(_loc2_, name));
		centerNameVertically(_loc2_);
	}

	public function destroy() {
		if (mBattleButton != null) {
			mBattleButton.destroy();
			mBattleButton = null;
		}
		mPopup = null;
		mCurrentDungeon = null;
		mNextDungeon = null;
		mCallback = null;
		mDBFacade = null;
	}

	public function buttonCallback() {
		var dbFacade = mDBFacade;
		var stateMachine = mDBFacade.mainStateMachine;
		var nextDungeonId = mNextDungeon.Id;
		var nextDungeonType = mNextDungeon.NodeType;
		stateMachine.setOneShotReloadTownCallback(function() {
			if (dbFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(nextDungeonId) == null) {
				Logger.warn("Play next skipped locked map node " + nextDungeonId + ", opening the world map instead");
				stateMachine.enterTownState(true);
				return;
			}
			stateMachine.enterLoadingScreenState(nextDungeonId, nextDungeonType);
		});
		mCallback();
	}

	public function findNextDungeon() {
		if (mTypeOfPopup != "VICTORY") {
			mNextDungeon = mCurrentDungeon;
			if (mTypeOfPopup == "ULTIMATE_RAMPAGE") {
				mNextDungeonIsUltimateRampage = true;
			}
			return;
		}
		mNextDungeon = nextDungeonAfterWin(mDBFacade, mCurrentDungeon, mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1);
		if (ASCompat.stringAsBool(mNextDungeon.InfiniteDungeon)) {
			mNextDungeonIsUltimateRampage = true;
		}
	}

	public function setButtonEnabled() {
		mBattleButton.root.filters = cast([]);
		mBattleButton.enabled = true;
	}

	@:isVar public var battleButton(get, never):UIButton;

	public function get_battleButton():UIButton {
		return mBattleButton;
	}
}
