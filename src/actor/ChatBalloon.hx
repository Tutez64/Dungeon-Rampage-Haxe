package actor;

import brain.assetRepository.SwfAsset;
import brain.utils.TextUtil;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;

class ChatBalloon extends Sprite {
	static inline final TEXT_SIZE_MODIFIER:Float = 1.05;

	@:allow(Actor) final renderContent:Sprite = new Sprite();

	@:allow(Actor) var cutOverlay:ChatBalloonOverlay;

	@:allow(Actor) var cutRegistered:Bool = false;

	var mText:TextField;

	var mTypingClip:MovieClip;

	var mBubbleSmall:MovieClip;

	var mBubbleMedium:MovieClip;

	var mBubbleMediumScaledDown:MovieClip;

	var mBubbleLargeScaledDown:MovieClip;

	var mAuthoredSizes:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mSizeModifier:Float = 1;

	var mGrowsDown:Bool = false;

	var mIsInitialized:Bool = false;

	public function new() {
		super();
		addChild(renderContent);
	}

	override public function set_visible(value:Bool) {
		super.visible = value;
		if (cutRegistered) {
			ChatBalloonOverlay.visibilityChanged(this);
		}
		return value;
	}

	override public function get_visible():Bool {
		return super.visible;
	}

	public function initializeChatBalloon(swfAsset:SwfAsset, typingClip:MovieClip = null, sizeModifier:Float = 1) {
		mTypingClip = typingClip;
		mSizeModifier = sizeModifier;
		var _loc4_ = swfAsset.getClass("UI_speechbubble");
		mBubbleSmall = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
		_loc4_ = swfAsset.getClass("UI_speechbubble_02");
		mBubbleMedium = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
		_loc4_ = swfAsset.getClass("UI_speechbubble_03");
		mBubbleMediumScaledDown = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
		_loc4_ = swfAsset.getClass("UI_speechbubble_04");
		mBubbleLargeScaledDown = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
		var _loc5_:MovieClip;
		final __ax4_iter_16:Array<ASAny> = [mBubbleSmall, mBubbleMedium, mBubbleMediumScaledDown, mBubbleLargeScaledDown];
		if (checkNullIteratee(__ax4_iter_16))
			for (_tmp_ in __ax4_iter_16) {
				_loc5_ = ASCompat.coerce(_tmp_, flash.display.MovieClip);
				mAuthoredSizes[_loc5_] = ASCompat.toNumber(cast((_loc5_ : ASAny).chatMessage, TextField).defaultTextFormat.size);
			}
		if (mTypingClip != null) {
			renderContent.addChild(mTypingClip);
			hidePlayerTyping();
		}
		mIsInitialized = true;
	}

	@:isVar public var sizeModifier(never, set):Float;

	public function set_sizeModifier(value:Float):Float {
		return mSizeModifier = value;
	}

	@:isVar public var growsDown(never, set):Bool;

	public function set_growsDown(value:Bool):Bool {
		return mGrowsDown = value;
	}

	public function showPlayerTyping() {
		mTypingClip.visible = true;
	}

	public function hidePlayerTyping() {
		mTypingClip.visible = false;
	}

	public function showBalloon() {
		this.visible = true;
	}

	public function hideBalloon() {
		this.visible = false;
	}

	@:isVar public var text(get, set):String;

	public function set_text(value:String):String {
		var _loc2_:MovieClip = null;
		if (mIsInitialized) {
			if (mText != null) {
				mText.parent.parent.removeChild(mText.parent);
			}
			_loc2_ = mBubbleSmall;
			mText = ASCompat.coerce((_loc2_ : ASAny).chatMessage, flash.text.TextField);
			mText.text = value;
			if (mText.numLines > 3) {
				_loc2_ = mBubbleMedium;
			}
			mText = ASCompat.coerce((_loc2_ : ASAny).chatMessage, flash.text.TextField);
			mText.text = value;
			if (mText.numLines > 4) {
				_loc2_ = mBubbleMediumScaledDown;
			}
			mText = ASCompat.coerce((_loc2_ : ASAny).chatMessage, flash.text.TextField);
			mText.text = value;
			if (mText.numLines > 6) {
				_loc2_ = mBubbleLargeScaledDown;
			}
			mText = ASCompat.coerce((_loc2_ : ASAny).chatMessage, flash.text.TextField);
			mText.text = value;
			scaleBubbleToFloor(_loc2_);
			renderContent.addChild(_loc2_);
			_loc2_.addChild(mText);
		}
		return value;
	}

	function scaleBubbleToFloor(bubble:MovieClip) {
		var _loc4_ = TextUtil.scaleToFloor(ASCompat.toNumber(mAuthoredSizes[bubble]), mSizeModifier * 1.05);
		var _loc3_ = bubble.getBounds(bubble);
		var _loc2_ = mGrowsDown ? _loc3_.top : _loc3_.bottom;
		bubble.scaleX = bubble.scaleY = _loc4_;
		bubble.y = _loc2_ * (1 - _loc4_);
	}

	function get_text():String {
		if (mText != null) {
			return mText.text;
		}
		return "";
	}
}
