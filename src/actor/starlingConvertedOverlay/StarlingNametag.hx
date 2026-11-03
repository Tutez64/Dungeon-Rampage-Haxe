package actor.starlingConvertedOverlay;

import actor.ActorNametag;
import brain.starling.swfConverter.BakeBudget;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.text.TextField;
import starling.display.Sprite;

class StarlingNametag {
	static inline final DEG_TO_RAD:Float = 0.017453292519943295;

	static inline final SLOW_EVERY = 15;

	static inline final RETRY_FRAMES = 60;

	static inline final MAX_RETRY_FRAMES = 1920;

	var mOverlays:StarlingOverlays;

	var mNametag:ActorNametag;

	var mTop:DisplayObject;

	var mArt:DisplayObjectContainer;

	var mName:TextField;

	var mAfk:TextField;

	var mHp:DisplayObjectContainer;

	var mFill:DisplayObject;

	var mNamePart:TagPart;

	var mAfkPart:TagPart;

	var mUnderPart:TagPart;

	var mFillPart:TagPart;

	var mOverPart:TagPart;

	var mParts:Vector<TagPart>;

	var mOrder:Vector<Int>;

	var mView:TagView;

	var mFlashHidden:Bool = false;

	var mTextDirty:Bool = true;

	var mBarShown:Bool = false;

	var mSlowCountdown:Int = 0;

	var mArtCountdown:Int = 0;

	var mOverArt:Bool = false;

	var mNextRetry:Int = 0;

	var mRetryFrames:Int = 60;

	var mWaitForAllocation:Bool = false;

	var mCellsChanged:Bool = true;

	var mNameShiftX:Float = 0;

	var mNameShiftY:Float = 0;

	var mAfkShiftX:Float = 0;

	var mAfkShiftY:Float = 0;

	var mNameX:Float = 0;

	var mNameY:Float = 0;

	var mAfkX:Float = 0;

	var mAfkY:Float = 0;

	var mArtX:Float = 0;

	var mArtY:Float = 0;

	public function new(overlays:StarlingOverlays, nametag:ActorNametag, top:DisplayObject, art:DisplayObjectContainer, name:TextField, afk:TextField,
			hp:DisplayObjectContainer, fill:DisplayObject) {
		var before:Vector<DisplayObject>;
		var after:Vector<DisplayObject>;
		var depth:Vector<Int>;
		mArtCountdown = ASCompat.floatToInt(Math.random() * 15);

		mOverlays = overlays;
		mNametag = nametag;
		mTop = top;
		mArt = art;
		mName = name;
		mAfk = afk;
		mHp = hp;
		mFill = fill;
		before = new Vector<DisplayObject>((0 : UInt));
		after = new Vector<DisplayObject>((0 : UInt));
		splitAround(hp, fill, before, after, false);
		mNamePart = new TagPart(name);
		mAfkPart = new TagPart(afk);
		mUnderPart = new TagPart(hp, Vector.ofArray([fill]).concat(after), true);
		mFillPart = new TagPart(fill, null, true);
		mOverPart = ASCompat.coerce(after.length > 0 ? new TagPart(hp, Vector.ofArray([fill]).concat(before), true) : null,
			actor.starlingConvertedOverlay.TagPart);
		mParts = Vector.ofArray([mNamePart, mAfkPart, mUnderPart, mFillPart]);
		if (mOverPart != null) {
			mParts.push(mOverPart);
		}
		mOrder = Vector.ofArray([0, 1, 2]);
		if (hp.parent == art && name.parent == art && afk.parent == art) {
			depth = Vector.ofArray([art.getChildIndex(hp), art.getChildIndex(name), art.getChildIndex(afk)]);
			ASCompat.ASVector.sort(mOrder, function(param1:Int, param2:Int):Int {
				return depth[param1] - depth[param2];
			});
		}
	}

	static function apply(image:BakedImage, part:TagPart) {
		var _loc3_ = part.drawn;
		image.cell = ASCompat.coerce(_loc3_ ? part.cell : null, brain.starling.swfConverter.BakedCell);
		image.visible = _loc3_;
	}

	static function placeImage(target:BakedImage, source:DisplayObject, x:Float, y:Float) {
		target.x = x;
		target.y = y;
		target.scaleX = source.scaleX;
		target.scaleY = source.scaleY;
		target.alpha = source.alpha;
	}

	static function textContent(prefix:String, field:TextField):String {
		var _loc3_ = field.text;
		if (_loc3_ == null || _loc3_.length == 0) {
			return null;
		}
		return prefix + _loc3_ + "|" + ASCompat.toRadix(field.textColor, (16 : UInt)) + "|" + Math.fround(field.textWidth * 4) + "x"
			+ Math.fround(field.textHeight * 4) + "|" + Math.fround(field.width * 4);
	}

	static function splitAround(container:DisplayObjectContainer, target:DisplayObject, before:Vector<DisplayObject>, after:Vector<DisplayObject>,
			found:Bool):Bool {
		var _loc6_ = 0;
		var _loc7_:DisplayObject = null;
		_loc6_ = 0;
		while (_loc6_ < container.numChildren) {
			_loc7_ = container.getChildAt(_loc6_);
			if (_loc7_ == target) {
				found = true;
			} else if (Std.isOfType(_loc7_, DisplayObjectContainer) && cast(_loc7_, DisplayObjectContainer).contains(target)) {
				found = splitAround(cast(_loc7_, DisplayObjectContainer), target, before, after, found);
			} else {
				(found ? after : before).push(_loc7_);
			}
			_loc6_++;
		}
		return found;
	}

	public function contentChanged() {
		mTextDirty = true;
	}

	@:allow(Actor.StarlingConvertedOverlay) function update(frame:Int) {
		var _loc3_:DisplayObjectContainer = null;
		var _loc2_:DisplayObject = mNametag.parent;
		if (_loc2_ == null || _loc2_.parent == null) {
			if (mView != null) {
				mView.tag.visible = false;
			}
			return;
		}
		if (_loc2_.parent == mOverlays.aboveFadeLayer) {
			showFlash();
			return;
		}
		if (--mArtCountdown <= 0) {
			mArtCountdown = 15;
			_loc3_ = ASCompat.reinterpretAs(_loc2_, DisplayObjectContainer);
			mOverArt = _loc3_ != null && hasFlashArt(_loc3_, _loc3_, mHp.getBounds(_loc3_).union(mName.getBounds(_loc3_)));
		}
		if (mOverArt) {
			showFlash();
			return;
		}
		if (!prepare(frame)) {
			showFlash();
			return;
		}
		if (mView == null) {
			mView = mOverlays.takeView();
			mView.tag.owner = this;
			mView.order(mOrder[0], mOrder[1], mOrder[2]);
			mCellsChanged = true;
		}
		if (!mFlashHidden) {
			mName.visible = false;
			mAfk.visible = false;
			mHp.visible = false;
			mFlashHidden = true;
		}
		sync(_loc2_);
	}

	@:allow(Actor.StarlingConvertedOverlay) function switchToFlash() {
		showFlash();
		if (mView != null) {
			mOverlays.returnView(mView);
			mView = null;
		}
	}

	@:allow(Actor.StarlingConvertedOverlay) function compareInFlash(other:StarlingNametag):Int {
		var _loc3_ = ASCompat.coerce(mNametag != null ? mNametag.parent : null, flash.display.DisplayObject);
		var _loc2_ = ASCompat.coerce(other.mNametag != null ? other.mNametag.parent : null, flash.display.DisplayObject);
		if (_loc3_ == _loc2_) {
			return 0;
		}
		if (_loc3_ == null || _loc2_ == null) {
			return _loc3_ == null ? -1 : 1;
		}
		if (_loc3_.y != _loc2_.y) {
			return _loc3_.y < _loc2_.y ? -1 : 1;
		}
		if (_loc3_.x != _loc2_.x) {
			return _loc2_.x < _loc3_.x ? -1 : 1;
		}
		if (_loc3_.parent == null || _loc3_.parent != _loc2_.parent) {
			return 0;
		}
		return _loc3_.parent.getChildIndex(_loc3_) < _loc3_.parent.getChildIndex(_loc2_) ? -1 : 1;
	}

	public function destroy() {
		if (mOverlays == null) {
			return;
		}
		if (mView != null) {
			mOverlays.returnView(mView);
		}
		mView = null;
		var _loc1_:TagPart;
		final __ax4_iter_433 = mParts;
		if (checkNullIteratee(__ax4_iter_433))
			for (_tmp_ in __ax4_iter_433) {
				_loc1_ = _tmp_;
				setCell(_loc1_, null, null, 0);
			}
		mOverlays.removeTag(this);
		mOverlays = null;
		mNametag = null;
	}

	@:allow(Actor.StarlingConvertedOverlay) function rescale() {
		mSlowCountdown = 0;
		mTextDirty = true;
		var _loc1_:TagPart;
		final __ax4_iter_434 = mParts;
		if (checkNullIteratee(__ax4_iter_434))
			for (_tmp_ in __ax4_iter_434) {
				_loc1_ = _tmp_;
				_loc1_.cellScale = -1;
			}
		mNextRetry = 0;
		mRetryFrames = 60;
	}

	function hasFlashArt(node:DisplayObjectContainer, root:DisplayObject, box:Rectangle):Bool {
		var _loc4_ = 0;
		var _loc5_:DisplayObject = null;
		_loc4_ = 0;
		while (_loc4_ < node.numChildren) {
			_loc5_ = node.getChildAt(_loc4_);
			if (!(_loc5_ == mNametag || !_loc5_.visible || _loc5_.alpha <= 0)) {
				if (Std.isOfType(_loc5_, MovieClip) || Std.isOfType(_loc5_, Bitmap) || Std.isOfType(_loc5_, Shape)) {
					if (_loc5_.width > 0 && _loc5_.getBounds(root).intersects(box)) {
						return true;
					}
				} else if (Std.isOfType(_loc5_, DisplayObjectContainer) && hasFlashArt(cast(_loc5_, DisplayObjectContainer), root, box)) {
					return true;
				}
			}
			_loc4_++;
		}
		return false;
	}

	function showFlash() {
		if (mFlashHidden) {
			mName.visible = true;
			mAfk.visible = true;
			mHp.visible = true;
			mFlashHidden = false;
		}
		if (mView != null) {
			mView.tag.visible = false;
		}
	}

	function prepare(frame:Int):Bool {
		var _loc5_:TagPart;
		var __ax4_iter_435:Vector<TagPart>;
		var _loc2_ = mNametag.hpBarVisible;
		var _loc3_ = --mSlowCountdown <= 0 || mTextDirty || _loc2_ != mBarShown;
		if (_loc3_) {
			mSlowCountdown = 15;
			if (mTextDirty) {
				mTextDirty = false;
				mNamePart.wantContent = textContent("name|", mName);
				mAfkPart.wantContent = textContent("afk|", mAfk);
				measureShift(mName, true);
				measureShift(mAfk, false);
			}
			mBarShown = _loc2_;
			mUnderPart.wantContent = _loc2_ ? "hpUnder" : null;
			mFillPart.wantContent = _loc2_ ? "hpFill" : null;
			if (mOverPart != null) {
				mOverPart.wantContent = _loc2_ ? "hpOver" : null;
			}
			__ax4_iter_435 = mParts;
			if (checkNullIteratee(__ax4_iter_435))
				for (_tmp_ in __ax4_iter_435) {
					_loc5_ = _tmp_;
					if (_loc5_.wantContent != null) {
						_loc5_.wantScale = mOverlays.bakeScale(chainScale(_loc5_.source));
					}
				}
		}
		var _loc4_ = true;
		final __ax4_iter_436 = mParts;
		if (checkNullIteratee(__ax4_iter_436))
			for (_tmp_ in __ax4_iter_436) {
				_loc5_ = _tmp_;
				if (!_loc5_.current) {
					prepareOne(_loc5_, frame);
				}
				if (!_loc5_.usable) {
					_loc4_ = false;
				}
			}
		return _loc4_;
	}

	function prepareOne(part:TagPart, frame:Int) {
		if (part.wantContent == null) {
			setCell(part, null, null, 0);
			return;
		}
		if (mWaitForAllocation) {
			if (!BakeBudget.admitting) {
				return;
			}
			mWaitForAllocation = false;
			mNextRetry = 0;
		}
		if (frame < mNextRetry) {
			return;
		}
		var _loc3_ = mOverlays.cellFor(part.wantContent + "|" + BakedPages.scaleKey(part.wantScale), part.source, part.wantScale, part.hide, part.shared);
		if (_loc3_ == 0) {
			setCell(part, mOverlays.lastCell, part.wantContent, part.wantScale);
			mRetryFrames = 60;
		} else if (_loc3_ == 2) {
			mWaitForAllocation = !BakeBudget.admitting;
			mNextRetry = frame + mRetryFrames;
			if (!mWaitForAllocation) {
				mRetryFrames = ASCompat.floatToInt(Math.min(1920, mRetryFrames * 2));
			}
		}
	}

	function setCell(part:TagPart, cell:BakedCell, content:String, scale:Float) {
		var _loc5_ = part.cell;
		part.cell = cell;
		part.cellContent = content;
		part.cellScale = scale;
		mCellsChanged = true;
		if (mView != null) {
			applyCells();
		}
		if (_loc5_ != null) {
			mOverlays.releaseCell(_loc5_);
		}
	}

	function applyCells() {
		mCellsChanged = false;
		apply(mView.name, mNamePart);
		apply(mView.afk, mAfkPart);
		apply(mView.under, mUnderPart);
		apply(mView.fill, mFillPart);
		if (mOverPart != null) {
			apply(mView.over, mOverPart);
		} else {
			mView.over.visible = false;
		}
	}

	function sync(root:DisplayObject) {
		var _loc18_:Float;
		var _loc9_:Float;
		var _loc11_:Float;
		var _loc17_ = Math.NaN;
		var _loc12_:DisplayObjectContainer = null;
		var _loc7_:BakedImage = null;
		var _loc13_ = mView;
		if (mCellsChanged) {
			applyCells();
			layoutSlow(_loc13_);
		}
		var _loc15_ = root.visible && mNametag.shownOnScreen && mTop.visible && mArt.visible;
		var _loc14_ = mNametag.scaleX;
		var _loc10_ = mNametag.scaleY;
		var _loc2_ = mTop.scaleX;
		var _loc4_ = mTop.scaleY;
		var _loc16_ = mNametag.x + _loc14_ * (mTop.x + _loc2_ * mArt.x);
		var _loc19_ = mNametag.y + _loc10_ * (mTop.y + _loc4_ * mArt.y);
		var _loc6_ = root.x;
		var _loc8_ = root.y;
		var _loc5_ = root.scaleY;
		if (_loc15_ && mOverlays.isCulled(_loc6_, _loc8_ + _loc19_ * _loc5_)) {
			_loc15_ = false;
		}
		_loc13_.tag.visible = _loc15_;
		if (!_loc15_) {
			return;
		}
		var _loc20_:Sprite = _loc13_.tag;
		_loc20_.x = _loc6_;
		_loc20_.y = _loc8_;
		_loc20_.scaleX = root.scaleX;
		_loc20_.scaleY = _loc5_;
		_loc20_.rotation = root.rotation * 0.017453292519943295;
		_loc20_.alpha = root.alpha * mNametag.alpha * mTop.alpha * mArt.alpha;
		var _loc3_ = _loc13_.art;
		_loc3_.x = _loc16_;
		_loc3_.y = _loc19_;
		_loc3_.scaleX = _loc14_ * _loc2_ * mArt.scaleX;
		_loc3_.scaleY = _loc10_ * _loc4_ * mArt.scaleY;
		if (mSlowCountdown == 15) {
			layoutSlow(_loc13_);
		}
		mArtX = _loc16_;
		mArtY = _loc19_;
		_loc13_.bar.visible = mBarShown && (mUnderPart.drawn || mFillPart.drawn);
		if (_loc13_.bar.visible && mFillPart.drawn) {
			_loc17_ = mFill.x;
			_loc18_ = mFill.y;
			_loc9_ = mFill.scaleX;
			_loc11_ = mFill.scaleY;
			_loc12_ = mFill.parent;
			while (_loc12_ != null && _loc12_ != mHp) {
				_loc17_ = _loc12_.x + _loc12_.scaleX * _loc17_;
				_loc18_ = _loc12_.y + _loc12_.scaleY * _loc18_;
				_loc9_ *= _loc12_.scaleX;
				_loc11_ *= _loc12_.scaleY;
				_loc12_ = _loc12_.parent;
			}
			_loc7_ = _loc13_.fill;
			_loc7_.x = _loc17_;
			_loc7_.y = _loc18_;
			_loc7_.scaleX = _loc9_;
			_loc7_.scaleY = _loc11_;
		}
	}

	@:allow(Actor.StarlingConvertedOverlay) function snapToScreen(pixelSize:Float) {
		var _loc2_ = ASCompat.coerce(mView.name.visible
			&& mNamePart.current ? mView.name : ASCompat.coerce(mView.afk.visible && mAfkPart.current ? mView.afk : null,
				brain.starling.swfConverter.BakedImage),
			brain.starling.swfConverter.BakedImage);
		mView.snapToScreen(ASCompat.coerce(mOverlays.snapPixelsPerUnit > 0 ? _loc2_ : null, brain.starling.swfConverter.BakedImage), pixelSize, mArtX, mArtY,
			mOverlays.cameraOffsetX, mOverlays.cameraOffsetY);
	}

	function layoutSlow(view:TagView) {
		mNameX = mName.x - mNameShiftX * mName.scaleX;
		mNameY = mName.y - mNameShiftY * mName.scaleY;
		mAfkX = mAfk.x - mAfkShiftX * mAfk.scaleX;
		mAfkY = mAfk.y - mAfkShiftY * mAfk.scaleY;
		placeImage(view.name, mName, mNameX, mNameY);
		placeImage(view.afk, mAfk, mAfkX, mAfkY);
		var _loc2_ = view.bar;
		_loc2_.x = mHp.x;
		_loc2_.y = mHp.y;
		_loc2_.scaleX = mHp.scaleX;
		_loc2_.scaleY = mHp.scaleY;
		_loc2_.alpha = mHp.alpha;
	}

	function measureShift(field:TextField, isName:Bool) {
		var _loc4_:Rectangle = null;
		var _loc3_ = field.getBounds(field);
		var _loc5_:Float = 0;
		var _loc6_:Float = 0;
		if (field.parent != null && field.scaleX != 0 && field.scaleY != 0) {
			_loc4_ = field.getBounds(field.parent);
			_loc5_ = _loc3_.x - (_loc4_.x - field.x) / field.scaleX;
			_loc6_ = _loc3_.y - (_loc4_.y - field.y) / field.scaleY;
		}
		if (isName) {
			mNameShiftX = _loc5_;
			mNameShiftY = _loc6_;
		} else {
			mAfkShiftX = _loc5_;
			mAfkShiftY = _loc6_;
		}
	}

	function chainScale(node:DisplayObject):Float {
		var _loc4_:DisplayObject = null;
		var _loc2_:DisplayObject = mNametag.parent;
		var _loc3_:Float = 1;
		_loc4_ = node;
		while (_loc4_ != null) {
			_loc3_ *= Math.abs(_loc4_.scaleY);
			if (_loc4_ == _loc2_) {
				break;
			}
			_loc4_ = _loc4_.parent;
		}
		return _loc3_;
	}
}
