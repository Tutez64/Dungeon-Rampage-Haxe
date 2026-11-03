package actor;

import account.PlayerSpecialStatus;
import actor.starlingConvertedOverlay.StarlingNametag;
import actor.starlingConvertedOverlay.StarlingOverlays;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.gameObject.GameObject;
import brain.uI.UIProgressBar;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import distributedObjects.PlayerGameObject;
import events.GameObjectEvent;
import facade.DBFacade;
import facade.Locale;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.text.TextField;

class ActorNametag extends Sprite {
	public static inline final NAMETAG_SWF_ROOT = "Resources/Art2D/UI/db_UI_nametag.swf";

	static inline final STEAM_AVATAR_VISIBLE_TIME:Float = 5;

	static inline final STEAM_AVATAR_ANIMATE_UP_FRAMES:Float = 0.25;

	static inline final STEAM_AVATAR_ANIMATE_DOWN_FRAMES:Float = 0.25;

	static inline final AFK_TEXT_GAP:Float = 2;

	static inline final AFK_TEXT_SIZE_MODIFIER:Float = 1.45;

	static inline final TYPING_TEXT_SIZE:Float = 16;

	static inline final TYPING_FLOOR_SCALE:Float = 0.7;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mShowNametagTask:Task;

	var mHpProgressBar:UIProgressBar;

	var mHpBarBg:Sprite;

	var mHpProgressBarVisible:Bool = true;

	var mTextField:TextField;

	var mTextFieldBottom:Float = Math.NaN;

	var mAFKText:TextField;

	var mAFKTextBottom:Float = Math.NaN;

	var mScreenName:String = Locale.getString("DEFAULT_NAMETAG");

	var mHealth:Float = 1;

	var mDBFacade:DBFacade;

	var mNametagTop:Sprite;

	var mNametagTopStartingYPosition:Float = Math.NaN;

	var mChatBalloon:ChatBalloon;

	var mPlayerIsTypingNotification:MovieClip;

	var mTypingTopY:Float = 0;

	var mChatDuration:Float = 5;

	var mAFK:Bool = false;

	var mNametagFBPicSlot:MovieClip;

	var mSteamAvatar:DisplayObject;

	var mHpBarHolder:MovieClip;

	var mStarlingNametag:StarlingNametag;

	var mWantVisible:Bool = true;

	public function new(dbfacade:DBFacade, assetLoader:AssetLoadingComponent, workComponent:LogicalWorkComponent, nametagY:Float) {
		super();
		mDBFacade = dbfacade;
		mLogicalWorkComponent = workComponent;
		mEventComponent = new EventComponent(mDBFacade);
		this.name = "ActorNametag";
		this.mouseChildren = false;
		this.mouseEnabled = false;
		mNametagTop = new Sprite();
		mNametagTop.name = "ActorNametag.mNametagTop";
		this.addChild(mNametagTop);
		this.y = -nametagY;
		this.x = 0;
		showNametag();
		mChatBalloon = new ChatBalloon();
		mChatBalloon.visible = false;
		this.addChild(mChatBalloon);
		ChatBalloonOverlay.register(mChatBalloon);
		mEventComponent.addListener("UI_HIDE_TOGGLE_CHANGED", applyVisible);
		applyVisible();
		assetLoader.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"), setupNametagFromSwf);
	}

	override public function set_visible(value:Bool) {
		mWantVisible = value;
		applyVisible();
		return value;
	}

	override public function get_visible():Bool {
		return mWantVisible;
	}

	@:isVar public var shownOnScreen(get, never):Bool;

	public function get_shownOnScreen():Bool {
		return super.visible;
	}

	function applyVisible(event:Event = null) {
		var _loc2_ = mDBFacade != null && mDBFacade.uiHideToggle != null && mDBFacade.uiHideToggle.hidden;
		super.visible = mWantVisible && !_loc2_;
	}

	function setupNametagFromSwf(swfAsset:SwfAsset) {
		var _loc3_ = swfAsset.getClass("UI_nametag");
		var _loc5_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
		mNametagFBPicSlot = ASCompat.coerce((_loc5_ : ASAny).avatar, flash.display.MovieClip);
		mNametagFBPicSlot.visible = false;
		mHpBarHolder = ASCompat.coerce((_loc5_ : ASAny).hp, flash.display.MovieClip);
		mHpProgressBar = new UIProgressBar(mDBFacade, ASCompat.coerce((_loc5_ : ASAny).hp.hpBar, flash.display.MovieClip));
		mHpProgressBar.value = mHealth;
		mHpProgressBar.visible = mHpProgressBarVisible;
		mTextField = ASCompat.coerce((_loc5_ : ASAny).nameText, flash.text.TextField);
		mTextFieldBottom = mTextField.y + mTextField.height;
		if (TextUtil.enabled) {
			mTextField.autoSize = "center";
		}
		updateNameTagText();
		mAFKText = ASCompat.coerce((_loc5_ : ASAny).AFKText, flash.text.TextField);
		mAFKTextBottom = mAFKText.y + mAFKText.height;
		if (TextUtil.enabled) {
			mAFKText.autoSize = "center";
		}
		mAFKText.text = "";
		mHpBarBg = ASCompat.coerce((_loc5_ : ASAny).hp.hpBarBg, flash.display.Sprite);
		mNametagTop.addChild(_loc5_);
		mNametagTopStartingYPosition = mNametagTop.y;
		var _loc4_ = swfAsset.getClass("UI_speechbubble");
		var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
		mChatBalloon.initializeChatBalloon(swfAsset, null, chatSizeModifier);
		var _loc6_ = swfAsset.getClass("UI_speechbubble_typing");
		mPlayerIsTypingNotification = ASCompat.coerce(ASCompat.createInstance(_loc6_, []), flash.display.MovieClip);
		this.addChild(mPlayerIsTypingNotification);
		mPlayerIsTypingNotification.visible = false;
		mPlayerIsTypingNotification.stop();
		mTypingTopY = mPlayerIsTypingNotification.getBounds(mPlayerIsTypingNotification).top;
		if (StarlingOverlays.wanted(mDBFacade)) {
			mStarlingNametag = StarlingOverlays.get(mDBFacade).addTag(this, mNametagTop, _loc5_, mTextField, mAFKText, mHpBarHolder, mHpProgressBar.bar);
		}
	}

	public function setChat(message:String) {
		if (mChatBalloon != null) {
			mChatBalloon.sizeModifier = chatSizeModifier;
			mChatBalloon.text = message;
		}
		showChat();
		if (mShowNametagTask != null) {
			mShowNametagTask.destroy();
		}
		mShowNametagTask = mLogicalWorkComponent.doLater(mChatDuration, showNametag);
	}

	@:isVar public var chatBalloon(get, never):ChatBalloon;

	public function get_chatBalloon():ChatBalloon {
		return mChatBalloon;
	}

	@:isVar var chatSizeModifier(get, never):Float;

	function get_chatSizeModifier():Float {
		return Math.max(1.82, Locale.nametagSizeModifier);
	}

	public function setHp(hp:UInt, maxHp:UInt) {
		mHealth = hp / maxHp;
		if (mHpProgressBar != null) {
			mHpProgressBar.value = mHealth;
		}
	}

	@:isVar public var hpBarVisible(get, set):Bool;

	public function set_hpBarVisible(value:Bool):Bool {
		mHpProgressBarVisible = value;
		if (mHpProgressBar != null) {
			mHpProgressBar.visible = mHpProgressBarVisible;
		}
		if (mHpBarBg != null) {
			mHpBarBg.visible = mHpProgressBarVisible;
		}
		return value;
	}

	@:isVar public var hpBar(get, never):MovieClip;

	public function get_hpBar():MovieClip {
		return mHpBarHolder;
	}

	function get_hpBarVisible():Bool {
		return mHpProgressBarVisible;
	}

	@:isVar public var screenName(never, set):String;

	public function set_screenName(value:String):String {
		mScreenName = value;
		updateNameTagText();
		return value;
	}

	function updateNameTagText() {
		if (mTextField != null) {
			TextUtil.setText(mTextField, mScreenName, Locale.nametagSizeModifier);
			TextUtil.addOverhangSlack(mTextField);
			mTextField.y = mTextFieldBottom - mTextField.height;
			mTextField.textColor = PlayerSpecialStatus.getSpecialTextColor(mScreenName, mTextField.textColor);
			layoutAFKText();
		}
		if (mStarlingNametag != null) {
			mStarlingNametag.contentChanged();
		}
	}

	function layoutAFKText() {
		if (mAFKText == null) {
			return;
		}
		var _loc1_ = mAFKTextBottom;
		if (mTextField != null && mTextField.text != "") {
			_loc1_ = Math.min(_loc1_, mTextField.y - 2);
		}
		mAFKText.y = _loc1_ - mAFKText.height;
	}

	function showChat(gameClock:GameClock = null) {
		if (mChatBalloon != null) {
			mChatBalloon.visible = true;
		}
		mNametagTop.visible = false;
	}

	function showNametag(gameClock:GameClock = null) {
		if (mChatBalloon != null) {
			mChatBalloon.visible = false;
		}
		mNametagTop.visible = true;
	}

	public function showPlayerIsTypingNotification(value:Bool) {
		if (mPlayerIsTypingNotification != null && !mChatBalloon.visible) {
			mPlayerIsTypingNotification.visible = value;
			if (value) {
				scaleTypingToFloor();
				mPlayerIsTypingNotification.play();
			} else {
				mPlayerIsTypingNotification.stop();
			}
		}
	}

	function scaleTypingToFloor() {
		var _loc1_ = TextUtil.scaleToFloor(16, Locale.nametagSizeModifier * 0.7);
		mPlayerIsTypingNotification.scaleX = mPlayerIsTypingNotification.scaleY = _loc1_;
		mPlayerIsTypingNotification.y = mTypingTopY * (1 - _loc1_);
	}

	public function destroy() {
		if (mStarlingNametag != null) {
			mStarlingNametag.destroy();
		}
		mStarlingNametag = null;
		if (mShowNametagTask != null) {
			mShowNametagTask.destroy();
		}
		if (mHpProgressBar != null) {
			mHpProgressBar.destroy();
		}
		if (mEventComponent != null) {
			mEventComponent.destroy();
		}
		mEventComponent = null;
		mHpBarHolder = null;
		if (mChatBalloon != null) {
			ChatBalloonOverlay.unregister(mChatBalloon);
		}
		mChatBalloon = null;
		mSteamAvatar = null;
		mNametagFBPicSlot = null;
		if (mPlayerIsTypingNotification != null) {
			mPlayerIsTypingNotification.stop();
		}
		mPlayerIsTypingNotification = null;
		mLogicalWorkComponent = null;
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
		mDBFacade = null;
	}

	public function showSteamAvatar(playerId:UInt) {
		var go:GameObject;
		var player:PlayerGameObject;
		if (mSteamAvatar == null) {
			go = mDBFacade.gameObjectManager.getReferenceFromId(playerId);
			player = ASCompat.reinterpretAs(go, PlayerGameObject);
			if (player != null) {
				if (ASCompat.stringAsBool(player.steamAvatarUrl) && player.steamAvatarUrl != "") {
					saveSteamAvatar(player.steamAvatarUrl);
				} else {
					mEventComponent.addListener(GameObjectEvent.uniqueEvent("STEAM_AVATAR_URL_RECEIVED_EVENT", player.id),
						function(param1:events.SteamAvatarUrlReceivedEvent) {
							saveSteamAvatar(param1.steamAvatarUrl);
						});
				}
			}
		} else if (mNametagFBPicSlot != null && !mNametagFBPicSlot.visible) {
			startSteamAvatarPicLerp();
		}
	}

	function saveSteamAvatar(steamAvatarUrl:String) {
		var lc:LoaderContext;
		var loader = new Loader();
		var picUrl = steamAvatarUrl;
		var url = new URLRequest(picUrl);
		EventListeners.add(loader.contentLoaderInfo, "ioError", function() {});
		EventListeners.add(loader.contentLoaderInfo, "securityError", function() {});
		EventListeners.add(loader.contentLoaderInfo, "complete", function(param1:Event) {
			mSteamAvatar = loader;
			mSteamAvatar.x -= 25;
			mSteamAvatar.y -= 25;
			mSteamAvatar.width = mSteamAvatar.height = 50;
			if (mNametagFBPicSlot != null) {
				mNametagFBPicSlot.addChild(mSteamAvatar);
				startSteamAvatarPicLerp();
			}
		});
		lc = new LoaderContext(true);
		lc.checkPolicyFile = true;
		loader.load(url, lc);
	}

	function startSteamAvatarPicLerp() {
		var _loc1_ = mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mNametagTop, 0.25, {"y": mNametagTopStartingYPosition - mNametagFBPicSlot.height}),
				mDBFacade.mTween.tweenMaxTo(mNametagFBPicSlot, 0.041666666666666664, {"visible": true})
			],
			"align": "sequence"
		});
		mLogicalWorkComponent.doLater(5, finishSteamAvatarLerp);
	}

	function finishSteamAvatarLerp(gameClock:GameClock) {
		var _loc2_ = mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mNametagFBPicSlot, 0.041666666666666664, {"visible": false}),
				mDBFacade.mTween.tweenMaxTo(mNametagTop, 0.25, {"y": mNametagTopStartingYPosition})
			],
			"align": "sequence"
		});
	}

	@:isVar public var AFK(never, set):Bool;

	public function set_AFK(value:Bool):Bool {
		mAFK = value;
		if (mAFKText != null) {
			Locale.setText(mAFKText, mAFK ? "AFK" : null, null, 1.82 * 1.45);
			layoutAFKText();
		}
		if (mStarlingNametag != null) {
			mStarlingNametag.contentChanged();
		}
		return value;
	}
}
