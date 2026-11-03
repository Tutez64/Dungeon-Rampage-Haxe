package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import brain.utils.TextUtil;
import facade.DBFacade;
import uI.UIChatLog;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.TextField;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;

/*internal*/
class StarlingChatPrompt {
	static inline final GUTTER:Float = 2;

	@:allow(UI.Hud.StarlingConverted) static inline final PATH = "chatBar";

	var mFacade:DBFacade;

	var mTicker:HudTicker;

	var mInput:StarlingInput;

	var mChat:UIChatLog;

	var mBar:Sprite = new Sprite();

	var mLabel:Sprite = new Sprite();

	var mView:ArtView;

	var mButtons:Vector<StarlingButton> = new Vector((0 : UInt));

	var mSend:StarlingButton;

	var mLog:StarlingButton;

	var mFlashParts:Vector<flash.display.DisplayObject> = new Vector((0 : UInt));

	var mFlashShown:Vector<Bool> = new Vector((0 : UInt));

	var mClip:MovieClip;

	var mModel:Dynamic;

	var mLabelSource:TextField;

	var mBarKey:String;

	var mLabelKey:String;

	var mLabelArt:ArtNode;

	var mRetry:ASFunction;

	var mChanged:ASFunction;

	var mReady:ASFunction;

	var mDisposed:Bool = false;

	var mBakeFailed:Bool = false;

	public function new(facade:DBFacade, ticker:HudTicker, parent:DisplayObjectContainer, input:StarlingInput, holder:flash.display.DisplayObjectContainer,
			clip:MovieClip, model:Dynamic, chat:UIChatLog, prompt:String, color:UInt, layout:UInt, changed:ASFunction, ready:ASFunction = null) {
		var _loc16_:String = null;
		var _loc14_:flash.display.DisplayObject = null;

		var _loc15_ = ASCompat.reinterpretAs(clip.getChildByName("textField"), TextField);
		final __ax4_iter_262 = Vector.ofArray(["textField", "chat_bar", "chat_btn", "log_btn"]);
		if (checkNullIteratee(__ax4_iter_262))
			for (_tmp_ in __ax4_iter_262) {
				_loc16_ = _tmp_;
				if (clip.getChildByName(_loc16_) == null) {
					HudArt.fatal("Missing Starling chat bar art: " + _loc16_);
				}
			}
		mFacade = facade;
		mTicker = ticker;
		mInput = input;
		mChat = chat;
		mChanged = changed;
		mClip = clip;
		mModel = model;
		mLabelSource = copyField(_loc15_, prompt, color);
		mBarKey = "starlingChatBar|" + layout;
		mLabelKey = "starlingChatPrompt|" + layout + "|label|" + prompt + "|" + color + "|" + Std.string(_loc15_.defaultTextFormat.size);
		mBar.touchable = mLabel.touchable = false;
		mBar.transformationMatrix = designMatrix(clip, holder);
		mLabel.transformationMatrix = designMatrix(_loc15_, holder);
		mLabel.visible = false;
		parent.addChild(mBar);
		parent.addChild(mLabel);
		final __ax4_iter_263 = Vector.ofArray(["chat_bar", "chat_btn", "log_btn"]);
		if (checkNullIteratee(__ax4_iter_263))
			for (_tmp_ in __ax4_iter_263) {
				_loc16_ = _tmp_;
				_loc14_ = clip.getChildByName(_loc16_);
				mFlashParts.push(_loc14_);
				mFlashShown.push(_loc14_.visible);
				_loc14_.visible = false;
			}
		mRetry = bake;
		if (!bake()) {
			mTicker.deferBake(mRetry);
		}
		mReady = ready;
	}

	static function bakePart(parent:MovieClip, name:String, key:String, scale:Float):ArtNode {
		var _loc7_ = parent.getChildByName(name);
		if (_loc7_ == null) {
			HudArt.fatal("Missing Starling chat bar art: " + name);
		}
		var _loc6_ = new flash.display.Sprite();
		_loc7_.visible = true;
		_loc6_.addChild(_loc7_);
		var _loc5_ = new ArtNode();
		_loc5_.name = name;
		_loc5_.kind = "static";
		_loc5_.cell = _loc5_.hold(HudArt.bakeContent(key + "|" + name, _loc6_, scale), HudArt.pages);
		return _loc5_;
	}

	static function snap(container:Sprite, art:DisplayObject) {
		var _loc3_ = Starling.current;
		var _loc6_ = _loc3_.viewPort.width / _loc3_.stage.stageWidth;
		var _loc5_ = art.getBounds(_loc3_.stage);
		var _loc4_ = container.parent.getTransformationMatrix(_loc3_.stage).a;
		if (_loc6_ <= 0 || _loc4_ <= 0 || _loc5_.isEmpty()) {
			return;
		}
		container.x += (Math.fround(_loc5_.x * _loc6_) / _loc6_ - _loc5_.x) / _loc4_;
		container.y += (Math.fround(_loc5_.y * _loc6_) / _loc6_ - _loc5_.y) / _loc4_;
	}

	static function designMatrix(node:flash.display.DisplayObject, holder:flash.display.DisplayObjectContainer):Matrix {
		var _loc4_ = node.transform.matrix;
		if (Std.isOfType(node, TextField) && deviceText(ASCompat.reinterpretAs(node, TextField))) {
			_loc4_.setTo(node.scaleY, 0, 0, node.scaleY, node.x + 2 * (node.scaleX - node.scaleY), node.y);
		} else if (Std.isOfType(node, TextField)) {
			_loc4_.tx = node.x;
			_loc4_.ty = node.y;
		}
		if (node == holder) {
			return _loc4_;
		}
		var _loc3_ = node.parent;
		while (_loc3_ != null) {
			_loc4_.concat(_loc3_.transform.matrix);
			if (_loc3_ == holder) {
				return _loc4_;
			}
			_loc3_ = _loc3_.parent;
		}
		throw new Error("Chat prompt art is not under the chat holder");
		return null;
	}

	static function deviceText(field:TextField):Bool {
		return !field.embedFonts && field.rotation == 0 && field.scaleY > 0;
	}

	static function copyField(field:TextField, text:String, color:UInt):TextField {
		var _loc5_ = new TextField();
		var _loc4_ = field.getBounds(field);
		_loc5_.width = deviceText(field) ? _loc4_.width * field.scaleX / field.scaleY : _loc4_.width;
		_loc5_.height = _loc4_.height;
		_loc5_.defaultTextFormat = field.defaultTextFormat;
		_loc5_.embedFonts = field.embedFonts;
		_loc5_.antiAliasType = field.antiAliasType;
		_loc5_.gridFitType = field.gridFitType;
		_loc5_.sharpness = field.sharpness;
		_loc5_.thickness = field.thickness;
		_loc5_.multiline = field.multiline;
		_loc5_.wordWrap = field.wordWrap;
		_loc5_.background = field.background;
		_loc5_.backgroundColor = field.backgroundColor;
		_loc5_.border = field.border;
		_loc5_.borderColor = field.borderColor;
		_loc5_.filters = cast(field.filters);
		_loc5_.selectable = false;
		_loc5_.text = text;
		TextUtil.addOverhangSlack(_loc5_);
		_loc5_.textColor = color;
		return _loc5_;
	}

	public function show(value:Bool) {
		if (mDisposed || mLabel.visible == value) {
			return;
		}
		mLabel.visible = value;
		if (mChanged != null) {
			mChanged();
		}
	}

	@:allow(UI.Hud.StarlingConverted) @:isVar var labelShown(get, never):Bool;

	function get_labelShown():Bool {
		return !mDisposed && mLabel.visible;
	}

	@:allow(UI.Hud.StarlingConverted) @:isVar var sendButton(get, never):StarlingButton;

	function get_sendButton():StarlingButton {
		return mSend;
	}

	@:allow(UI.Hud.StarlingConverted) @:isVar var logButton(get, never):StarlingButton;

	function get_logButton():StarlingButton {
		return mLog;
	}

	@:allow(UI.Hud.StarlingConverted) function node(path:String):DisplayObject {
		return ASCompat.coerce(path.length == 0 ? mBar : ASCompat.coerce(mView != null ? mView.node(path) : null, starling.display.DisplayObject),
			starling.display.DisplayObject);
	}

	function bake():Bool {
		var _loc5_:Bool;
		try {
			if (mDisposed) {
				return true;
			}
			if (Starling.current == null || !Starling.current.contextValid || mBar.stage == null) {
				return false;
			}
			if (mView == null) {
				buildBar();
			}
			if (mLabelArt == null) {
				placeLabel();
			}
			mRetry = null;
			mLabelSource = null;
			if (mChanged != null) {
				mChanged();
			}
			return true;
		} catch (error:Dynamic) {
			if (Std.isOfType(error, HudFatalError) || !mBakeFailed) {
				StarlingHud.reportError(error);
			}
			mBakeFailed = true;
			if (!Std.isOfType(error, HudFatalError)) {
				return false;
			}
			_loc5_ = true;
		}
		return _loc5_;
	}

	function buildBar() {
		var __ax4_iter_264:Vector<String>;
		var _loc12_:MovieClip = null;
		var _loc6_:MovieClip = null;
		var _loc10_:String = null;
		var _loc3_:String = null;
		var _loc5_ = 0;
		var _loc13_:MovieClip = null;
		var _loc7_:ArtNode = null;
		var _loc11_:Vector<String> = /*undefined*/ null;
		var _loc4_ = BakeScale.forDisplay(mBar);
		var _loc14_ = mBarKey + "|" + BakedPages.scaleKey(_loc4_);
		var _loc2_ = HudArt.content(_loc14_);
		if (_loc2_ == null) {
			_loc12_ = ASCompat.dynamicAs(ASCompat.createInstance(mModel, []), MovieClip);
			_loc6_ = ASCompat.coerce(_loc12_ != null ? ASCompat.reinterpretAs(_loc12_.getChildByName("UI_chat"), MovieClip) : null, flash.display.MovieClip);
			if (_loc6_ == null || _loc6_.getChildByName("textField") == null) {
				HudArt.fatal("Missing Starling chat bar art: " + mBarKey);
			}
			HudArtConverter.stopTree(_loc12_);
			_loc2_ = new ArtNode();
			_loc2_.name = "UI_chat";
			_loc2_.key = _loc14_;
			try {
				_loc2_.children.push(bakePart(_loc6_, "chat_bar", _loc14_, _loc4_));
				__ax4_iter_264 = Vector.ofArray(["chat_btn", "log_btn"]);
				if (checkNullIteratee(__ax4_iter_264))
					for (_tmp_ in __ax4_iter_264) {
						_loc10_ = _tmp_;
						_loc13_ = ASCompat.reinterpretAs(_loc6_.getChildByName(_loc10_), MovieClip);
						if (_loc13_ == null || _loc13_.getChildByName("up") == null) {
							HudArt.fatal("Missing Starling chat button art: " + _loc10_);
						}
						_loc7_ = new ArtNode();
						_loc7_.name = _loc10_;
						_loc7_.matrix = _loc13_.transform.matrix;
						_loc2_.children.push(_loc7_);
						_loc11_ = new Vector<String>((0 : UInt));
						_loc5_ = 0;
						while (_loc5_ < _loc13_.numChildren) {
							_loc3_ = _loc13_.getChildAt(_loc5_).name;
							if (_loc3_ == "up" || _loc3_ == "over" || _loc3_ == "down" || _loc3_ == "label") {
								_loc11_.push(_loc3_);
							}
							_loc5_++;
						}
						if (checkNullIteratee(_loc11_))
							for (_tmp_ in _loc11_) {
								_loc3_ = _tmp_;
								_loc7_.children.push(bakePart(_loc13_, _loc3_, _loc14_ + "|" + _loc10_, _loc4_ * BakeScale.magnitude(_loc7_.matrix)));
							}
					}
			} catch (error:Dynamic) {
				_loc2_.release(HudArt.pages);
				throw error;
			}
			HudArt.storeContent(_loc14_, _loc2_);
		}
		var _loc8_ = ArtView.build(_loc2_, mTicker);
		mBar.addChild(_loc8_.root);
		mView = _loc8_;
		snap(mBar, _loc8_.root);
		var _loc1_:DisplayObject = mBar.parent;
		var _loc9_ = new StarlingButton(_loc8_, "chat_bar", _loc1_);
		mInput.add(_loc9_, false);
		mButtons.push(_loc9_);
		mSend = button(_loc8_, "chat_btn", _loc1_, mChat.chatSendButton.releaseCallback);
		mLog = button(_loc8_, "log_btn", _loc1_, mChat.chatLogButton.releaseCallback);
		if (mReady != null) {
			mReady();
		}
	}

	function button(view:ArtView, path:String, space:DisplayObject, release:ASFunction):StarlingButton {
		var _loc5_ = new StarlingButton(view, path, space);
		_loc5_.releaseCallback = release;
		mInput.add(_loc5_);
		mButtons.push(_loc5_);
		return _loc5_;
	}

	function placeLabel() {
		var _loc3_ = BakeScale.forDisplay(mLabel);
		var _loc4_ = mLabelKey + "|" + BakedPages.scaleKey(_loc3_);
		var _loc2_ = HudArt.content(_loc4_);
		if (_loc2_ == null) {
			_loc2_ = new ArtNode();
			_loc2_.cell = _loc2_.hold(HudArt.bakeContent(_loc4_, mLabelSource, _loc3_), HudArt.pages);
			HudArt.storeContent(_loc4_, _loc2_);
		}
		_loc2_.retainView();
		mLabelArt = _loc2_;
		var _loc1_ = new BakedImage(_loc2_.cell);
		mLabel.addChild(_loc1_);
		snap(mLabel, _loc1_);
	}

	public function dispose() {
		var _loc1_:StarlingButton = null;
		var _loc2_ = 0;
		if (mDisposed) {
			return;
		}
		mDisposed = true;
		if (mRetry != null && mTicker != null) {
			mTicker.cancelBake(mRetry);
		}
		mRetry = null;
		final __ax4_iter_265 = mButtons;
		if (checkNullIteratee(__ax4_iter_265))
			for (_tmp_ in __ax4_iter_265) {
				_loc1_ = _tmp_;
				if (mInput != null) {
					mInput.remove(_loc1_);
				}
				_loc1_.dispose();
			}
		mButtons.length = 0;
		mSend = mLog = null;
		if (mView != null) {
			mView.dispose();
		}
		mView = null;
		mBar.removeFromParent(true);
		mLabel.removeFromParent(true);
		if (mLabelArt != null) {
			mLabelArt.releaseView();
		}
		mLabelArt = null;
		_loc2_ = 0;
		while (_loc2_ < mFlashParts.length) {
			mFlashParts[_loc2_].visible = mFlashShown[_loc2_];
			_loc2_++;
		}
		mFlashParts.length = mFlashShown.length = 0;
		mClip = null;
		mModel = null;
		mLabelSource = null;
		mChanged = mReady = null;
		mTicker = null;
		mInput = null;
		mChat = null;
		mFacade = null;
	}
}
