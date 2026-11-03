package actor.stateMachine;

import account.StackableInfo;
import account.StoreServicesController;
import actor.ActorView;
import box2D.collision.shapes.B2CircleShape;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.render.tweens.TweenHandle;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.uI.UICircularProgressBar;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import collision.HeroReviveSensor;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObject;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMDoober;
import gameMasterDictionary.GMOffer;
import generatedCode.InfiniteRewardData;
import stateMachine.mainStateMachine.DungeonTutorial;
import steamInput.UnboundActionEvent;
import uI.infiniteIsland.II_UIExitDungeonPopUp;
import uI.popup.UILootLossPopup;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.text.TextField;

class ActorReviveState extends ActorState {
	public static inline final NAME = "ActorReviveState";

	public static inline final CLEAR_REVIVE_EVENT = "CLEAR_REVIVE_EVENT";

	public static inline final ON_ENTER_STATE_SATURATE_VALUE:Float = 25;

	public static inline final ON_EXIT_STATE_SATURATE_VALUE:Float = 100;

	public static inline final REVIVE_DURATION:Float = 30;

	public static inline final REVIVE_CIRCULAR_BAR_INCREMENT_DURATION:Float = 0.5;

	public static inline final DEAD_PLAYER_EFFECT_Y_OFFSET:Float = -100;

	public static inline final TRIGGER_RANGE:Float = 100;

	public static inline final BOMB_BUTTON_LOCK_DURATION:Float = 2;

	static final CONTROLLER_ICON_POSITION_FOR_REVIVE:Vector3D = new Vector3D(15, 26);

	static final CONTROLLER_GLYPH_SCALE_REVIVE:Point = new Point(20, 20);

	static final CONTROLLER_ICON_POSITION_FOR_SPECTATE:Vector3D = new Vector3D(50, -60);

	static final CONTROLLER_GLYPH_SCALE_SPECTATE:Point = new Point(50, 50);

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mOffScreenBootTimer:UICircularProgressBar;

	var mPopupBootTimer:UICircularProgressBar;

	var mPopupBootTimerTask:Task;

	var mDestroyTimerTask:Task;

	var mSpaceBarTask:Task;

	var mLoadReviveTriggerTask:Task;

	var mBombButtonLockTask:Task;

	var mRevivePanel:MovieClip;

	var mSelfReviveMeButton:UIButton;

	var mSelfReviveAllButton:UIButton;

	var mReturnToTownButton:UIButton;

	var mReturnToTownButtonEnableTask:Task;

	var mDeadPlayerEffect:MovieClip;

	var mKeyBoardInput:MovieClip;

	var mKeyBoardInputWanted:Bool = false;

	var mRevivePressed:Bool = false;

	var mMouseInput:MovieClip;

	var mReviveTrigger:HeroReviveSensor;

	var mHeroGameObject:HeroGameObject;

	var mSpaceBarReviveDownFunction:ASFunction;

	var mSpaceBarReviveUpFunction:ASFunction;

	var mDungeonReviveTutorial:DungeonTutorial;

	var mDeathCount:UInt = (0 : UInt);

	var mHitTabClip:MovieClip;

	var mHitTabTween:TweenHandle;

	var mCloseButton:UIButton;

	public function new(dbFacade:DBFacade, heroGameObject:HeroGameObject, actorView:ActorView, finishedCallback:ASFunction = null) {
		super(dbFacade, heroGameObject, actorView, "ActorReviveState", finishedCallback);
		mHeroGameObject = heroGameObject;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "ActorReviveState");
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "ActorReviveState");
		mDungeonReviveTutorial = new DungeonTutorial(mDBFacade);
		mEventComponent = new EventComponent(mDBFacade);
		mEventComponent.addListener("CLEAR_REVIVE_EVENT", function(param1:Event) {
			deActivateReviveUI();
		});
		mEventComponent.addListener("DUNGEON_FAILED_EVENT", function(param1:Event) {
			destroyUI();
		});
		mEventComponent.addListener("CLIENT_COUNTDOWN_FINISHED_EVENT", function(param1:Event) {
			if (mRevivePanel != null) {
				mRevivePanel.visible = false;
			}
		});
		mEventComponent.addListener("UI_HIDE_TOGGLE_CHANGED", function(param1:Event) {
			applyUiHidden();
		});
	}

	public function refreshHudControllerIcons() {
		if (!mDBFacade.steamInputManager.isSteamInputReady || mDBFacade.hud == null) {
			return;
		}
		if (mKeyBoardInput != null) {
			mDBFacade.hud.initControllerIcon("revive_ally", mKeyBoardInput, CONTROLLER_ICON_POSITION_FOR_REVIVE, CONTROLLER_GLYPH_SCALE_REVIVE);
		}
		if (mHitTabClip != null) {
			mDBFacade.hud.initControllerIcon("revive_ally", mHitTabClip, CONTROLLER_ICON_POSITION_FOR_SPECTATE, CONTROLLER_GLYPH_SCALE_SPECTATE);
		}
	}

	override public function enterState() {
		var ownerHero:HeroGameObjectOwner;
		var ownerHeroId:UInt;
		var go:GameObject;
		var ownerHeroGO:HeroGameObjectOwner;
		var reviveTutorialPopupPosition:String;
		super.enterState();
		mActorView.actionsForDeadState();
		mHeroGameObject.movementControllerType = "locked";
		mHeroGameObject.stopRunIdleMonitoring();
		mEventComponent.dispatchEvent(new Event("CLEAR_REVIVE_EVENT"));
		if (mActorView.hasAnimationRenderer()) {
			mActorView.playAnim("death", 0, false, false);
		}
		if (mActorView.currentWeapon != null && mActorView.currentWeapon.weaponRenderer != null) {
			mActorView.currentWeapon.weaponRenderer.stop();
		}
		if (Std.isOfType(mHeroGameObject, HeroGameObjectOwner)) {
			ownerHero = ASCompat.reinterpretAs(mHeroGameObject, HeroGameObjectOwner);
			ownerHero.clearWeaponInput();
		}
		if (Std.isOfType(mHeroGameObject, HeroGameObjectOwner)) {
			cast(mHeroGameObject, HeroGameObjectOwner).startDeathCamInput();
		}
		if (mHeroGameObject.distributedDungeonFloor != null && mHeroGameObject.distributedDungeonFloor.isADefeat) {
			return;
		}
		mLoadReviveTriggerTask = mLogicalWorkComponent.doEverySeconds(0.5, checkIfHeroIsReadyAndInitReviveSensor);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"), function(param1:SwfAsset) {
			var alertText:TextField;
			var swfAsset = param1;
			var assetClass = swfAsset.getClass("UI_widget");
			mDeadPlayerEffect = ASCompat.coerce(ASCompat.createInstance(assetClass, []), flash.display.MovieClip);
			mDeadPlayerEffect.y += -100;
			ASCompat.setProperty((mDeadPlayerEffect : ASAny).NametagText, "text", "");
			alertText = ASCompat.coerce((mDeadPlayerEffect : ASAny).AlertText, flash.text.TextField);
			Locale.setText(alertText, "NAMETAG_RESCUE", null, 1.64);
			TextUtil.fitToField(alertText);
			if (TextUtil.enabled) {
				alertText.autoSize = "center";
			}
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Avatars/db_icon_death.swf"), function(param1:SwfAsset) {
				var _loc3_ = param1.getClass("death_icon");
				var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				_loc2_.name = "revivePic";
				(mDeadPlayerEffect : ASAny).UI_avatar.addChild(_loc2_);
			});
			ASCompat.setProperty((mDeadPlayerEffect : ASAny).UI_arrow, "visible", false);
			mDeadPlayerEffect.name = "deadEffect";
			mHeroGameObject.view.root.addChildAt(mDeadPlayerEffect, 0);
			applyUiHidden();
		});
		if (mDBFacade.hud != null) {
			mDBFacade.hud.offScreenPicChange((mHeroGameObject.id : Int), "REVIVE");
		}
		if (Std.isOfType(mHeroGameObject, HeroGameObjectOwner)) {
			mDeathCount = mDeathCount + 1;
			saturate(25);
			mDBFacade.uiHideToggle.reveal();
			loadDeadPlayerUI();
		} else if (!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam()) {
			if (mHeroGameObject != null && mHeroGameObject.distributedDungeonFloor != null) {
				ownerHeroId = mDBFacade.dbAccountInfo.activeAvatarInfo.id;
				go = mDBFacade.gameObjectManager.getReferenceFromId(ownerHeroId);
				ownerHeroGO = ASCompat.reinterpretAs(go, HeroGameObjectOwner);
				if (ownerHeroGO != null) {
					reviveTutorialPopupPosition = "TUTORIAL_PANEL_RIGHT";
					if (ownerHeroGO.view.position.x < mHeroGameObject.view.position.x) {
						reviveTutorialPopupPosition = "TUTORIAL_PANEL_LEFT";
					}
					if (ownerHeroGO.heroStateMachine.currentStateName != "ActorReviveState") {
						destroyReviveTutorial();
						mDungeonReviveTutorial = new DungeonTutorial(mDBFacade);
						mDungeonReviveTutorial.showReviveTutorial(reviveTutorialPopupPosition);
					}
				}
			}
		}
	}

	function checkIfHeroIsReadyAndInitReviveSensor(gameClock:GameClock) {
		var _loc2_:B2CircleShape = null;
		if (mHeroGameObject != null && mHeroGameObject.distributedDungeonFloor != null) {
			_loc2_ = new B2CircleShape(100 / 50);
			mReviveTrigger = new HeroReviveSensor(mDBFacade, mHeroGameObject.distributedDungeonFloor, _loc2_, (mHeroGameObject.team : UInt));
			mReviveTrigger.position = mHeroGameObject.actorView.position;
			mReviveTrigger.callback = activateReviveUI;
			mReviveTrigger.finishedCallback = deActivateReviveUI;
			if (mLoadReviveTriggerTask != null) {
				mLoadReviveTriggerTask.destroy();
			}
			mLoadReviveTriggerTask = null;
		}
	}

	override public function exitState() {
		if (mHitTabTween != null) {
			mDBFacade.mTween.killTween(mHitTabTween);
		}
		mHitTabTween = null;
		if (mHitTabClip != null && mDBFacade.hud != null) {
			mDBFacade.hud.removeControllerIcons(mHitTabClip);
		}
		mSceneGraphComponent.removeChild(mHitTabClip);
		mHitTabClip = null;
		if (Std.isOfType(mHeroGameObject, HeroGameObjectOwner)) {
			cast(mHeroGameObject, HeroGameObjectOwner).stopDeathCamInput();
		}
		if (mActorView.hasAnimationRenderer() && mActorView.hasAnim("getUp")) {
			mActorView.playAnim("getUp", 0, false, false);
			mActorGameObject.holdOneShotUntilMoving(mActorView.getAnimDurationInSeconds("getUp"));
		}
		mActorGameObject.playEffectAtActor("Resources/Art2D/FX/db_fx_library.swf", "db_fx_revive", 1, "foreground");
		mActorView.reviveHighlight();
		mLogicalWorkComponent.doLater(0.1, removeHighlight);
		mDBFacade.regainFocus();
		mActorView.actionsForExitDeadState();
		if (mDBFacade.hud != null) {
			mDBFacade.hud.offScreenPicChange((mHeroGameObject.id : Int), "alive");
		}
		mLogicalWorkComponent.doLater(2, destroyReviveTutorial);
		this.destroyUI();
		super.exitState();
	}

	function removeHighlight(gameClock:GameClock = null) {
		mActorView.reviveUnhighlight();
	}

	function activateReviveUI(heroGameObjectOwner:HeroGameObjectOwner) {
		if (heroGameObjectOwner != mHeroGameObject) {
			mKeyBoardInputWanted = true;
			if (mKeyBoardInput == null) {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"), function(param1:SwfAsset) {
					var __tmpAssignObj27:ASAny;
					var _loc2_ = param1.getClass("db_fx_revive_spacebar");
					mKeyBoardInput = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
					refreshReviveKeyLabel();
					if (mRevivePressed) {
						showRevivePressed(true);
					}
					mKeyBoardInput.x = mActorGameObject.position.x;
					mKeyBoardInput.y = mActorGameObject.position.y;
					mSceneGraphComponent.addChild(mKeyBoardInput, (30 : UInt));
					applyUiHidden();
					if (mDBFacade.steamInputManager.hasGlyphForAction("revive_ally")) {
						ASCompat.setProperty((mKeyBoardInput : ASAny).up, "scaleX", 0.8);
						ASCompat.setProperty((mKeyBoardInput : ASAny).over, "scaleX", 0.8);
						__tmpAssignObj27 = (mKeyBoardInput : ASAny).label;
						ASCompat.setProperty(__tmpAssignObj27, "x", __tmpAssignObj27.x + -15);
						Locale.setText(ASCompat.coerce((mKeyBoardInput : ASAny).label, flash.text.TextField), "REVIVE_TRIGGER_BUTTON_CONTROLLER");
						mDBFacade.hud.initControllerIcon("revive_ally", mKeyBoardInput, CONTROLLER_ICON_POSITION_FOR_REVIVE, CONTROLLER_GLYPH_SCALE_REVIVE);
					}
				});
			} else {
				applyUiHidden();
			}
			if (mSpaceBarReviveDownFunction == null) {
				mSpaceBarReviveDownFunction = function(param1:Event) {
					reviveKeyEvent(param1, heroGameObjectOwner);
				};
			}
			if (mSpaceBarReviveUpFunction == null) {
				mSpaceBarReviveUpFunction = function(param1:Event) {
					reviveReleasedKeyEvent(param1, heroGameObjectOwner);
				};
			}
			mDBFacade.keyBindings.addChangeListener(onKeyBindingsChanged);
			removeReviveInputListeners();
			EventListeners.add(mDBFacade.stageRef, "keyDown", mSpaceBarReviveDownFunction);
			EventListeners.add(mDBFacade.stageRef, "UnboundActionEvent.PRESSED", mSpaceBarReviveDownFunction);
			EventListeners.add(mDBFacade.stageRef, "keyUp", mSpaceBarReviveUpFunction);
			EventListeners.add(mDBFacade.stageRef, "UnboundActionEvent.RELEASED", mSpaceBarReviveUpFunction);
		}
	}

	function removeReviveInputListeners() {
		if (mSpaceBarReviveDownFunction != null) {
			EventListeners.remove(mDBFacade.stageRef, "keyDown", mSpaceBarReviveDownFunction);
			EventListeners.remove(mDBFacade.stageRef, "UnboundActionEvent.PRESSED", mSpaceBarReviveDownFunction);
		}
		if (mSpaceBarReviveUpFunction != null) {
			EventListeners.remove(mDBFacade.stageRef, "keyUp", mSpaceBarReviveUpFunction);
			EventListeners.remove(mDBFacade.stageRef, "UnboundActionEvent.RELEASED", mSpaceBarReviveUpFunction);
		}
	}

	function refreshReviveKeyLabel() {
		if (mKeyBoardInput == null || mDBFacade.steamInputManager.hasGlyphForAction("revive_ally")) {
			return;
		}
		TextUtil.setText(ASCompat.coerce((mKeyBoardInput : ASAny).label, flash.text.TextField),
			Locale.getString("REVIVE_TRIGGER_BUTTON") + mDBFacade.keyBindings.displayNameFor("reviveAlly"));
	}

	function onKeyBindingsChanged(action:String) {
		if (action != "reviveAlly") {
			return;
		}
		refreshReviveKeyLabel();
		showRevivePressed(false);
	}

	function deActivateReviveUI() {
		mKeyBoardInputWanted = false;
		applyUiHidden();
		showRevivePressed(false);
		removeReviveInputListeners();
	}

	function applyUiHidden() {
		var _loc1_ = mDBFacade.uiHideToggle.hidden;
		if (mDeadPlayerEffect != null) {
			mDeadPlayerEffect.visible = !_loc1_;
		}
		if (mKeyBoardInput != null) {
			mKeyBoardInput.visible = mKeyBoardInputWanted && !_loc1_;
		}
	}

	function reviveKeyEvent(event:Event, heroOwner:HeroGameObjectOwner) {
		if (heroOwner != null && heroOwner.heroStateMachine != null && mHeroGameObject != null) {
			if (isReviveEvent(event)
				&& didPressReviveAction()
				&& heroOwner.heroStateMachine.currentSubState.name == "ActorNavigationState") {
				showRevivePressed(true);
				if (mSpaceBarTask != null) {
					mSpaceBarTask.destroy();
				}
				mSpaceBarTask = null;
				heroOwner.attemptRevive(mHeroGameObject);
				if (!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam() && mDungeonReviveTutorial != null) {
					mEventComponent.dispatchEvent(new Event("REVIVE_SPACEBAR_PRESSED"));
				}
			}
		}
	}

	function isReviveEvent(event:Event):Bool {
		var _loc2_ = ASCompat.reinterpretAs(event, KeyboardEvent);
		if (_loc2_ != null) {
			return mDBFacade.keyBindings.matches("reviveAlly", (_loc2_.keyCode : Int));
		}
		return UnboundActionEvent.isAction(event, "revive_ally");
	}

	function reviveReleasedKeyEvent(event:Event, heroOwner:HeroGameObjectOwner) {
		if (!isReviveEvent(event)) {
			return;
		}
		if (heroOwner != null && heroOwner.heroStateMachine != null && mHeroGameObject != null) {
			showRevivePressed(false);
		}
	}

	function showRevivePressed(pressed:Bool) {
		mRevivePressed = pressed;
		if (mKeyBoardInput == null) {
			return;
		}
		ASCompat.setProperty((mKeyBoardInput : ASAny).up, "visible", !pressed);
		ASCompat.setProperty((mKeyBoardInput : ASAny).over, "visible", pressed);
	}

	function didPressReviveAction():Bool {
		return mDBFacade.keyBindings.wasPressed("reviveAlly") || mDBFacade.steamInputManager.pressedAction("revive_ally");
	}

	function initRevive() {}

	function loadDeadPlayerUI() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"), function(param1:SwfAsset) {
			if (mHeroGameObject.distributedDungeonFloor.isInfiniteDungeon) {
				loadDeadPlayerUIStage2(param1);
			} else {
				buildOriginalPanel(param1);
			}
		});
	}

	function loadDeadPlayerUIStage2(stage1Asset:SwfAsset) {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"), function(param1:SwfAsset) {
			if (mHeroGameObject.distributedDungeonFloor.isInfiniteDungeon) {
				buildLimitedHealthBombUsageRevivePanel(stage1Asset, param1);
			} else {
				buildOriginalPanel(param1);
			}
		});
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

	function buildLimitedHealthBombUsageRevivePanel(swfAsset:SwfAsset, chestAsset:SwfAsset) {
		var __tmpAssignObj28:ASAny;
		var reviveMeCallback:ASFunction;
		var reviveAllCallback:ASFunction;
		var partyBombsOwned:StackableInfo;
		var ownedHealthBombs:StackableInfo;
		var healthBombCount:UInt;
		var partyBombCount:UInt;
		var hitTabClass:Dynamic;
		var rewardSlots:Vector<MovieClip>;
		var myHero:HeroGameObjectOwner;
		var myRewards:Vector<InfiniteRewardData>;
		var reward:InfiniteRewardData;
		var slotNumber:Int;
		var alreadyReceived:Bool;
		var dooberData:GMDoober;
		var gmChestItem:GMChest;
		var chestClass:Dynamic;
		var dooberMC:MovieClip;
		var dooberController:MovieClipRenderController;
		var healthBombCostMultiplier:Float = 1;
		var offer:GMOffer = null;
		var assetClass = swfAsset.getClass("revive_prompt");
		mRevivePanel = ASCompat.coerce(ASCompat.createInstance(assetClass, []), flash.display.MovieClip);
		mRevivePanel.x = mDBFacade.viewWidth - mRevivePanel.width / 2.8;
		mRevivePanel.y += 169;
		mSceneGraphComponent.addChildAt(mRevivePanel, (105 : UInt), (0 : UInt));
		Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_heading, flash.text.TextField), "REVIVE_PANEL_HEADER");
		if (mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0) {
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_text_box, flash.text.TextField), "REVIVE_PANEL_INNER_MULTI_PLAYER");
		} else {
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_text_box, flash.text.TextField), "REVIVE_PANEL_INNER_SINGLE_PLAYER");
		}
		mSelfReviveMeButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_me, flash.display.MovieClip));
		mSelfReviveAllButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_all, flash.display.MovieClip));
		mReturnToTownButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button, flash.display.MovieClip));
		ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, "text", "");
		ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_me, "text", "");
		Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_me, flash.text.TextField), "REVIVE_PANEL_SELF_REVIVE_BUTTON");
		Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_all, flash.text.TextField), "REVIVE_PANEL_PARTY_REVIVE_BUTTON");
		partyBombsOwned = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.PARTYBOMB_POTION_STACK_ID),
			account.StackableInfo);
		offer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(DBGlobal.PARTYBOMB_POTION_OFFER_ID), gameMasterDictionary.GMOffer);
		if (mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.PARTYBOMB_POTION_STACK_ID) && partyBombsOwned != null) {
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_me, "visible", false);
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cash_icon_buy_me, "visible", false);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_me, flash.text.TextField), "REVIVE_PANEL_USE");
			reviveAllCallback = function() {
				mRevivePanel.visible = false;
				useRezAllPotion();
			};
		} else {
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_me, "visible", true);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_all, flash.text.TextField), "REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG");
			healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
			if (healthBombCostMultiplier < 1 && 0 != 0) {
				mSelfReviveAllButton.destroy();
				ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all, "visible", false);
			}
			TextUtil.setText(ASCompat.coerce((mSelfReviveAllButton.root : ASAny).cost_text_buy_me, flash.text.TextField), Std.string(offer.Price));
			reviveAllCallback = function() {
				if (offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price) {
					mRevivePanel.visible = false;
					EventListeners.add(mRevivePanel, "purchaseReviveAll-failed", handleReviveAllPurchaseFail);
				}
				buyReviveAll();
			};
		}
		mSelfReviveAllButton.releaseCallback = reviveAllCallback;
		if (mHeroGameObject.canUsePartyBombs()) {
			mSelfReviveAllButton.enabled = true;
			TextUtil.setText(ASCompat.coerce((mSelfReviveAllButton.root : ASAny).cost_text_buy_me, flash.text.TextField), Std.string(offer.Price));
		} else {
			mSelfReviveAllButton.enabled = false;
			Locale.setText(ASCompat.coerce((mSelfReviveAllButton.root : ASAny).cost_text_buy_me, flash.text.TextField),
				"REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT");
		}
		Locale.setText(mReturnToTownButton.label, "REVIVE_PANEL_FORFEIT_BUTTON");
		ownedHealthBombs = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.RESSURECTION_POTION_STACK_ID),
			account.StackableInfo);
		healthBombCount = (0 : UInt);
		if (ownedHealthBombs != null) {
			healthBombCount = ownedHealthBombs.count;
		}
		TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).quantity_hBomb, flash.text.TextField),
			Locale.getString("LIMITED_REVIVES_PANEL_HBOMBS_OWNED") + ": " + Std.string(healthBombCount));
		partyBombCount = (0 : UInt);
		if (partyBombsOwned != null) {
			partyBombCount = partyBombsOwned.count;
		}
		TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).quantity_pBomb, flash.text.TextField),
			Locale.getString("LIMITED_REVIVES_PANEL_PBOMBS_OWNED") + ": " + Std.string(partyBombCount));
		offer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(DBGlobal.RESSURECTION_POTION_OFFER_ID), gameMasterDictionary.GMOffer);
		if (mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.RESSURECTION_POTION_STACK_ID) && ownedHealthBombs != null) {
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", false);
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cash_icon_buy_me, "visible", false);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, flash.text.TextField), "REVIVE_PANEL_USE");
			reviveMeCallback = function() {
				mRevivePanel.visible = false;
				useRezMePotion();
			};
		} else {
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", true);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_me, flash.text.TextField), "REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG");
			healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
			if (healthBombCostMultiplier < 1 && 0 != 0) {
				mSelfReviveMeButton.destroy();
				ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me, "visible", false);
				mSelfReviveMeButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_sale, flash.display.MovieClip));
				TextUtil.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).original_cost_text, flash.text.TextField),
					Std.string(Math.fround(offer.Price / healthBombCostMultiplier)));
				__tmpAssignObj28 = (mSelfReviveMeButton.root : ASAny).strike;
				ASCompat.setProperty(__tmpAssignObj28, "scaleX",
					__tmpAssignObj28.scaleX * ASCompat.toNumberField((mSelfReviveMeButton.root : ASAny).original_cost_text.text, "length") / 3);
			}
			TextUtil.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, flash.text.TextField), Std.string(offer.Price));
			reviveMeCallback = function() {
				if (offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price) {
					mRevivePanel.visible = false;
				}
				buyReviveMe();
			};
		}
		mSelfReviveMeButton.releaseCallback = reviveMeCallback;
		if (mHeroGameObject.canUseHealthBombs()) {
			mSelfReviveMeButton.enabled = true;
			TextUtil.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, flash.text.TextField), Std.string(offer.Price));
		} else {
			mSelfReviveMeButton.enabled = false;
			Locale.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, flash.text.TextField),
				"REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT");
		}
		Locale.setText(mReturnToTownButton.label, "REVIVE_PANEL_FORFEIT_BUTTON");
		mReturnToTownButton.releaseCallback = function() {
			var _loc2_ = mHeroGameObject.distributedDungeonFloor.completionXp;
			var _loc1_ = new II_UIExitDungeonPopUp(mDBFacade, onForfeitClick, null);
		};
		hitTabClass = swfAsset.getClass("popup_keyboard_tab");
		mHitTabClip = ASCompat.dynamicAs(ASCompat.createInstance(hitTabClass, []), MovieClip);
		mHitTabClip.x = -150;
		mHitTabClip.y = 250;
		Locale.setText(ASCompat.coerce((mHitTabClip : ASAny).label, flash.text.TextField), "HIT_TAB_TEXT");
		mSceneGraphComponent.addChildAt(mHitTabClip, (105 : UInt), (0 : UInt));
		mHitTabTween = mDBFacade.mTween.tweenMaxTo(mHitTabClip, 0.5, {
			"x": 20,
			"y": mHitTabClip.y
		});
		rewardSlots = new Vector<MovieClip>();
		rewardSlots.push(ASCompat.coerce((mRevivePanel : ASAny).current_reward.loot_01, flash.display.MovieClip));
		rewardSlots.push(ASCompat.coerce((mRevivePanel : ASAny).current_reward.loot_02, flash.display.MovieClip));
		rewardSlots.push(ASCompat.coerce((mRevivePanel : ASAny).current_reward.loot_03, flash.display.MovieClip));
		rewardSlots.push(ASCompat.coerce((mRevivePanel : ASAny).current_reward.loot_04, flash.display.MovieClip));
		TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).current_reward.coin_count, flash.text.TextField),
			Std.string(mHeroGameObject.distributedDungeonFloor.parentArea.infiniteTotalGold));
		myHero = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id), HeroGameObjectOwner);
		myRewards = myHero.distributedDungeonFloor.parentArea.infiniteRewardData;
		slotNumber = 0;
		if (checkNullIteratee(myRewards))
			for (_tmp_ in myRewards) {
				reward = _tmp_;
				if (slotNumber < rewardSlots.length) {
					alreadyReceived = false;
					if (reward.status == 1) {
						alreadyReceived = true;
					} else {
						if (reward.status == 0) {
							break;
						}
						if (reward.status == 3) {
							continue;
						}
					}
					dooberData = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(reward.dooberId), gameMasterDictionary.GMDoober);
					gmChestItem = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(dooberData.ChestId), gameMasterDictionary.GMChest);
					chestClass = chestAsset.getClass(gmChestItem.IconName);
					dooberMC = ASCompat.coerce(ASCompat.createInstance(chestClass, []), flash.display.MovieClip);
					if (slotNumber == 0) {
						dooberMC.scaleY = 0.4;
						dooberMC.scaleX = 0.4;
						dooberMC.x -= 2;
					} else {
						dooberMC.scaleY = 0.51;
						dooberMC.scaleX = 0.51;
					}
					if (alreadyReceived) {
						desaturate(dooberMC);
					}
					dooberController = new MovieClipRenderController(mDBFacade, dooberMC);
					dooberController.loop = false;
					dooberController.stop();
					rewardSlots[slotNumber].addChild(dooberMC);
					ASCompat.setProperty((rewardSlots[slotNumber] : ASAny).loot, "visible", false);
				}
				slotNumber = slotNumber + 1;
			}
		if (mDBFacade.steamInputManager.hasGlyphForAction("revive_ally")) {
			ASCompat.setProperty((mHitTabClip : ASAny).tab, "visible", false);
			mDBFacade.hud.initControllerIcon("revive_ally", mHitTabClip, CONTROLLER_ICON_POSITION_FOR_SPECTATE, CONTROLLER_GLYPH_SCALE_SPECTATE);
		}
		lockBombButtons();
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			mDBFacade.menuNavigationController.pushNewLayer("REVIVE_MENU", popReviveMenuLayer, mReturnToTownButton);
			mSelfReviveMeButton.isAbove(mSelfReviveAllButton);
			mSelfReviveAllButton.isAbove(mReturnToTownButton);
		}
		setUpLimitedHealthBombGUI((mHeroGameObject.healthBombUsesRemaining : UInt), mRevivePanel);
		setUpLimitedPartyBombGUI((mHeroGameObject.partyBombUsesRemaining : UInt), mRevivePanel);
	}

	function setUpLimitedHealthBombGUI(usageRemaining:UInt, revivePanelClip:MovieClip) {
		ASCompat.setProperty((revivePanelClip : ASAny).hBomb01, "visible", false);
		ASCompat.setProperty((revivePanelClip : ASAny).hBomb01_off, "visible", true);
		ASCompat.setProperty((revivePanelClip : ASAny).hBomb02, "visible", false);
		ASCompat.setProperty((revivePanelClip : ASAny).hBomb02_off, "visible", true);
		ASCompat.setProperty((revivePanelClip : ASAny).hBomb03, "visible", false);
		ASCompat.setProperty((revivePanelClip : ASAny).hBomb03_off, "visible", true);
		switch (usageRemaining - 1) {
			case 0:
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb01, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb01_off, "visible", false);

			case 1:
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb01, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb01_off, "visible", false);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb02, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb02_off, "visible", false);

			case 2:
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb01, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb01_off, "visible", false);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb02, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb02_off, "visible", false);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb03, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).hBomb03_off, "visible", false);
		}
	}

	function setUpLimitedPartyBombGUI(usageRemaining:UInt, revivePanelClip:MovieClip) {
		ASCompat.setProperty((revivePanelClip : ASAny).pBomb01, "visible", false);
		ASCompat.setProperty((revivePanelClip : ASAny).pBomb01_off, "visible", true);
		ASCompat.setProperty((revivePanelClip : ASAny).pBomb02, "visible", false);
		ASCompat.setProperty((revivePanelClip : ASAny).pBomb02_off, "visible", true);
		ASCompat.setProperty((revivePanelClip : ASAny).pBomb03, "visible", false);
		ASCompat.setProperty((revivePanelClip : ASAny).pBomb03_off, "visible", true);
		switch (usageRemaining - 1) {
			case 0:
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb01, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb01_off, "visible", false);

			case 1:
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb01, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb01_off, "visible", false);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb02, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb02_off, "visible", false);

			case 2:
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb01, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb01_off, "visible", false);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb02, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb02_off, "visible", false);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb03, "visible", true);
				ASCompat.setProperty((revivePanelClip : ASAny).pBomb03_off, "visible", false);
		}
	}

	function buildOriginalPanel(swfAsset:SwfAsset) {
		var __tmpAssignObj29:ASAny;
		var healthBomb:StackableInfo;
		var REVIVE_MENU_SCALE:Float;
		var king:DisplayObject;
		var kingBounds:Rectangle;
		var reviveMeCallback:ASFunction;
		var reviveAllCallback:ASFunction;
		var partyBomb:StackableInfo;
		var hitTabClass:Dynamic;
		var healthBombCostMultiplier:Float = 1;
		var offer:GMOffer = null;
		var assetClass = swfAsset.getClass("DR_revive_prompt");
		mRevivePanel = ASCompat.coerce(ASCompat.createInstance(assetClass, []), flash.display.MovieClip);
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).revive_king.revive_chat_balloon.close, flash.display.MovieClip));
		mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mCloseButton.releaseCallback = function() {
			mRevivePanel.removeChild(ASCompat.coerce((mRevivePanel : ASAny).revive_king, flash.display.DisplayObject));
		};
		ASCompat.setProperty((mRevivePanel : ASAny).revive_king.revive_chat_balloon, "king_title", Locale.getString("KING_REVIVE_TITLE"));
		ASCompat.setProperty((mRevivePanel : ASAny).revive_king.revive_chat_balloon, "king_text", Locale.getString("KING_REVIVE_MESSAGE"));
		mSceneGraphComponent.addChildAt(mRevivePanel, (105 : UInt), (0 : UInt));
		mRevivePanel.scaleX = mRevivePanel.scaleY = 1.8;
		mRevivePanel.x = mDBFacade.viewWidth - mRevivePanel.width / 2;
		mRevivePanel.y = mDBFacade.viewHeight - mRevivePanel.height / 2;
		king = ASCompat.dynamicAs((mRevivePanel : ASAny).revive_king, DisplayObject);
		king.scaleX = king.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE / 1.8;
		kingBounds = king.getBounds(mRevivePanel.parent);
		king.x += (0 - kingBounds.left) / 1.8;
		king.y += (mDBFacade.viewHeight - kingBounds.bottom) / 1.8;
		Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_heading, flash.text.TextField), "REVIVE_PANEL_HEADER");
		if (mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0) {
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_text_box, flash.text.TextField), "REVIVE_PANEL_INNER_MULTI_PLAYER");
		} else {
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_text_box, flash.text.TextField), "REVIVE_PANEL_INNER_SINGLE_PLAYER");
		}
		mSelfReviveMeButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_me, flash.display.MovieClip));
		mSelfReviveAllButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_all, flash.display.MovieClip));
		mReturnToTownButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_2, flash.display.MovieClip));
		ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, "text", "");
		ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_all, "text", "");
		ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, "text", "");
		Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_me, flash.text.TextField), "REVIVE_PANEL_SELF_REVIVE_BUTTON");
		Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_all, flash.text.TextField), "REVIVE_PANEL_PARTY_REVIVE_BUTTON");
		partyBomb = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.PARTYBOMB_POTION_STACK_ID),
			account.StackableInfo);
		offer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(DBGlobal.PARTYBOMB_POTION_OFFER_ID), gameMasterDictionary.GMOffer);
		if (mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.PARTYBOMB_POTION_STACK_ID) && partyBomb != null) {
			TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_all.stackable_buy_all, flash.text.TextField),
				"X" + Std.string(partyBomb.count));
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_all, "visible", false);
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cash_icon_buy_me, "visible", false);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_all, flash.text.TextField), "REVIVE_PANEL_USE");
			reviveAllCallback = function() {
				mRevivePanel.visible = false;
				useRezAllPotion();
			};
		} else {
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_all, "visible", true);
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.stackable_buy_all, "visible", false);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_all, flash.text.TextField), "REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG");
			healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
			if (healthBombCostMultiplier < 1 && 0 != 0) {
				mSelfReviveAllButton.destroy();
				ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all, "visible", false);
			}
			TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_all.stackable_buy_all, flash.text.TextField), "0");
			TextUtil.setText(ASCompat.coerce((mSelfReviveAllButton.root : ASAny).cost_text_buy_all, flash.text.TextField), Std.string(offer.Price));
			reviveAllCallback = function() {
				if (offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price) {
					mRevivePanel.visible = false;
					EventListeners.add(mRevivePanel, "purchaseReviveAll-failed", handleReviveAllPurchaseFail);
				}
				buyReviveAll();
			};
		}
		mSelfReviveAllButton.releaseCallback = reviveAllCallback;
		if (mHeroGameObject.canUsePartyBombs()) {
			mSelfReviveAllButton.enabled = true;
			TextUtil.setText(ASCompat.coerce((mSelfReviveAllButton.root : ASAny).cost_text_buy_all, flash.text.TextField), Std.string(offer.Price));
		} else {
			mSelfReviveAllButton.enabled = false;
			Locale.setText(ASCompat.coerce((mSelfReviveAllButton.root : ASAny).cost_text_buy_all, flash.text.TextField),
				"REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT");
		}
		Locale.setText(mReturnToTownButton.label, "REVIVE_PANEL_FORFEIT_BUTTON");
		healthBomb = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(DBGlobal.RESSURECTION_POTION_STACK_ID),
			account.StackableInfo);
		offer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(DBGlobal.RESSURECTION_POTION_OFFER_ID), gameMasterDictionary.GMOffer);
		if (mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(DBGlobal.RESSURECTION_POTION_STACK_ID) && healthBomb != null) {
			TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, flash.text.TextField),
				"X" + Std.string(healthBomb.count));
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", false);
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cash_icon_buy_me, "visible", false);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, flash.text.TextField), "REVIVE_PANEL_USE");
			reviveMeCallback = function() {
				mRevivePanel.visible = false;
				useRezMePotion();
			};
		} else {
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", true);
			ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, "visible", false);
			Locale.setText(ASCompat.coerce((mRevivePanel : ASAny).label_buy_me, flash.text.TextField), "REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG");
			healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
			if (healthBombCostMultiplier < 1 && 0 != 0) {
				mSelfReviveMeButton.destroy();
				ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me, "visible", false);
				mSelfReviveMeButton = new UIButton(mDBFacade, ASCompat.coerce((mRevivePanel : ASAny).prompt_button_sale, flash.display.MovieClip));
				TextUtil.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).original_cost_text, flash.text.TextField),
					Std.string(Math.fround(offer.Price / healthBombCostMultiplier)));
				__tmpAssignObj29 = (mSelfReviveMeButton.root : ASAny).strike;
				ASCompat.setProperty(__tmpAssignObj29, "scaleX",
					__tmpAssignObj29.scaleX * ASCompat.toNumberField((mSelfReviveMeButton.root : ASAny).original_cost_text.text, "length") / 3);
			}
			TextUtil.setText(ASCompat.coerce((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, flash.text.TextField), "0");
			TextUtil.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, flash.text.TextField), Std.string(offer.Price));
			reviveMeCallback = function() {
				if (offer.CurrencyType == GMOffer.PREMIUM_CURRENCY && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price) {
					mRevivePanel.visible = false;
				}
				buyReviveMe();
			};
		}
		mSelfReviveMeButton.releaseCallback = reviveMeCallback;
		if (mHeroGameObject.canUseHealthBombs()) {
			mSelfReviveMeButton.enabled = true;
			TextUtil.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, flash.text.TextField), Std.string(offer.Price));
		} else {
			mSelfReviveMeButton.enabled = false;
			Locale.setText(ASCompat.coerce((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, flash.text.TextField),
				"REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT");
		}
		Locale.setText(mReturnToTownButton.label, "REVIVE_PANEL_FORFEIT_BUTTON");
		mReturnToTownButton.releaseCallback = function() {
			var _loc2_ = mHeroGameObject.distributedDungeonFloor.completionXp;
			var _loc1_ = new UILootLossPopup(mDBFacade, _loc2_, mHeroGameObject.distributedDungeonFloor.treasureCollected, onForfeitClick, null);
			MemoryTracker.track(_loc1_, "UILootLossPopup - created in ActorReviveState.loadedAssets()");
		};
		hitTabClass = swfAsset.getClass("popup_keyboard_tab");
		mHitTabClip = ASCompat.dynamicAs(ASCompat.createInstance(hitTabClass, []), MovieClip);
		mHitTabClip.x = -150;
		mHitTabClip.y = 250;
		Locale.setText(ASCompat.coerce((mHitTabClip : ASAny).label, flash.text.TextField), "HIT_TAB_TEXT");
		mSceneGraphComponent.addChildAt(mHitTabClip, (105 : UInt), (0 : UInt));
		mHitTabTween = mDBFacade.mTween.tweenMaxTo(mHitTabClip, 0.5, {
			"x": 20,
			"y": mHitTabClip.y
		});
		if (mDBFacade.steamInputManager.hasGlyphForAction("revive_ally")) {
			ASCompat.setProperty((mHitTabClip : ASAny).tab, "visible", false);
			mDBFacade.hud.initControllerIcon("revive_ally", mHitTabClip, CONTROLLER_ICON_POSITION_FOR_SPECTATE, CONTROLLER_GLYPH_SCALE_SPECTATE);
		}
		lockBombButtons();
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			mDBFacade.menuNavigationController.pushNewLayer("REVIVE_MENU", popReviveMenuLayer, mReturnToTownButton);
			mSelfReviveMeButton.isToTheLeftOf(mSelfReviveAllButton);
			mSelfReviveMeButton.isAbove(mReturnToTownButton);
		}
	}

	function lockBombButtons() {
		var reviveMeEnabled = mSelfReviveMeButton.enabled;
		var reviveAllEnabled = mSelfReviveAllButton.enabled;
		mSelfReviveMeButton.enabled = false;
		mSelfReviveAllButton.enabled = false;
		mReturnToTownButton.enabled = true;
		if (mBombButtonLockTask != null) {
			mBombButtonLockTask.destroy();
		}
		mBombButtonLockTask = mLogicalWorkComponent.doLater(2, function(param1:GameClock = null) {
			mBombButtonLockTask = null;
			if (mSelfReviveMeButton != null) {
				mSelfReviveMeButton.enabled = reviveMeEnabled;
			}
			if (mSelfReviveAllButton != null) {
				mSelfReviveAllButton.enabled = reviveAllEnabled;
			}
		});
	}

	function popReviveMenuLayer() {
		if (!Std.isOfType(mHeroGameObject, HeroGameObjectOwner)) {
			return;
		}
		if (mDBFacade.menuNavigationController.getTopUILayer() != "REVIVE_MENU") {
			return;
		}
		mDBFacade.menuNavigationController.popLayer("REVIVE_MENU");
	}

	function popForfeitConfirmLayer() {
		if (mDBFacade.menuNavigationController.getTopUILayer() == "EXIT_DUNGEON") {
			mDBFacade.menuNavigationController.popLayer("EXIT_DUNGEON");
		}
		if (mDBFacade.menuNavigationController.getTopUILayer() == "EXIT_INFINITE_DUNGEON") {
			mDBFacade.menuNavigationController.popLayer("EXIT_INFINITE_DUNGEON");
		}
	}

	function handleReviveAllPurchaseFail(event:Event) {
		mRevivePanel.visible = false;
	}

	function getHealthBombSplitTestMultiplier():Float {
		return mDBFacade.getSplitTestNumber("InDungeonHealthBombSale", 1);
	}

	function startLogMetrics(buttonText:String) {
		var _loc2_:ASObject = {};
		ASCompat.setProperty(_loc2_, "buttonDesc", buttonText);
		ASCompat.setProperty(_loc2_, "areaType", "Dungeon");
		logMetrics("ButtonClick", _loc2_);
	}

	function onForfeitClick() {
		var metricsObject:ASObject = {};
		ASCompat.setProperty(metricsObject, "buttonDesc", "Revive Exit Button Clicked");
		ASCompat.setProperty(metricsObject, "areaType", "Dungeon");
		logMetrics("ButtonClick", metricsObject);
		popForfeitConfirmLayer();
		Logger.debug("ActorReviveState -- Starting Clean Shutdown");
		mLogicalWorkComponent.doLater(5, function() {
			mDBFacade.mainStateMachine.enterReloadTownState();
		});
		mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
		if (mDBFacade.hud.chatLog != null) {
			mDBFacade.hud.chatLog.hideChatLog();
		}
		this.destroyUI();
	}

	public function useRezMePotion() {
		startLogMetrics("Rez Potion Button Clicked");
		ASCompat.reinterpretAs(mHeroGameObject, HeroGameObjectOwner).proposeSelfRevive((0 : UInt));
	}

	public function buyReviveMe() {
		startLogMetrics("Buy Revive Button Clicked");
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(DBGlobal.RESSURECTION_POTION_OFFER_ID), gameMasterDictionary.GMOffer);
		StoreServicesController.tryBuyOffer(mDBFacade, _loc1_, buyReviveMeSuccess);
	}

	public function buyReviveMeSuccess(details:ASAny) {
		ASCompat.reinterpretAs(mHeroGameObject, HeroGameObjectOwner).proposeSelfRevive((0 : UInt));
	}

	public function useRezAllPotion() {
		startLogMetrics("Rez Potion Button Clicked");
		ASCompat.reinterpretAs(mHeroGameObject, HeroGameObjectOwner).proposeSelfRevive((1 : UInt));
	}

	public function buyReviveAll() {
		startLogMetrics("Buy Revive Button Clicked");
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(DBGlobal.PARTYBOMB_POTION_OFFER_ID), gameMasterDictionary.GMOffer);
		StoreServicesController.tryBuyOffer(mDBFacade, _loc1_, buyReviveAllSuccess);
	}

	public function buyReviveAllSuccess(details:ASAny) {
		ASCompat.reinterpretAs(mHeroGameObject, HeroGameObjectOwner).proposeSelfRevive((1 : UInt));
	}

	public function destroyUI() {
		popReviveMenuLayer();
		if (Std.isOfType(mHeroGameObject, HeroGameObjectOwner)) {
			saturate(100);
		}
		if (mLoadReviveTriggerTask != null) {
			mLoadReviveTriggerTask.destroy();
			mLoadReviveTriggerTask = null;
		}
		if (mSpaceBarTask != null) {
			mSpaceBarTask.destroy();
			mSpaceBarTask = null;
		}
		if (mBombButtonLockTask != null) {
			mBombButtonLockTask.destroy();
			mBombButtonLockTask = null;
		}
		if (mDeadPlayerEffect != null) {
			if (mHeroGameObject.view.root.contains(mDeadPlayerEffect)) {
				mHeroGameObject.view.root.removeChild(mDeadPlayerEffect);
			}
			mDeadPlayerEffect = null;
		}
		if (mKeyBoardInput != null) {
			if (mDBFacade.hud != null) {
				mDBFacade.hud.removeControllerIcons(mKeyBoardInput);
			}
			mSceneGraphComponent.removeChild(mKeyBoardInput);
			mKeyBoardInput = null;
		}
		mKeyBoardInputWanted = false;
		mRevivePressed = false;
		if (mDBFacade.keyBindings != null) {
			mDBFacade.keyBindings.removeChangeListener(onKeyBindingsChanged);
		}
		removeReviveInputListeners();
		mSpaceBarReviveDownFunction = null;
		mSpaceBarReviveUpFunction = null;
		if (mReviveTrigger != null) {
			mReviveTrigger.destroy();
			mReviveTrigger = null;
		}
		if (mRevivePanel != null) {
			mSceneGraphComponent.removeChild(mRevivePanel);
			if (mSelfReviveMeButton != null) {
				mSelfReviveMeButton.destroy();
				mSelfReviveMeButton = null;
			}
			if (mSelfReviveAllButton != null) {
				mSelfReviveAllButton.destroy();
				mSelfReviveAllButton = null;
			}
			if (mReturnToTownButton != null) {
				mReturnToTownButton.destroy();
				mReturnToTownButton = null;
			}
			if (mCloseButton != null) {
				mCloseButton.destroy();
				mCloseButton = null;
			}
			mRevivePanel = null;
		}
	}

	function destroyReviveTutorial(gameClock:GameClock = null) {
		if (mDungeonReviveTutorial != null) {
			mDungeonReviveTutorial.destroy();
		}
		mDungeonReviveTutorial = null;
	}

	override public function destroy() {
		this.destroyUI();
		mHeroGameObject = null;
		destroyReviveTutorial();
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		mEventComponent.destroy();
		mEventComponent = null;
		super.destroy();
	}

	public function logMetrics(eventName:String, metricsObject:ASObject) {
		ASCompat.setProperty(metricsObject, "areaId", mHeroGameObject.distributedDungeonFloor.id);
		mDBFacade.metrics.log(eventName, metricsObject);
	}

	function saturate(value:Float) {
		var _loc2_:Array<ASAny> = [50, 105];
		mSceneGraphComponent.saturateLayers(value, _loc2_);
	}
}
