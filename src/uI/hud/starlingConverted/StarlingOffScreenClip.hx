package uI.hud.starlingConverted;

import account.PlayerSpecialStatus;
import actor.ActorGameObject;
import brain.event.EventComponent;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import brain.utils.TextUtil;
import distributedObjects.HeroGameObject;
import events.ChatEvent;
import events.GameObjectEvent;
import events.HpEvent;
import events.PlayerIsTypingEvent;
import facade.DBFacade;
import facade.Locale;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.text.TextField;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

class StarlingOffScreenClip {
	var mFacade:DBFacade;

	var mPlayer:ActorGameObject;

	var mView:ArtView;

	var mArrow:DisplayObject;

	var mName:StarlingText;

	var mNameX:Float = Math.NaN;

	var mAlert:StarlingText;

	var mAlertX:Float = Math.NaN;

	var mHpView:ArtView;

	var mHpRoot:DisplayObject;

	var mHp:StarlingBar;

	var mEvents:EventComponent;

	var mTicker:HudTicker;

	var mAvatar:StarlingHudIcon;

	var mRedAvatar:StarlingHudIcon;

	var mDeath:StarlingHudIcon;

	var mTyping:ArtView;

	var mBalloon:BakedImage;

	var mBalloonCell:BakedCell;

	var mBalloonSource:MovieClip;

	var mBalloonRetry:ASFunction;

	var mBalloonKey:String;

	var mBalloonScale:Float = Math.NaN;

	var mBalloonPixelScale:Float = Math.NaN;

	var mBalloonY:Float = Math.NaN;

	var mChatUntil:Int = 0;

	var mRescue:Bool = false;

	var mDeathOnTop:Bool = true;

	var mNextSwap:Int = 0;

	var mSteamCount:UInt = 0;

	var mChanged:ASFunction;

	var mBounds:Rectangle = new Rectangle();

	var mDisposed:Bool = false;

	var mFresh:Bool = true;

	var mBalloonPages:BakedPages;

	var mPendingMessage:String;

	public function new(facade:DBFacade, ticker:HudTicker, parent:DisplayObjectContainer, player:ActorGameObject, changed:ASFunction) {
		var _loc6_:String = null;
		var _loc8_:String = null;

		mFacade = facade;
		mTicker = ticker;
		mPlayer = player;
		mChanged = changed;
		mView = ArtView.build(HudArt.art("UI_widget"), ticker);
		cast(mView.root, ArtDisplay).advanceHiddenTimelines(true);
		mArrow = mView.node("UI_arrow");
		mView.root.scaleX = mView.root.scaleY = 1.44;
		mView.root.visible = false;
		parent.addChild(mView.root);
		var _loc7_ = ASCompat.reinterpretAs(mView.node("NametagText"), StarlingText);
		_loc7_.text = "";
		_loc7_.mode = "baked";
		_loc7_.color = PlayerSpecialStatus.getSpecialTextColor(player.screenName, _loc7_.color);
		_loc7_.setFittedText(player.screenName, 1.82, 1.27);
		mName = _loc7_;
		mNameX = _loc7_.x;
		mAlert = ASCompat.reinterpretAs(mView.node("AlertText"), StarlingText);
		mAlert.text = "";
		mAlertX = mAlert.x;
		mEvents = new EventComponent(facade);
		mEvents.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE", player.id), hpChanged);
		mHpView = ArtView.build(HudArt.art("UI_nametag"), ticker);
		mHpRoot = mHpView.root;
		cast(mView.root, DisplayObjectContainer).addChild(mHpRoot);
		mHpRoot.y = 25;
		mHp = new StarlingBar(mHpRoot, null, ticker);
		mHp.value = player.maxHitPoints > 0 ? player.hitPoints / player.maxHitPoints : 0;
		var _loc9_ = ASCompat.reinterpretAs(player, HeroGameObject);
		if (_loc9_ != null) {
			_loc6_ = _loc9_.gmSkin.IconSwfFilepath;
			_loc8_ = _loc9_.gmSkin.IconName;
		} else {
			_loc6_ = player.actorData.gMActor.IconSwfFilepath;
			_loc8_ = player.actorData.gMActor.IconName;
		}
		var _loc10_ = ASCompat.reinterpretAs(mView.node("UI_avatar"), DisplayObjectContainer);
		mAvatar = new StarlingHudIcon(facade, ticker, _loc10_, avatarReady);
		mRedAvatar = new StarlingHudIcon(facade, ticker, _loc10_, avatarReady);
		mDeath = new StarlingHudIcon(facade, ticker, _loc10_, avatarReady);
		mAvatar.load(_loc6_, _loc8_, 1, 1, 0, false, true);
		mRedAvatar.load(_loc6_, _loc8_, 1, 1, 0, true, true);
		mDeath.load("Resources/Art2D/Icons/Avatars/db_icon_death.swf", "death_icon", 1, 1, 0, false, true);
		if (_loc9_ != null) {
			mTyping = ArtView.build(HudArt.art("UI_speechbubble_typing"), ticker);
			cast(mTyping.root, ArtDisplay).advanceHiddenTimelines(true);
			mTyping.root.y = -40;
			mTyping.root.visible = false;
			cast(mView.root, DisplayObjectContainer).addChild(mTyping.root);
			mEvents.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE", _loc9_.playerID), chatChanged);
			mEvents.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING", _loc9_.playerID), typingChanged);
			showSteamAvatar();
		}
		mBalloonRetry = bakeBalloon;
		if (_loc9_ != null && _loc9_.isInReviveState()) {
			handlePicChange("REVIVE");
		}
		changed();
	}

	public function beginUpdate():Bool {
		if (!mFresh) {
			return true;
		}
		mFresh = false;
		return false;
	}

	@:isVar public var root(get, never):DisplayObject;

	public function get_root():DisplayObject {
		return mView.root;
	}

	@:isVar public var player(get, never):ActorGameObject;

	public function get_player():ActorGameObject {
		return mPlayer;
	}

	@:isVar public var arrow(get, never):DisplayObject;

	public function get_arrow():DisplayObject {
		return mArrow;
	}

	function hpChanged(event:HpEvent) {
		try {
			if (mPlayer.isDestroyed) {
				return;
			}
			mHp.value = event.maxHp > 0 ? event.hp / event.maxHp : 0;
			mChanged();
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	function chatChanged(event:ChatEvent) {
		try {
			if (!mPlayer.isDestroyed) {
				setChat(event.message);
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	function typingChanged(event:PlayerIsTypingEvent) {
		try {
			if (mBalloon == null) {
				mTyping.root.visible = event.subtype == "CHAT_BOX_FOCUS_IN";
				mChanged();
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	public function showSteamAvatar() {
		var _loc1_ = ASCompat.reinterpretAs(mPlayer, HeroGameObject);
		if (_loc1_ == null || _loc1_.isDestroyed || mSteamCount >= 5) {
			return;
		}
		mSteamCount = mSteamCount + 1;
		_loc1_.heroView.nametag.showSteamAvatar(_loc1_.playerID);
	}

	function avatarReady() {
		var _loc2_:BakedImage = null;
		var _loc1_:BakedImage = null;
		var _loc3_:BakedImage = null;
		var _loc4_ = false;
		try {
			_loc2_ = mAvatar.image;
			_loc1_ = mRedAvatar.image;
			_loc3_ = mDeath.image;
			_loc4_ = mRescue && !mDeath.absent;
			if (_loc2_ != null) {
				_loc2_.visible = !_loc4_;
			}
			if (_loc1_ != null) {
				_loc1_.visible = _loc4_;
			}
			if (_loc3_ != null) {
				_loc3_.visible = mRescue;
				if (mRescue && _loc1_ != null && _loc3_.parent == _loc1_.parent) {
					_loc3_.parent.setChildIndex(mDeathOnTop ? _loc3_ : _loc1_, _loc3_.parent.numChildren - 1);
				}
			}
			mChanged();
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	public function handlePicChange(type:String) {
		mRescue = type == "REVIVE";
		mAlert.mode = "baked";
		if (mRescue) {
			mAlert.setFittedText(Locale.getString("NAMETAG_RESCUE"), 1.36, 1.27);
		} else {
			mAlert.text = "";
		}
		mDeathOnTop = true;
		mNextSwap = mTicker.gameTime + 250;
		avatarReady();
	}

	public function update() {
		var _loc1_:String = null;
		if (mChatUntil > 0 && mTicker.gameTime >= mChatUntil) {
			clearChat();
		}
		if (root.visible && mPendingMessage != null) {
			_loc1_ = mPendingMessage;
			mPendingMessage = null;
			buildChat(_loc1_);
		}
		while (mRescue && mTicker.gameTime >= mNextSwap) {
			mDeathOnTop = !mDeathOnTop;
			mNextSwap += 250;
			avatarReady();
		}
	}

	public function setChat(message:String) {
		clearChat();
		mChatUntil = mTicker.gameTime + 5000;
		if (!root.visible) {
			mPendingMessage = message;
			return;
		}
		buildChat(message);
	}

	function buildChat(message:String) {
		var _loc6_ = 0;
		var _loc2_:Dynamic = null;
		var _loc5_:MovieClip = null;
		var _loc4_:TextField = null;
		var _loc3_ = Vector.ofArray([
			"UI_speechbubble",
			"UI_speechbubble_02",
			"UI_speechbubble_03",
			"UI_speechbubble_04"
		]);
		var _loc7_ = Vector.ofArray([3, 4, 6]);
		_loc6_ = 0;
		while (_loc6_ < _loc3_.length) {
			_loc2_ = HudArt.swfClass(_loc3_[_loc6_]);
			_loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
			_loc4_ = ASCompat.coerce((_loc5_ : ASAny).chatMessage, flash.text.TextField);
			_loc4_.text = message;
			if (_loc6_ == 3 || _loc4_.numLines <= _loc7_[_loc6_]) {
				break;
			}
			_loc6_++;
		}
		HudArtConverter.stopTree(_loc5_);
		mBalloonScale = TextUtil.scaleToFloor(ASCompat.toNumber(_loc4_.defaultTextFormat.size), 1.82 * 1.05);
		mBalloonY = _loc5_.getBounds(_loc5_).bottom * (1 - mBalloonScale);
		mBalloonSource = _loc5_;
		mBalloonPixelScale = BakeScale.forDisplay(root) * mBalloonScale;
		mBalloonKey = "starlingOffScreenChat|" + _loc3_[_loc6_] + "|" + message + "|" + mBalloonPixelScale;
		if (!bakeBalloon()) {
			mTicker.deferBake(mBalloonRetry);
		}
	}

	function bakeBalloon():Bool {
		var _loc1_:ArtNode = null;
		if (mDisposed || mBalloonSource == null) {
			return true;
		}
		if (!root.visible) {
			return false;
		}
		mBalloonPages = HudArt.pages;
		mBalloonCell = HudArt.bakeContent(mBalloonKey, mBalloonSource, mBalloonPixelScale);
		if (mBalloonCell == null) {
			return false;
		}
		if (HudArt.content(mBalloonKey) == null) {
			_loc1_ = new ArtNode();
			_loc1_.cell = _loc1_.hold(mBalloonPages.acquire(mBalloonKey), mBalloonPages);
			HudArt.storeContent(mBalloonKey, _loc1_);
		}
		mBalloon = new BakedImage(mBalloonCell);
		mBalloon.scaleX = mBalloon.scaleY = mBalloonScale;
		mBalloon.y = -40 + mBalloonY;
		cast(root, DisplayObjectContainer).addChild(mBalloon);
		mBalloonSource = null;
		mPendingMessage = null;
		mChanged();
		return true;
	}

	function clearChat() {
		mPendingMessage = null;
		mTicker.cancelBake(mBalloonRetry);
		try {
			if (mBalloon != null) {
				mBalloon.removeFromParent(true);
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
		try {
			if (mBalloonCell != null) {
				mBalloonPages.release(mBalloonCell);
			}
		} catch (cellError:Dynamic) {
			StarlingHud.reportError(cellError);
		}
		mBalloonPages = null;
		mBalloonCell = null;
		mBalloon = null;
		mBalloonSource = null;
		mBalloonKey = null;
		mChatUntil = 0;
		mChanged();
	}

	public function keepChatOnScreen(width:Float, height:Float) {
		if (mBalloon == null) {
			return;
		}
		mBalloon.x = 0;
		mBalloon.y = -40 + mBalloonY;
		mBalloon.getBounds(root.parent, mBounds);
		var _loc3_ = mBounds.left < 0 ? -mBounds.left : (mBounds.right > width ? width - mBounds.right : 0);
		var _loc4_ = mBounds.top < 0 ? -mBounds.top : (mBounds.bottom > height ? height - mBounds.bottom : 0);
		mBalloon.x += _loc3_ / root.scaleX;
		mBalloon.y += _loc4_ / root.scaleY;
	}

	public function keepTextOnScreen(width:Float) {
		var _loc2_ = keepOnScreen(mName, mNameX, width);
		if (keepOnScreen(mAlert, mAlertX, width)) {
			_loc2_ = true;
		}
		if (_loc2_) {
			mChanged();
		}
	}

	function keepOnScreen(text:StarlingText, authoredX:Float, width:Float):Bool {
		var _loc4_ = text.x;
		text.x = authoredX;
		text.getBounds(root.parent, mBounds);
		if (mBounds.width > 0) {
			text.x += (mBounds.left < 0 ? -mBounds.left : (mBounds.right > width ? width - mBounds.right : 0)) / root.scaleX;
		}
		return text.x != _loc4_;
	}

	public function dispose() {
		if (mDisposed) {
			return;
		}
		mDisposed = true;
		try {
			clearChat();
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
		StarlingHud.disposeResource(mEvents, "destroy");
		StarlingHud.disposeResource(mAvatar);
		StarlingHud.disposeResource(mRedAvatar);
		StarlingHud.disposeResource(mDeath);
		StarlingHud.disposeResource(mHp);
		StarlingHud.disposeResource(mHpView);
		StarlingHud.disposeResource(mTyping);
		StarlingHud.disposeResource(mView);
		mChanged();
	}
}
