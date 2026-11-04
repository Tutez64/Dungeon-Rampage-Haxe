package uI.hud.starlingConverted;

import actor.buffs.BuffGameObject;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.GameMasterLocale;
import flash.display.MovieClip;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

class StarlingBuff {
	var mBuff:BuffGameObject;

	var mView:ArtView;

	var mButton:StarlingButton;

	var mTooltip:StarlingTooltip;

	var mClip:MovieClip;

	var mIcon:StarlingHudIcon;

	var mCooldown:TimelineView;

	var mInput:StarlingInput;

	var mChanged:ASFunction;

	public function new(facade:DBFacade, ticker:HudTicker, input:StarlingInput, parent:DisplayObjectContainer, buff:BuffGameObject, changed:ASFunction) {
		var _loc7_:Dynamic = null;
		var _loc8_:MovieClip = null;

		mBuff = buff;
		mInput = input;
		mChanged = changed;
		try {
			mView = ArtView.build(HudArt.art("buff_cooldown_icon"), ticker);
			parent.addChild(mView.root);
			_loc7_ = HudArt.swfClass("buff_cooldown_icon");
			_loc8_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
			HudArtConverter.stopTree(_loc8_);
			mClip = ASCompat.coerce((_loc8_ : ASAny).tooltip, flash.display.MovieClip);
			mButton = new StarlingButton(mView, "", parent);
			mTooltip = new StarlingTooltip(facade, mButton.root, parent, mClip);
			mButton.rollOverCallback = mTooltip.rollOver;
			mButton.rollOutCallback = mTooltip.hide;
			input.add(mButton, false);
			mIcon = new StarlingHudIcon(facade, ticker, ASCompat.reinterpretAs(mView.node("graphic"), DisplayObjectContainer), changed);
			mIcon.load(buff.buffData.IconSwf, buff.buffData.IconName, 0.75, 0.75);
			mCooldown = ASCompat.reinterpretAs(mView.node("cooldown"), TimelineView);
			updateInstance();
		} catch (error:Dynamic) {
			dispose();
			throw error;
		}
	}

	@:allow(uI.hud.starlingConverted) function rebuild(facade:DBFacade, ticker:HudTicker, input:StarlingInput, parent:DisplayObjectContainer):StarlingBuff {
		var __finallyReturn0:StarlingBuff;
		var _loc5_:StarlingBuff = null;
		{
			var __finallyReturn0:StarlingBuff;
			try {
				try {
					_loc5_ = new StarlingBuff(facade, ticker, input, parent, mBuff, mChanged);
					_loc5_.root.x = root.x;
					_loc5_.root.y = root.y;
					if (mCooldown != null && _loc5_.mCooldown != null) {
						if (mCooldown.isPlaying) {
							_loc5_.mCooldown.play(mCooldown.playHead);
						} else {
							_loc5_.mCooldown.gotoAndStop(mCooldown.currentFrame);
						}
					}
					{
						__finallyReturn0 = _loc5_;
						{
							dispose();
						};
						return __finallyReturn0;
					};
				} catch (error:Dynamic) {
					if (_loc5_ != null) {
						_loc5_.dispose();
					}
					throw error;
				};
			} catch (__finallyError1:Dynamic) {
				{
					dispose();
				};
				throw __finallyError1;
			};
			{
				dispose();
			};
		}
		return null;
	}

	public function updateInstance() {
		var _loc2_:String = null;
		if (mBuff.isDestroyed) {
			return;
		}
		TextUtil.setText(ASCompat.coerce((mClip : ASAny).title_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("BUFF_NAME", mBuff.buffData.Constant));
		TextUtil.setText(ASCompat.coerce((mClip : ASAny).description_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",
				mBuff.buffData.Constant) + mBuff.buffData.getStacksDescription((mBuff.instanceCount : Int)));
		var _loc1_ = ASCompat.reinterpretAs(mView.node("quantity"), StarlingText);
		if (_loc1_ != null) {
			_loc2_ = Std.string(mBuff.instanceCount);
			_loc1_.setContent(_loc2_, "glyphs");
		}
		if (mCooldown != null) {
			mCooldown.stageRate = false;
			mCooldown.playRate = 4.1 / mBuff.buffData.Duration;
			mCooldown.play();
		}
		mChanged();
	}

	public function position(index:Int, condensed:Bool) {
		mView.root.x = (condensed ? 455 : 424) + 63 * index;
		mView.root.y = condensed ? 865 : 980;
		mChanged();
	}

	public function rebindInput(input:StarlingInput) {
		if (mInput != null) {
			mInput.remove(mButton);
		}
		mInput = input;
		input.add(mButton, false);
	}

	public function detachInput() {
		mTooltip.hide();
		if (mInput != null) {
			mInput.remove(mButton);
		}
		mInput = null;
	}

	@:isVar public var root(get, never):DisplayObject;

	public function get_root():DisplayObject {
		return mView.root;
	}

	@:allow(uI.hud.starlingConverted) @:isVar var art(get, never):ArtNode;

	function get_art():ArtNode {
		return mView.artNode("");
	}

	@:isVar public var buff(get, never):BuffGameObject;

	public function get_buff():BuffGameObject {
		return mBuff;
	}

	public function hideTooltip() {
		mTooltip.hide();
	}

	public function dispose() {
		try {
			if (mInput != null) {
				mInput.remove(mButton);
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
		mInput = null;
		StarlingHud.disposeResource(mTooltip);
		StarlingHud.disposeResource(mButton);
		StarlingHud.disposeResource(mIcon);
		StarlingHud.disposeResource(mView);
		mTooltip = null;
		mButton = null;
		mIcon = null;
		mView = null;
		mCooldown = null;
		mChanged();
	}
}
