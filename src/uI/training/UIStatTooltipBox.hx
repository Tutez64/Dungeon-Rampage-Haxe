package uI.training;

import brain.logger.Logger;
import brain.utils.TextUtil;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.text.TextField;

class UIStatTooltipBox extends MovieClip {
	static inline final DESCRIPTION_BOTTOM_LIMIT:Float = -32;

	static inline final BOX_CORNER:Float = 16;

	var mRoot:MovieClip;

	var mTitleLabel:TextField;

	var mDescription:TextField;

	var mDescriptionSize:Float = Math.NaN;

	var mBackground:Shape;

	var mBackgroundBounds:Rectangle;

	var mBackgroundY:Float = Math.NaN;

	var mTitleY:Float = Math.NaN;

	var mDescriptionY:Float = Math.NaN;

	public function new(templateClass:Dynamic) {
		var _loc2_ = Math.NaN;
		super();
		mRoot = ASCompat.coerce(ASCompat.createInstance(templateClass, []), flash.display.MovieClip);
		addChild(mRoot);
		mTitleLabel = ASCompat.coerce((mRoot : ASAny).title_label, flash.text.TextField);
		mDescription = ASCompat.coerce((mRoot : ASAny).stat_description_label, flash.text.TextField);
		mDescription.wordWrap = true;
		mDescription.multiline = true;
		mDescription.autoSize = "center";
		mDescriptionSize = ASCompat.toNumber(mDescription.defaultTextFormat.size);
		mTitleY = mTitleLabel.y;
		mDescriptionY = mDescription.y;
		mBackground = findBackground();
		if (mBackground != null) {
			mBackgroundBounds = mBackground.getBounds(mRoot);
			mBackgroundY = mBackground.y;
			_loc2_ = mDescription.getBounds(mRoot).top;
			mBackground.scale9Grid = new Rectangle(mBackgroundBounds.left + 16, _loc2_, mBackgroundBounds.width - 2 * 16, -32 - 16 - _loc2_);
		} else {
			Logger.warn("UIStatTooltipBox: stat_tooltip has no box shape; long descriptions will overflow it");
		}
	}

	public function destroy() {
		removeChild(mRoot);
		mRoot = null;
		mTitleLabel = null;
		mDescription = null;
		mBackground = null;
	}

	function setTexts(title:String, description:String, descriptionSizeModifier:Float) {
		TextUtil.setText(mTitleLabel, title);
		TextUtil.setText(mDescription, description, Math.max(TextUtil.modifierForSize(mDescriptionSize), descriptionSizeModifier));
		fitBox();
	}

	function findBackground():Shape {
		var _loc2_ = 0;
		var _loc1_:Shape = null;
		_loc2_ = 0;
		while (_loc2_ < mRoot.numChildren) {
			_loc1_ = ASCompat.reinterpretAs(mRoot.getChildAt(_loc2_), Shape);
			if (_loc1_ != null) {
				return _loc1_;
			}
			_loc2_++;
		}
		return null;
	}

	function fitBox() {
		if (mBackground == null) {
			return;
		}
		mDescription.y = mDescriptionY;
		var _loc1_ = Math.max(0, mDescription.getBounds(mRoot).bottom - -32);
		mTitleLabel.y = mTitleY - _loc1_;
		mDescription.y = mDescriptionY - _loc1_;
		mBackground.scaleY = 1 + _loc1_ / mBackgroundBounds.height;
		mBackground.y = mBackgroundY;
		mBackground.y += mBackgroundBounds.bottom - mBackground.getBounds(mRoot).bottom;
	}
}
