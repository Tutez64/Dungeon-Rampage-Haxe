package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;
import starling.styles.MeshStyle;

/*use*/ /*namespace*/ /*starling_internal*/ class ArtDisplay extends Sprite {
	static var sClips:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mArt:ArtNode;

	var mImage:BakedImage;

	var mChildren:Vector<ArtDisplay> = new Vector((0 : UInt));

	var mRed:Float = 1;

	var mGreen:Float = 1;

	var mBlue:Float = 1;

	var mOffsetRed:Float = 0;

	var mOffsetGreen:Float = 0;

	var mOffsetBlue:Float = 0;

	var mLocalColor:ColorTransform;

	var mHudVisibility:Int = -1;

	var mGrayscale:Bool = false;

	var mCell__UI_Hud_StarlingConverted_ArtDisplay /*redefined private*/:BakedCell;

	var mHudOffsetX:Float = 0;

	var mHudOffsetY:Float = 0;

	var mColorStyle:StarlingColorStyle;

	var mDefaultStyle:MeshStyle;

	@:allow(uI.hud.starlingConverted) var contentBoundsChanged:ASFunction;

	var mClip:Quad;

	@:allow(uI.hud.starlingConverted) var filterIndex:Int = 0;

	public function new(art:ArtNode) {
		super();
		mArt = art;
		mLocalColor = art.colorTransform;
		name = art.name;
		transformationMatrix = art.matrix;
		alpha = art.alpha;
		visible = art.visible;
		blendMode = art.blendMode;
		touchable = false;
	}

	@:allow(uI.hud.starlingConverted) static function isClipMask(node:DisplayObject):Bool {
		return sClips[node] == true;
	}

	static function rgb(red:Float, green:Float, blue:Float):UInt {
		return (ASCompat.floatToInt(Math.max(0,
			Math.min(1,
				red)) * 255) << 16 | ASCompat.floatToInt(Math.max(0,
				Math.min(1, green)) * 255) << 8 | ASCompat.floatToInt(Math.max(0, Math.min(1, blue)) * 255):UInt);
	}

	public function setHudVisibility(value:ASAny) {
		mHudVisibility = value == null ? -1 : (ASCompat.toBool(value) ? 1 : 0);
		if (mHudVisibility >= 0) {
			visible = mHudVisibility == 1;
		}
	}

	public function setHudOffset(x:Float, y:Float) {
		if (x == mHudOffsetX && y == mHudOffsetY) {
			return;
		}
		this.x += x - mHudOffsetX;
		this.y += y - mHudOffsetY;
		mHudOffsetX = x;
		mHudOffsetY = y;
		if (contentBoundsChanged != null) {
			contentBoundsChanged();
		}
	}

	@:allow(uI.hud.starlingConverted) function authoredMatrix(matrix:Matrix) {
		transformationMatrix = matrix;
		x += mHudOffsetX;
		y += mHudOffsetY;
	}

	@:allow(uI.hud.starlingConverted) function authoredVisibility(value:Bool) {
		visible = mHudVisibility >= 0 ? mHudVisibility == 1 : value;
	}

	@:allow(uI.hud.starlingConverted) function addArt(child:ArtDisplay) {
		mChildren.push(child);
		addChild(child);
		if (contentBoundsChanged != null) {
			contentBoundsChanged();
		}
	}

	@:allow(uI.hud.starlingConverted) function prepareClip() {
		if (mClip != null || parent == null) {
			return;
		}
		mClip = new Quad(1, 1);
		sClips[mClip] = true;
		mClip.touchable = false;
		parent.addChild(mClip);
		applyClip(mArt.parentClip);
	}

	@:allow(uI.hud.starlingConverted) function applyClip(rect:Rectangle) {
		if (mClip == null) {
			return;
		}
		if (rect == null) {
			mask = null;
			mClip.visible = false;
			return;
		}
		mClip.x = rect.x;
		mClip.y = rect.y;
		mClip.width = Math.max(0.001, rect.width);
		mClip.height = Math.max(0.001, rect.height);
		mClip.visible = true;
		mask = mClip;
	}

	@:allow(uI.hud.starlingConverted) function applyFilters(index:Int) {
		if (index == filterIndex) {
			return;
		}
		filterIndex = index;
		refreshTextFilters();
	}

	@:allow(uI.hud.starlingConverted) function refreshTextFilters() {
		var _loc1_:ArtDisplay = null;
		final __ax4_iter_285 = mChildren;
		if (checkNullIteratee(__ax4_iter_285))
			for (_tmp_ in __ax4_iter_285) {
				_loc1_ = _tmp_;
				_loc1_.refreshTextFilters();
			}
	}

	@:allow(uI.hud.starlingConverted) function prepareTextFilters() {
		var _loc1_:ArtDisplay = null;
		final __ax4_iter_286 = mChildren;
		if (checkNullIteratee(__ax4_iter_286))
			for (_tmp_ in __ax4_iter_286) {
				_loc1_ = _tmp_;
				_loc1_.prepareTextFilters();
			}
	}

	@:allow(uI.hud.starlingConverted) function addArtAt(child:ArtDisplay, index:Int) {
		mChildren.push(child);
		addChildAt(child, index);
		refreshColor();
		if (contentBoundsChanged != null) {
			contentBoundsChanged();
		}
	}

	@:allow(uI.hud.starlingConverted) function flashChild(index:Int):ArtDisplay {
		var _loc3_:ArtDisplay = null;
		var _loc2_ = 0;
		_loc2_ = 0;
		while (_loc2_ < numChildren) {
			_loc3_ = ASCompat.reinterpretAs(getChildAt(_loc2_), ArtDisplay);
			if (_loc3_ != null && _loc3_.art.name != "@graphics" && index-- == 0) {
				return _loc3_;
			}
			_loc2_++;
		}
		return null;
	}

	@:allow(uI.hud.starlingConverted) function addAtFlashDepth(child:DisplayObject, depth:Int, track:Bool = false) {
		var _loc5_ = flashChild(depth);
		var _loc4_ = _loc5_ != null ? getChildIndex(_loc5_) : numChildren;
		if (track) {
			addArtAt(ASCompat.reinterpretAs(child, ArtDisplay), _loc4_);
		} else {
			addChildAt(child, _loc4_);
		}
	}

	@:allow(uI.hud.starlingConverted) function removeArt(child:ArtDisplay) {
		var _loc2_ = mChildren.indexOf(child);
		if (_loc2_ >= 0) {
			mChildren.removeAt(_loc2_);
		}
		child.removeFromParent();
		if (contentBoundsChanged != null) {
			contentBoundsChanged();
		}
	}

	@:allow(uI.hud.starlingConverted) function buildImages() {
		mImage = ASCompat.coerce(mArt.barFill
			&& mArt.masked ? new StarlingBarImage() : new BakedImage(), brain.starling.swfConverter.BakedImage);
		mColorStyle = new StarlingColorStyle();
		mDefaultStyle = mImage.style;
		addChild(mImage);
		showCells(mArt.cell);
	}

	function showCells(cell:BakedCell) {
		mCell__UI_Hud_StarlingConverted_ArtDisplay = cell;
		mImage.cell = mGrayscale ? HudArtConverter.grayCell(cell) : cell;
		mImage.visible = cell != null && !cell.isEmpty;
		refreshColor();
	}

	@:allow(uI.hud.starlingConverted) function setGrayscale(value:Bool):Bool {
		var __ax4_iter_287:Vector<ArtFrame>;
		var _loc4_:ArtFrame = null;
		var _loc5_:ArtDisplay = null;
		var _loc3_ = true;
		var _loc2_ = ASCompat.coerce(mArt.lease != null ? ASCompat.coerce(mArt.lease.pages, brain.starling.swfConverter.BakedPages) : HudArt.pages,
			brain.starling.swfConverter.BakedPages);
		if (value) {
			if (mArt.cell != null && HudArtConverter.grayscale(mArt.cell, _loc2_) == null) {
				_loc3_ = false;
			}
			__ax4_iter_287 = mArt.frames;
			if (checkNullIteratee(__ax4_iter_287))
				for (_tmp_ in __ax4_iter_287) {
					_loc4_ = _tmp_;
					if (_loc4_ != null && _loc4_.cell != null && HudArtConverter.grayscale(_loc4_.cell, _loc2_) == null) {
						_loc3_ = false;
					}
				}
		}
		mGrayscale = value;
		if (mImage != null && mCell__UI_Hud_StarlingConverted_ArtDisplay != null) {
			mImage.cell = value ? HudArtConverter.grayCell(mCell__UI_Hud_StarlingConverted_ArtDisplay) : mCell__UI_Hud_StarlingConverted_ArtDisplay;
		}
		final __ax4_iter_288 = mChildren;
		if (checkNullIteratee(__ax4_iter_288))
			for (_tmp_ in __ax4_iter_288) {
				_loc5_ = _tmp_;
				if (!_loc5_.setGrayscale(value)) {
					_loc3_ = false;
				}
			}
		return _loc3_;
	}

	@:allow(uI.hud.starlingConverted) function setLocalColor(value:ColorTransform) {
		mLocalColor = value;
		refreshColor();
	}

	@:allow(uI.hud.starlingConverted) function tint(red:Float, green:Float, blue:Float, offsetRed:Float, offsetGreen:Float, offsetBlue:Float) {
		mRed = red;
		mGreen = green;
		mBlue = blue;
		mOffsetRed = offsetRed;
		mOffsetGreen = offsetGreen;
		mOffsetBlue = offsetBlue;
		refreshColor();
	}

	function refreshColor() {
		var _loc9_:ArtDisplay = null;
		var _loc5_ = false;
		var _loc6_:MeshStyle = null;
		var _loc1_ = mRed * mLocalColor.redMultiplier;
		var _loc3_ = mGreen * mLocalColor.greenMultiplier;
		var _loc4_ = mBlue * mLocalColor.blueMultiplier;
		var _loc7_ = mOffsetRed + mRed * mLocalColor.redOffset;
		var _loc8_ = mOffsetGreen + mGreen * mLocalColor.greenOffset;
		var _loc2_ = mOffsetBlue + mBlue * mLocalColor.blueOffset;
		if (mImage != null) {
			if (mColorStyle != null) {
				_loc5_ = _loc1_ == 1 && _loc3_ == 1 && _loc4_ == 1 && _loc7_ == 0 && _loc8_ == 0 && _loc2_ == 0;
				_loc6_ = ASCompat.coerce(_loc5_ ? mDefaultStyle : mColorStyle, starling.styles.MeshStyle);
				if (mImage.style != _loc6_) {
					mImage.style = _loc6_;
				}
				if (!_loc5_) {
					mColorStyle.setTransform(_loc1_, _loc3_, _loc4_, _loc7_, _loc8_, _loc2_);
				}
			} else {
				mImage.color = rgb(_loc1_, _loc3_, _loc4_);
			}
		}
		applyContentColor(_loc1_, _loc3_, _loc4_, _loc7_, _loc8_, _loc2_);
		final __ax4_iter_289 = mChildren;
		if (checkNullIteratee(__ax4_iter_289))
			for (_tmp_ in __ax4_iter_289) {
				_loc9_ = _tmp_;
				_loc9_.tint(_loc1_, _loc3_, _loc4_, _loc7_, _loc8_, _loc2_);
			}
	}

	function applyContentColor(red:Float, green:Float, blue:Float, offsetRed:Float, offsetGreen:Float, offsetBlue:Float) {}

	@:allow(uI.hud.starlingConverted) function refresh() {
		refreshColor();
	}

	@:allow(uI.hud.starlingConverted) function driveChildren(head:Float) {
		var _loc2_:ArtDisplay = null;
		final __ax4_iter_290 = mChildren;
		if (checkNullIteratee(__ax4_iter_290))
			for (_tmp_ in __ax4_iter_290) {
				_loc2_ = _tmp_;
				if (_loc2_.visible) {
					if (!(Std.isOfType(_loc2_, TimelineView) && cast(_loc2_, TimelineView).stageRate)) {
						if (Std.isOfType(_loc2_, TimelineView)) {
							cast(_loc2_, TimelineView).driveHead(head);
						} else {
							_loc2_.driveChildren(head);
						}
					}
				}
			}
	}

	@:allow(uI.hud.starlingConverted) function resetChildren() {
		var _loc1_:ArtDisplay = null;
		final __ax4_iter_291 = mChildren;
		if (checkNullIteratee(__ax4_iter_291))
			for (_tmp_ in __ax4_iter_291) {
				_loc1_ = _tmp_;
				if (!(Std.isOfType(_loc1_, TimelineView) && cast(_loc1_, TimelineView).stageRate)) {
					if (Std.isOfType(_loc1_, TimelineView)) {
						cast(_loc1_, TimelineView).resetIntro();
					}
					_loc1_.resetChildren();
				}
			}
	}

	@:allow(uI.hud.starlingConverted) function setStageRate(value:Bool) {
		var _loc2_:ArtDisplay = null;
		final __ax4_iter_292 = mChildren;
		if (checkNullIteratee(__ax4_iter_292))
			for (_tmp_ in __ax4_iter_292) {
				_loc2_ = _tmp_;
				if (Std.isOfType(_loc2_, TimelineView)) {
					cast(_loc2_, TimelineView).stageRate = value;
					if (value) {
						cast(_loc2_, TimelineView).play(0, true);
					} else {
						cast(_loc2_, TimelineView).stop();
					}
				} else {
					_loc2_.setStageRate(value);
				}
			}
	}

	@:allow(uI.hud.starlingConverted) function advanceHiddenTimelines(value:Bool) {
		var _loc2_:ArtDisplay = null;
		if (Std.isOfType(this, TimelineView)) {
			cast(this, TimelineView).advanceWhileHidden = value;
		}
		final __ax4_iter_293 = mChildren;
		if (checkNullIteratee(__ax4_iter_293))
			for (_tmp_ in __ax4_iter_293) {
				_loc2_ = _tmp_;
				_loc2_.advanceHiddenTimelines(value);
			}
	}

	@:isVar public var art(get, never):ArtNode;

	public function get_art():ArtNode {
		return mArt;
	}

	override public function dispose() {
		var _loc1_:DisplayObject = null;
		contentBoundsChanged = null;
		mask = null;
		if (mClip != null) {
			sClips.remove(mClip);
		}
		if (mClip != null) {
			mClip.removeFromParent(true);
		}
		mClip = null;
		while (numChildren > 0) {
			_loc1_ = removeChildAt(numChildren - 1);
			try {
				_loc1_.dispose();
			} catch (error:Dynamic) {
				StarlingHud.reportError(ASCompat.asError(error));
			}
		}
		mChildren.length = 0;
		super.dispose();
	}
}
