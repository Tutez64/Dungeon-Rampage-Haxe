package starling.textures;

import flash.geom.Point;
import flash.geom.Rectangle;
import starling.display.Image;
import starling.utils.StringUtil;
import flash.errors.ArgumentError;

class TextureAtlas {
	static final NAME_REGEX:compat.RegExp = new compat.RegExp("(.+?)\\d+$");

	static var sNames:Vector<String> = new Vector((0 : UInt));

	var _atlasTexture:Texture;

	var _subTextures:ASDictionary<ASAny, ASAny>;

	var _subTextureNames:Vector<String>;

	public function new(texture:Texture, data:ASAny = null) {
		_subTextures = new ASDictionary<ASAny, ASAny>();
		_atlasTexture = texture;
		if (ASCompat.toBool(data)) {
			parseAtlasData(data);
		}
	}

	public function dispose() {
		_atlasTexture.dispose();
	}

	function parseAtlasData(data:ASAny) {
		if (Std.isOfType(data, compat.XML.typeReference())) {
			parseAtlasXml(ASCompat.asXML(data));
			return;
		}
		throw new ArgumentError("TextureAtlas only supports XML data");
	}

	function parseAtlasXml(atlasXml:compat.XML) {
		var __ax4_iter_96:ASDictionary<ASAny, ASAny>;
		var _loc13_:String = null;
		var _loc14_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc5_ = false;
		var _loc8_:Array<ASAny> = null;
		var _loc20_:String = null;
		var _loc17_:Point = null;
		var _loc3_ = _atlasTexture.scale;
		var _loc19_ = new Rectangle();
		var _loc21_ = new Rectangle();
		var _loc18_ = new ASDictionary<ASAny, ASAny>();
		var _loc12_:compat.XML;
		final __ax4_iter_95 = atlasXml.child("SubTexture");
		if (checkNullIteratee(__ax4_iter_95))
			for (_tmp_ in __ax4_iter_95) {
				_loc12_ = _tmp_;
				_loc13_ = StringUtil.clean(_loc12_.attribute("name"));
				_loc14_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("x")) / _loc3_, 0));
				_loc16_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("y")) / _loc3_, 0));
				_loc15_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("width")) / _loc3_, 0));
				_loc22_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("height")) / _loc3_, 0));
				_loc4_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("frameX")) / _loc3_, 0));
				_loc9_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("frameY")) / _loc3_, 0));
				_loc11_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("frameWidth")) / _loc3_, 0));
				_loc2_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("frameHeight")) / _loc3_, 0));
				_loc7_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("pivotX")) / _loc3_, 0));
				_loc6_ = ASCompat.toNumber(ASCompat.orValue(Std.parseFloat(_loc12_.attribute("pivotY")) / _loc3_, 0));
				_loc5_ = StringUtil.parseBoolean(_loc12_.attribute("rotated"));
				_loc19_.setTo(_loc14_, _loc16_, _loc15_, _loc22_);
				_loc21_.setTo(_loc4_, _loc9_, _loc11_, _loc2_);
				if (_loc11_ > 0 && _loc2_ > 0) {
					addRegion(_loc13_, _loc19_, _loc21_, _loc5_);
				} else {
					addRegion(_loc13_, _loc19_, null, _loc5_);
				}
				if (_loc7_ != 0 || _loc6_ != 0) {
					Image.bindPivotPointToTexture(getTexture(_loc13_), _loc7_, _loc6_);
					_loc18_[_loc13_] = new Point(_loc7_, _loc6_);
				}
			}
		var _loc10_:String;
		if (checkNullIteratee(_loc18_))
			for (_tmp_ in _loc18_.keys()) {
				_loc10_ = _tmp_;
				_loc8_ = (cast NAME_REGEX.match(_loc10_));
				if (_loc8_ != null && _loc8_.length > 0) {
					_loc20_ = _loc8_[1];
					_loc17_ = ASCompat.coerce(ASDictionary.getString(_loc18_, _loc10_), flash.geom.Point);
					__ax4_iter_96 = _subTextures;
					if (checkNullIteratee(__ax4_iter_96))
						for (_tmp_ in __ax4_iter_96.keys()) {
							_loc13_ = _tmp_;
							if (_loc13_.indexOf(_loc20_) == 0 && !_loc18_.exists(_loc13_)) {
								Image.bindPivotPointToTexture(ASCompat.coerce(ASDictionary.getString(_subTextures, _loc13_), starling.textures.Texture),
									_loc17_.x, _loc17_.y);
							}
						}
				}
			}
	}

	public function getTexture(name:String):Texture {
		return ASCompat.coerce(ASDictionary.getString(_subTextures, name), starling.textures.Texture);
	}

	public function getTextures(prefix:String = "", out:Vector<Texture> = null):Vector<Texture> {
		if (out == null) {
			out = new Vector<Texture>((0 : UInt));
		}
		var _loc3_:String;
		final __ax4_iter_97 = getNames(prefix, sNames);
		if (checkNullIteratee(__ax4_iter_97))
			for (_tmp_ in __ax4_iter_97) {
				_loc3_ = _tmp_;
				out[out.length] = getTexture(_loc3_);
			}
		sNames.length = 0;
		return out;
	}

	public function getNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		var __ax4_iter_98:ASDictionary<ASAny, ASAny>;
		var _loc3_:String = null;
		if (out == null) {
			out = new Vector<String>((0 : UInt));
		}
		if (_subTextureNames == null) {
			_subTextureNames = new Vector<String>((0 : UInt));
			__ax4_iter_98 = _subTextures;
			if (checkNullIteratee(__ax4_iter_98))
				for (_tmp_ in __ax4_iter_98.keys()) {
					_loc3_ = _tmp_;
					_subTextureNames[_subTextureNames.length] = _loc3_;
				}
			ASCompat.ASVector.sortWithOptions(_subTextureNames, 1);
		}
		final __ax4_iter_99 = _subTextureNames;
		if (checkNullIteratee(__ax4_iter_99))
			for (_tmp_ in __ax4_iter_99) {
				_loc3_ = _tmp_;
				if (_loc3_.indexOf(prefix) == 0) {
					out[out.length] = _loc3_;
				}
			}
		return out;
	}

	public function getRegion(name:String):Rectangle {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_subTextures, name), starling.textures.SubTexture);
		return _loc2_ != null ? _loc2_.region : null;
	}

	public function getFrame(name:String):Rectangle {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_subTextures, name), starling.textures.SubTexture);
		return _loc2_ != null ? _loc2_.frame : null;
	}

	public function getRotation(name:String):Bool {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_subTextures, name), starling.textures.SubTexture);
		return _loc2_ != null ? _loc2_.rotated : false;
	}

	public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Bool = false) {
		addSubTexture(name, new SubTexture(_atlasTexture, region, false, frame, rotated));
	}

	public function addSubTexture(name:String, subTexture:SubTexture) {
		if (subTexture.root != _atlasTexture.root) {
			throw new ArgumentError("SubTexture\'s root must be atlas texture.");
		}
		_subTextures[name] = subTexture;
		_subTextureNames = null;
	}

	public function removeRegion(name:String) {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(_subTextures, name), starling.textures.SubTexture);
		if (_loc2_ != null) {
			_loc2_.dispose();
		}
		_subTextures.remove(name);
		_subTextureNames = null;
	}

	public function removeRegions(prefix:String = "") {
		var _loc2_:String;
		final __ax4_iter_100 = _subTextures;
		if (checkNullIteratee(__ax4_iter_100))
			for (_tmp_ in __ax4_iter_100.keys()) {
				_loc2_ = _tmp_;
				if (prefix == "" || _loc2_.indexOf(prefix) == 0) {
					removeRegion(_loc2_);
				}
			}
	}

	@:isVar public var texture(get, never):Texture;

	public function get_texture():Texture {
		return _atlasTexture;
	}
}
