package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;

class StarlingHudIcon {
	var mFacade:DBFacade;

	var mAssets:AssetLoadingComponent;

	var mTicker:HudTicker;

	var mParent:DisplayObjectContainer;

	var mImage:BakedImage;

	var mRetry:ASFunction;

	var mChanged:ASFunction;

	var mDisposed:Bool = false;

	var mGeneration:UInt = 0;

	var mArt:ArtNode;

	var mAbsent:Bool = false;

	public function new(facade:DBFacade, ticker:HudTicker, parent:DisplayObjectContainer, changed:ASFunction) {
		mFacade = facade;
		mAssets = new AssetLoadingComponent(facade);
		mTicker = ticker;
		mParent = parent;
		mChanged = changed;
	}

	public function load(swf:String, name:String, scale:Float = 1, alpha:Float = 1, fit:Float = 0, red:Bool = false, circle:Bool = false) {
		var generation:UInt;
		if (mDisposed) {
			return;
		}
		if (mParent == null) {
			throw new Error("HUD icon mount unavailable: " + name);
		}
		generation = ++mGeneration;
		if (mRetry != null) {
			mTicker.cancelBake(mRetry);
		}
		mRetry = null;
		if (mImage != null) {
			mImage.removeFromParent(true);
		}
		if (mArt != null) {
			mArt.releaseView();
		}
		mArt = null;
		mImage = null;
		mAbsent = false;
		HudArt.loadRuntimeSwf(mAssets, swf, name, function(param1:brain.assetRepository.SwfAsset) {
			var symbol:Dynamic;
			var source:MovieClip;
			var bounds:Rectangle;
			var bakeSource:DisplayObject;
			var holder:Sprite;
			var pixelScale:Float;
			var key:String;
			var masked = false;
			var retry:ASFunction;
			var asset = param1;
			if (mDisposed || generation != mGeneration) {
				return;
			}
			symbol = HudIconBake.symbol(asset, swf, name);
			if (symbol == null) {
				mAbsent = true;
				if (mChanged != null) {
					mChanged();
				}
				return;
			}
			source = ASCompat.dynamicAs(ASCompat.createInstance(symbol, []), MovieClip);
			if (source == null) {
				HudArt.fatal("Required HUD icon is not a MovieClip: " + swf + " " + name);
			}
			HudArtConverter.stopTree(source);
			bounds = source.getBounds(source);
			if (fit > 0) {
				scale = fit / Math.max(source.width, source.height);
			}
			bakeSource = source;
			if (red) {
				source.transform.colorTransform = new ColorTransform(2.5, 0.25, 0.25, 1);
				holder = new Sprite();
				holder.addChild(source);
				bakeSource = holder;
			}
			pixelScale = BakeScale.forDisplay(mParent) * scale;
			key = swf + "|" + name + "|" + scale + "|" + red + "|" + (circle ? "circle|" : "") + BakedPages.scaleKey(pixelScale);
			retry = function():Bool {
				var _loc8_:Bool;
				var _loc1_:ArtNode = null;
				var _loc2_:BakedCell = null;
				try {
					if (mDisposed || generation != mGeneration) {
						return true;
					}
					if (Starling.current == null || !Starling.current.contextValid) {
						return false;
					}
					_loc1_ = HudArt.content(key);
					if (_loc1_ == null) {
						if (circle && !masked) {
							bakeSource = HudIconBake.maskAvatar(bakeSource);
							masked = true;
						}
						_loc2_ = HudArt.bakeContent(key, bakeSource, pixelScale);
						if (_loc2_ == null) {
							return false;
						}
						_loc1_ = new ArtNode();
						_loc1_.cell = _loc1_.hold(_loc2_, HudArt.pages);
						HudArt.storeContent(key, _loc1_);
					}
					mImage = new BakedImage(_loc1_.cell);
					mArt = _loc1_;
					_loc1_.retainView();
					mImage.scaleX = mImage.scaleY = scale;
					mImage.alpha = alpha;
					if (fit > 0) {
						mImage.x = -(bounds.left + bounds.width * 0.5) + 10;
						mImage.y = -(bounds.top + bounds.height * 0.5) + 10;
					}
					mParent.addChild(mImage);
					mRetry = null;
					source = null;
					bakeSource = null;
					if (mChanged != null) {
						mChanged();
					}
					return true;
				} catch (error:Dynamic) {
					StarlingHud.reportError(error);
					_loc8_ = true;
				}
				return _loc8_;
			};
			mRetry = retry;
			if (!ASCompat.toBool(retry()) && !mDisposed && generation == mGeneration) {
				mTicker.deferBake(retry);
			}
		});
	}

	@:isVar public var image(get, never):BakedImage;

	public function get_image():BakedImage {
		return mImage;
	}

	@:isVar public var absent(get, never):Bool;

	public function get_absent():Bool {
		return mAbsent;
	}

	public function dispose() {
		mDisposed = true;
		mGeneration = mGeneration + 1;
		if (mRetry != null) {
			mTicker.cancelBake(mRetry);
		}
		if (mImage != null) {
			mImage.removeFromParent(true);
		}
		if (mArt != null) {
			mArt.releaseView();
		}
		mArt = null;
		mAssets.destroy();
		mParent = null;
		mImage = null;
		mRetry = mChanged = null;
	}
}
