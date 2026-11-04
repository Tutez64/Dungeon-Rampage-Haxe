package uI.hud.starlingConverted;

import starling.display.DisplayObject;

class ArtView {
	var mArt:ArtNode;

	var mRoot:ArtDisplay;

	var mObjects:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new(art:ArtNode, ticker:HudTicker = null) {
		mArt = art;
		mArt.retainView();
		try {
			mRoot = buildDisplay(art, ticker, mObjects);
			mRoot.prepareTextFilters();
		} catch (error:Dynamic) {
			{
				try {
					if (mRoot != null) {
						mRoot.dispose();
					}
				} catch (__finallyError0:Dynamic) {
					{
						mRoot = null;
						mArt.releaseView();
					};
					throw __finallyError0;
				};
				{
					mRoot = null;
					mArt.releaseView();
				};
			}
			throw error;
		}
	}

	public static function build(art:ArtNode, ticker:HudTicker = null):ArtView {
		return new ArtView(art, ticker);
	}

	@:allow(uI.hud.starlingConverted) static function buildDisplay(art:ArtNode, ticker:HudTicker, objects:ASDictionary<ASAny, ASAny>):ArtDisplay {
		var __ax4_iter_160:Vector<ArtNode>;
		var _loc5_:ArtDisplay = null;
		var _loc6_:ArtNode = null;
		var _loc4_:ArtDisplay = null;
		if (art.kind == "text") {
			_loc5_ = new StarlingText(art, art.textPages, art.pixelScale, art.name == "NametagText"
				|| art.name == "AlertText" ? "baked" : "auto", ticker);
		} else if (art.kind == "timeline" || art.kind == "flipbook") {
			_loc5_ = new TimelineView(art, ticker);
		} else if (art.kind == "states") {
			_loc5_ = new StatesView(art);
		} else {
			_loc5_ = new ArtDisplay(art);
		}
		try {
			objects[art] = _loc5_;
			if (art.kind == "static" || art.kind == "flipbook" || art.kind == "states" && art.children.length == 0) {
				_loc5_.buildImages();
			}
			__ax4_iter_160 = art.children;
			if (checkNullIteratee(__ax4_iter_160))
				for (_tmp_ in __ax4_iter_160) {
					_loc6_ = _tmp_;
					_loc4_ = buildDisplay(_loc6_, ticker, objects);
					_loc5_.addArt(_loc4_);
					if (_loc6_.parentClip != null) {
						_loc4_.prepareClip();
					}
				}
			if (Std.isOfType(_loc5_, StatesView)) {
				cast(_loc5_, StatesView).gotoAndStop(0);
			}
			if (Std.isOfType(_loc5_, TimelineView) && art.stageRate) {
				cast(_loc5_, TimelineView).play(0, true);
			}
			_loc5_.refresh();
			return _loc5_;
		} catch (buildError:Dynamic) {
			_loc5_.dispose();
			throw buildError;
		}
		return null;
	}

	@:isVar public var root(get, never):DisplayObject;

	public function get_root():DisplayObject {
		return mRoot;
	}

	public function node(path:String):DisplayObject {
		return ASCompat.dynamicAs(mObjects[mArt.find(path)], DisplayObject);
	}

	public function artNode(path:String):ArtNode {
		return mArt.find(path);
	}

	public function dispose() {
		if (mRoot != null) {
			{
				try {
					mRoot.removeFromParent(true);
				} catch (__finallyError0:Dynamic) {
					{
						mRoot = null;
						mArt.releaseView();
					};
					throw __finallyError0;
				};
				{
					mRoot = null;
					mArt.releaseView();
				};
			}
		}
		mObjects = new ASDictionary<ASAny, ASAny>();
	}
}
