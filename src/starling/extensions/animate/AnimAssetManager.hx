package starling.extensions.animate;

import starling.assets.AssetManager;

class AnimAssetManager extends AssetManager {
	static var sNames:Vector<String> = new Vector((0 : UInt));

	public function new() {
		super();
		registerFactory(new AnimationAtlasFactory(), 10);
	}

	override public function addAsset(name:String, asset:ASObject, type:String = null) {
		if (type == null && Std.isOfType(asset, AnimationAtlas)) {
			type = "animationAtlas";
		}
		super.addAsset(name, asset, type);
	}

	public function getAnimationAtlas(name:String):AnimationAtlas {
		return ASCompat.dynamicAs(getAsset("animationAtlas", name), AnimationAtlas);
	}

	public function getAnimationAtlasNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("animationAtlas", prefix, true, out);
	}

	public function hasAnimation(name:String):Bool {
		var _loc2_:String = null;
		var _loc4_ = getAnimationAtlasNames("", sNames);
		var _loc3_ = _loc4_.indexOf(name) != -1;
		if (!_loc3_) {
			if (checkNullIteratee(_loc4_))
				for (_tmp_ in _loc4_) {
					_loc2_ = _tmp_;
					if (getAnimationAtlas(_loc2_).hasAnimation(name)) {
						_loc3_ = true;
						break;
					}
				}
		}
		if (!_loc3_) {
			if (checkNullIteratee(_loc4_))
				for (_tmp_ in _loc4_) {
					_loc2_ = _tmp_;
					if (getAnimationAtlas(_loc2_).getLabelSymbolName(name) != null) {
						_loc3_ = true;
						break;
					}
				}
		}
		sNames.length = 0;
		return _loc3_;
	}

	public function createAnimation(name:String):Animation {
		var _loc2_:String = null;
		var _loc3_:AnimationAtlas = null;
		var _loc4_:String = null;
		var _loc5_ = getAnimationAtlasNames("", sNames);
		var _loc6_:Animation = null;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc2_ = _tmp_;
				_loc3_ = getAnimationAtlas(_loc2_);
				if (_loc3_.hasAnimation(name)) {
					_loc6_ = _loc3_.createAnimation(name);
					break;
				}
			}
		if (_loc6_ == null) {
			if (checkNullIteratee(_loc5_))
				for (_tmp_ in _loc5_) {
					_loc2_ = _tmp_;
					_loc3_ = getAnimationAtlas(_loc2_);
					_loc4_ = _loc3_.getLabelSymbolName(name);
					if (_loc4_ != null) {
						_loc6_ = _loc3_.createAnimation(_loc4_);
						break;
					}
				}
		}
		if (_loc6_ == null && _loc5_.indexOf(name) != -1) {
			_loc6_ = getAnimationAtlas(name).createAnimation();
		}
		sNames.length = 0;
		return _loc6_;
	}

	public function createAnimationInAtlas(atlasName:String, name:String):Animation {
		var _loc3_ = getAnimationAtlas(atlasName);
		if (_loc3_ == null) {
			return null;
		}
		if (_loc3_.hasAnimation(name)) {
			return _loc3_.createAnimation(name);
		}
		var _loc4_ = _loc3_.getLabelSymbolName(name);
		return _loc4_ != null ? _loc3_.createAnimation(_loc4_) : null;
	}

	public function isPackedAtlas(atlasName:String):Bool {
		var _loc2_ = getAnimationAtlas(atlasName);
		return _loc2_ != null && _loc2_.hasClipLabels;
	}

	override function getNameFromUrl(url:String):String {
		var _loc3_ = super.getNameFromUrl(url);
		var _loc2_ = super.getExtensionFromUrl(url);
		if (AnimationAtlasFactory.isSpritemapName(_loc3_) && (_loc2_ == "png" || _loc2_ == "atf")) {
			return AnimationAtlasFactory.getName(url, _loc3_, true);
		}
		return _loc3_;
	}
}
