package starling.extensions.animate;

import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Pool;
import flash.errors.ArgumentError;

class MultiTextureAtlas extends TextureAtlas {
	static inline final UNNAMED_SHEET = "";

	var _textures:Vector<Texture>;

	var _regions:ASDictionary<ASAny, ASAny>;

	var _regionNames:Vector<String>;

	var _sheets:ASDictionary<ASAny, ASAny>;

	public var declaredSheets:Int = 0;

	public function new(texture:Texture = null, data:ASAny = null) {
		super(texture, null);
		_textures = new Vector<Texture>((0 : UInt));
		_regions = new ASDictionary<ASAny, ASAny>();
		_sheets = new ASDictionary<ASAny, ASAny>();
		if (texture != null) {
			addTexture(texture);
		}
		if (ASCompat.toBool(data)) {
			parseAtlasData(data);
		}
	}

	public function addTexture(texture:Texture) {
		if (texture == null) {
			throw new ArgumentError("texture must not be null");
		}
		if (_textures.indexOf(texture) == -1) {
			_textures[_textures.length] = texture;
		}
	}

	public function addSheet(name:String, texture:Texture, data:ASObject) {
		var _loc4_:ASObject = null;
		var _loc6_:String = null;
		if (texture == null) {
			throw new ArgumentError("texture must not be null");
		}
		if (data == null || data.ATLAS == null || data.ATLAS.SPRITES == null) {
			throw new ArgumentError("data is not texture atlas json");
		}
		removeSheet(name);
		addTexture(texture);
		var _loc5_ = new Vector<String>((0 : UInt));
		var _loc7_ = Pool.getRectangle();
		var _loc8_:ASObject;
		final __ax4_iter_518:ASAny = data.ATLAS.SPRITES;
		if (checkNullIteratee(__ax4_iter_518))
			for (_tmp_ in __ax4_iter_518) {
				_loc8_ = _tmp_;
				_loc4_ = _loc8_.SPRITE;
				_loc6_ = _loc4_.name;
				_loc7_.setTo(ASCompat.toNumberField(_loc4_, "x"), ASCompat.toNumberField(_loc4_, "y"), ASCompat.toNumberField(_loc4_, "w"),
					ASCompat.toNumberField(_loc4_, "h"));
				addSubTexture(_loc6_, new SubTexture(texture, _loc7_, false, null, ASCompat.toBool(_loc4_.rotated)));
				_loc5_[_loc5_.length] = _loc6_;
			}
		Pool.putRectangle(_loc7_);
		_sheets[name] = {
			"texture": texture,
			"names": _loc5_
		};
	}

	public function removeSheet(name:String) {
		var _loc4_:ASObject = ASDictionary.getString(_sheets, name);
		if (_loc4_ == null) {
			return;
		}
		var _loc2_:String;
		final __ax4_iter_519:ASAny = _loc4_.names;
		if (checkNullIteratee(__ax4_iter_519))
			for (_tmp_ in __ax4_iter_519) {
				_loc2_ = _tmp_;
				removeRegion(_loc2_);
			}
		var _loc3_ = _textures.indexOf(ASCompat.coerce(_loc4_.texture, starling.textures.Texture));
		if (_loc3_ != -1) {
			_textures.removeAt(_loc3_);
		}
		_sheets.remove(name);
	}

	@:isVar public var numTextures(get, never):Int;

	public function get_numTextures():Int {
		return _textures.length;
	}

	public function getTextureAt(index:Int):Texture {
		return _textures[index];
	}

	override function parseAtlasData(data:ASAny) {
		if (Std.isOfType(data, compat.XML.typeReference())) {
			super.parseAtlasData(data);
		} else {
			addSheet("", texture, (data : ASObject));
		}
	}

	override public function addSubTexture(name:String, subTexture:SubTexture) {
		if (!ownsRootOf(subTexture)) {
			throw new ArgumentError("SubTexture\'s root must be one of the atlas textures; register it with addTexture() or addSheet() first.");
		}
		if (ASCompat.dictionaryLookupNeNull(_regions, name)) {}
		_regions[name] = subTexture;
		_regionNames = null;
	}

	override public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Bool = false) {
		if (texture == null) {
			throw new IllegalOperationError("no sheet to add the region to, this atlas was created without a texture");
		}
		addSubTexture(name, new SubTexture(texture, region, false, frame, rotated));
	}

	override public function getTexture(name:String):Texture {
		return ASCompat.coerce(ASDictionary.getString(_regions, name), starling.textures.Texture);
	}

	override public function getNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		var __ax4_iter_520:ASDictionary<ASAny, ASAny>;
		var _loc3_:String = null;
		if (out == null) {
			out = new Vector<String>((0 : UInt));
		}
		if (_regionNames == null) {
			_regionNames = new Vector<String>((0 : UInt));
			__ax4_iter_520 = _regions;
			if (checkNullIteratee(__ax4_iter_520))
				for (_tmp_ in __ax4_iter_520.keys()) {
					_loc3_ = _tmp_;
					_regionNames[_regionNames.length] = _loc3_;
				}
			ASCompat.ASVector.sortWithOptions(_regionNames, 1);
		}
		final __ax4_iter_521 = _regionNames;
		if (checkNullIteratee(__ax4_iter_521))
			for (_tmp_ in __ax4_iter_521) {
				_loc3_ = _tmp_;
				if (_loc3_.indexOf(prefix) == 0) {
					out[out.length] = _loc3_;
				}
			}
		return out;
	}

	override public function getRegion(name:String):Rectangle {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_regions, name), starling.textures.SubTexture);
		return _loc2_ != null ? _loc2_.region : null;
	}

	override public function getFrame(name:String):Rectangle {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_regions, name), starling.textures.SubTexture);
		return _loc2_ != null ? _loc2_.frame : null;
	}

	override public function getRotation(name:String):Bool {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_regions, name), starling.textures.SubTexture);
		return _loc2_ != null ? _loc2_.rotated : false;
	}

	override public function removeRegion(name:String) {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_regions, name), starling.textures.SubTexture);
		if (_loc2_ != null) {
			_loc2_.dispose();
		}
		_regions.remove(name);
		_regionNames = null;
	}

	override public function removeRegions(prefix:String = "") {
		var _loc2_:String;
		final __ax4_iter_522 = _regions;
		if (checkNullIteratee(__ax4_iter_522))
			for (_tmp_ in __ax4_iter_522.keys()) {
				_loc2_ = _tmp_;
				if (prefix == "" || _loc2_.indexOf(prefix) == 0) {
					removeRegion(_loc2_);
				}
			}
	}

	override public function dispose() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < _textures.length) {
			_textures[_loc1_].dispose();
			_loc1_++;
		}
		_textures.length = 0;
	}

	function ownsRootOf(subTexture:SubTexture):Bool {
		var _loc3_ = 0;
		if (subTexture == null) {
			return false;
		}
		var _loc2_:Texture = subTexture.root;
		_loc3_ = 0;
		while (_loc3_ < _textures.length) {
			if (_textures[_loc3_].root == _loc2_) {
				return true;
			}
			_loc3_++;
		}
		return false;
	}
}
