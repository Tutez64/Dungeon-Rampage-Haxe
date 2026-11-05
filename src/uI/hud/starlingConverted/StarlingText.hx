package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import brain.starling.swfConverter.BakedPicture;
import brain.starling.swfConverter.FlashBaker;
import brain.utils.TextUtil;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import starling.core.Starling;
import starling.display.DisplayObject;

class StarlingText extends ArtDisplay {
	public static inline final AUTO = "auto";

	public static inline final GLYPHS = "glyphs";

	public static inline final BAKED = "baked";

	static inline final CHARS = "0123456789+-x.,%/:";

	static var sGlyphOrigins:ASObject;

	var mPages:BakedPages;

	var mScale:Float = Math.NaN;

	var mMode:String;

	var mText:String;

	var mColor:UInt = 0;

	var mFull:StarlingGlyphFont;

	var mFill:StarlingGlyphFont;

	var mWhiteFont:StarlingGlyphFont;

	var mFullText:StarlingGlyphText;

	var mFillText:StarlingGlyphText;

	var mWhiteText:StarlingGlyphText;

	var mCell:BakedCell;

	var mDisposed:Bool = false;

	var mNeedsBake:Bool = false;

	var mBox:Rectangle;

	var mFontSize:Float = Math.NaN;

	var mGlyphX:Float = Math.NaN;

	var mGlyphY:Float = Math.NaN;

	var mFittedFormat:TextFormat;

	var mFitModel:TextField;

	var mFontAvailable:Bool = false;

	var mBoundsMatrix:Matrix = new Matrix();

	var mImageMatrix:Matrix = new Matrix();

	var mFilterAncestors:Vector<ArtDisplay>;

	var mFilterCells:Vector<BakedCell> = new Vector((0 : UInt));

	var mFilterPlacements:Vector<Matrix> = new Vector((0 : UInt));

	var mBakingVariant:Int = -1;

	var mSingleFilterVariant:Bool = false;

	var mTicker:HudTicker;

	var mContextRetry:ASFunction;

	public function new(art:ArtNode, pages:BakedPages, scale:Float, mode:String = "auto", ticker:HudTicker = null) {
		super(art);
		mTicker = ticker;
		mContextRetry = retryAfterContext;
		if (sGlyphOrigins == null) {
			sGlyphOrigins = {};
		}
		mPages = pages;
		mScale = scale;
		mMode = mode;
		mBox = art.textBounds != null ? art.textBounds.clone() : art.model.getBounds(art.model);
		mColor = art.model.textColor;
		touchable = false;
		mImage = new BakedImage();
		mImage.name = "@baked";
		mImage.visible = false;
		addChild(mImage);
		try {
			mFontAvailable = buildFont("0123456789+-x.,%/:");
			if (!mFontAvailable && mMode == "glyphs") {
				throw new Error("HUD numeric font unavailable: " + art.key);
			}
			setText(art.initialText);
		} catch (error:Dynamic) {
			dispose();
			throw error;
		}
	}

	static function restoreBox(model:TextField, matrix:Matrix, box:Rectangle) {
		model.transform.matrix = new Matrix();
		model.width = box.width;
		model.height = box.height;
		model.transform.matrix = matrix;
	}

	function buildFont(chars:String, grayscale:Bool = false):Bool {
		var _loc14_:StarlingGlyphFont = null;
		var _loc6_:StarlingGlyphFont = null;
		var _loc11_:StarlingGlyphFont = null;
		var _loc12_:TextFormat = null;
		var _loc13_ = mArt.model;
		var _loc10_ = _loc13_.filters.length > 0;
		var _loc4_ = grayscale ? mArt.grayFontKeys : mArt.textFontKeys;
		mFontSize = mArt.textFontSize;
		if (_loc4_ != null && _loc4_[0] != null) {
			_loc14_ = StarlingGlyphFont.acquire(mPages, _loc4_[0]);
			_loc6_ = ASCompat.coerce(_loc4_[1] != null ? StarlingGlyphFont.acquire(mPages, _loc4_[1]) : null, uI.hud.starlingConverted.StarlingGlyphFont);
			_loc11_ = ASCompat.coerce(_loc4_[2] != null ? StarlingGlyphFont.acquire(mPages, _loc4_[2]) : null, uI.hud.starlingConverted.StarlingGlyphFont);
			if (_loc14_ != null && (_loc4_[1] == null || _loc6_ != null) && (_loc4_[2] == null || _loc11_ != null)) {
				return useFonts(_loc14_, _loc6_, _loc11_);
			}
			if (_loc14_ != null) {
				_loc14_.release();
			}
			if (_loc6_ != null) {
				_loc6_.release();
			}
			if (_loc11_ != null) {
				_loc11_.release();
			}
		}
		_loc4_ = new Vector<String>((3 : UInt), true);
		if (grayscale) {
			mArt.grayFontKeys = _loc4_;
		} else {
			mArt.textFontKeys = _loc4_;
		}
		mFontSize = ASCompat.toNumber(_loc13_.length > 0 ? _loc13_.getTextFormat().size : _loc13_.defaultTextFormat.size);
		mArt.textFontSize = mFontSize;
		var _loc8_ = _loc13_.textColor;
		var _loc3_ = _loc13_.defaultTextFormat;
		var _loc9_ = _loc13_.htmlText;
		var _loc7_ = _loc13_.transform.matrix;
		var _loc5_ = _loc13_.getBounds(_loc13_);
		{
			try {
				if (!_loc10_) {
					_loc12_ = _loc13_.length > 0 ? _loc13_.getTextFormat() : _loc13_.defaultTextFormat;
					_loc12_.color = 16777215;
					_loc13_.defaultTextFormat = _loc12_;
					_loc13_.setTextFormat(_loc12_);
					_loc13_.textColor = (16777215 : UInt);
				}
				_loc14_ = HudArt.buildFont(mPages, "hudStarling", _loc13_, mScale, chars, 0);
			} catch (__finallyError0:Dynamic) {
				{
					_loc13_.defaultTextFormat = _loc3_;
					_loc13_.textColor = _loc8_;
					_loc13_.htmlText = _loc9_;
					restoreBox(_loc13_, _loc7_, _loc5_);
				};
				throw __finallyError0;
			};
			{
				_loc13_.defaultTextFormat = _loc3_;
				_loc13_.textColor = _loc8_;
				_loc13_.htmlText = _loc9_;
				restoreBox(_loc13_, _loc7_, _loc5_);
			};
		}
		if (_loc14_ == null) {
			return false;
		}
		{
			try {
				_loc6_ = ASCompat.coerce(_loc10_ ? HudArt.buildFont(mPages, "hudStarling", _loc13_, mScale, chars, 1) : null,
					uI.hud.starlingConverted.StarlingGlyphFont);
			} catch (__finallyError1:Dynamic) {
				{
					_loc13_.defaultTextFormat = _loc3_;
					_loc13_.textColor = _loc8_;
					_loc13_.htmlText = _loc9_;
					restoreBox(_loc13_, _loc7_, _loc5_);
				};
				throw __finallyError1;
			};
			{
				_loc13_.defaultTextFormat = _loc3_;
				_loc13_.textColor = _loc8_;
				_loc13_.htmlText = _loc9_;
				restoreBox(_loc13_, _loc7_, _loc5_);
			};
		}
		if (_loc10_ && mArt.wantsSilhouette) {
			_loc11_ = buildWhiteFont(chars);
		}
		if (_loc10_ && (_loc6_ == null || mArt.wantsSilhouette && _loc11_ == null)) {
			_loc14_.release();
			if (_loc6_ != null) {
				_loc6_.release();
			}
			if (_loc11_ != null) {
				_loc11_.release();
			}
			return false;
		}
		_loc4_[0] = _loc14_.cell.key;
		_loc4_[1] = _loc6_ != null ? _loc6_.cell.key : null;
		_loc4_[2] = _loc11_ != null ? _loc11_.cell.key : null;
		return useFonts(_loc14_, _loc6_, _loc11_);
	}

	function useFonts(full:StarlingGlyphFont, fill:StarlingGlyphFont, white:StarlingGlyphFont):Bool {
		var _loc4_ = mArt.model.filters.length > 0;
		if (mFull != null) {
			mFull.release();
		}
		if (mFill != null) {
			mFill.release();
		}
		if (mWhiteFont != null) {
			mWhiteFont.release();
		}
		mFull = full;
		mFill = fill;
		mWhiteFont = white;
		var _loc7_ = mArt.alignment == "right" ? 2 : (mArt.alignment == "center" ? 1 : 0);
		if (mFullText == null) {
			mFullText = new StarlingGlyphText(full, _loc7_);
			mFullText.name = "@glyph";
			mFullText.visible = false;
			addChild(mFullText);
		} else {
			mFullText.font = full;
		}
		if (mFillText == null && fill != null) {
			mFillText = new StarlingGlyphText(fill, _loc7_);
			mFillText.name = "@fill";
			mFillText.visible = false;
			addChild(mFillText);
		} else if (mFillText != null) {
			mFillText.font = fill;
		}
		if (mArt.wantsSilhouette) {
			if (mWhiteText == null) {
				mWhiteText = new StarlingGlyphText(_loc4_ ? white : full, _loc7_);
				mWhiteText.name = "@white";
				mWhiteText.visible = false;
				addChild(mWhiteText);
			} else {
				mWhiteText.font = _loc4_ ? white : full;
			}
		}
		var _loc6_ = full;
		mFullText.layoutFont = _loc6_;
		if (mFillText != null) {
			mFillText.layoutFont = _loc6_;
		}
		if (mWhiteText != null) {
			mWhiteText.layoutFont = _loc6_;
		}
		var _loc5_ = glyphOrigin();
		mGlyphX = _loc5_.x;
		mGlyphY = _loc5_.y;
		mFullText.x = _loc5_.x;
		mFullText.y = _loc5_.y;
		if (mFillText != null) {
			mFillText.x = _loc5_.x;
			mFillText.y = _loc5_.y;
		}
		if (mWhiteText != null) {
			mWhiteText.x = _loc5_.x;
			mWhiteText.y = _loc5_.y;
		}
		refresh();
		return true;
	}

	function glyphOrigin():Point {
		var _loc4_:BakedPicture = null;
		var _loc7_:TextFormat = null;
		var _loc11_ = mArt.key + "|" + mFull.cell.key;
		if (sGlyphOrigins[_loc11_] != null) {
			return ASCompat.dynamicAs(sGlyphOrigins[_loc11_], Point);
		}
		var _loc8_ = mArt.model;
		var _loc1_ = _loc8_.htmlText;
		var _loc3_ = _loc8_.defaultTextFormat;
		var _loc10_ = _loc8_.transform.matrix;
		var _loc9_ = _loc8_.getBounds(_loc8_);
		var _loc6_ = new Rectangle();
		var _loc12_ = new StarlingGlyphText(mFull, mArt.alignment == "right" ? 2 : (mArt.alignment == "center" ? 1 : 0));
		_loc12_.layoutFont = mFull;
		_loc12_.visible = false;
		var _loc5_ = new Point(mBox.x + 2, mBox.y + 2);
		var _loc2_ = _loc8_.autoSize;
		{
			try {
				_loc7_ = _loc8_.length > 0 ? _loc8_.getTextFormat() : _loc3_;
				_loc7_.align = mArt.alignment;
				_loc8_.defaultTextFormat = _loc7_;
				_loc8_.autoSize = "none";
				restoreBox(_loc8_, _loc10_, mBox);
				_loc8_.text = "0";
				_loc8_.setTextFormat(_loc7_);
				_loc4_ = HudArt.bakePixels(_loc8_, mScale);
				_loc12_.setText("0");
				_loc12_.getBounds(_loc12_, _loc6_);
				if (_loc4_ != null && !_loc4_.empty) {
					_loc5_.setTo(-_loc4_.originX / mScale - _loc6_.x, -_loc4_.originY / mScale - _loc6_.y);
				}
			} catch (__finallyError0:Dynamic) {
				{
					_loc12_.dispose();
					if (_loc4_ != null) {
						_loc4_.dispose();
					}
					_loc8_.defaultTextFormat = _loc3_;
					_loc8_.autoSize = _loc2_;
					_loc8_.htmlText = _loc1_;
					restoreBox(_loc8_, _loc10_, _loc9_);
				};
				throw __finallyError0;
			};
			{
				_loc12_.dispose();
				if (_loc4_ != null) {
					_loc4_.dispose();
				}
				_loc8_.defaultTextFormat = _loc3_;
				_loc8_.autoSize = _loc2_;
				_loc8_.htmlText = _loc1_;
				restoreBox(_loc8_, _loc10_, _loc9_);
			};
		}
		sGlyphOrigins[_loc11_] = _loc5_;
		return _loc5_;
	}

	function buildWhiteFont(chars:String):StarlingGlyphFont {
		var __finallyReturn0:StarlingGlyphFont;
		var _loc4_:BitmapFilter = null;
		var _loc7_:ASObject = null;
		var _loc9_ = mArt.model;
		var _loc2_ = _loc9_.htmlText;
		var _loc3_ = _loc9_.textColor;
		var _loc6_ = _loc9_.defaultTextFormat;
		var _loc5_ = _loc9_.filters;
		var _loc11_:Array<ASAny> = [];
		var _loc8_ = _loc9_.length > 0 ? _loc9_.getTextFormat() : _loc9_.defaultTextFormat;
		var _loc12_ = _loc9_.transform.matrix;
		var _loc10_ = _loc9_.getBounds(_loc9_);
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc4_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
				_loc7_ = _loc4_.clone();
				if (_loc7_.hasOwnProperty("color")) {
					ASCompat.setProperty(_loc7_, "color", 16777215);
				}
				_loc11_.push(_loc7_);
			}
		{
			var __finallyReturn0:StarlingGlyphFont;
			try {
				_loc8_.color = 16777215;
				_loc9_.defaultTextFormat = _loc8_;
				_loc9_.setTextFormat(_loc8_);
				_loc9_.textColor = (16777215 : UInt);
				_loc9_.filters = cast(_loc11_);
				{
					__finallyReturn0 = HudArt.buildFont(mPages, "hudStarlingWhite", _loc9_, mScale, chars, 0);
					{
						_loc9_.filters = cast(_loc5_);
						_loc9_.defaultTextFormat = _loc6_;
						_loc9_.textColor = _loc3_;
						_loc9_.htmlText = _loc2_;
						restoreBox(_loc9_, _loc12_, _loc10_);
					};
					return __finallyReturn0;
				};
			} catch (__finallyError1:Dynamic) {
				{
					_loc9_.filters = cast(_loc5_);
					_loc9_.defaultTextFormat = _loc6_;
					_loc9_.textColor = _loc3_;
					_loc9_.htmlText = _loc2_;
					restoreBox(_loc9_, _loc12_, _loc10_);
				};
				throw __finallyError1;
			};
			{
				_loc9_.filters = cast(_loc5_);
				_loc9_.defaultTextFormat = _loc6_;
				_loc9_.textColor = _loc3_;
				_loc9_.htmlText = _loc2_;
				restoreBox(_loc9_, _loc12_, _loc10_);
			};
		}
		return null;
	}

	function covers(text:String):Bool {
		var _loc3_ = 0;
		var _loc2_ = 0;
		if (!mFontAvailable || mFull == null || !mFull.alive) {
			return false;
		}
		_loc3_ = 0;
		while (_loc3_ < text.length) {
			_loc2_ = text.charCodeAt(_loc3_);
			if (_loc2_ != 32 && !mFull.hasGlyph(_loc2_)) {
				return false;
			}
			_loc3_++;
		}
		return true;
	}

	@:allow(uI.hud.starlingConverted) function setContent(value:String, mode:String) {
		if (mode != mMode) {
			mMode = mode;
			mText = null;
		}
		setFittedText(value, 1);
	}

	public function setText(value:String) {
		if (mDisposed) {
			return;
		}
		if (value == null) {
			value = "";
		}
		if (value == mText) {
			return;
		}
		mText = value;
		renderSafely();
		if (contentBoundsChanged != null) {
			contentBoundsChanged();
		}
	}

	@:allow(uI.hud.starlingConverted) function setFittedText(value:String, sizeModifier:Float, shrinkModifier:Float = null) {
		if (shrinkModifier == null)
			shrinkModifier = Math.NaN;
		var _loc4_:TextField = null;
		if (mDisposed) {
			return;
		}
		if (value == null) {
			value = "";
		}
		if (value == mText) {
			return;
		}
		if (mFitModel == null) {
			_loc4_ = mArt.model;
			mFitModel = FlashBaker.textCopy(_loc4_);
			mFitModel.autoSize = _loc4_.autoSize;
			mFitModel.multiline = _loc4_.multiline;
			mFitModel.wordWrap = _loc4_.wordWrap;
			restoreBox(mFitModel, _loc4_.transform.matrix, mBox);
		}
		TextUtil.setText(mFitModel, value, sizeModifier);
		if (shrinkModifier > 0) {
			TextUtil.fitToField(mFitModel, shrinkModifier);
		}
		mFittedFormat = mFitModel.getTextFormat();
		setText(value);
	}

	function renderText() {
		mNeedsBake = false;
		if (mFilterAncestors == null && mMode == "glyphs" && (!mFontAvailable || mFull == null || !mFull.alive)) {
			throw new Error("HUD numeric font unavailable: " + mArt.key);
		}
		var _loc1_ = mFilterAncestors == null && mText.length > 0 && mMode != "baked" && !mArt.model.wordWrap && !mArt.model.multiline && covers(mText);
		if (mFullText != null) {
			mFullText.visible = _loc1_;
			if (mFillText != null) {
				mFillText.visible = _loc1_;
			}
		}
		mImage.visible = !_loc1_ && mText.length > 0;
		if (mCell != null) {
			mPages.release(mCell);
			mCell = null;
		}
		mImage.cell = null;
		if (mWhiteText != null) {
			mWhiteText.visible = false;
		}
		if (_loc1_) {
			fitGlyphs(mFittedFormat != null ? ASCompat.toNumber(mFittedFormat.size) : mFontSize);
			mFullText.setText(mText);
			if (mFillText != null) {
				mFillText.setText(mText);
			}
			if (mWhiteText != null) {
				mWhiteText.setText(mText);
			}
		} else if (mText.length > 0) {
			clearGlyphs();
			if (mFilterAncestors != null) {
				bakeFilterVariants();
			} else {
				bakeString();
			}
		} else {
			clearGlyphs();
		}
		refresh();
	}

	function renderSafely() {
		try {
			renderText();
		} catch (error:Dynamic) {
			releaseFilterVariants();
			if (mCell != null) {
				mPages.release(mCell);
			}
			mCell = null;
			mImage.cell = null;
			mImage.visible = false;
			if (mFullText != null) {
				mFullText.visible = false;
			}
			if (mFillText != null) {
				mFillText.visible = false;
			}
			if (mWhiteText != null) {
				mWhiteText.visible = false;
			}
			if (Std.isOfType(error, HudFatalError) || !HudArt.ready) {
				throw error;
			}
			StarlingHud.reportError(error);
			if (mTicker != null && (Starling.current == null || !Starling.current.contextValid)) {
				mTicker.deferBake(mContextRetry);
			}
		}
	}

	function retryAfterContext():Bool {
		if (Starling.current == null || !Starling.current.contextValid) {
			return false;
		}
		renderSafely();
		return true;
	}

	@:allow(uI.hud.starlingConverted)
	override function prepareTextFilters() {
		var __ax4_iter_216:Vector<Array<ASAny>>;
		var _loc3_:Array<ASAny> = null;
		var _loc2_ = ASCompat.reinterpretAs(parent, ArtDisplay);
		var _loc4_ = new Vector<ArtDisplay>((0 : UInt));
		var _loc1_ = false;
		while (_loc2_ != null) {
			_loc4_.push(_loc2_);
			__ax4_iter_216 = _loc2_.art.filterStates;
			if (checkNullIteratee(__ax4_iter_216))
				for (_tmp_ in __ax4_iter_216) {
					_loc3_ = _tmp_;
					if (_loc3_.length > 0) {
						_loc1_ = true;
					}
				}
			if (Std.isOfType(_loc2_, StatesView)) {
				break;
			}
			_loc2_ = ASCompat.reinterpretAs(_loc2_.parent, ArtDisplay);
		}
		if (!_loc1_) {
			return;
		}
		mFilterAncestors = _loc4_;
		mMode = "baked";
		renderSafely();
	}

	function releaseFilterVariants() {
		var _loc1_:BakedCell = null;
		final __ax4_iter_217 = mFilterCells;
		if (checkNullIteratee(__ax4_iter_217))
			for (_tmp_ in __ax4_iter_217) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					mPages.release(_loc1_);
				}
			}
		mFilterCells.length = 0;
		mFilterPlacements.length = 0;
	}

	function bakeFilterVariants() {
		var _loc1_:ArtDisplay = null;
		var _loc3_ = 0;
		releaseFilterVariants();
		var _loc2_ = 1;
		mSingleFilterVariant = false;
		final __ax4_iter_218 = mFilterAncestors;
		if (checkNullIteratee(__ax4_iter_218))
			for (_tmp_ in __ax4_iter_218) {
				_loc1_ = _tmp_;
				_loc2_ = ASCompat.floatToInt(_loc2_ * Math.max(1, _loc1_.art.filterStates.length));
				if (_loc2_ > 16) {
					_loc2_ = 1;
					mSingleFilterVariant = true;
					break;
				}
			}
		{
			try {
				_loc3_ = 0;
				while (_loc3_ < _loc2_) {
					mBakingVariant = _loc3_;
					bakeString();
					mFilterCells.push(mPages.acquire(mCell.key));
					mFilterPlacements.push(mImage.transformationMatrix.clone());
					mPages.release(mCell);
					mCell = null;
					_loc3_++;
				}
			} catch (__finallyError0:Dynamic) {
				{
					mBakingVariant = -1;
				};
				throw __finallyError0;
			};
			{
				mBakingVariant = -1;
			};
		}
		refreshTextFilters();
	}

	@:allow(uI.hud.starlingConverted)
	override function refreshTextFilters() {
		var _loc1_:ArtDisplay = null;
		if (mFilterAncestors == null || mFilterCells.length == 0) {
			return;
		}
		var _loc2_ = 0;
		var _loc3_ = 1;
		final __ax4_iter_219 = mFilterAncestors;
		if (checkNullIteratee(__ax4_iter_219))
			for (_tmp_ in __ax4_iter_219) {
				_loc1_ = _tmp_;
				_loc2_ += _loc3_ * _loc1_.filterIndex;
				_loc3_ *= _loc1_.art.filterStates.length;
			}
		if (mSingleFilterVariant) {
			_loc2_ = 0;
		}
		if (_loc2_ < 0 || _loc2_ >= mFilterCells.length || _loc2_ >= mFilterPlacements.length) {
			mImage.cell = null;
			mImage.visible = false;
			return;
		}
		mImage.cell = mFilterCells[_loc2_];
		mImage.visible = mImage.cell != null;
		mImage.transformationMatrix = mFilterPlacements[_loc2_];
	}

	function clearGlyphs() {
		if (mFullText != null) {
			mFullText.setText(null);
		}
		if (mFillText != null) {
			mFillText.setText(null);
		}
		if (mWhiteText != null) {
			mWhiteText.setText(null);
		}
	}

	function fitGlyphs(size:Float) {
		var _loc5_ = mFontSize > 0 && size > 0 ? size / mFontSize : 1;
		var _loc2_ = mArt.alignment == "right" ? mBox.right : (mArt.alignment == "center" ? mBox.x + mBox.width * 0.5 : mBox.x);
		var _loc3_ = _loc2_ + (mGlyphX - _loc2_) * _loc5_;
		var _loc4_ = mBox.y + (mGlyphY - mBox.y) * _loc5_;
		mFullText.scaleX = mFullText.scaleY = _loc5_;
		mFullText.x = _loc3_;
		mFullText.y = _loc4_;
		if (mFillText != null) {
			mFillText.scaleX = mFillText.scaleY = _loc5_;
			mFillText.x = _loc3_;
			mFillText.y = _loc4_;
		}
		if (mWhiteText != null) {
			mWhiteText.scaleX = mWhiteText.scaleY = _loc5_;
			mWhiteText.x = _loc3_;
			mWhiteText.y = _loc4_;
		}
	}

	function bakeString() {
		var _loc8_:String = null;
		var _loc9_ = (0 : UInt);
		var _loc3_:TextFormat = null;
		var _loc1_:Array<ASAny> = null;
		var _loc4_:TextFormat = null;
		var _loc7_:Matrix = null;
		var _loc6_:Rectangle = null;
		var _loc15_:Matrix = null;
		var _loc2_:Matrix = null;
		var _loc10_:BakedPicture = null;
		var _loc5_:Error = null;
		var _loc14_ = mArt.model;
		var _loc11_ = mFittedFormat ?? (_loc14_.length > 0 ? _loc14_.getTextFormat() : _loc14_.defaultTextFormat);
		var _loc16_ = mArt.key + "|text|" + mColor + "|" + mText + "|" + Std.string(_loc11_.size) + "|" + _loc11_.align + "|" + BakedPages.scaleKey(mScale)
			+ "|" + _loc14_.multiline + "|" + _loc14_.wordWrap + "|" + _loc14_.autoSize + "|" + mBox.x + "|" + mBox.y + "|" + mBox.width + "|" + mBox.height
			+ (mGrayscale ? "|gray" : "");
		if (mBakingVariant >= 0) {
			_loc16_ += "|ancestorFilters|" + mBakingVariant;
		}
		var _loc12_ = HudArt.content(_loc16_, mPages);
		var _loc13_ = ASCompat.coerce(_loc12_ != null ? _loc12_.cell : null, brain.starling.swfConverter.BakedCell);
		var _loc17_ = _loc13_ != null && _loc13_.alive;
		if (_loc13_ == null || !_loc13_.alive) {
			_loc8_ = _loc14_.htmlText;
			_loc9_ = _loc14_.textColor;
			_loc3_ = _loc14_.defaultTextFormat;
			_loc1_ = _loc14_.filters;
			_loc4_ = mFittedFormat ?? (_loc14_.length > 0 ? _loc14_.getTextFormat() : _loc3_);
			_loc7_ = _loc14_.transform.matrix;
			_loc6_ = _loc14_.getBounds(_loc14_);
			{
				try {
					_loc14_.defaultTextFormat = _loc4_;
					restoreBox(_loc14_, _loc7_, mBox);
					_loc14_.text = mText;
					_loc14_.textColor = mColor;
					if (mGrayscale) {
						_loc14_.filters = cast(_loc1_.concat((cast [HudArtConverter.grayscaleFilter()])));
					}
					_loc15_ = _loc14_.transform.matrix;
					_loc2_ = _loc7_.clone();
					_loc2_.invert();
					_loc15_.concat(_loc2_);
					try {
						if (mBakingVariant >= 0) {
							_loc10_ = TextFilterBake.bake(_loc14_, mFilterAncestors, mBakingVariant, mScale, _loc15_);
							_loc13_ = ASCompat.coerce(_loc10_ != null ? mPages.add(_loc16_, _loc10_, true) : null, brain.starling.swfConverter.BakedCell);
						} else {
							_loc13_ = HudArt.bakeOn(mPages, _loc16_, _loc14_, mScale, false);
						}
					} catch (error:Dynamic) {
						StarlingHud.reportError(error);
						_loc13_ = null;
					}
				} catch (__finallyError0:Dynamic) {
					{
						_loc14_.filters = cast(_loc1_);
						_loc14_.defaultTextFormat = _loc3_;
						_loc14_.textColor = _loc9_;
						_loc14_.htmlText = _loc8_;
						restoreBox(_loc14_, _loc7_, _loc6_);
					};
					throw __finallyError0;
				};
				{
					_loc14_.filters = cast(_loc1_);
					_loc14_.defaultTextFormat = _loc3_;
					_loc14_.textColor = _loc9_;
					_loc14_.htmlText = _loc8_;
					restoreBox(_loc14_, _loc7_, _loc6_);
				};
			}
			if (_loc13_ != null) {
				_loc12_ = new ArtNode();
				_loc12_.cell = _loc12_.hold(_loc13_, mPages);
				_loc12_.matrix = _loc15_;
				HudArt.storeContent(_loc16_, _loc12_, mPages);
			}
		}
		mCell = ASCompat.coerce(_loc13_ != null ? mPages.acquire(_loc16_) : null, brain.starling.swfConverter.BakedCell);
		mImage.cell = mCell;
		mImage.visible = mCell != null;
		mNeedsBake = mCell == null;
		if (mNeedsBake) {
			_loc5_ = new Error("HUD text rasterisation refused: " + mArt.key);
			throw _loc5_;
		}
		if (mCell != null) {
			mImageMatrix.copyFrom(_loc12_.matrix);
			mImageMatrix.tx -= mImageMatrix.a * mCell.pivotX + mImageMatrix.c * mCell.pivotY;
			mImageMatrix.ty -= mImageMatrix.b * mCell.pivotX + mImageMatrix.d * mCell.pivotY;
			mImage.transformationMatrix = mImageMatrix;
		}
	}

	override function applyContentColor(red:Float, green:Float, blue:Float, offsetRed:Float, offsetGreen:Float, offsetBlue:Float) {
		var _loc7_ = Math.NaN;
		var _loc8_ = ArtDisplay.rgb(((mColor : Int) >> 16 & 0xFF) / 255 * red, ((mColor : Int) >> 8 & 0xFF) / 255 * green,
			((mColor : Int) & 0xFF) / 255 * blue);
		if (mFillText != null) {
			mFillText.color = _loc8_;
		}
		if (mFullText != null) {
			mFullText.color = mArt.model.filters.length > 0 ? ArtDisplay.rgb(red, green, blue) : _loc8_;
		}
		if (mWhiteText != null) {
			_loc7_ = Math.max(0, Math.max(Math.max(offsetRed, offsetGreen), offsetBlue));
			mWhiteText.visible = mFullText.visible && _loc7_ > 0;
			mWhiteText.alpha = Math.min(1, _loc7_ / 255);
			mWhiteText.color = _loc7_ > 0 ? ArtDisplay.rgb(offsetRed / _loc7_, offsetGreen / _loc7_, offsetBlue / _loc7_) : (16777215 : UInt);
		}
	}

	@:isVar public var text(get, set):String;

	public function get_text():String {
		return mText;
	}

	function set_text(value:String):String {
		setText(value);
		return value;
	}

	@:isVar public var color(get, set):UInt;

	public function get_color():UInt {
		return mColor;
	}

	function set_color(value:UInt):UInt {
		if (value == mColor) {
			return value;
		}
		mColor = value;
		refresh();
		if (mImage.visible || mNeedsBake) {
			renderSafely();
		}
		return value;
	}

	@:isVar public var mode(get, set):String;

	public function get_mode():String {
		return mMode;
	}

	override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle {
		if (mFullText != null && mFullText.visible) {
			return mFullText.getBounds(targetSpace, resultRect);
		}
		if (mImage != null && mImage.visible && mImage.cell != null && !mImage.cell.isEmpty) {
			return mImage.getBounds(targetSpace, resultRect);
		}
		if (resultRect == null) {
			resultRect = new Rectangle();
		}
		getTransformationMatrix(targetSpace, mBoundsMatrix);
		resultRect.setTo(mBoundsMatrix.tx, mBoundsMatrix.ty, 0, 0);
		return resultRect;
	}

	function set_mode(value:String):String {
		if (value == mMode) {
			return value;
		}
		mMode = value;
		renderSafely();
		return value;
	}

	@:allow(uI.hud.starlingConverted)
	override function setGrayscale(value:Bool):Bool {
		if (value == mGrayscale) {
			return true;
		}
		var _loc4_ = mArt.model.filters;
		var _loc2_ = mColor;
		var _loc3_ = (ASCompat.floatToInt(((_loc2_ : Int) >> 16 & 0xFF) * 0.3086 + ((_loc2_ : Int) >> 8 & 0xFF) * 0.6094 +
			((_loc2_ : Int) & 0xFF) * 0.082) : UInt);
		{
			try {
				if (value) {
					mArt.model.filters = cast(_loc4_.concat((cast [HudArtConverter.grayscaleFilter()])));
					mColor = ((_loc3_ : Int) << 16 | (_loc3_ : Int) << 8 | (_loc3_ : Int) : UInt);
				} else {
					mColor = mArt.model.textColor;
				}
				mFontAvailable = buildFont("0123456789+-x.,%/:", value);
				mGrayscale = value;
			} catch (__finallyError0:Dynamic) {
				{
					mArt.model.filters = cast(_loc4_);
				};
				throw __finallyError0;
			};
			{
				mArt.model.filters = cast(_loc4_);
			};
		}
		renderSafely();
		return true;
	}

	override public function dispose() {
		var _loc1_:ASAny = null;
		if (mDisposed) {
			return;
		}
		mDisposed = true;
		if (mTicker != null) {
			mTicker.cancelBake(mContextRetry);
		}
		mTicker = null;
		mContextRetry = null;
		if (mCell != null) {
			mPages.release(mCell);
		}
		releaseFilterVariants();
		if (mFull != null) {
			mFull.release();
		}
		if (mFill != null) {
			mFill.release();
		}
		if (mWhiteFont != null) {
			mWhiteFont.release();
		}
		super.dispose();
	}
}
