package uI.map;

import account.MapnodeInfo;
import actor.FloatingMessage;
import actor.Revealer;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIProgressBar;
import brain.utils.ColorMatrix;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.utils.Timers;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import collections.Map;
import dBGlobals.DBGlobal;
import distributedObjects.MatchMaker;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMColiseumTier;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMInfiniteDungeon;
import gameMasterDictionary.GMMapNode;
import town.TownStateMachine;
import uI.infiniteIsland.II_UIMapBattlePopup;
import uI.popup.DBUIOneButtonPopup;
import uI.popup.DBUIUltimateRampagePopup;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Timer;

class UIMapWorldMap {
	static inline final CAMERA_LERP_SPEED:Float = 0.2916666666666667;

	static inline final DRAG_MESSAGE_TIME:Float = 17;

	static inline final ROOKIE_LEAGUE = (0 : UInt);

	static inline final GLADIATOR_LEAGUE = (1 : UInt);

	static inline final HEROIC_LEAGUE = (2 : UInt);

	static inline final GRINDER_LEAGUE = (3 : UInt);

	static inline final INFINITE_ISLAND_LEAGUE = (4 : UInt);

	static inline final MAX_NODE_NAVIGATION_STEPS = (150 : UInt);

	static var LEAGUE_BOUNDARY_NODE_IDS:Array<ASAny>;

	static final LEAGUE_DEFAULT_NODE_IDS:Vector<UInt> = Vector.ofArray(([(50002 : UInt), (50021 : UInt), (50052 : UInt), (50084 : UInt), (50156 : UInt)] : Array<UInt>));

	static var OPEN_COLOR_MATRIX:ColorMatrix = new ColorMatrix();

	static var CLOSED_COLOR_MATRIX:ColorMatrix = new ColorMatrix();

	static final ___init = {
		OPEN_COLOR_MATRIX.adjustBrightness(-20);
		OPEN_COLOR_MATRIX.adjustSaturation(0.75);
		OPEN_COLOR_MATRIX.adjustHue(65);
		CLOSED_COLOR_MATRIX.adjustBrightness(-40);
		CLOSED_COLOR_MATRIX.adjustSaturation(0);
		null;
	};

	var mWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mDBFacade:DBFacade;

	var mRootMovieClip:MovieClip;

	var mTownSwfAsset:SwfAsset;

	var mXPBar:UIProgressBar;

	var mIIBattlePopup:UIMapBattlePopup;

	var mRegularBattlePopup:UIMapBattlePopup;

	var mBattlePopup:UIMapBattlePopup;

	var mInfiniteIslandUnlocked:Bool = false;

	var mMouseTask:Task;

	var mCameraLerpTask:Task;

	var mCameraTargetX:Float = Math.NaN;

	var mCameraTargetY:Float = Math.NaN;

	var mCameraVelocityX:Float = Math.NaN;

	var mCameraVelocityY:Float = Math.NaN;

	var mOldMouseX:Float = Math.NaN;

	var mOldMouseY:Float = Math.NaN;

	var mMouseVelocityX:Float = Math.NaN;

	var mMouseVelocityY:Float = Math.NaN;

	var mCurrentNode:GMMapNode;

	var mOpenNodeButtons:Map;

	var mMapDragTask:Task;

	var mMapNodeClass:Dynamic;

	var mMapCursorKey:UInt = 0;

	var mDragCursorKey:UInt = 0;

	var mDragMessageRevealer:Revealer;

	var mDragMessageFloater:FloatingMessage;

	var mChooseDungeonMessage:FloatingMessage;

	var mShowedDragMessage:Bool = false;

	var mDidDrag:Bool = false;

	var mLeagueNameRevealer:Revealer;

	var mDidKeySpentMessage:Bool = false;

	var mUnlockSuccessful:Bool = false;

	var mUnlockResponseReceived:Bool = false;

	var mRevealer:Revealer;

	var mReturnToMapNode:GMMapNode;

	var mMapWidth:Float = Math.NaN;

	var mMapHeight:Float = Math.NaN;

	var mReturnToTownButton:UIButton;

	var mReturnToTownCallback:ASFunction;

	var mCurrentLeague:UInt = (0 : UInt);

	var mLeftLeagueButton:UIButton;

	var mRightLeagueButton:UIButton;

	var mTownStateMachine:TownStateMachine;

	var mEpochCountdownTimer:Timer;

	public function new(dbFacade:DBFacade, rootMovieClip:MovieClip, townSwfAsset:SwfAsset, townStateMachine:TownStateMachine) {
		mDBFacade = dbFacade;
		mTownStateMachine = townStateMachine;
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIMapWorldMap");
		mEventComponent = new EventComponent(mDBFacade);
		mRootMovieClip = rootMovieClip;
		mTownSwfAsset = townSwfAsset;
		mShowedDragMessage = false;
		mInfiniteIslandUnlocked = false;
	}

	static function setNodeTitle(field:TextField, text:String) {
		TextUtil.setText(field, text, 1.73);
		TextUtil.fitToField(field);
	}

	static function setNodeDescription(field:TextField, text:String) {
		TextUtil.setText(field, text, 1.55);
		TextUtil.fitToField(field);
	}

	public function initialize(tavernCallback:ASFunction, inventoryCallback:ASFunction, shopCallback:ASFunction, townCallback:ASFunction) {
		var finalLeagueBounds:Rectangle;
		var globalBottomRight:Point;
		var setReturnNode:ASFunction;
		mWorkComponent = new LogicalWorkComponent(mDBFacade, "UIMapWorldMap");
		mDBFacade.mouseCursorManager.popMouseCursor(mMapCursorKey);
		mMapCursorKey = mDBFacade.mouseCursorManager.pushMouseCursor("HAND");
		mWorkComponent.doEverySeconds(59, mDBFacade.playerActivityCount.fetchPublicDungeonActivityLevel);
		finalLeagueBounds = ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league.getRect((mRootMovieClip : ASAny)
			.worldmap.infinite_island_league), flash.geom.Rectangle);
		globalBottomRight = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league,
			flash.display.DisplayObject), finalLeagueBounds.bottomRight);
		mMapWidth = globalBottomRight.x - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x") + 390;
		mMapHeight = ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "height");
		mCurrentNode = null;
		mReturnToTownCallback = townCallback;
		setReturnNode = function(param1:ASFunction):ASFunction {
			var callback = param1;
			return function() {
				callback();
				mReturnToMapNode = mCurrentNode;
			};
		};
		mIIBattlePopup = new II_UIMapBattlePopup(mDBFacade, ASCompat.coerceFunction(setReturnNode(tavernCallback)),
			ASCompat.coerceFunction(setReturnNode(inventoryCallback)), ASCompat.coerceFunction(setReturnNode(shopCallback)), this.battleButtonCallback,
			"MapBattlePopup");
		MemoryTracker.track(mIIBattlePopup, "II_UIMapBattlePopup - created in UIMapWorldMap.UIMapWorldMap()");
		mIIBattlePopup.animatePopupOut();
		mRegularBattlePopup = new UIMapBattlePopup(mDBFacade, ASCompat.coerceFunction(setReturnNode(tavernCallback)),
			ASCompat.coerceFunction(setReturnNode(inventoryCallback)), ASCompat.coerceFunction(setReturnNode(shopCallback)), this.battleButtonCallback,
			"MapBattlePopup");
		MemoryTracker.track(mRegularBattlePopup, "UIMapBattlePopup - created in UIMapWorldMap.UIMapWorldMap()");
		mRegularBattlePopup.animatePopupOut();
		mBattlePopup = mRegularBattlePopup;
		mEventComponent.addListener(MatchMaker.EPOCH_ROLL_OVER_EVENT_NAME, epochRollOverHandler);
		mUnlockResponseReceived = false;
		mUnlockSuccessful = false;
		mDidKeySpentMessage = false;
		mCameraVelocityX = 0;
		mCameraVelocityY = 0;
		mCurrentLeague = (0 : UInt);
		mMapNodeClass = (ASCompat.constructorOf(cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer)
			.getChildByName("TUTORIAL")) : Dynamic);
		mXPBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).ui_league.UI_XP.xp_bar, flash.display.MovieClip));
		mXPBar.dontKillMyChildren = true;
		if (ASCompat.toBool((mRootMovieClip : ASAny).ui_league.UI_XP.xp_bar_delta)) {
			ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.UI_XP.xp_bar_delta, "visible", false);
		}
		setXP(mDBFacade.dbAccountInfo.activeAvatarInfo.experience, mDBFacade.dbAccountInfo.activeAvatarInfo.mAscensionLevel,
			mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero);
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_01.label, flash.text.TextField), "MAP_PAGE_ROOKIE_LEAGUE_LABEL");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_02.label, flash.text.TextField), "MAP_PAGE_GLADIATOR_LEAGUE_LABEL");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_04.label, flash.text.TextField), "MAP_PAGE_CHAMPION_LEAGUE_LABEL");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_03.label, flash.text.TextField), "MAP_PAGE_GRINDER_LEAGUE_LABEL");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_05.label, flash.text.TextField), "MAP_PAGE_INFINITE_LEAGUE_LABEL");
		mLeftLeagueButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).ui_league.shift_left, flash.display.MovieClip));
		mLeftLeagueButton.releaseCallback = function() {
			var _loc1_ = mCurrentLeague;
			mCurrentLeague = mCurrentLeague > 0 ? mCurrentLeague - 1 : (0 : UInt);
			if (_loc1_ != mCurrentLeague) {
				updateCurrentLeague();
			}
		};
		mRightLeagueButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).ui_league.shift_right, flash.display.MovieClip));
		mRightLeagueButton.releaseCallback = function() {
			var _loc1_ = mCurrentLeague;
			mCurrentLeague = determineNextLeague();
			if (_loc1_ != mCurrentLeague) {
				updateCurrentLeague();
			}
		};
		EventListeners.add(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseDown", onMouseDown);
		mDBFacade.dbAccountInfo.activeAvatarInfo.loadHeroIcon(function(param1:MovieClip) {
			UIObject.scaleToFit(param1, 40);
			(mRootMovieClip : ASAny).ui_league.ui_avatar.addChild(param1);
		});
		clearMouseEnabledOnWorldmap();
		setupMapNodeButtons();
		setupMapNodeLinks();
		if (mChooseDungeonMessage == null) {
			mWorkComponent.doLater(1, showChooseDungeonMessage);
		}
		if (!mShowedDragMessage) {
			mWorkComponent.doEverySeconds(17, function(param1:GameClock) {
				var dragMessageClass:Dynamic;
				var dragMessage:MovieClip;
				var gameClock = param1;
				if (!mDidDrag && !mDBFacade.steamInputManager.wantsControllerPrompts) {
					mShowedDragMessage = true;
					dragMessageClass = mTownSwfAsset.getClass("Branch_map_drag");
					dragMessage = ASCompat.dynamicAs(ASCompat.createInstance(dragMessageClass, []), MovieClip);
					mRootMovieClip.addChild(dragMessage);
					dragMessage.x = mDBFacade.viewWidth / 2;
					dragMessage.y = mDBFacade.viewHeight * 0.4;
					dragMessage.mouseChildren = false;
					dragMessage.mouseEnabled = false;
					dragMessage.alpha = 0;
					dragMessage.scaleX = dragMessage.scaleY = 0.9;
					if (mDragMessageRevealer != null) {
						mDragMessageRevealer.destroy();
						mDragMessageRevealer = null;
					}
					mDragMessageRevealer = new Revealer(dragMessage, mDBFacade, (24 : UInt), function() {
						mDragMessageFloater = new FloatingMessage(dragMessage, mDBFacade, (32 : UInt), (48 : UInt), 1.5, 0, null, function() {
							mRootMovieClip.removeChild(dragMessage);
						});
					}, (1 : UInt));
				}
			});
		}
		if (mReturnToMapNode != null) {
			moveAvatarToNode(mReturnToMapNode)();
			mReturnToMapNode = null;
		}
		mCameraTargetY = -156;
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "x", mCameraTargetX);
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "y", mCameraTargetY);
		updateCurrentLeague();
		clampMap();
		if (mInfiniteIslandUnlocked) {
			mDBFacade.steamAchievementsHelper.unlockAchievement("UNLOCK_ULTIMATE_RAMPAGE");
		}
	}

	function setupMapNodeLinks() {
		var _loc8_ = 0;
		var _loc9_ = (0 : UInt);
		var _loc4_:GMMapNode = null;
		var _loc7_:UIButton = null;
		var _loc5_ = (0 : UInt);
		var _loc6_:UIButton = null;
		var _loc2_ = (0 : UInt);
		var _loc3_:UIButton = null;
		var _loc1_ = mOpenNodeButtons.keysToArray();
		ASCompat.ASArray.sortWithOptions(_loc1_, 16);
		setupMapNodeNavigationUltimateRampage();
		_loc8_ = 0;
		while (_loc8_ < _loc1_.length) {
			_loc9_ = (ASCompat.toInt(_loc1_[_loc8_]) : UInt);
			if (mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc9_)) {
				_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeById.itemFor(_loc9_), gameMasterDictionary.GMMapNode);
				if (_loc4_.IsInfiniteDungeon) {
					break;
				}
				_loc7_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc9_), brain.uI.UIButton);
				_loc5_ = (ASCompat.toInt(_loc8_ > 0 ? _loc1_[_loc8_ - 1] : 0) : UInt);
				if (_loc5_ > 0) {
					_loc6_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc5_), brain.uI.UIButton);
					if (_loc6_ != null && mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc5_)) {
						_loc7_.leftNavigation = _loc6_;
					}
				}
				_loc2_ = (ASCompat.toInt(_loc8_ < _loc1_.length - 1 ? _loc1_[_loc8_ + 1] : 0) : UInt);
				if (_loc2_ > 0) {
					_loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc2_), brain.uI.UIButton);
					if (_loc3_ != null && mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc2_) && _loc2_ != 50150) {
						_loc7_.rightNavigation = _loc3_;
					}
				}
			}
			_loc8_++;
		}
		setupMapNodeMenuNavigationLeagueChangeTriggers();
		setupMapNodeNavigationGladiatorLeaguePrisonPath();
		setupMapNodeNavigationGladiatorLeagueCretaceousPath();
		setupMapNodeNavigationGladiatorLeagueFrostguardPath();
		setupMapNodeNavigationChampionLeagueKnightFortressPath();
	}

	function setupMapNodeMenuNavigationLeagueChangeTriggers() {
		var _loc2_:UIButton = null;
		var _loc3_:UIButton = null;
		var _loc1_:Array<ASAny>;
		final __ax4_iter_523 = LEAGUE_BOUNDARY_NODE_IDS;
		if (checkNullIteratee(__ax4_iter_523))
			for (_tmp_ in __ax4_iter_523) {
				_loc1_ = ASCompat.coerce(_tmp_, Array);
				_loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc1_[0]), brain.uI.UIButton);
				_loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc1_[1]), brain.uI.UIButton);
				if (_loc2_ == null || _loc3_ == null) {
					Logger.warn("Missing map node button for the league boundary between " + Std.string(_loc1_[0]) + " and " + Std.string(_loc1_[1]));
				} else {
					_loc2_.rightNavigationAdditionalInteraction = createLeagueChangeInteraction(_loc2_, true);
					_loc3_.leftNavigationAdditionalInteraction = createLeagueChangeInteraction(_loc3_, false);
				}
			}
	}

	function createLeagueChangeInteraction(sourceNode:UIButton, movingRight:Bool):ASFunction {
		return function() {
			var _loc1_ = findNavigationDestination(sourceNode, movingRight);
			if (_loc1_ != null) {
				setCurrentLeague(getButtonLeagueView(_loc1_));
			}
		};
	}

	function findNavigationDestination(sourceNode:UIButton, movingRight:Bool):UIButton {
		var _loc3_ = movingRight ? sourceNode.rightNavigation : sourceNode.leftNavigation;
		var _loc4_ = (0 : UInt);
		while (_loc3_ != null && !_loc3_.canBeFocused() && ++_loc4_ < 150) {
			_loc3_ = movingRight ? _loc3_.rightNavigation : _loc3_.leftNavigation;
		}
		return _loc3_ != null && _loc3_.canBeFocused() ? ASCompat.reinterpretAs(_loc3_, UIButton) : null;
	}

	function setupMapNodeNavigationGladiatorLeaguePrisonPath() {
		var _loc8_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50026), brain.uI.UIButton);
		var _loc6_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50027), brain.uI.UIButton);
		var _loc7_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50028), brain.uI.UIButton);
		var _loc4_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50029), brain.uI.UIButton);
		var _loc5_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50030), brain.uI.UIButton);
		var _loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50031), brain.uI.UIButton);
		var _loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50032), brain.uI.UIButton);
		var _loc1_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50033), brain.uI.UIButton);
		_loc8_.clearNavigationAndInteractions();
		_loc6_.clearNavigationAndInteractions();
		_loc7_.clearNavigationAndInteractions();
		_loc4_.clearNavigationAndInteractions();
		_loc5_.clearNavigationAndInteractions();
		_loc2_.clearNavigationAndInteractions();
		_loc3_.clearNavigationAndInteractions();
		_loc1_.clearLeftNavigation();
		_loc8_.leftNavigation = ASCompat.coerce(mOpenNodeButtons.itemFor(50025), brain.uI.UIObject);
		_loc5_.isAbove(_loc8_);
		_loc5_.leftNavigation = _loc8_;
		_loc3_.isToTheLeftOf(_loc1_);
		_loc3_.isAbove(_loc2_);
		_loc2_.isToTheLeftOf(_loc3_);
		_loc2_.isAbove(_loc5_);
		_loc5_.isToTheLeftOf(_loc2_);
		_loc8_.isToTheLeftOf(_loc6_);
		_loc6_.isToTheLeftOf(_loc7_);
		_loc7_.isToTheLeftOf(_loc4_);
		_loc4_.rightNavigation = _loc1_;
		_loc1_.isAbove(_loc4_);
	}

	function setupMapNodeNavigationGladiatorLeagueCretaceousPath() {
		var _loc8_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50036), brain.uI.UIButton);
		var _loc4_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50037), brain.uI.UIButton);
		var _loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50038), brain.uI.UIButton);
		var _loc6_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50039), brain.uI.UIButton);
		var _loc5_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50040), brain.uI.UIButton);
		var _loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50041), brain.uI.UIButton);
		var _loc1_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50042), brain.uI.UIButton);
		var _loc7_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50043), brain.uI.UIButton);
		_loc4_.clearNavigationAndInteractions();
		_loc6_.clearNavigationAndInteractions();
		_loc3_.clearNavigationAndInteractions();
		_loc2_.clearNavigationAndInteractions();
		_loc1_.clearNavigationAndInteractions();
		_loc7_.clearNavigationAndInteractions();
		_loc5_.clearNavigationAndInteractions();
		_loc4_.leftNavigation = _loc8_;
		_loc8_.downNavigation = _loc4_;
		_loc6_.isAbove(_loc4_);
		_loc6_.isToTheLeftOf(_loc5_);
		_loc5_.isAbove(_loc6_);
		_loc4_.isAbove(_loc3_);
		_loc3_.leftNavigation = _loc4_;
		_loc3_.isAbove(_loc2_);
		_loc3_.isToTheLeftOf(_loc2_);
		_loc2_.isAbove(_loc1_);
		_loc2_.isToTheLeftOf(_loc1_);
		_loc1_.isAbove(_loc7_);
		_loc1_.isToTheLeftOf(_loc7_);
	}

	function setupMapNodeNavigationGladiatorLeagueFrostguardPath() {
		var _loc9_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50044), brain.uI.UIButton);
		var _loc10_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50045), brain.uI.UIButton);
		var _loc1_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50046), brain.uI.UIButton);
		var _loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50047), brain.uI.UIButton);
		var _loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50048), brain.uI.UIButton);
		var _loc4_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50049), brain.uI.UIButton);
		var _loc5_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50050), brain.uI.UIButton);
		var _loc6_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50051), brain.uI.UIButton);
		_loc9_.clearNavigationAndInteractions();
		_loc10_.clearNavigationAndInteractions();
		_loc1_.clearNavigationAndInteractions();
		_loc2_.clearNavigationAndInteractions();
		_loc3_.clearNavigationAndInteractions();
		_loc4_.clearNavigationAndInteractions();
		_loc5_.clearNavigationAndInteractions();
		_loc6_.clearLeftNavigation();
		var _loc7_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50040), brain.uI.UIButton);
		var _loc8_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50043), brain.uI.UIButton);
		_loc8_.isToTheLeftOf(_loc9_);
		_loc7_.isToTheLeftOf(_loc3_);
		_loc9_.isToTheLeftOf(_loc10_);
		_loc10_.isAbove(_loc9_);
		_loc10_.isToTheLeftOf(_loc1_);
		_loc1_.isAbove(_loc10_);
		_loc1_.isToTheLeftOf(_loc2_);
		_loc2_.isAbove(_loc1_);
		_loc3_.isToTheLeftOf(_loc4_);
		_loc3_.isAbove(_loc4_);
		_loc4_.isToTheLeftOf(_loc5_);
		_loc4_.isAbove(_loc5_);
		_loc5_.isAbove(_loc2_);
		_loc5_.rightNavigation = _loc2_;
		_loc2_.isToTheLeftOf(_loc6_);
	}

	function setupMapNodeNavigationChampionLeagueKnightFortressPath() {
		var _loc19_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50064), brain.uI.UIButton);
		var _loc20_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50065), brain.uI.UIButton);
		var _loc22_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50066), brain.uI.UIButton);
		var _loc16_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50067), brain.uI.UIButton);
		var _loc17_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50068), brain.uI.UIButton);
		var _loc24_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50069), brain.uI.UIButton);
		var _loc5_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50070), brain.uI.UIButton);
		var _loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50071), brain.uI.UIButton);
		var _loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50072), brain.uI.UIButton);
		var _loc1_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50073), brain.uI.UIButton);
		_loc19_.clearNavigationAndInteractions();
		_loc20_.clearNavigationAndInteractions();
		_loc22_.clearNavigationAndInteractions();
		_loc16_.clearNavigationAndInteractions();
		_loc17_.clearNavigationAndInteractions();
		_loc24_.clearNavigationAndInteractions();
		_loc5_.clearNavigationAndInteractions();
		_loc2_.clearNavigationAndInteractions();
		_loc3_.clearNavigationAndInteractions();
		_loc1_.clearNavigationAndInteractions();
		_loc19_.isToTheLeftOf(_loc20_);
		_loc20_.isToTheLeftOf(_loc22_);
		_loc22_.isToTheLeftOf(_loc16_);
		_loc16_.isToTheLeftOf(_loc17_);
		_loc17_.isToTheLeftOf(_loc24_);
		_loc24_.isToTheLeftOf(_loc5_);
		_loc5_.isToTheLeftOf(_loc2_);
		_loc2_.isToTheLeftOf(_loc3_);
		_loc3_.isToTheLeftOf(_loc1_);
		var _loc10_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50057), brain.uI.UIButton);
		var _loc11_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50058), brain.uI.UIButton);
		var _loc7_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50059), brain.uI.UIButton);
		var _loc9_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50060), brain.uI.UIButton);
		var _loc4_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50061), brain.uI.UIButton);
		var _loc6_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50062), brain.uI.UIButton);
		var _loc28_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50063), brain.uI.UIButton);
		var _loc27_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50074), brain.uI.UIButton);
		var _loc26_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50075), brain.uI.UIButton);
		var _loc25_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50076), brain.uI.UIButton);
		_loc10_.clearNavigationAndInteractions();
		_loc11_.clearNavigationAndInteractions();
		_loc7_.clearNavigationAndInteractions();
		_loc9_.clearNavigationAndInteractions();
		_loc4_.clearNavigationAndInteractions();
		_loc6_.clearNavigationAndInteractions();
		_loc28_.clearNavigationAndInteractions();
		_loc27_.clearNavigationAndInteractions();
		_loc26_.clearNavigationAndInteractions();
		_loc25_.clearNavigationAndInteractions();
		_loc10_.isToTheLeftOf(_loc11_);
		_loc11_.isToTheLeftOf(_loc7_);
		_loc7_.isToTheLeftOf(_loc9_);
		_loc9_.isToTheLeftOf(_loc4_);
		_loc4_.isToTheLeftOf(_loc6_);
		_loc6_.isToTheLeftOf(_loc28_);
		_loc28_.isToTheLeftOf(_loc27_);
		_loc27_.isToTheLeftOf(_loc26_);
		_loc26_.isToTheLeftOf(_loc25_);
		var _loc8_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50077), brain.uI.UIButton);
		var _loc15_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50078), brain.uI.UIButton);
		var _loc14_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50079), brain.uI.UIButton);
		var _loc13_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50080), brain.uI.UIButton);
		var _loc12_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50081), brain.uI.UIButton);
		var _loc18_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50082), brain.uI.UIButton);
		var _loc21_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50083), brain.uI.UIButton);
		_loc8_.clearNavigationAndInteractions();
		_loc15_.clearNavigationAndInteractions();
		_loc14_.clearNavigationAndInteractions();
		_loc13_.clearNavigationAndInteractions();
		_loc12_.clearNavigationAndInteractions();
		_loc18_.clearNavigationAndInteractions();
		_loc21_.clearLeftNavigation();
		_loc1_.isAbove(_loc8_);
		_loc8_.isAbove(_loc15_);
		_loc8_.isToTheLeftOf(_loc15_);
		_loc15_.isAbove(_loc12_);
		_loc15_.rightNavigation = _loc12_;
		_loc25_.isToTheLeftOf(_loc14_);
		_loc14_.isToTheLeftOf(_loc13_);
		_loc13_.isToTheLeftOf(_loc12_);
		_loc12_.isToTheLeftOf(_loc18_);
		_loc18_.isToTheLeftOf(_loc21_);
		_loc1_.isToTheLeftOf(_loc8_);
		var _loc23_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50056), brain.uI.UIButton);
		_loc23_.clearRightNavigation();
		_loc19_.isAbove(_loc23_);
		_loc23_.isToTheLeftOf(_loc10_);
		_loc23_.isAbove(ASCompat.coerce(mOpenNodeButtons.itemFor(50055), brain.uI.UIObject));
	}

	function setupMapNodeNavigationUltimateRampage() {
		var _loc6_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50150), brain.uI.UIButton);
		var _loc8_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50151), brain.uI.UIButton);
		var _loc9_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50153), brain.uI.UIButton);
		var _loc4_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50155), brain.uI.UIButton);
		var _loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50156), brain.uI.UIButton);
		var _loc5_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50158), brain.uI.UIButton);
		var _loc10_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50159), brain.uI.UIButton);
		var _loc7_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50161), brain.uI.UIButton);
		var _loc3_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50162), brain.uI.UIButton);
		var _loc1_ = ASCompat.coerce(mOpenNodeButtons.itemFor(50099), brain.uI.UIButton);
		_loc3_.isAbove(_loc2_);
		_loc3_.isToTheLeftOf(_loc8_);
		_loc8_.isToTheLeftOf(_loc4_);
		_loc4_.isAbove(_loc6_);
		_loc6_.isAbove(_loc7_);
		_loc5_.isToTheLeftOf(_loc6_);
		_loc10_.isToTheLeftOf(_loc7_);
		_loc9_.isToTheLeftOf(_loc10_);
		_loc2_.isAbove(_loc9_);
		_loc1_.isToTheLeftOf(_loc2_);
	}

	public function getCurrentNodeButton():UIButton {
		var _loc1_ = ASCompat.coerce(mOpenNodeButtons.itemFor(mCurrentNode.Id), brain.uI.UIButton);
		if (_loc1_ != null && _loc1_.canBeFocused()) {
			return _loc1_;
		}
		var _loc2_ = findFirstNavigableNodeInLeague(getNodeLeagueValue(mCurrentNode));
		return _loc2_ ?? _loc1_;
	}

	public function getButtonLeagueView(uiObject:UIObject):UInt {
		var _loc5_ = 0;
		var _loc6_ = (0 : UInt);
		var _loc2_:UIButton = null;
		var _loc3_:GMMapNode = null;
		var _loc4_ = mOpenNodeButtons.keysToArray();
		_loc5_ = 0;
		while (_loc5_ < _loc4_.length) {
			_loc6_ = (ASCompat.toInt(_loc4_[_loc5_]) : UInt);
			_loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc6_), brain.uI.UIButton);
			if (_loc2_ == uiObject) {
				_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeById.itemFor(_loc6_), gameMasterDictionary.GMMapNode);
				return getNodeLeagueValue(_loc3_);
			}
			_loc5_++;
		}
		return (0 : UInt);
	}

	function getNodeLeagueValue(gmMapNode:GMMapNode):UInt {
		var _loc3_ = 0;
		var _loc4_:MovieClip = null;
		var _loc2_:MovieClip = null;
		_loc3_ = 0;
		while (_loc3_ <= 4) {
			_loc4_ = getLeagueClip((_loc3_ : UInt));
			_loc2_ = ASCompat.reinterpretAs(_loc4_.getChildByName(gmMapNode.Constant), MovieClip);
			if (_loc2_ != null) {
				return (_loc3_ : UInt);
			}
			_loc3_++;
		}
		return (0 : UInt);
	}

	function getLeagueClip(leagueIdx:UInt):MovieClip {
		switch (leagueIdx) {
			case 0:
				return ASCompat.coerce((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip);
			case 1:
				return ASCompat.coerce((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip);
			case 2:
				return ASCompat.coerce((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip);
			case 3:
				return ASCompat.coerce((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip);
			case 4:
				return ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip);
			default:
				return null;
		}
		return null;
	}

	public function setCurrentLeague(newLeague:UInt, doNamePop:Bool = true) {
		if (newLeague != mCurrentLeague) {
			mCurrentLeague = newLeague;
			updateCurrentLeague(doNamePop);
		}
	}

	function epochRollOverHandler(e:Event) {
		if (mBattlePopup == mIIBattlePopup) {
			mBattlePopup.animatePopupOut();
			setCurrentNode(mCurrentNode);
			mBattlePopup.animatePopupIn();
		}
	}

	function determineNextLeague():UInt {
		return mCurrentLeague < 4 ? mCurrentLeague + 1 : (4 : UInt);
	}

	public function showPreviousLeague() {
		var _loc1_ = (ASCompat.floatToInt(mCurrentLeague > 0 ? (mCurrentLeague : Float) - 1 : 0) : UInt);
		showLeagueAndFocusFirstUnlockedNode(_loc1_);
	}

	public function showNextLeague() {
		showLeagueAndFocusFirstUnlockedNode(determineNextLeague());
	}

	function showLeagueAndFocusFirstUnlockedNode(league:UInt) {
		if (league == mCurrentLeague) {
			return;
		}
		setCurrentLeague(league);
		var _loc2_ = findFirstNavigableNodeInLeague(league);
		if (_loc2_ != null) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc2_);
		}
	}

	function findFirstNavigableNodeInLeague(league:UInt):UIButton {
		var _loc5_ = 0;
		var _loc7_:MovieClip = null;
		var _loc3_:GMMapNode = null;
		var _loc4_:UIButton = null;
		var _loc2_ = ASCompat.coerce(mOpenNodeButtons.itemFor(LEAGUE_DEFAULT_NODE_IDS[(league : Int)]), brain.uI.UIButton);
		if (_loc2_ != null && _loc2_.canBeFocused()) {
			return _loc2_;
		}
		var _loc6_ = getLeagueClip(league);
		if (_loc6_ == null) {
			return null;
		}
		_loc5_ = 0;
		while (_loc5_ < _loc6_.numChildren) {
			_loc7_ = ASCompat.reinterpretAs(_loc6_.getChildAt(_loc5_), MovieClip);
			if (_loc7_ != null) {
				_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc7_.name), gameMasterDictionary.GMMapNode);
				if (_loc3_ != null) {
					_loc4_ = ASCompat.coerce(mOpenNodeButtons.itemFor(_loc3_.Id), brain.uI.UIButton);
					if (_loc4_ != null && _loc4_.canBeFocused()) {
						return _loc4_;
					}
				}
			}
			_loc5_++;
		}
		return null;
	}

	function popLeagueName(clip:MovieClip) {
		if (mLeagueNameRevealer != null) {
			mLeagueNameRevealer.destroy();
			mLeagueNameRevealer = null;
		}
		clip.scaleX = 1;
		clip.scaleY = 1;
		clip.alpha = 1;
		mLeagueNameRevealer = new Revealer(clip, mDBFacade, (10 : UInt));
	}

	function updateCurrentLeague(doNamePop:Bool = true) {
		var _loc2_:DBUIUltimateRampagePopup = null;
		var _loc3_:MovieClip = null;
		ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.clock, "visible", false);
		ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_new_dungeon, "visible", false);
		ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "visible", false);
		ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.ui_avatar, "visible", true);
		ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.UI_XP, "visible", true);
		endEpochCountdown();
		switch (mCurrentLeague) {
			case 0:
				mLeftLeagueButton.enabled = false;
				mRightLeagueButton.enabled = true;
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
				centerMapOnClip(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip), "ROOKIE");
				_loc3_ = ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_01, flash.display.MovieClip);

			case 1:
				mLeftLeagueButton.enabled = true;
				mRightLeagueButton.enabled = true;
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
				centerMapOnClip(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip), "GLADIATOR");
				_loc3_ = ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_02, flash.display.MovieClip);

			case 2:
				mLeftLeagueButton.enabled = true;
				mRightLeagueButton.enabled = true;
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
				centerMapOnClip(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip), "CHAMPION");
				_loc3_ = ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_04, flash.display.MovieClip);

			case 3:
				mLeftLeagueButton.enabled = true;
				mRightLeagueButton.enabled = true;
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
				centerMapOnClip(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip), "GRINDHOUSE");
				_loc3_ = ASCompat.coerce((mRootMovieClip : ASAny).ui_league.league_03, flash.display.MovieClip);

			case 4:
				if (mInfiniteIslandUnlocked && !mDBFacade.dbAccountInfo.hasAttribute("seenUltimatePopup")) {
					mDBFacade.dbAccountInfo.alterAttribute("seenUltimatePopup", "1");
					_loc2_ = new DBUIUltimateRampagePopup(mDBFacade);
					MemoryTracker.track(_loc2_, "DBUIOneButtonPopup - created in UIMapWorldMap.setLeague()");
				}
				mLeftLeagueButton.enabled = true;
				mRightLeagueButton.enabled = false;
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.ui_avatar, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.UI_XP, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.clock, "visible", true);
				Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.label_new_dungeon, flash.text.TextField), "INFINITE_TIMER_LABEL");
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_new_dungeon, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "text", "");
				startEpochCountdown();
				centerMapOnClip(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip), "INFINITEISLAND");
				_loc3_ = null;

			default:
				Logger.warn("Map page league paging in borked state");
		}
		if (doNamePop && _loc3_ != null) {
			popLeagueName(_loc3_);
		}
	}

	function startEpochCountdown() {
		mEpochCountdownTimer = Timers.create(1000, 0, "UIMapWorldMap.mEpochCountdownTimer");
		EventListeners.add(mEpochCountdownTimer, "timer", tickEpochCountdown);
		tickEpochCountdown(null);
		mEpochCountdownTimer.start();
	}

	function endEpochCountdown() {
		if (mEpochCountdownTimer != null) {
			EventListeners.remove(mEpochCountdownTimer, "timer", tickEpochCountdown);
			mEpochCountdownTimer.stop();
		}
	}

	function tickEpochCountdown(event:TimerEvent) {
		var _loc2_ = GameClock.getArrayTimeToEpoch();
		var _loc3_ = "";
		if (ASCompat.toNumber(_loc2_[4]) == 1) {
			_loc3_ += Std.string(_loc2_[4]) + " " + Locale.getString("EPOCH_TIMER_WEEK");
		} else if (ASCompat.toBool(_loc2_[4])) {
			_loc3_ += Std.string(_loc2_[4]) + " " + Locale.getString("EPOCH_TIMER_WEEKS");
		}
		if (ASCompat.toNumber(_loc2_[3]) == 1) {
			_loc3_ += Std.string(_loc2_[3]) + " " + Locale.getString("EPOCH_TIMER_DAY");
		} else if (ASCompat.toBool(_loc2_[3])) {
			_loc3_ += Std.string(_loc2_[3]) + " " + Locale.getString("EPOCH_TIMER_DAYS");
		}
		if (ASCompat.toNumber(_loc2_[4]) == 0 && ASCompat.toNumber(_loc2_[3]) == 0) {
			_loc3_ = ASCompat.toNumber(_loc2_[2]) + ":" + zeroPad(ASCompat.toInt(_loc2_[1]), 2) + ":" + zeroPad(ASCompat.toInt(_loc2_[0]), 2);
		}
		TextUtil.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.label_timer, flash.text.TextField), _loc3_);
	}

	public function zeroPad(number:Int, width:Int):String {
		var _loc3_ = "" + number;
		while (_loc3_.length < width) {
			_loc3_ = "0" + _loc3_;
		}
		return _loc3_;
	}

	function setXP(xp:UInt, ascensionLevel:UInt, gmHero:GMHero) {
		mXPBar.value = xp;
		var _loc6_ = gmHero.getLevelFromExp(xp, ascensionLevel);
		TextUtil.setText(ASCompat.coerce((mRootMovieClip : ASAny).ui_league.UI_XP.xp_level, flash.text.TextField), Std.string(_loc6_));
		var _loc5_ = xp;
		var _loc4_ = (gmHero.getLevelIndex(xp, (ascensionLevel : Int)) : UInt);
		var _loc8_ = (ASCompat.toInt(_loc4_ > 0 ? gmHero.getExpFromIndex(_loc4_ - 1) : 0) : UInt);
		var _loc7_ = gmHero.getExpFromIndex(_loc4_);
		mXPBar.value = ((_loc5_ : Float) - (_loc8_ : Float)) / ((_loc7_ : Float) - (_loc8_ : Float));
	}

	public function deinit() {
		var _loc1_:UIButton;
		var __ax4_iter_524:Array<ASAny>;
		mTownStateMachine = null;
		mDidDrag = false;
		mShowedDragMessage = false;
		endEpochCountdown();
		if (mXPBar != null) {
			mXPBar.destroy();
			mXPBar = null;
		}
		if (mRevealer != null) {
			mRevealer.destroy();
			mRevealer = null;
		}
		if (mLeagueNameRevealer != null) {
			mLeagueNameRevealer.destroy();
			mLeagueNameRevealer = null;
		}
		if (mChooseDungeonMessage != null) {
			mChooseDungeonMessage.destroy();
			mChooseDungeonMessage = null;
		}
		if (mDragMessageRevealer != null) {
			mDragMessageRevealer.destroy();
			mDragMessageRevealer = null;
		}
		if (mDragMessageFloater != null) {
			mDragMessageFloater.destroy();
			mDragMessageFloater = null;
		}
		if (mReturnToTownButton != null) {
			mReturnToTownButton.enabled = false;
			mReturnToTownButton.destroy();
			mReturnToTownButton = null;
		}
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseUp", onMouseUp);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOut", onMouseOut);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseLeave", onMouseOut);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseMove", onDrag);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOver", onMouseOver);
		popDragCursor();
		mDBFacade.mouseCursorManager.popMouseCursor(mMapCursorKey);
		mMapCursorKey = (0 : UInt);
		if (mIIBattlePopup != null) {
			mIIBattlePopup.destroy();
			mIIBattlePopup = null;
		}
		if (mRegularBattlePopup != null) {
			mRegularBattlePopup.destroy();
			mRegularBattlePopup = null;
		}
		mBattlePopup = null;
		if (mMouseTask != null) {
			mMouseTask.destroy();
			mMouseTask = null;
		}
		if (mCameraLerpTask != null) {
			mCameraLerpTask.destroy();
			mCameraLerpTask = null;
		}
		if (mMapDragTask != null) {
			mMapDragTask.destroy();
			mMapDragTask = null;
		}
		if (mOpenNodeButtons != null) {
			__ax4_iter_524 = mOpenNodeButtons.toArray();
			if (checkNullIteratee(__ax4_iter_524))
				for (_tmp_ in __ax4_iter_524) {
					_loc1_ = ASCompat.coerce(_tmp_, brain.uI.UIButton);
					_loc1_.enabled = false;
					_loc1_.destroy();
				}
			mOpenNodeButtons.clear();
			mOpenNodeButtons = null;
		}
		if (mMouseTask != null) {
			mMouseTask.destroy();
			mMouseTask = null;
		}
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
		if (mEventComponent != null) {
			mEventComponent.removeAllListeners();
		}
		clearTooltipLayer();
	}

	function clearTooltipLayer() {
		var tooltipLayer:flash.display.DisplayObjectContainer;
		if (mDBFacade == null || mDBFacade.sceneGraphManager == null) {
			return;
		}
		tooltipLayer = mDBFacade.sceneGraphManager.getLayer(107);
		if (tooltipLayer == null) {
			return;
		}
		while (tooltipLayer.numChildren > 0) {
			tooltipLayer.removeChildAt(0);
		}
	}

	function killCameraLerp() {
		if (mCameraLerpTask != null) {
			mCameraLerpTask.destroy();
			mCameraLerpTask = null;
			mCameraVelocityX = 0;
			mCameraVelocityY = 0;
		}
	}

	function centerMapOnClip(clip:MovieClip, islandName:String = null) {
		var _loc6_ = clip.getRect(clip);
		var _loc3_ = mDBFacade.designLocalToGlobal(clip, new Point(_loc6_.left + clip.width * 0.5, 0));
		var _loc4_ = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.display.DisplayObject), new Point(0, 0));
		var _loc5_ = _loc3_.x - _loc4_.x;
		if (islandName == "ROOKIE") {
			mCameraTargetX = 159;
		} else if (islandName == "GLADIATOR") {
			mCameraTargetX = -1950;
		} else if (islandName == "CHAMPION") {
			mCameraTargetX = -3900;
		} else if (islandName == "GRINDHOUSE") {
			mCameraTargetX = -5870;
		}
		if (islandName == "INFINITEISLAND") {
			mCameraTargetX = -8200;
		}
		if (mCameraLerpTask != null) {
			mCameraLerpTask.destroy();
		}
		mCameraVelocityX = 0;
		mCameraVelocityY = 0;
		mCameraLerpTask = mWorkComponent.doEveryFrame(centerCamera);
	}

	function centerCamera(clock:GameClock) {
		var _loc3_ = mCameraTargetX - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x");
		var _loc4_ = mCameraTargetY - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "y");
		var _loc2_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
		mCameraVelocityX = _loc3_ * 0.2916666666666667;
		var __tmpAssignObj78:ASAny = (mRootMovieClip : ASAny).worldmap;
		ASCompat.setProperty(__tmpAssignObj78, "x", __tmpAssignObj78.x + mCameraVelocityX);
		clampMap();
		if (_loc2_ < 0.0001) {
			mCameraVelocityX = 0;
			mCameraVelocityY = 0;
			killCameraLerp();
		}
	}

	function startSlide() {
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", true);
		if (mMouseTask != null) {
			mMouseTask.destroy();
			mMouseTask = null;
		}
		mMouseTask = mWorkComponent.doEveryFrame(updateSlide);
	}

	function clampMap() {
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "x", Math.min(ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x"), -13));
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "x",
			Math.max(ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x"), -mMapWidth + mDBFacade.viewWidth));
	}

	function updateSlide(clock:GameClock) {
		var _loc2_ = (0 : UInt);
		var _loc7_:Point = null;
		var _loc3_:Point = null;
		var _loc5_:Point = null;
		var _loc6_:Point = null;
		var _loc4_:Point = null;
		updateDrag(clock);
		var _loc8_ = Math.abs(mMouseVelocityX);
		if (mMouseTask != null) {
			mMouseTask.destroy();
			mMouseTask = null;
			_loc2_ = mCurrentLeague;
			if (_loc8_ > 10) {
				if (mMouseVelocityX > 0) {
					mCurrentLeague = determineNextLeague();
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				} else {
					mCurrentLeague = mCurrentLeague > 0 ? mCurrentLeague - 1 : (0 : UInt);
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				}
			} else {
				_loc7_ = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.DisplayObject),
					new Point(0, 0));
				_loc3_ = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObject),
					new Point(0, 0));
				_loc5_ = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.DisplayObject),
					new Point(0, 0));
				_loc6_ = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.DisplayObject),
					new Point(0, 0));
				_loc4_ = mDBFacade.designLocalToGlobal(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.DisplayObject),
					new Point(0, 0));
				if (Math.abs(_loc7_.x) < Math.abs(_loc3_.x)
					&& Math.abs(_loc7_.x) < Math.abs(_loc5_.x)
					&& Math.abs(_loc7_.x) < Math.abs(_loc6_.x)
					&& Math.abs(_loc7_.x) < Math.abs(_loc4_.x)) {
					mCurrentLeague = (1 : UInt);
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				} else if (Math.abs(_loc3_.x) < Math.abs(_loc7_.x)
					&& Math.abs(_loc3_.x) < Math.abs(_loc5_.x)
					&& Math.abs(_loc3_.x) < Math.abs(_loc6_.x)
					&& Math.abs(_loc3_.x) < Math.abs(_loc4_.x)) {
					mCurrentLeague = (0 : UInt);
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				} else if (Math.abs(_loc5_.x) < Math.abs(_loc3_.x)
					&& Math.abs(_loc5_.x) < Math.abs(_loc7_.x)
					&& Math.abs(_loc5_.x) < Math.abs(_loc6_.x)
					&& Math.abs(_loc5_.x) < Math.abs(_loc4_.x)) {
					mCurrentLeague = (3 : UInt);
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				} else if (Math.abs(_loc6_.x) < Math.abs(_loc3_.x)
					&& Math.abs(_loc6_.x) < Math.abs(_loc7_.x)
					&& Math.abs(_loc6_.x) < Math.abs(_loc5_.x)
					&& Math.abs(_loc6_.x) < Math.abs(_loc4_.x)) {
					mCurrentLeague = (2 : UInt);
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				} else if (Math.abs(_loc4_.x) < Math.abs(_loc3_.x)
					&& Math.abs(_loc4_.x) < Math.abs(_loc7_.x)
					&& Math.abs(_loc4_.x) < Math.abs(_loc5_.x)
					&& Math.abs(_loc4_.x) < Math.abs(_loc6_.x)) {
					mCurrentLeague = (4 : UInt);
					updateCurrentLeague(_loc2_ != mCurrentLeague);
				}
			}
		}
	}

	function updateDrag(clock:GameClock) {
		var _loc2_ = mMouseVelocityX * Math.min(0.9, clock.tickLength * 10);
		var __tmpAssignObj79:ASAny = (mRootMovieClip : ASAny).worldmap;
		ASCompat.setProperty(__tmpAssignObj79, "x", __tmpAssignObj79.x - _loc2_);
		mMouseVelocityX -= _loc2_;
		clampMap();
	}

	function onDrag(mouseEvent:MouseEvent) {
		mDidDrag = true;
		killCameraLerp();
		var _loc2_ = mOldMouseX - mouseEvent.stageX;
		mMouseVelocityX += _loc2_;
		mOldMouseX = mouseEvent.stageX;
		mOldMouseY = mouseEvent.stageY;
		clampMap();
	}

	function onMouseUp(mouseEvent:MouseEvent) {
		if (mMapDragTask != null) {
			mMapDragTask.destroy();
			mMapDragTask = null;
		}
		popDragCursor();
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", true);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseUp", onMouseUp);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOut", onMouseOut);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseLeave", onMouseOut);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseMove", onDrag);
		startSlide();
	}

	function popDragCursor() {
		mDBFacade.mouseCursorManager.popMouseCursor(mDragCursorKey);
		mDragCursorKey = (0 : UInt);
	}

	function onMouseOut(mouseEvent:MouseEvent) {
		popDragCursor();
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", true);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseUp", onMouseUp);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOut", onMouseOut);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseLeave", onMouseOut);
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseMove", onDrag);
		EventListeners.add(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOver", onMouseOver);
		startSlide();
	}

	function onMouseOver(mouseEvent:MouseEvent) {
		EventListeners.remove(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOver", onMouseOver);
		if (mouseEvent.buttonDown) {
			onMouseDown(mouseEvent);
		}
	}

	function onMouseDown(mouseEvent:MouseEvent) {
		popDragCursor();
		mDragCursorKey = mDBFacade.mouseCursorManager.pushMouseCursor("DRAG");
		if (mMouseTask != null) {
			mMouseTask.destroy();
			mMouseTask = null;
		}
		mOldMouseX = mouseEvent.stageX;
		mOldMouseY = mouseEvent.stageY;
		mMouseVelocityX = 0;
		mMouseVelocityY = 0;
		if (mMapDragTask == null) {
			mMapDragTask = mWorkComponent.doEveryFrame(updateDrag);
		}
		ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", false);
		EventListeners.add(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseMove", onDrag);
		EventListeners.add(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseUp", onMouseUp);
		EventListeners.add(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseOut", onMouseOut);
		EventListeners.add(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.events.IEventDispatcher), "mouseLeave", onMouseOut);
	}

	function clearMouseEnabledOnWorldmap() {
		var _loc1_ = (0 : UInt);
		var _loc2_:MovieClip = null;
		_loc1_ = (0 : UInt);
		while (_loc1_ < ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "numChildren")) {
			_loc2_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.getChildAt(_loc1_), MovieClip);
			if (_loc2_ != null
				&& _loc2_ != (mRootMovieClip : ASAny).worldmap.TOWNBUTTON
					&& _loc2_ != (mRootMovieClip : ASAny).worldmap.rookie_league
						&& _loc2_ != (mRootMovieClip : ASAny).worldmap.gladiator_league
							&& _loc2_ != (mRootMovieClip : ASAny).worldmap.grinder_league
								&& _loc2_ != (mRootMovieClip : ASAny).worldmap.heroic_league
									&& _loc2_ != (mRootMovieClip : ASAny).worldmap.infinite_island_league) {
				_loc2_.mouseChildren = false;
				_loc2_.mouseEnabled = false;
			}
			_loc1_++;
		}
	}

	function revealCallback(childClip:MovieClip):ASFunction {
		return function(param1:GameClock) {
			var _loc2_:Revealer = null;
			if (childClip != null) {
				childClip.visible = true;
				_loc2_ = new Revealer(childClip, mDBFacade, (24 : UInt));
			}
		};
	}

	function mapNodesOpen(mapNodes:Array<ASAny>, andDefeated:Bool = false):Bool {
		var _loc4_ = (0 : UInt);
		var _loc3_:GMMapNode = null;
		if (mapNodes == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null) {
			return false;
		}
		_loc4_ = (0 : UInt);
		while (_loc4_ < (mapNodes.length:UInt)) {
			_loc3_ = ASCompat.coerce(mapNodes[(_loc4_ : Int)], gameMasterDictionary.GMMapNode);
			if (mapNodeOpen(_loc3_, andDefeated)) {
				return true;
			}
			_loc4_++;
		}
		return false;
	}

	function mapNodeOpen(mapNode:GMMapNode, andDefeated:Bool = false):Bool {
		if (mapNode == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null) {
			return false;
		}
		var _loc3_ = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mapNode.Id), account.MapnodeInfo);
		return _loc3_ != null && (!andDefeated || _loc3_.MapnodeState == 1 || _loc3_.MapnodeState == 3);
	}

	function mapNodeOpenNotDefeated(mapNode:GMMapNode):Bool {
		if (mapNode == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null) {
			return false;
		}
		var _loc2_ = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mapNode.Id), account.MapnodeInfo);
		return _loc2_ != null && _loc2_.MapnodeState == 3;
	}

	function mapNodeLocked(mapNode:GMMapNode):Bool {
		if (mapNode == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null) {
			return false;
		}
		var _loc2_ = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mapNode.Id), account.MapnodeInfo);
		return _loc2_ == null;
	}

	function getUnlockedNodes():Array<ASAny> {
		return mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.toArray();
	}

	function hasLockedNextNode(node:GMMapNode):Bool {
		var _loc2_:GMMapNode;
		final __ax4_iter_525 = node.ChildNodes;
		if (checkNullIteratee(__ax4_iter_525))
			for (_tmp_ in __ax4_iter_525) {
				_loc2_ = ASCompat.coerce(_tmp_, gameMasterDictionary.GMMapNode);
				if (_loc2_ != null) {
					if (mapNodeLocked(_loc2_)) {
						return true;
					}
				}
			}
		return false;
	}

	function hasUnlockedChild(node:GMMapNode):Bool {
		var _loc2_:GMMapNode = null;
		var _loc3_:String;
		final __ax4_iter_526 = node.RevealNodes;
		if (checkNullIteratee(__ax4_iter_526))
			for (_tmp_ in __ax4_iter_526) {
				_loc3_ = _tmp_;
				if (ASCompat.stringAsBool(_loc3_)) {
					_loc2_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc3_), gameMasterDictionary.GMMapNode);
					if (_loc2_ != null && mapNodeOpen(_loc2_, true)) {
						return true;
					}
				}
			}
		return false;
	}

	function getClipFromConstant(nodeConstant:String):MovieClip {
		var _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer)
			.getChildByName(nodeConstant), MovieClip);
		if (_loc2_ == null) {
			_loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.DisplayObjectContainer)
				.getChildByName(nodeConstant), MovieClip);
			if (_loc2_ == null) {
				_loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.DisplayObjectContainer)
					.getChildByName(nodeConstant), MovieClip);
				if (_loc2_ == null) {
					_loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.DisplayObjectContainer)
						.getChildByName(nodeConstant), MovieClip);
					if (_loc2_ == null) {
						_loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.DisplayObjectContainer)
							.getChildByName(nodeConstant),
							MovieClip);
						if (_loc2_ == null) {
							return null;
						}
					}
				}
			}
		}
		return _loc2_;
	}

	function revealChildNodes(node:GMMapNode) {
		var _loc3_:GMMapNode = null;
		var _loc2_:MovieClip = null;
		var _loc5_:GMMapNode = null;
		var _loc6_ = getClipFromConstant(node.Constant);
		if (_loc6_ == null) {
			return;
		}
		_loc6_.visible = true;
		var _loc7_:Float = 0.15;
		var _loc4_ = hasUnlockedChild(node);
		var _loc8_:String;
		final __ax4_iter_527 = node.RevealNodes;
		if (checkNullIteratee(__ax4_iter_527))
			for (_tmp_ in __ax4_iter_527) {
				_loc8_ = _tmp_;
				if (ASCompat.stringAsBool(_loc8_)) {
					_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc8_), gameMasterDictionary.GMMapNode);
					if (!(_loc3_ != null && mapNodeOpen(_loc3_, true))) {
						_loc2_ = getClipFromConstant(_loc8_);
						if (_loc4_) {
							if (_loc2_ != null) {
								_loc2_.visible = true;
							}
						} else if (_loc2_ != null) {
							_loc5_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc2_.name), gameMasterDictionary.GMMapNode);
							if (_loc5_ != null && !_loc5_.AlwaysVisible) {
								mWorkComponent.doLater(_loc7_, revealCallback(_loc2_));
								_loc7_ += 0.15;
							}
						}
					}
				}
			}
	}

	function initializeLeagueMapNodes(league:MovieClip, isInfiniteLeague:Bool = false) {
		var _loc5_ = (0 : UInt);
		var _loc3_:MovieClip = null;
		var _loc4_:GMMapNode = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (league.numChildren:UInt)) {
			_loc3_ = ASCompat.reinterpretAs(league.getChildAt((_loc5_ : Int)), MovieClip);
			if (_loc3_ != null) {
				ASCompat.setProperty((_loc3_ : ASAny).arrow, "visible", false);
				ASCompat.setProperty((_loc3_ : ASAny).arrow, "mouseEnabled", false);
				ASCompat.setProperty((_loc3_ : ASAny).arrow, "mouseChildren", false);
				if (ASCompat.toBool((_loc3_ : ASAny).defeated)
					&& ASCompat.toBool((_loc3_ : ASAny).unlocked)
					&& ASCompat.toBool((_loc3_ : ASAny).locked)) {
					ASCompat.setProperty((_loc3_ : ASAny).defeated, "visible", false);
					ASCompat.setProperty((_loc3_ : ASAny).unlocked, "visible", false);
					ASCompat.setProperty((_loc3_ : ASAny).locked, "visible", true);
				}
				if (ASCompat.toBool((_loc3_ : ASAny).lock)) {
					ASCompat.setProperty((_loc3_ : ASAny).lock, "visible", false);
					ASCompat.setProperty((_loc3_ : ASAny).lock, "mouseEnabled", false);
				}
				if (ASCompat.toBool((_loc3_ : ASAny).text_popup) && ASCompat.toBool((_loc3_ : ASAny).text_popup.title_label)) {
					ASCompat.setProperty((_loc3_ : ASAny).text_popup, "visible", false);
					setNodeTitle(ASCompat.coerce((_loc3_ : ASAny).text_popup.title_label, flash.text.TextField), Locale.getString("DUNGEON_LOCKED_TITLE"));
				}
				if (ASCompat.toBool((_loc3_ : ASAny).label)) {
					ASCompat.setProperty((_loc3_ : ASAny).label, "text", "");
				}
				_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc3_.name), gameMasterDictionary.GMMapNode);
				if (_loc4_ == null) {
					Logger.warn("Can\'t find gmMapNode for: " + _loc3_.name);
				} else if (!_loc4_.AlwaysVisible) {
					_loc3_.visible = false;
				}
			}
			_loc5_++;
		}
	}

	function initializeAllMapNodes() {
		var _loc2_ = (0 : UInt);
		var _loc1_:MovieClip = null;
		_loc2_ = (0 : UInt);
		while (_loc2_ < ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "numChildren")) {
			_loc1_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.getChildAt(_loc2_), MovieClip);
			if (_loc1_ != null && _loc1_.name.indexOf("_unlocked") != -1) {
				_loc1_.visible = false;
			}
			_loc2_++;
		}
		initializeLeagueMapNodes(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip));
		initializeLeagueMapNodes(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip));
		initializeLeagueMapNodes(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip));
		initializeLeagueMapNodes(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip));
		initializeLeagueMapNodes(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip), true);
	}

	function initializeOpenMapNodes() {
		var _loc8_:MapnodeInfo = null;
		var _loc5_:GMMapNode = null;
		var _loc2_:MovieClip = null;
		var _loc9_:String = null;
		var _loc11_:GMColiseumTier = null;
		var _loc3_ = 0;
		var _loc10_:GMInfiniteDungeon = null;
		var _loc1_:Array<ASAny> = null;
		var _loc7_ = 0;
		var _loc4_ = getUnlockedNodes();
		_loc4_.sort(Reflect.compare);
		var _loc6_ = (0 : UInt);
		mCurrentLeague = (0 : UInt);
		ASCompat.ASArray.sortOn(_loc4_, "nodeId", 16);
		_loc6_ = (0 : UInt);
		while (_loc6_ < (_loc4_.length:UInt)) {
			_loc8_ = ASCompat.dynamicAs(_loc4_[(_loc6_ : Int)], MapnodeInfo);
			_loc5_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeById.itemFor(_loc8_.nodeId), gameMasterDictionary.GMMapNode);
			if (_loc5_ != null) {
				_loc2_ = ASCompat.coerce(cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer)
					.getChildByName(_loc5_.Constant),
					flash.display.MovieClip);
				if (_loc2_ == null) {
					_loc2_ = ASCompat.coerce(cast((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.DisplayObjectContainer)
						.getChildByName(_loc5_.Constant),
						flash.display.MovieClip);
					mCurrentLeague = _loc2_ != null && mCurrentLeague < 1 ? (1 : UInt) : mCurrentLeague;
					if (_loc2_ == null) {
						_loc2_ = ASCompat.coerce(cast((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.DisplayObjectContainer)
							.getChildByName(_loc5_.Constant),
							flash.display.MovieClip);
						mCurrentLeague = _loc2_ != null && mCurrentLeague < 3 ? (3 : UInt) : mCurrentLeague;
						if (_loc2_ == null) {
							_loc2_ = ASCompat.coerce(cast((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.DisplayObjectContainer)
								.getChildByName(_loc5_.Constant),
								flash.display.MovieClip);
							mCurrentLeague = _loc2_ != null && mCurrentLeague < 2 ? (2 : UInt) : mCurrentLeague;
							if (_loc2_ == null) {
								_loc2_ = ASCompat.coerce(cast((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.DisplayObjectContainer)
									.getChildByName(_loc5_.Constant),
									flash.display.MovieClip);
								mCurrentLeague = _loc2_ != null && mCurrentLeague < 4 ? (4 : UInt) : mCurrentLeague;
								if (_loc2_ == null) {
									Logger.warn("Can\'t find movie clip node for gmMapNode Constant: " + _loc5_.Constant);
								}
							}
						}
					}
				}
				mCurrentNode = _loc5_;
				setPopulationGlowState(_loc2_, _loc5_);
				if (_loc2_ != null) {
					if (ASCompat.toBool((_loc2_ : ASAny).text_popup)
						&& ASCompat.toBool((_loc2_ : ASAny).text_popup.title_label)
						&& ASCompat.toBool((_loc2_ : ASAny).text_popup.description_label)) {
						ASCompat.setProperty((_loc2_ : ASAny).text_popup, "visible", true);
						setNodeTitle(ASCompat.coerce((_loc2_ : ASAny).text_popup.title_label, flash.text.TextField),
							GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", _loc5_.Constant).toUpperCase());
						_loc11_ = ASCompat.coerce(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(_loc5_.TierRank), gameMasterDictionary.GMColiseumTier);
						if (_loc11_.TotalFloors > 0 && _loc5_.NodeType != GMMapNode.BOSS_NODE_TYPE) {
							_loc9_ = _loc11_.TotalFloors > 1 ? Locale.getString("FLOORS") : Locale.getString("FLOOR");
							if (_loc11_.TotalFloors >= 50) {
								setNodeDescription(ASCompat.coerce((_loc2_ : ASAny).text_popup.description_label, flash.text.TextField),
									Locale.getString("INFINITE_FLOORS_POPUP"));
							} else {
								setNodeDescription(ASCompat.coerce((_loc2_ : ASAny).text_popup.description_label, flash.text.TextField),
									Std.string(_loc11_.TotalFloors) + " " + _loc9_);
							}
						} else {
							setNodeDescription(ASCompat.coerce((_loc2_ : ASAny).text_popup.description_label, flash.text.TextField),
								GameMasterLocale.getGameMasterSubString("DUNGEON_DIFFICULTY_NAME", _loc5_.Constant));
						}
					}
					_loc2_.visible = true;
					ASCompat.setProperty((_loc2_ : ASAny).arrow, "visible", false);
					ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseEnabled", false);
					ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseChildren", false);
					if (ASCompat.toBool((_loc2_ : ASAny).locked)) {
						ASCompat.setProperty((_loc2_ : ASAny).locked, "visible", false);
					}
					if (mapNodeOpenNotDefeated(_loc5_)) {
						ASCompat.setProperty((_loc2_ : ASAny).unlocked, "visible", true);
						revealChildNodes(_loc5_);
					} else if (mapNodeOpen(_loc5_, true)) {
						if (ASCompat.toBool((_loc2_ : ASAny).defeated)) {
							ASCompat.setProperty((_loc2_ : ASAny).defeated, "visible", true);
						}
						revealChildNodes(_loc5_);
					} else if (ASCompat.toBool((_loc2_ : ASAny).unlocked)) {
						ASCompat.setProperty((_loc2_ : ASAny).unlocked, "visible", true);
						if (hasLockedNextNode(_loc5_)) {
							ASCompat.setProperty((_loc2_ : ASAny).arrow, "visible", true);
							ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseChildren", false);
							ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseEnabled", false);
						}
					}
					if (_loc5_.IsInfiniteDungeon) {
						if (mDBFacade.dbAccountInfo.localFriendInfo == null) {
							return;
						}
						_loc3_ = mDBFacade.dbAccountInfo.localFriendInfo.getIIAvatarScoreForNode((mDBFacade.dbAccountInfo.activeAvatarId : Int),
							(_loc5_.Id : Int));
						_loc10_ = ASCompat.coerce(mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(_loc5_.InfiniteDungeon),
							gameMasterDictionary.GMInfiniteDungeon);
						_loc1_ = [
							(_loc2_ : ASAny)
							.reward01,
							(_loc2_ : ASAny)
							.reward02,
							(_loc2_ : ASAny)
							.reward03,
							(_loc2_ : ASAny)
							.reward04
						];
						_loc7_ = 0;
						while (_loc7_ < 4) {
							ASCompat.setProperty(_loc1_[_loc7_], "visible", (_loc3_ : UInt) > _loc10_.RewardFloors[_loc7_]);
							_loc7_++;
						}
					}
					if (ASCompat.toBool((_loc2_ : ASAny).label) && mCurrentLeague != 3) {
						TextUtil.setText(ASCompat.coerce((_loc2_ : ASAny).label, flash.text.TextField),
							GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", _loc5_.Constant).toUpperCase());
					} else if (ASCompat.toBool((_loc2_ : ASAny).label) && mCurrentLeague == 3) {
						ASCompat.setProperty((_loc2_ : ASAny).label, "visible", false);
					}
				}
			}
			_loc6_++;
		}
	}

	function setPopulationGlowState(node:MovieClip, mMapNode:GMMapNode) {
		if (node == null || mMapNode == null) {
			return;
		}
		var _loc4_ = ASCompat.asString(mDBFacade.playerActivityCount.publicDungeonActivityLevel[Std.string(mMapNode.Id)]);
		var _loc3_ = mDBFacade.playerActivityCount.getPopulationGlow(_loc4_);
		if (_loc3_ != null) {
			node.filters = cast([_loc3_]);
		}
	}

	function createNodeButtonsForLeague(league:MovieClip):Bool {
		var _loc5_ = (0 : UInt);
		var _loc10_:MovieClip = null;
		var _loc13_ = false;
		var _loc11_ = false;
		var _loc3_:GMMapNode = null;
		var _loc9_:MovieClip = null;
		var _loc4_:MovieClipRenderController = null;
		var _loc7_ = (0 : UInt);
		var _loc6_:GMMapNode = null;
		var _loc14_:MovieClip = null;
		var _loc8_:UIButton = null;
		var _loc12_:UIButton = null;
		var _loc2_ = false;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (league.numChildren:UInt)) {
			_loc10_ = ASCompat.reinterpretAs(league.getChildAt((_loc5_ : Int)), MovieClip);
			if (_loc10_ != null) {
				_loc13_ = false;
				_loc11_ = false;
				_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc10_.name), gameMasterDictionary.GMMapNode);
				if (_loc3_ != null) {
					if (mapNodesOpen(_loc3_.ParentNodes, false)) {
						if (_loc3_.LevelRequirement <= mDBFacade.dbAccountInfo.activeAvatarInfo.ogLevel) {
							if (ASCompat.toBool((_loc10_ : ASAny).level_req)) {
								ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", false);
							}
						} else {
							_loc13_ = true;
							if (ASCompat.toBool((_loc10_ : ASAny).level_req)) {
								ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", true);
								TextUtil.setText(ASCompat.coerce((_loc10_ : ASAny).level_req.level_label, flash.text.TextField),
									Std.string(_loc3_.LevelRequirement));
							}
							if (ASCompat.toBool((_loc10_ : ASAny).text_popup)) {
								setNodeDescription(ASCompat.coerce((_loc10_ : ASAny).text_popup.description_label, flash.text.TextField),
									"You are not high enough level to play this dungeon.");
							}
						}
						if (_loc3_.TrophyRequirement <= mDBFacade.dbAccountInfo.trophies) {
							if (ASCompat.toBool((_loc10_ : ASAny).level_req)) {
								ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", false);
								ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", false);
							}
						} else {
							_loc13_ = true;
							if ((_loc10_ : ASAny).level_req.visible == true) {
								ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", false);
								ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", false);
								ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", true);
								TextUtil.setText(ASCompat.coerce((_loc10_ : ASAny).trophy_req_left.level_label, flash.text.TextField),
									Std.string(_loc3_.LevelRequirement));
								TextUtil.setText(ASCompat.coerce((_loc10_ : ASAny).trophy_req_left.trophy_label, flash.text.TextField),
									Std.string(_loc3_.TrophyRequirement));
								setNodeDescription(ASCompat.coerce((_loc10_ : ASAny).text_popup.description_label, flash.text.TextField),
									"Not high enough level, and not enough trophies.");
							} else {
								ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", false);
								ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", true);
								TextUtil.setText(ASCompat.coerce((_loc10_ : ASAny).trophy_req.trophy_label, flash.text.TextField),
									Std.string(_loc3_.TrophyRequirement));
								setNodeDescription(ASCompat.coerce((_loc10_ : ASAny).text_popup.description_label, flash.text.TextField),
									"Not enough trophies to play this dungeon.");
							}
						}
						if (_loc13_) {
							if (ASCompat.toBool((_loc10_ : ASAny).lock)) {
								ASCompat.setProperty((_loc10_ : ASAny).lock, "visible", true);
							}
							_loc11_ = true;
						} else if (!mapNodesOpen(_loc3_.ParentNodes, true)) {
							if (ASCompat.toBool((_loc10_ : ASAny).lock)) {
								ASCompat.setProperty((_loc10_ : ASAny).lock, "visible", true);
							}
							_loc13_ = true;
						}
					} else if (ASCompat.toBool((_loc10_ : ASAny).level_req) && ASCompat.toBool((_loc10_ : ASAny).trophy_req)) {
						ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", false);
						ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", false);
						ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", false);
					}
					if ((_loc10_ : ASAny).unlocked.visible == true) {
						_loc9_ = ASCompat.coerce((_loc10_ : ASAny).unlocked, flash.display.MovieClip);
						_loc4_ = new MovieClipRenderController(mDBFacade, _loc9_);
						_loc4_.play((0 : UInt), true);
					} else if ((_loc10_ : ASAny).defeated.visible == true) {
						_loc9_ = ASCompat.coerce((_loc10_ : ASAny).defeated, flash.display.MovieClip);
					} else {
						_loc13_ = true;
						_loc9_ = ASCompat.coerce((_loc10_ : ASAny).locked, flash.display.MovieClip);
					}
					if (!_loc13_) {
						_loc2_ = true;
						_loc7_ = (0 : UInt);
						while (_loc7_ < (_loc3_.ParentNodes.length:UInt)) {
							_loc6_ = ASCompat.coerce(_loc3_.ParentNodes[(_loc7_ : Int)], gameMasterDictionary.GMMapNode);
							if (_loc6_ != null && mapNodeOpen(_loc6_, true)) {
								_loc14_ = ASCompat.coerce(cast((mRootMovieClip : ASAny).worldmap, flash.display.DisplayObjectContainer)
									.getChildByName(_loc6_.Constant
									+ "_" + _loc3_.Constant + "_unlocked"),
									flash.display.MovieClip);
								if (_loc14_ != null) {
									_loc14_.visible = true;
									_loc4_ = new MovieClipRenderController(mDBFacade, _loc14_);
									if (_loc9_ == (_loc10_ : ASAny).unlocked) {
										_loc4_.play((0 : UInt), false);
									} else {
										_loc4_.setFrame((_loc14_.totalFrames - 1:UInt));
									}
								}
							}
							_loc7_++;
						}
						_loc8_ = new UIMapNodeButton(mDBFacade, _loc9_, true);
						_loc8_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
						_loc8_.releaseCallback = moveAvatarToNode(_loc3_);
						_loc8_.rollOverCursor = "POINT";
						_loc8_.dontKillMyChildren = true;
						ASCompat.setProperty((_loc10_ : ASAny).text_popup, "x", 0);
						ASCompat.setProperty((_loc10_ : ASAny).text_popup, "y", 0);
						_loc8_.tooltip = ASCompat.coerce((_loc10_ : ASAny).text_popup, flash.display.MovieClip);
						_loc8_.lockTooltipToParent(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.display.DisplayObjectContainer));
						mOpenNodeButtons.add(_loc3_.Id, _loc8_);
					} else {
						_loc12_ = new UIMapNodeButton(mDBFacade, _loc9_, false);
						if (ASCompat.toBool((_loc10_ : ASAny).text_popup)
							&& ASCompat.toBool((_loc10_ : ASAny).text_popup.description_label)) {
							if (!_loc11_) {
								setNodeDescription(ASCompat.coerce((_loc10_ : ASAny).text_popup.description_label, flash.text.TextField),
									Locale.getString("DUNGEON_LOCKED_DESCRIPTION"));
							}
							ASCompat.setProperty((_loc10_ : ASAny).text_popup, "x", 0);
							ASCompat.setProperty((_loc10_ : ASAny).text_popup, "y", 0);
							ASCompat.setProperty((_loc10_ : ASAny).text_popup, "visible", true);
							_loc12_.tooltip = ASCompat.coerce((_loc10_ : ASAny).text_popup, flash.display.MovieClip);
							_loc12_.lockTooltipToParent(ASCompat.coerce((mRootMovieClip : ASAny).worldmap, flash.display.DisplayObjectContainer));
						}
						_loc12_.rolloverFilter = DBGlobal.UI_DISABLED_FILTER;
						_loc12_.releaseCallback = null;
						_loc12_.rollOverCursor = "POINT";
						_loc12_.dontKillMyChildren = true;
						mOpenNodeButtons.add(_loc3_.Id, _loc12_);
					}
				} else {
					Logger.warn("Badly named map node in worldmap: " + _loc10_.name + " for node: " + _loc3_);
				}
			}
			_loc5_++;
		}
		return _loc2_;
	}

	function setupMapNodeButtons() {
		mOpenNodeButtons = new Map();
		initializeAllMapNodes();
		initializeOpenMapNodes();
		createNodeButtonsForLeague(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip));
		createNodeButtonsForLeague(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip));
		createNodeButtonsForLeague(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip));
		createNodeButtonsForLeague(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip));
		mInfiniteIslandUnlocked = createNodeButtonsForLeague(ASCompat.coerce((mRootMovieClip : ASAny).worldmap.infinite_island_league,
			flash.display.MovieClip));
		setCurrentNode(mCurrentNode);
	}

	function moveAvatarToNode(gmMapNode:GMMapNode, force:Bool = false, returningToNodeFromAnotherScreen:Bool = false):ASFunction {
		return function() {
			setCurrentNode(gmMapNode);
			if (mapNodeOpen(gmMapNode, false) || mapNodesOpen(gmMapNode.ParentNodes, true)) {
				mBattlePopup.animatePopupIn();
				return;
			}
			mBattlePopup.animatePopupOut();
		};
	}

	function setCurrentNode(currentNode:GMMapNode) {
		mCurrentNode = currentNode;
		if (mCurrentNode != null) {
			if (mCurrentNode.IsInfiniteDungeon) {
				mBattlePopup = mIIBattlePopup;
			} else {
				mBattlePopup = mRegularBattlePopup;
			}
			mBattlePopup.currentDungeon = mCurrentNode;
			mBattlePopup.mapNodeOpen = mapNodeOpen(mCurrentNode);
			mBattlePopup.setDungeonDetails();
		}
	}

	public function battleButtonCallback() {
		var _loc2_:DBUIOneButtonPopup = null;
		var _loc1_:DBUIOneButtonPopup = null;
		if (mCurrentNode.LevelRequirement <= mDBFacade.dbAccountInfo.activeAvatarInfo.ogLevel) {
			if (mCurrentNode.TrophyRequirement > mDBFacade.dbAccountInfo.trophies) {
				mDBFacade.metrics.log("NotEnoughTrophiesWarning");
				_loc2_ = new DBUIOneButtonPopup(mDBFacade, "MAP_DEBUG_POPUP", "STOP IT!", "NO! NOT ENOUGH TROPHIES!", "OK", null);
				MemoryTracker.track(_loc2_, "DBUIOneButtonPopup - created in UIMapWorldMap.battleButtonCallback()");
				return;
			}
			if (mapNodeOpen(mCurrentNode)) {
				mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id, mCurrentNode.NodeType, (0 : UInt), (0 : UInt), true,
					mBattlePopup.IsPrivate);
			}
		} else {
			_loc1_ = new DBUIOneButtonPopup(mDBFacade, "MAP_DEBUG_POPUP", "STOP IT!", "NO! NOT HIGH ENOUGH LEVEL!", "OK", null);
			MemoryTracker.track(_loc1_, "DBUIOneButtonPopup - created in UIMapWorldMap.battleButtonCallback()");
		}
	}

	function showChooseDungeonMessage(clock:GameClock) {
		var messageClass = mTownSwfAsset.getClass("Branch_choose_dungeon");
		var messageClip = ASCompat.dynamicAs(ASCompat.createInstance(messageClass, []), MovieClip);
		mRootMovieClip.addChild(messageClip);
		messageClip.x = mDBFacade.viewWidth / 2;
		messageClip.y = mDBFacade.viewHeight * 0.4;
		messageClip.scaleX = messageClip.scaleY = 1.5;
		messageClip.mouseChildren = false;
		messageClip.mouseEnabled = false;
		messageClip.alpha = 0;
		mRevealer = new Revealer(messageClip, mDBFacade, (32 : UInt), function() {
			mChooseDungeonMessage = new FloatingMessage(messageClip, mDBFacade, (32 : UInt), (32 : UInt), 1.35, 0, null, function() {
				mChooseDungeonMessage = null;
				mRootMovieClip.removeChild(messageClip);
			});
		}, (1 : UInt));
	}

	static function __init__() {
		LEAGUE_BOUNDARY_NODE_IDS = [[50020, 50021], [50051, 50052], [50083, 50084], [50099, 50156]];
	}
}
