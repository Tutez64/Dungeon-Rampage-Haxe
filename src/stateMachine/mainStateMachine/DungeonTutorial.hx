package stateMachine.mainStateMachine;

import actor.player.input.DungeonBusterControlActivatedEvent;
import brain.assetRepository.AssetLoadingComponent;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.render.MovieClipRenderer;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import facade.DBFacade;
import facade.Locale;
import input.keyBindings.InputAction;
import steamInput.OnSteamInputButtonPressedEvent;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;

class DungeonTutorial {
	public static inline final MOVEMENT_TUTORIAL = "MOVEMENT_TUTORIAL";

	public static inline final BUSTER_TUTORIAL = "BUSTER_TUTORIAL";

	public static inline final CHARGE_TUTORIAL = "CHARGE_TUTORIAL";

	public static inline final REVIVE_TUTORIAL = "REVIVE_TUTORIAL";

	public static inline final LOOT_SHARING_TUTORIAL = "LOOT_SHARING_TUTORIAL";

	public static inline final SUPER_WEAK_TUTORIAL = "SUPER_WEAK_TUTORIAL";

	public static inline final TUTORIAL_PANEL_LEFT = "TUTORIAL_PANEL_LEFT";

	public static inline final TUTORIAL_PANEL_RIGHT = "TUTORIAL_PANEL_RIGHT";

	public static inline final REVIVE_SPACEBAR_PRESSED_EVENT = "REVIVE_SPACEBAR_PRESSED";

	public static inline final CHEST_TUTORIAL_NEARBY = "CHEST_TUTORIAL_NEARBY";

	public static inline final CHEST_TUTORIAL_COLLECTED = "CHEST_TUTORIAL_COLLECTED";

	public static inline final COOLDOWN_TUTORIAL = "COOLDOWN_TUTORIAL";

	public static inline final SCALING_TUTORIAL = "SCALING_TUTORIAL";

	public static inline final REPEATER_TUTORIAL = "REPEATER_TUTORIAL";

	static inline final ATTACK_POPUP_DELAY:Float = 1;

	static inline final TUTORIAL_SWF = "Resources/Art2D/UI/db_UI_screens.swf";

	static inline final CARD_SCALE:Float = 1;

	static inline final LOOT_CARD_SCALE:Float = 1.1764705882352942;

	static inline final CONTROLLER_GLYPH_SIZE:Float = 56;

	static inline final CONTROLLER_STICK_GLYPH_SIZE:Float = 80;

	static inline final GAMEPAD_MOVEMENT_DEADZONE:Float = 0.05;

	static var ATTACK_ACTIONS:Array<ASAny>;

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mMovementTutorialDone:Bool = false;

	var mMovementPopup:MovieClip;

	var mGamepadMovementTask:Task;

	var mAttackTutorialDone:Bool = false;

	var mAttackPopup:MovieClip;

	var mChestTutorialDone:Bool = false;

	var mChestCloseButton:UIButton;

	var mChestPopup:MovieClip;

	var mCooldownRenderer:MovieClipRenderer;

	var mCooldownTutorialReadyToClose:Bool = false;

	var mScalingTutorialReadyToClose:Bool = false;

	var mRepeaterTutorialReadyToClose:Bool = false;

	var mChargeTutorialReadyToClose:Bool = false;

	var mCooldownTutorialDone:Bool = false;

	var mScalingTutorialDone:Bool = false;

	var mRepeaterTutorialDone:Bool = false;

	var mChargeTutorialDone:Bool = false;

	var mBusterTutorialDone:Bool = false;

	var mBusterCloseButton:UIButton;

	var mBusterPopup:MovieClip;

	var mChargeCloseButton:UIButton;

	var mChargePopup:MovieClip;

	var mReviveTutorialDone:Bool = false;

	var mReviveCloseButton:UIButton;

	var mRevivePopup:MovieClip;

	var mRevivePopupPosition:String;

	var mLootSharingTutorialDone:Bool = false;

	var mLootSharingCloseButton:UIButton;

	var mLootSharingPopup:MovieClip;

	var mLootSharingChestRenderer:MovieClipRenderer;

	var mSuperWeakTutorialDone:Bool = false;

	var mSuperWeakCloseButton:UIButton;

	var mSuperWeakPopup:MovieClip;

	var mTutorialComplete:Bool = false;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "DungeonTutorial");
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "DungeonTutorial");
		mEventComponent = new EventComponent(mDBFacade);
		EventListeners.add(mDBFacade.stageRef, "keyDown", handleKeyDown);
		EventListeners.add(mDBFacade.stageRef, "mouseDown", handleMouseDown);
		mEventComponent.addListener("DungeonBusterControlActivatedEvent", handleBuster);
		mEventComponent.addListener("REVIVE_SPACEBAR_PRESSED", handleRevive);
		mEventComponent.addListener("OnSteamInputButtonPressedEvent", handleSteamInputButtonPressed);
		if (mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam()) {
			mMovementTutorialDone = true;
		}
	}

	static function isKeyboardArt(child:DisplayObject, hideUnnamedClips:Bool):Bool {
		if (Std.isOfType(child, Shape)) {
			return true;
		}
		var _loc3_ = ASCompat.reinterpretAs(child, TextField);
		if (_loc3_ != null) {
			return new compat.RegExp("\\s", "g").replace(_loc3_.text, "").length <= 2;
		}
		return hideUnnamedClips && Std.isOfType(child, Sprite) && child.name.indexOf("instance") == 0;
	}

	public function destroy() {
		stopGamepadMovementCheck();
		EventListeners.remove(mDBFacade.stageRef, "keyDown", handleKeyDown);
		EventListeners.remove(mDBFacade.stageRef, "mouseDown", handleMouseDown);
		this.destroyChestTutorial();
		this.destroyMovementTutorial();
		this.destroyAttackTutorial();
		this.destroyBusterTutorial();
		this.destroyChargeTutorial();
		this.destroyReviveTutorial();
		this.destroyLootSharingTutorial();
		this.destroySuperWeakTutorial();
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mEventComponent.destroy();
		mEventComponent = null;
		mDBFacade = null;
	}

	function handleMouseDown(event:MouseEvent) {
		if (mMovementPopup != null && !mMovementTutorialDone) {
			this.advanceToAttackTutorial();
		}
	}

	function handleKeyDown(event:KeyboardEvent) {
		if (event.keyCode == 27) {
			if (mAttackPopup != null && !mAttackTutorialDone) {
				this.finishAttackTutorial();
			}
			if (mMovementPopup != null && !mMovementTutorialDone) {
				this.advanceToAttackTutorial();
			}
			if (mChestPopup != null && !mChestTutorialDone) {
				this.finishChestTutorial();
			}
			if (mChestPopup != null && !mCooldownTutorialDone) {
				this.finishCooldownTutorial();
			}
			if (mChestPopup != null && !mScalingTutorialDone) {
				this.finishScalingTutorial();
			}
			if (mChestPopup != null && !mRepeaterTutorialDone) {
				this.finishRepeaterTutorial();
			}
			if (mBusterPopup != null && !mBusterTutorialDone) {
				this.finishBusterTutorial();
			}
			if (mChargePopup != null && !mChargeTutorialDone) {
				this.finishChargeTutorial();
			}
			return;
		}
		var _loc2_ = mDBFacade.keyBindings.actionForKey((event.keyCode : Int));
		if (_loc2_ == null) {
			return;
		}
		if (InputAction.isWeaponAttack(_loc2_)) {
			handleAttackInput();
		} else if (_loc2_ == "useDungeonBuster") {
			if (mBusterPopup != null && !mBusterTutorialDone) {
				this.finishBusterTutorial();
			}
		} else if (InputAction.isMovement(_loc2_)) {
			if (mMovementPopup != null && !mMovementTutorialDone) {
				this.advanceToAttackTutorial();
			}
		}
	}

	function handleAttackInput() {
		if (mAttackPopup != null && !mAttackTutorialDone) {
			this.finishAttackTutorial();
		}
		if (mChestPopup != null && !mCooldownTutorialDone) {
			this.finishCooldownTutorial();
		}
		if (mChestPopup != null && !mScalingTutorialDone) {
			this.finishScalingTutorial();
		}
		if (mChestPopup != null && !mRepeaterTutorialDone) {
			this.finishRepeaterTutorial();
		}
		if (mChargePopup != null && !mChargeTutorialDone) {
			this.finishChargeTutorial();
		}
	}

	function handleSteamInputButtonPressed(event:OnSteamInputButtonPressedEvent) {
		if (ATTACK_ACTIONS.indexOf(event.actionName) != -1) {
			handleAttackInput();
		} else if (event.actionName == "use_dungeon_buster") {
			if (mBusterPopup != null && !mBusterTutorialDone) {
				this.finishBusterTutorial();
			}
		}
	}

	function checkGamepadMovement(gameClock:GameClock) {
		if (mMovementPopup == null || mMovementTutorialDone) {
			stopGamepadMovementCheck();
			return;
		}
		var _loc2_ = mDBFacade.steamInputManager.getAnalogAction("game_movement");
		if (_loc2_.lengthSquared > 0.05) {
			stopGamepadMovementCheck();
			advanceToAttackTutorial();
		}
	}

	function stopGamepadMovementCheck() {
		if (mGamepadMovementTask != null) {
			mGamepadMovementTask.destroy();
		}
		mGamepadMovementTask = null;
	}

	function showControllerPrompts(popup:MovieClip, glyphFilePaths:Array<ASAny>, glyphSize:Float, hideUnnamedClips:Bool) {
		var _loc6_ = 0;
		var _loc14_:DisplayObject = null;
		var _loc12_:Rectangle = null;
		var _loc5_ = 0;
		if (!mDBFacade.steamInputManager.wantsControllerPrompts) {
			return;
		}
		var _loc11_:Array<ASAny> = [];
		var _loc7_:String;
		if (checkNullIteratee(glyphFilePaths))
			for (_tmp_ in glyphFilePaths) {
				_loc7_ = _tmp_;
				if (_loc7_ != null && _loc7_ != "" && _loc7_ != "error1" && _loc11_.indexOf(_loc7_) == -1) {
					_loc11_.push(_loc7_);
				}
			}
		if (_loc11_.length == 0) {
			return;
		}
		var _loc13_:Rectangle = null;
		_loc6_ = popup.getChildIndex(ASCompat.coerce((popup : ASAny).title, flash.display.DisplayObject)) + 1;
		while (_loc6_ < popup.numChildren) {
			_loc14_ = popup.getChildAt(_loc6_);
			if (isKeyboardArt(_loc14_, hideUnnamedClips)) {
				_loc14_.visible = false;
				_loc12_ = _loc14_.getBounds(popup);
				_loc13_ = _loc13_ != null ? _loc13_.union(_loc12_) : _loc12_;
			}
			_loc6_++;
		}
		if (_loc13_ == null) {
			return;
		}
		var _loc8_ = glyphSize * 0.25;
		var _loc10_ = _loc13_.x + (_loc13_.width - (_loc11_.length * glyphSize + (_loc11_.length - 1) * _loc8_)) / 2;
		var _loc9_ = _loc13_.y + (_loc13_.height - glyphSize) / 2;
		_loc5_ = 0;
		while (_loc5_ < _loc11_.length) {
			addControllerGlyph(popup, _loc11_[_loc5_], _loc10_ + _loc5_ * (glyphSize + _loc8_), _loc9_, glyphSize);
			_loc5_++;
		}
	}

	function addControllerGlyph(popup:MovieClip, glyphFilePath:String, x:Float, y:Float, size:Float) {
		mAssetLoadingComponent.getImageAsset(glyphFilePath, function(param1:brain.assetRepository.ImageAsset) {
			var _loc2_ = new Bitmap(param1.image.bitmapData, param1.image.pixelSnapping, param1.image.smoothing);
			_loc2_.x = x;
			_loc2_.y = y;
			_loc2_.width = size;
			_loc2_.height = size;
			popup.addChild(_loc2_);
		});
	}

	function getAttackGlyphFilePaths():Array<ASAny> {
		var _loc1_:Array<ASAny> = [];
		if (!mDBFacade.steamInputManager.isSteamInputReady) {
			return _loc1_;
		}
		var _loc2_:String;
		final __ax4_iter_129 = ATTACK_ACTIONS;
		if (checkNullIteratee(__ax4_iter_129))
			for (_tmp_ in __ax4_iter_129) {
				_loc2_ = _tmp_;
				_loc1_.push(mDBFacade.steamInputManager.getGlyphFilePathForAction(_loc2_));
			}
		return _loc1_;
	}

	function handleBuster(event:DungeonBusterControlActivatedEvent) {
		if (mBusterPopup != null && !mBusterTutorialDone) {
			this.finishBusterTutorial();
		}
	}

	function handleRevive(event:Event) {
		if (mRevivePopup != null && !mReviveTutorialDone) {
			this.finishReviveTutorial();
		}
	}

	function timelineAttackAdvance() {
		destroyMovementTutorial();
		showAttackTutorial();
	}

	public function advanceToAttackTutorial() {
		mMovementTutorialDone = true;
		ASCompat.setProperty((mMovementPopup : ASAny).check, "visible", true);
		var _loc1_ = mMovementPopup.x;
		var _loc3_ = mDBFacade.viewWidth + mMovementPopup.width;
		var _loc2_ = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mMovementPopup, 0.08333333333333333, {
					"delay": 1,
					"x": _loc1_ - 20,
					"y": _loc2_
				}),
				mDBFacade.mTween.tweenMaxTo(mMovementPopup, 0.3333333333333333, {
					"x": _loc3_,
					"y": _loc2_
				}),
				mDBFacade.mTween.delayedCall(1.5, timelineAttackAdvance)
			],
			"align": "sequence"
		});
	}

	function destroyMovementTutorial() {
		stopGamepadMovementCheck();
		if (mMovementPopup != null) {
			mDBFacade.mTween.killDelayedCallsTo(timelineAttackAdvance);
			mDBFacade.mTween.killTweensOf(mMovementPopup);
			mSceneGraphComponent.removeChild(mMovementPopup);
			mMovementPopup = null;
		}
	}

	public function showMovementTutorial() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc3_ = param1.getClass("tutorial_movement");
				if (_loc3_ == null) {
					return;
				}
				mMovementPopup = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mMovementPopup : ASAny).title, flash.text.TextField), "TUTORIAL_MOVEMENT_TITLE");
				ASCompat.setProperty((mMovementPopup : ASAny).check, "visible", false);
				showControllerPrompts(mMovementPopup, [mDBFacade.steamInputManager.getGlyphFilePathForAnalogAction("game_movement")], 80, true);
				stopGamepadMovementCheck();
				mGamepadMovementTask = mLogicalWorkComponent.doEveryFrame(checkGamepadMovement);
				mSceneGraphComponent.addChild(mMovementPopup, (105 : UInt));
				mMovementPopup.scaleX = mMovementPopup.scaleY = 1;
				var _loc2_ = mDBFacade.viewWidth - mMovementPopup.width * 0.5 - 50;
				var _loc4_ = mDBFacade.viewHeight * 0.5;
				mMovementPopup.x = mDBFacade.viewWidth + mMovementPopup.width;
				mMovementPopup.y = _loc4_;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mMovementPopup, 0.3333333333333333, {
							"x": _loc2_ - 20,
							"y": _loc4_
						}),
						mDBFacade.mTween.tweenMaxTo(mMovementPopup, 0.08333333333333333, {
							"x": _loc2_,
							"y": _loc4_
						})
					],
					"align": "sequence"
				});
			});
	}

	function finishAttackTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		if (!mAttackTutorialDone) {
			mDBFacade.dbAccountInfo.dbAccountParams.setMovementTutorialParam();
		}
		mAttackTutorialDone = true;
		ASCompat.setProperty((mAttackPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyAttackTutorial();
		};
		curX = mAttackPopup.x;
		offscreenX = -mAttackPopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mAttackPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mAttackPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function destroyAttackTutorial() {
		if (mAttackPopup != null) {
			mDBFacade.mTween.killTweensOf(mAttackPopup);
			mSceneGraphComponent.removeChild(mAttackPopup);
			mAttackPopup = null;
		}
		mTutorialComplete = true;
	}

	public function showAttackTutorial() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc3_ = param1.getClass("tutorial_attack");
				if (_loc3_ == null) {
					return;
				}
				mAttackPopup = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mAttackPopup : ASAny).title, flash.text.TextField), "TUTORIAL_ATTACK_TITLE");
				ASCompat.setProperty((mAttackPopup : ASAny).check, "visible", false);
				showControllerPrompts(mAttackPopup, getAttackGlyphFilePaths(), 56, false);
				mSceneGraphComponent.addChild(mAttackPopup, (105 : UInt));
				mAttackPopup.scaleX = mAttackPopup.scaleY = 1;
				var _loc2_ = mAttackPopup.width * 0.5 + 10;
				var _loc4_ = mDBFacade.viewHeight * 0.5;
				mAttackPopup.x = -mAttackPopup.width;
				mAttackPopup.y = _loc4_;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mAttackPopup, 0.3333333333333333, {
							"x": _loc2_ + 20,
							"y": _loc4_
						}),
						mDBFacade.mTween.tweenMaxTo(mAttackPopup, 0.08333333333333333, {
							"x": _loc2_,
							"y": _loc4_
						})
					],
					"align": "sequence"
				});
			});
	}

	function finishReviveTutorial() {
		var advanceFunc:ASFunction;
		var destX:Float;
		var bounceOffset:Float;
		var curX:Float;
		mReviveTutorialDone = true;
		ASCompat.setProperty((mRevivePopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyReviveTutorial();
		};
		curX = mRevivePopup.x;
		if (mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT") {
			destX = mDBFacade.viewWidth + mRevivePopup.width;
			bounceOffset = -20;
		} else {
			destX = -mRevivePopup.width;
			bounceOffset = 20;
		}
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mRevivePopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + bounceOffset
				}),
				mDBFacade.mTween.tweenMaxTo(mRevivePopup, 0.3333333333333333, {
					"x": destX,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function destroyReviveTutorial() {
		if (mRevivePopup != null) {
			mDBFacade.mTween.killTweensOf(mRevivePopup);
			mSceneGraphComponent.removeChild(mRevivePopup);
			mRevivePopup = null;
		}
		mTutorialComplete = true;
	}

	public function showReviveTutorial(popupPosition:String) {
		if (mRevivePopup != null) {
			return;
		}
		if (!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam()) {
			mDBFacade.dbAccountInfo.dbAccountParams.setReviveTutorialParam();
		}
		mRevivePopupPosition = popupPosition;
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc3_ = Math.NaN;
				var _loc2_ = Math.NaN;
				var _loc4_ = param1.getClass("tutorial_revive");
				if (_loc4_ == null) {
					return;
				}
				mRevivePopup = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mRevivePopup : ASAny).title, flash.text.TextField), "TUTORIAL_REVIVE_TITLE");
				Locale.setText(ASCompat.coerce((mRevivePopup : ASAny).description, flash.text.TextField), "TUTORIAL_REVIVE_DESCRIPTION");
				ASCompat.setProperty((mRevivePopup : ASAny).check, "visible", false);
				mReviveCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePopup : ASAny).close, flash.display.MovieClip));
				mReviveCloseButton.releaseCallback = finishReviveTutorial;
				mSceneGraphComponent.addChild(mRevivePopup, (105 : UInt));
				mRevivePopup.scaleX = mRevivePopup.scaleY = 1;
				mRevivePopup.y = mDBFacade.viewHeight * 0.5;
				if (mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT") {
					mRevivePopup.x = mDBFacade.viewWidth + mRevivePopup.width / 2;
					_loc3_ = mDBFacade.viewWidth - mRevivePopup.width / 2 + 25;
					_loc2_ = -20;
				} else {
					mRevivePopup.x = 0 - mRevivePopup.width / 2;
					_loc3_ = mRevivePopup.width / 2;
					_loc2_ = 20;
				}
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mRevivePopup, 0.3333333333333333, {"x": _loc3_ + _loc2_}),
						mDBFacade.mTween.tweenMaxTo(mRevivePopup, 0.08333333333333333, {"x": _loc3_})
					],
					"align": "sequence"
				});
			});
	}

	function finishLootSharingTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		mLootSharingTutorialDone = true;
		ASCompat.setProperty((mLootSharingPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyLootSharingTutorial();
		};
		curX = mLootSharingPopup.x;
		offscreenX = mDBFacade.viewWidth;
		offscreenY = mDBFacade.viewHeight * 0.3;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mLootSharingPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX - 40,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mLootSharingPopup, 0.3333333333333333, {
					"x": offscreenX - 40,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function destroyLootSharingTutorial() {
		if (mLootSharingChestRenderer != null) {
			mLootSharingChestRenderer.destroy();
			mLootSharingChestRenderer = null;
		}
		if (mLootSharingPopup != null) {
			mDBFacade.mTween.killTweensOf(mLootSharingPopup);
			mSceneGraphComponent.removeChild(mLootSharingPopup);
			mLootSharingPopup = null;
		}
		mTutorialComplete = true;
	}

	function finishSuperWeakTutorial(className:String, isRight:Bool = true) {
		var advanceFunc:ASFunction;
		var curX:Float;
		var sign:Int;
		var offscreenX:Float;
		var offscreenY:Float;
		ASCompat.setProperty((mSuperWeakPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroySuperWeakTutorial();
			if (className == "tutorial_enemy_defense1") {
				showSuperWeakTutorial("tutorial_enemy_defense2", false);
			} else if (className == "tutorial_enemy_defense2") {
				showSuperWeakTutorial("tutorial_enemy_defense3");
			} else if (className == "tutorial_enemy_defense3") {
				showSuperWeakTutorial("tutorial_enemy_defense4", false);
			} else {
				mSuperWeakTutorialDone = true;
			}
		};
		curX = mSuperWeakPopup.x;
		sign = isRight ? 1 : -1;
		offscreenX = isRight ? 900 : -100;
		offscreenY = mSuperWeakPopup.y;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX - sign * 40,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function destroySuperWeakTutorial() {
		if (mSuperWeakPopup != null) {
			mDBFacade.mTween.killTweensOf(mSuperWeakPopup);
			mSceneGraphComponent.removeChild(mSuperWeakPopup);
			mSuperWeakPopup = null;
		}
		mTutorialComplete = true;
	}

	public function showLootSharingTutorial() {
		if (!mDBFacade.dbAccountInfo.dbAccountParams.hasLootSharingTutorialParam()) {
			mDBFacade.dbAccountInfo.dbAccountParams.setLootSharingTutorialParam();
		}
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var swfAsset = param1;
				var popupClass = swfAsset.getClass("tutorial_loot_alt");
				if (popupClass == null) {
					return;
				}
				mLootSharingPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mLootSharingPopup : ASAny).title, flash.text.TextField), "TUTORIAL_LOOT_TITLE");
				Locale.setText(ASCompat.coerce((mLootSharingPopup : ASAny).shared_text, flash.text.TextField), "TUTORIAL_LOOT_SHARED");
				Locale.setText(ASCompat.coerce((mLootSharingPopup : ASAny).not_shared_text, flash.text.TextField), "TUTORIAL_LOOT_NOT_SHARED");
				ASCompat.setProperty((mLootSharingPopup : ASAny).check, "visible", false);
				mLootSharingCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mLootSharingPopup : ASAny).close, flash.display.MovieClip));
				mLootSharingCloseButton.releaseCallback = finishLootSharingTutorial;
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),
					function(param1:brain.assetRepository.SwfAsset) {
						var xpStar:MovieClip;
						var dbStar:MovieClip;
						var food:MovieClip;
						var treasureMC:MovieClip;
						var destX:Float;
						var destY:Float;
						var swfAsset2 = param1;
						var gold3 = swfAsset2.getClass("doober_currency_coin");
						var xp = swfAsset2.getClass("doober_xp_star");
						var db = swfAsset2.getClass("doober_db_star");
						var treasure = swfAsset2.getClass("db_doobers_treasure_chest_basic");
						var foodClass = swfAsset2.getClass("doober_health_burger");
						var gold = ASCompat.coerce(ASCompat.createInstance(gold3, []), flash.display.MovieClip);
						gold.scaleX = gold.scaleY = 0.75;
						xpStar = ASCompat.coerce(ASCompat.createInstance(xp, []), flash.display.MovieClip);
						xpStar.scaleX = xpStar.scaleY = 1;
						xpStar.x += 10;
						xpStar.y -= 10;
						dbStar = ASCompat.coerce(ASCompat.createInstance(db, []), flash.display.MovieClip);
						dbStar.scaleX = dbStar.scaleY = 1.75;
						dbStar.x += 10;
						dbStar.y -= 10;
						food = ASCompat.coerce(ASCompat.createInstance(foodClass, []), flash.display.MovieClip);
						food.scaleX = food.scaleY = 0.9;
						treasureMC = ASCompat.coerce(ASCompat.createInstance(treasure, []), flash.display.MovieClip);
						treasureMC.scaleX = treasureMC.scaleY = 0.65;
						treasureMC.x += 10;
						treasureMC.y += 5;
						(mLootSharingPopup : ASAny).gold3.addChild(gold);
						(mLootSharingPopup : ASAny).xp.addChild(xpStar);
						(mLootSharingPopup : ASAny).db.addChild(dbStar);
						(mLootSharingPopup : ASAny).treasure.addChild(treasureMC);
						mLootSharingChestRenderer = new MovieClipRenderer(mDBFacade, treasureMC);
						mLootSharingChestRenderer.play((0 : UInt), true);
						(mLootSharingPopup : ASAny).food.addChild(food);
						mSceneGraphComponent.addChild(mLootSharingPopup, (105 : UInt));
						mLootSharingPopup.scaleX = mLootSharingPopup.scaleY = 1.1764705882352942;
						destX = mDBFacade.viewWidth - mLootSharingPopup.width;
						destY = mDBFacade.viewHeight * 0.3;
						mLootSharingPopup.x = destX;
						mLootSharingPopup.y = destY;
						mDBFacade.mTween.createTimeline({
							"tweens": [
								mDBFacade.mTween.tweenMaxTo(mLootSharingPopup, 0.3333333333333333, {
									"x": destX + 20,
									"y": destY
								}),
								mDBFacade.mTween.tweenMaxTo(mLootSharingPopup, 0.08333333333333333, {
									"x": destX,
									"y": destY
								})
							],
							"align": "sequence"
						});
						mLogicalWorkComponent.doLater(10, function(param1:GameClock) {
							if (!mLootSharingTutorialDone) {
								finishLootSharingTutorial();
							}
						});
					});
			});
	}

	public function showSuperWeakTutorial(className:String, isRight:Bool = true) {
		if (!mDBFacade.dbAccountInfo.dbAccountParams.hasSuperWeakParam()) {
			mDBFacade.dbAccountInfo.dbAccountParams.setSuperWeakParam();
		}
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var swfAsset = param1;
				var popupClass = swfAsset.getClass(className);
				if (popupClass == null) {
					return;
				}
				mSuperWeakPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mSuperWeakPopup : ASAny).title, flash.text.TextField), "TUTORIAL_SUPER_WEAK_TITLE");
				ASCompat.setProperty((mSuperWeakPopup : ASAny).check, "visible", false);
				mSuperWeakCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mSuperWeakPopup : ASAny).close, flash.display.MovieClip));
				mSuperWeakCloseButton.releaseCallback = function() {
					mLogicalWorkComponent.clear();
					finishSuperWeakTutorial(className, isRight);
				};
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),
					function(param1:brain.assetRepository.SwfAsset) {
						var destXCaseRight:Float;
						var destXCaseLeft:Float;
						var destX:Float;
						var destY:Float;
						var swfAsset2 = param1;
						mSceneGraphComponent.addChild(mSuperWeakPopup, (105 : UInt));
						destXCaseRight = mDBFacade.viewWidth - mSuperWeakPopup.width / 1.6;
						destXCaseLeft = mSuperWeakPopup.width / 3;
						destX = isRight ? destXCaseRight : destXCaseLeft;
						destY = mDBFacade.viewHeight * 0.5;
						mSuperWeakPopup.x = destX;
						mSuperWeakPopup.y = destY;
						mDBFacade.mTween.createTimeline({
							"tweens": [
								mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup, 0.3333333333333333, {
									"x": destX + 20,
									"y": destY
								}),
								mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup, 0.08333333333333333, {
									"x": destX,
									"y": destY
								})
							],
							"align": "sequence"
						});
						mLogicalWorkComponent.clear();
						mLogicalWorkComponent.doLater(5, function(param1:GameClock) {
							if (!mSuperWeakTutorialDone) {
								finishSuperWeakTutorial(className, isRight);
							}
						});
					});
			});
	}

	public function finishChestTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		mDBFacade.dbAccountInfo.dbAccountParams.setChestCollectedTutorialParam();
		mChestTutorialDone = true;
		if (mChestPopup == null) {
			return;
		}
		ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyChestTutorial();
		};
		curX = mChestPopup.x;
		offscreenX = mDBFacade.viewWidth + mChestPopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	public function finishCooldownTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		if (!mCooldownTutorialReadyToClose) {
			return;
		}
		mCooldownTutorialDone = true;
		ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyChestTutorial();
		};
		curX = mChestPopup.x;
		offscreenX = mDBFacade.viewWidth + mChestPopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	public function finishScalingTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		if (!mScalingTutorialReadyToClose) {
			return;
		}
		mScalingTutorialDone = true;
		ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyChestTutorial();
		};
		curX = mChestPopup.x;
		offscreenX = mDBFacade.viewWidth + mChestPopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	public function finishRepeaterTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		if (!mRepeaterTutorialReadyToClose) {
			return;
		}
		mRepeaterTutorialDone = true;
		ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyChestTutorial();
		};
		curX = mChestPopup.x;
		offscreenX = mDBFacade.viewWidth + mChestPopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function finishBusterTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		if (!mBusterTutorialDone) {
			mDBFacade.dbAccountInfo.dbAccountParams.setDungeonBusterTutorialParam();
		}
		mBusterTutorialDone = true;
		ASCompat.setProperty((mBusterPopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyBusterTutorial();
		};
		curX = mBusterPopup.x;
		offscreenX = mDBFacade.viewWidth + mBusterPopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mBusterPopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mBusterPopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function destroyChestTutorial() {
		if (mChestPopup != null) {
			mLogicalWorkComponent.clear();
			if (mCooldownRenderer != null) {
				mCooldownRenderer.destroy();
				mCooldownRenderer = null;
			}
			mDBFacade.mTween.killTweensOf(mChestPopup);
			mSceneGraphComponent.removeChild(mChestPopup);
			mChestCloseButton.destroy();
			mChestCloseButton = null;
			mChestPopup = null;
		}
		mTutorialComplete = true;
	}

	function destroyBusterTutorial() {
		if (mBusterPopup != null) {
			mDBFacade.mTween.killTweensOf(mBusterPopup);
			mSceneGraphComponent.removeChild(mBusterPopup);
			mBusterCloseButton.destroy();
			mBusterCloseButton = null;
			mBusterPopup = null;
		}
		mTutorialComplete = true;
	}

	public function showChestTutorial() {
		mDBFacade.dbAccountInfo.dbAccountParams.setChestNearbyTutorialParam();
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc3_ = param1.getClass("tutorial_chest");
				if (_loc3_ == null) {
					return;
				}
				mChestPopup = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mChestPopup : ASAny).title, flash.text.TextField), "TUTORIAL_CHEST_TITLE");
				TextUtil.setText(ASCompat.coerce((mChestPopup : ASAny).title1, flash.text.TextField), Locale.getString("TUTORIAL_CHEST_DESC").toUpperCase());
				ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
				mChestCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mChestPopup : ASAny).close, flash.display.MovieClip));
				mChestCloseButton.releaseCallback = finishChestTutorial;
				mSceneGraphComponent.addChild(mChestPopup, (105 : UInt));
				mChestPopup.scaleX = mChestPopup.scaleY = 1;
				var _loc2_ = mDBFacade.viewWidth - mChestPopup.width / 1.6;
				var _loc4_ = mDBFacade.viewHeight * 0.5;
				mChestPopup.x = _loc2_;
				mChestPopup.y = _loc4_;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
							"x": _loc2_ + 20,
							"y": _loc4_
						}),
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
							"x": _loc2_,
							"y": _loc4_
						})
					],
					"align": "sequence"
				});
			});
	}

	public function showCooldownTutorial() {
		mDBFacade.dbAccountInfo.dbAccountParams.setCooldownTutorialParam();
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var destX:Float;
				var destY:Float;
				var swfAsset = param1;
				var popupClass = swfAsset.getClass("tutorial_cooldown");
				if (popupClass == null) {
					return;
				}
				mChestPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mChestPopup : ASAny).title, flash.text.TextField), "TUTORIAL_COOLDOWN_TITLE");
				TextUtil.setText(ASCompat.coerce((mChestPopup : ASAny).description, flash.text.TextField),
					Locale.getString("TUTORIAL_COOLDOWN_DESC").toUpperCase());
				ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
				mChestCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mChestPopup : ASAny).close, flash.display.MovieClip));
				mChestCloseButton.releaseCallback = finishCooldownTutorial;
				mSceneGraphComponent.addChild(mChestPopup, (105 : UInt));
				mChestPopup.scaleX = mChestPopup.scaleY = 1;
				destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
				destY = mDBFacade.viewHeight * 0.5;
				mChestPopup.x = destX;
				mChestPopup.y = destY;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
							"x": destX + 20,
							"y": destY
						}),
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
							"x": destX,
							"y": destY
						})
					],
					"align": "sequence"
				});
				mLogicalWorkComponent.doLater(3, function(param1:GameClock) {
					mCooldownTutorialReadyToClose = true;
				});
				mLogicalWorkComponent.doLater(6.5, function(param1:GameClock) {
					if (mCooldownTutorialReadyToClose && !mCooldownTutorialDone) {
						finishCooldownTutorial();
					}
				});
				mCooldownRenderer = new MovieClipRenderer(mDBFacade, ASCompat.coerce((mChestPopup : ASAny).icon, flash.display.MovieClip));
				mCooldownRenderer.play();
			});
	}

	public function showScalingTutorial() {
		mDBFacade.dbAccountInfo.dbAccountParams.setScalingTutorialParam();
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var destX:Float;
				var destY:Float;
				var swfAsset = param1;
				var popupClass = swfAsset.getClass("tutorial_scaling");
				if (popupClass == null) {
					return;
				}
				mChestPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mChestPopup : ASAny).title, flash.text.TextField), "TUTORIAL_SCALING_TITLE");
				TextUtil.setText(ASCompat.coerce((mChestPopup : ASAny).description, flash.text.TextField),
					Locale.getString("TUTORIAL_SCALING_DESC").toUpperCase());
				ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
				mChestCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mChestPopup : ASAny).close, flash.display.MovieClip));
				mChestCloseButton.releaseCallback = finishScalingTutorial;
				mSceneGraphComponent.addChild(mChestPopup, (105 : UInt));
				mChestPopup.scaleX = mChestPopup.scaleY = 1;
				destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
				destY = mDBFacade.viewHeight * 0.5;
				mChestPopup.x = destX;
				mChestPopup.y = destY;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
							"x": destX + 20,
							"y": destY
						}),
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
							"x": destX,
							"y": destY
						})
					],
					"align": "sequence"
				});
				mLogicalWorkComponent.doLater(3, function(param1:GameClock) {
					mScalingTutorialReadyToClose = true;
				});
				mLogicalWorkComponent.doLater(6.5, function(param1:GameClock) {
					if (mScalingTutorialReadyToClose && !mScalingTutorialDone) {
						finishScalingTutorial();
					}
				});
			});
	}

	public function showRepeaterTutorial() {
		mDBFacade.dbAccountInfo.dbAccountParams.setRepeaterTutorialParam();
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var destX:Float;
				var destY:Float;
				var swfAsset = param1;
				var popupClass = swfAsset.getClass("tutorial_repeater");
				if (popupClass == null) {
					return;
				}
				mChestPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mChestPopup : ASAny).title, flash.text.TextField), "TUTORIAL_REPEATER_TITLE");
				TextUtil.setText(ASCompat.coerce((mChestPopup : ASAny).description, flash.text.TextField),
					Locale.getString("TUTORIAL_REPEATER_DESC").toUpperCase());
				ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
				mChestCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mChestPopup : ASAny).close, flash.display.MovieClip));
				mChestCloseButton.releaseCallback = finishRepeaterTutorial;
				mSceneGraphComponent.addChild(mChestPopup, (105 : UInt));
				mChestPopup.scaleX = mChestPopup.scaleY = 1;
				destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
				destY = mDBFacade.viewHeight * 0.5;
				mChestPopup.x = destX;
				mChestPopup.y = destY;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.3333333333333333, {
							"x": destX + 20,
							"y": destY
						}),
						mDBFacade.mTween.tweenMaxTo(mChestPopup, 0.08333333333333333, {
							"x": destX,
							"y": destY
						})
					],
					"align": "sequence"
				});
				mLogicalWorkComponent.doLater(3, function(param1:GameClock) {
					mRepeaterTutorialReadyToClose = true;
				});
				mLogicalWorkComponent.doLater(6.5, function(param1:GameClock) {
					if (mRepeaterTutorialReadyToClose && !mRepeaterTutorialDone) {
						finishRepeaterTutorial();
					}
				});
			});
	}

	public function showBusterTutorial() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc3_ = param1.getClass("tutorial_db");
				if (_loc3_ == null) {
					return;
				}
				mBusterPopup = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mBusterPopup : ASAny).title, flash.text.TextField), "TUTORIAL_BUSTER_TITLE");
				ASCompat.setProperty((mBusterPopup : ASAny).check, "visible", false);
				showControllerPrompts(mBusterPopup,
					mDBFacade.steamInputManager.isSteamInputReady ? [mDBFacade.steamInputManager.getGlyphFilePathForAction("use_dungeon_buster")] : [], 56,
					false);
				mBusterCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mBusterPopup : ASAny).close, flash.display.MovieClip));
				mBusterCloseButton.releaseCallback = finishBusterTutorial;
				mSceneGraphComponent.addChild(mBusterPopup, (105 : UInt));
				mBusterPopup.scaleX = mBusterPopup.scaleY = 1;
				var _loc2_ = mDBFacade.viewWidth - mBusterPopup.width * 0.5 - 50;
				var _loc4_ = mDBFacade.viewHeight * 0.5;
				mBusterPopup.x = mDBFacade.viewWidth;
				mBusterPopup.y = _loc4_;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mBusterPopup, 0.3333333333333333, {
							"x": _loc2_ + 20,
							"y": _loc4_
						}),
						mDBFacade.mTween.tweenMaxTo(mBusterPopup, 0.08333333333333333, {
							"x": _loc2_,
							"y": _loc4_
						})
					],
					"align": "sequence"
				});
			});
	}

	function finishChargeTutorial() {
		var advanceFunc:ASFunction;
		var curX:Float;
		var offscreenX:Float;
		var offscreenY:Float;
		if (!mChargeTutorialReadyToClose) {
			return;
		}
		mChargeTutorialDone = true;
		ASCompat.setProperty((mChargePopup : ASAny).check, "visible", true);
		advanceFunc = function() {
			destroyChargeTutorial();
		};
		curX = mChargePopup.x;
		offscreenX = -mChargePopup.width;
		offscreenY = mDBFacade.viewHeight * 0.5;
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mChargePopup, 0.08333333333333333, {
					"delay": 1,
					"x": curX + 20,
					"y": offscreenY
				}),
				mDBFacade.mTween.tweenMaxTo(mChargePopup, 0.3333333333333333, {
					"x": offscreenX,
					"y": offscreenY,
					"onComplete": advanceFunc
				})
			],
			"align": "sequence"
		});
	}

	function destroyChargeTutorial() {
		if (mChargePopup != null) {
			mDBFacade.mTween.killTweensOf(mChargePopup);
			mSceneGraphComponent.removeChild(mChargePopup);
			mChargeCloseButton.destroy();
			mChargeCloseButton = null;
			mChargePopup = null;
		}
		mTutorialComplete = true;
	}

	public function showChargeTutorial() {
		mDBFacade.dbAccountInfo.dbAccountParams.setChargeTutorialParam();
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var destX:Float;
				var destY:Float;
				var swfAsset = param1;
				var popupClass = swfAsset.getClass("tutorial_charge");
				if (popupClass == null) {
					return;
				}
				mChargePopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((mChargePopup : ASAny).title, flash.text.TextField), "TUTORIAL_CHARGE_TITLE");
				ASCompat.setProperty((mChargePopup : ASAny).check, "visible", false);
				showControllerPrompts(mChargePopup, getAttackGlyphFilePaths(), 56, false);
				mChargeCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mChargePopup : ASAny).close, flash.display.MovieClip));
				mChargeCloseButton.releaseCallback = finishChargeTutorial;
				mSceneGraphComponent.addChild(mChargePopup, (105 : UInt));
				mChargePopup.scaleX = mChargePopup.scaleY = 1;
				destX = mChargePopup.width * 0.5 + 10;
				destY = mDBFacade.viewHeight * 0.5;
				mChargePopup.x = -mChargePopup.width;
				mChargePopup.y = destY;
				mDBFacade.mTween.createTimeline({
					"tweens": [
						mDBFacade.mTween.tweenMaxTo(mChargePopup, 0.3333333333333333, {
							"x": destX + 20,
							"y": destY
						}),
						mDBFacade.mTween.tweenMaxTo(mChargePopup, 0.08333333333333333, {
							"x": destX,
							"y": destY
						})
					],
					"align": "sequence"
				});
				mLogicalWorkComponent.doLater(3, function(param1:GameClock) {
					mChargeTutorialReadyToClose = true;
				});
				mLogicalWorkComponent.doLater(6.5, function(param1:GameClock) {
					if (mChargeTutorialReadyToClose && !mChargeTutorialDone) {
						finishChargeTutorial();
					}
				});
			});
	}

	@:isVar public var isTutorialComplete(get, never):Bool;

	public function get_isTutorialComplete():Bool {
		return mTutorialComplete;
	}

	static function __init__() {
		ATTACK_ACTIONS = ["attack_weapon_1", "attack_weapon_2", "attack_weapon_3"];
	}
}
