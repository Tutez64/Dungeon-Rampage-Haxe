package uI;

import account.PlayerSpecialStatus;
import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.render.tweens.TweenHandle;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.uI.UIInputText;
import brain.uI.UISlider;
import brain.utils.TextUtil;
import distributedObjects.HeroGameObjectOwner;
import events.ChatEvent;
import events.ChatLogEvent;
import facade.DBFacade;
import facade.Locale;
import com.amanitadesign.steam.SteamEvent;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class UIChatLog {
	static var JOINED_DUNGEON_COLOR:UInt = (16063002 : UInt);

	static var LEFT_DUNGEON_COLOR:UInt = (16063002 : UInt);

	static var FRIEND_STATUS_ONLINE_COLOR:UInt = (16764232 : UInt);

	static var FRIEND_STATUS_OFFLINE_COLOR:UInt = (16764232 : UInt);

	static var NAME_CHAT_COLOR:UInt = (16764232 : UInt);

	public static var JOINED_DUNGEON_TYPE:String = "JOINED_DUNGEON";

	public static var LEFT_DUNGEON_TYPE:String = "LEFT_DUNGEON";

	public static var FRIEND_STATUS_ONLINE_TYPE:String = "FRIEND_STATUS_ONLINE";

	public static var FRIEND_STATUS_OFFLINE_TYPE:String = "FRIEND_STATUS_OFFLINE";

	public static var CHAT_TYPE:String = "CHAT";

	static var MAX_CHATS:UInt = (50 : UInt);

	static inline final CHAT_FADE_DURATION:Float = 0.3;

	static inline final MAX_CHAT_CHARS = (169 : UInt);

	static var mChatLogXOffset:UInt = (0 : UInt);

	static var mChatLogYOffset:UInt = (0 : UInt);

	static var mChats:Vector<ChatTextFieldHelper>;

	static var sChatsVersion:Int = 0;

	var mDBFacade:DBFacade;

	var mChatLog:TextField;

	var mSlider:UISlider;

	var mEventComponent:EventComponent;

	var mChatLogContainer:MovieClip;

	var mFadeTween:TweenHandle;

	var mSceneGraphComponent:SceneGraphComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mAutoShowChatLog:Bool = false;

	var mUserToggled:Bool = false;

	var mToggledOpen:Bool = false;

	var mPlayerSetSlider:Bool = false;

	var mChatLogButton:UIButton;

	var mChatInputText:UIInputText;

	var mChatSendButton:UIButton;

	var mChatLogShowing:Bool = false;

	var mChatPromptVisible:Bool = true;

	var mStarlingPrompt:ASFunction;

	var mHeroOwner:HeroGameObjectOwner;

	var mEnabledChatEnterEvent:Bool = true;

	var mRenderedVersion:Int = -1;

	var mRenderedLength:Int = -1;

	var mDefaultFormat:TextFormat;

	var mPreviousHeight:Float = 1;

	public function new(dbFacade:DBFacade, chatLogContainer:MovieClip, chatTextField:MovieClip, chatLogButton:MovieClip, sendChatButton:MovieClip) {
		mDBFacade = dbFacade;
		if (mChats == null) {
			mChats = new Vector<ChatTextFieldHelper>();
		}
		mPlayerSetSlider = false;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIChatLog");
		mEventComponent = new EventComponent(mDBFacade);
		setupButtons(chatTextField, chatLogButton, sendChatButton);
		setupLog(chatLogContainer);
		mAutoShowChatLog = mDBFacade.dbConfigManager.getConfigBoolean("AUTO_SHOW_CHAT_LOG", true);
		constructAndRenderNewChat();
		enable();
	}

	static function growToFloor(field:TextField, sizeModifier:Float) {
		var _loc3_ = field.defaultTextFormat;
		var _loc5_ = ASCompat.toNumber(_loc3_.size);
		_loc3_.size = ASCompat.toInt(Math.fround(_loc5_ * TextUtil.scaleToFloor(_loc5_, sizeModifier)));
		field.defaultTextFormat = _loc3_;
		if (field.multiline) {
			return;
		}
		var _loc4_ = field.height * ASCompat.toNumber(_loc3_.size) / _loc5_;
		field.y -= (_loc4_ - field.height) / 2;
		field.height = _loc4_;
	}

	public static function growLogUp(chatLogContainer:MovieClip, scale:Float) {
		var _loc7_ = 0;
		var _loc4_:DisplayObject = null;
		var _loc5_ = ASCompat.coerce((chatLogContainer : ASAny).chatLog, flash.text.TextField);
		var _loc3_ = ASCompat.coerce((chatLogContainer : ASAny).slider, flash.display.MovieClip);
		var _loc6_:Float = 0;
		_loc7_ = 0;
		while (_loc7_ < chatLogContainer.numChildren) {
			_loc4_ = chatLogContainer.getChildAt(_loc7_);
			if (!(_loc4_ == _loc5_ || _loc4_ == _loc3_)) {
				if (!ASCompat.floatAsBool(_loc6_)) {
					_loc6_ = _loc4_.height * (scale - 1);
				}
				stretchUp(_loc4_, _loc6_);
			}
			_loc7_++;
		}
		stretchUp(_loc5_, _loc6_);
		_loc3_.y -= _loc6_;
		var __tmpAssignObj26:ASAny = (_loc3_ : ASAny).back;
		ASCompat.setProperty(__tmpAssignObj26, "height", __tmpAssignObj26.height + _loc6_ / _loc3_.scaleY);
	}

	static function stretchUp(object:DisplayObject, extra:Float) {
		var _loc3_ = object.getBounds(object.parent).bottom;
		object.height += extra;
		object.y += _loc3_ - object.getBounds(object.parent).bottom;
	}

	@:isVar public var heroOwner(never, set):HeroGameObjectOwner;

	public function set_heroOwner(hero:HeroGameObjectOwner):HeroGameObjectOwner {
		return mHeroOwner = hero;
	}

	public function enable() {
		this.disable();
		mEventComponent.addListener("CHAT_LOG_EVENT", chatEventHandler);
		EventListeners.add(mChatInputText.root, "focusIn", onChatTextFieldFocus);
		EventListeners.add(mChatInputText.root, "focusOut", onChatTextFieldLoseFocus);
		EventListeners.add(mDBFacade.stageRef, "keyDown", checkKeyEvent);
		EventListeners.add(mDBFacade.mSteamworks, SteamEvent.STEAM_RESPONSE, onSteamResponse);
	}

	public function disable() {
		mEventComponent.removeListener("CHAT_LOG_EVENT");
		EventListeners.remove(mChatInputText.root, "focusIn", onChatTextFieldFocus);
		EventListeners.remove(mChatInputText.root, "focusOut", onChatTextFieldLoseFocus);
		EventListeners.remove(mDBFacade.stageRef, "keyDown", checkKeyEvent);
		EventListeners.remove(mDBFacade.mSteamworks, SteamEvent.STEAM_RESPONSE, onSteamResponse);
	}

	function onSteamResponse(event:SteamEvent) {
		if (event.req_type != 35 && event.req_type != 34) {
			return;
		}
		if (mChatInputText == null || mDBFacade == null) {
			return;
		}
		if (mDBFacade.stageRef.focus != mChatInputText.textField) {
			return;
		}
		mToggledOpen = false;
		mChatInputText.releaseKeyboardFocus();
		hideChatLog();
		mDBFacade.inputManager.clear();
	}

	function onChatTextFieldFocus(event:FocusEvent) {
		if (mHeroOwner != null) {
			mHeroOwner.showPlayerIsTyping(true);
		}
		chatTextFieldFocus();
	}

	function onChatTextFieldLoseFocus(event:FocusEvent) {
		if (mHeroOwner != null) {
			mHeroOwner.showPlayerIsTyping(false);
		}
		chatTextFieldLostFocus();
	}

	function setupButtons(chatTextField:MovieClip, chatLogButton:MovieClip, sendChatButton:MovieClip) {
		mChatInputText = new UIInputText(mDBFacade, chatTextField);
		mChatInputText.defaultText = Locale.getString("DEFAULT_CHAT_PROMPT");
		mChatInputText.enterCallback = sendChat;
		mChatInputText.focusOutCallback = function() {
			if (mChatInputText.text == "") {
				resetChatPrompt();
			}
		};
		mChatInputText.textField.maxChars = 169;
		mChatLogButton = new UIButton(mDBFacade, chatLogButton);
		mChatLogButton.releaseCallback = toggleChatLog;
		mChatSendButton = new UIButton(mDBFacade, sendChatButton);
		mChatSendButton.releaseCallback = function() {
			if (mChatInputText.text == "") {
				focusChatInput();
				return;
			}
			sendChat(mChatInputText.text);
		};
	}

	function sendChat(value:String) {
		mChatInputText.clear();
		mDBFacade.regainFocus();
		mDBFacade.inputManager.clear();
		if (ASCompat.stringAsBool(value)) {
			mEventComponent.dispatchEvent(new ChatEvent("ChatEvent_OUTGOING_CHAT_UPDATE", (0 : UInt), value));
		} else {
			resetChatPrompt();
		}
	}

	function resetChatPrompt() {
		if (mStarlingPrompt != null) {
			mChatInputText.defaultText = "";
			updateStarlingPrompt();
			return;
		}
		mChatInputText.defaultText = mChatPromptVisible ? Locale.getString("DEFAULT_CHAT_PROMPT") : "";
	}

	@:isVar public var starlingPrompt(never, set):ASFunction;

	public function set_starlingPrompt(value:ASFunction):ASFunction {
		mStarlingPrompt = value;
		mChatInputText.focusInCallback = ASCompat.coerceFunction(value != null ? updateStarlingPrompt : null);
		if (mChatInputText.showingDefaultText) {
			resetChatPrompt();
		}
		return value;
	}

	@:isVar public var promptColor(get, never):UInt;

	public function get_promptColor():UInt {
		return mChatInputText.defaultTextColor;
	}

	function updateStarlingPrompt() {
		if (mStarlingPrompt != null) {
			mStarlingPrompt(mChatPromptVisible
				&& mChatInputText.showingDefaultText
				&& mDBFacade.stageRef.focus != mChatInputText.textField);
		}
	}

	public function setChatPromptVisible(inVisible:Bool) {
		mChatPromptVisible = inVisible;
		if (mChatInputText.text == "") {
			resetChatPrompt();
		}
	}

	@:isVar public var textSizeModifier(never, set):Float;

	public function set_textSizeModifier(value:Float):Float {
		growToFloor(mChatLog, value);
		growToFloor(mChatInputText.textField, value);
		mDefaultFormat = null;
		constructAndRenderNewChat();
		if (mChatInputText.showingDefaultText) {
			resetChatPrompt();
		}
		return value;
	}

	public function toggleChatLog() {
		if (mChatLogShowing) {
			mToggledOpen = false;
			hideChatLog();
		} else {
			mToggledOpen = true;
			showChatLog();
		}
	}

	function chatTextFieldFocus() {
		if (mAutoShowChatLog) {
			showChatLog();
		}
		if (mDBFacade.steamInputManager.usesSteamOnScreenKeyboard) {
			mDBFacade.steamInputManager.showFloatingGamepadTextInputForField(mChatInputText.textField);
		}
	}

	function chatTextFieldLostFocus() {
		if (mAutoShowChatLog && !mToggledOpen) {
			hideChatLog();
		}
	}

	function checkKeyEvent(event:KeyboardEvent) {
		if (!Logger.isConsoleVisible()) {
			if (event.keyCode == 13 && mEnabledChatEnterEvent) {
				focusChatInput();
			}
		}
	}

	public function focusChatInput() {
		mDBFacade.stageRef.focus = mChatInputText.textField;
	}

	public function tryToggleChatLog() {
		if (mDBFacade.mainStateMachine.currentStateName == "RunState") {
			toggleChatLog();
		}
	}

	function setupLog(chatLogContainer:MovieClip) {
		mChatLogContainer = chatLogContainer;
		mChatLog = ASCompat.coerce((mChatLogContainer : ASAny).chatLog, flash.text.TextField);
		mSlider = new UISlider(mDBFacade, ASCompat.coerce((mChatLogContainer : ASAny).slider, flash.display.MovieClip), (1 : UInt));
		mSlider.minimum = 100;
		mSlider.maximum = 0;
		mSlider.tick = 2;
		mSlider.value = 0;
		mSlider.updateCallback = sliderCallback;
		init();
	}

	function sliderCallback(pos:Float) {
		mPlayerSetSlider = true;
		setChatLogPosition(pos);
	}

	function init() {
		mChatLogContainer.y += mChatLogYOffset;
		mChatLogContainer.x += mChatLogXOffset;
		mChatLog.text = "";
		mChatLogContainer.visible = false;
		mSlider.visible = false;
	}

	function chatEventHandler(event:ChatLogEvent) {
		var _loc2_ = (0 : UInt);
		switch (event.chatLogType) {
			case(_ == JOINED_DUNGEON_TYPE => true):
				_loc2_ = JOINED_DUNGEON_COLOR;

			case(_ == LEFT_DUNGEON_TYPE => true):
				_loc2_ = LEFT_DUNGEON_COLOR;

			case(_ == FRIEND_STATUS_ONLINE_TYPE => true):
				_loc2_ = FRIEND_STATUS_ONLINE_COLOR;

			case(_ == FRIEND_STATUS_OFFLINE_TYPE => true):
				_loc2_ = FRIEND_STATUS_OFFLINE_COLOR;

			default:
		}
		addChatLog(event.chat, _loc2_, event.playerName);
	}

	function addChatLog(chat:String, color:UInt, playerName:String = "") {
		var _loc4_:ChatTextFieldHelper;
		var __ax4_iter_134:Vector<ChatTextFieldHelper>;
		var _loc10_:ChatTextFieldHelper = null;
		if (mChatLog == null) {
			return;
		}
		var _loc9_ = new ChatTextFieldHelper();
		if (chat.indexOf("\r\n") >= 0) {
			chat = chat.split("\r\n").join("\n");
		}
		chat += "\n";
		var _loc5_ = (mChatLog.length : UInt);
		var _loc7_ = sChatsVersion++;
		_loc9_.chatText = chat;
		_loc9_.color = color;
		_loc9_.playerName = playerName;
		_loc9_.colorStartIndex = _loc5_;
		_loc9_.colorEndIndex = _loc5_ + chat.length;
		mChats.push(_loc9_);
		var _loc6_ = (0 : UInt);
		if ((mChats.length : UInt) > MAX_CHATS) {
			_loc10_ = mChats.shift();
			_loc6_ = _loc10_.colorEndIndex - _loc10_.colorStartIndex;
			__ax4_iter_134 = mChats;
			if (checkNullIteratee(__ax4_iter_134))
				for (_tmp_ in __ax4_iter_134) {
					_loc4_ = _tmp_;
					_loc4_.colorEndIndex -= _loc6_;
					_loc4_.colorStartIndex -= _loc6_;
				}
		}
		if (mRenderedVersion != _loc7_ || mChatLog.length != mRenderedLength) {
			constructAndRenderNewChat();
			return;
		}
		if (_loc6_ > 0) {
			mChatLog.replaceText(0, (_loc6_ : Int), "");
		}
		var _loc8_ = mChatLog.length;
		mChatLog.appendText(chat);
		if (mDefaultFormat == null) {
			mDefaultFormat = mChatLog.defaultTextFormat;
		}
		mChatLog.setTextFormat(mDefaultFormat, _loc8_, mChatLog.length);
		formatChat(_loc9_);
		mRenderedVersion = sChatsVersion;
		mRenderedLength = mChatLog.length;
		checkToShowSlider();
		adjustSlider();
	}

	function constructAndRenderNewChat() {
		mChatLog.text = "";
		var _loc1_ = (0 : UInt);
		var _loc2_:ChatTextFieldHelper;
		final __ax4_iter_135 = mChats;
		if (checkNullIteratee(__ax4_iter_135))
			for (_tmp_ in __ax4_iter_135) {
				_loc2_ = _tmp_;
				mChatLog.text = mChatLog.text + _loc2_.chatText;
				_loc2_.colorStartIndex = _loc1_;
				_loc1_ += (_loc2_.chatText.length : UInt);
				_loc2_.colorEndIndex = _loc1_;
			}
		final __ax4_iter_136 = mChats;
		if (checkNullIteratee(__ax4_iter_136))
			for (_tmp_ in __ax4_iter_136) {
				_loc2_ = _tmp_;
				formatChat(_loc2_);
			}
		mRenderedVersion = sChatsVersion;
		mRenderedLength = mChatLog.length;
		checkToShowSlider();
		adjustSlider();
	}

	function formatChat(chat:ChatTextFieldHelper) {
		var _loc2_:TextFormat = null;
		var _loc3_ = chat.colorStartIndex;
		if (chat.playerName != "") {
			_loc2_ = new TextFormat();
			_loc2_.color = PlayerSpecialStatus.getSpecialTextColor(chat.playerName, NAME_CHAT_COLOR);
			mChatLog.setTextFormat(_loc2_, (_loc3_ : Int), (_loc3_ + chat.playerName.length + 1 : Int));
			_loc3_ += (chat.playerName.length + 1:UInt);
		}
		if (chat.color == 0) {
			return;
		}
		_loc2_ = new TextFormat();
		_loc2_.color = chat.color;
		mChatLog.setTextFormat(_loc2_, (_loc3_ : Int), (chat.colorEndIndex : Int));
	}

	function adjustSlider() {
		var _loc1_ = false;
		if (mSlider.value == mSlider.minimum) {
			_loc1_ = true;
		}
		if (_loc1_ || !mPlayerSetSlider) {
			mSlider.value = mSlider.minimum;
		} else {
			mSlider.value = mPreviousHeight / mChatLog.textHeight * mSlider.value;
		}
		mPreviousHeight = mChatLog.textHeight;
		setChatLogPosition(mSlider.value);
	}

	function setChatLogPosition(pos:Float) {
		var _loc2_ = Math.fround((mChatLog.maxScrollV + 1) * pos / 100);
		mChatLog.scrollV = ASCompat.floatToInt(_loc2_);
	}

	public function isShowing():Bool {
		return mChatLogContainer.visible;
	}

	public function hideChatLog() {
		if (!mChatLogShowing) {
			return;
		}
		mChatLogShowing = false;
		if (mFadeTween != null && mDBFacade.mTween.getCurrentProgress(mFadeTween) != 1) {
			mDBFacade.mTween.completeTween(mFadeTween);
		}
		mChatLogContainer.alpha = 1;
		mFadeTween = mDBFacade.mTween.tweenMaxTo(mChatLogContainer, 0.3, {
			"alpha": 0,
			"onComplete": function() {
				mChatLogContainer.visible = false;
			}
		});
		mSlider.visible = false;
	}

	public function showChatLog() {
		if (mChatLogShowing) {
			return;
		}
		mChatLogShowing = true;
		if (mFadeTween != null && mDBFacade.mTween.getCurrentProgress(mFadeTween) != 1) {
			mDBFacade.mTween.completeTween(mFadeTween);
		}
		mChatLogContainer.visible = true;
		mChatLogContainer.alpha = 0;
		mFadeTween = mDBFacade.mTween.tweenMaxTo(mChatLogContainer, 0.3, {"alpha": 1});
		constructAndRenderNewChat();
		checkToShowSlider();
	}

	function checkToShowSlider() {
		if (mChatLog.maxScrollV > 1) {
			mSlider.visible = true;
		}
	}

	public function destroy() {
		if (mFadeTween != null && mDBFacade.mTween.getCurrentProgress(mFadeTween) != 1) {
			mDBFacade.mTween.completeTween(mFadeTween);
		}
		disable();
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
			mSceneGraphComponent = null;
		}
		if (mEventComponent != null) {
			mEventComponent.removeAllListeners();
			mEventComponent.destroy();
		}
		if (mSlider != null) {
			mSlider.destroy();
		}
		mSlider = null;
		if (mChatInputText != null) {
			mChatInputText.destroy();
		}
		mChatInputText = null;
		if (mChatSendButton != null) {
			mChatSendButton.destroy();
		}
		mChatSendButton = null;
		if (mChatLogButton != null) {
			mChatLogButton.destroy();
		}
		mChatLogButton = null;
		if (mChatSendButton != null) {
			mChatSendButton.destroy();
		}
		mChatSendButton = null;
		mStarlingPrompt = null;
		if (mChatInputText != null) {
			mChatInputText.destroy();
		}
		mChatInputText = null;
		mHeroOwner = null;
		mFadeTween = null;
		mEventComponent = null;
		mDBFacade = null;
		mChatLog = null;
		mChatLogContainer = null;
	}

	@:isVar public var enabledChatEnterEvent(get, set):Bool;

	public function set_enabledChatEnterEvent(inBoolean:Bool):Bool {
		return mEnabledChatEnterEvent = inBoolean;
	}

	function get_enabledChatEnterEvent():Bool {
		return mEnabledChatEnterEvent;
	}

	@:isVar public var chatLogButton(get, never):UIButton;

	public function get_chatLogButton():UIButton {
		return mChatLogButton;
	}

	@:isVar public var chatSendButton(get, never):UIButton;

	public function get_chatSendButton():UIButton {
		return mChatSendButton;
	}
}

private class ChatTextFieldHelper {
	public var chatText:String;

	public var color:UInt = 0;

	public var colorStartIndex:UInt = 0;

	public var colorEndIndex:UInt = 0;

	public var playerName:String;

	public function new() {}
}
