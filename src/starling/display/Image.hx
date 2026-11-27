package starling.display;

import flash.geom.Rectangle;
import starling.textures.Texture;
import starling.utils.MathUtil;
import starling.utils.Padding;
import starling.utils.Pool;
import starling.utils.RectangleUtil;
import starling.display.Image;
import starling.utils.Execute;

class Image extends Quad {
	static var sAutomators:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	static var sPadding:Padding = new Padding();

	static var sBounds:Rectangle = new Rectangle();

	static var sBasCols:Vector<Float> = new Vector((3 : UInt), true);

	static var sBasRows:Vector<Float> = new Vector((3 : UInt), true);

	static var sPosCols:Vector<Float> = new Vector((3 : UInt), true);

	static var sPosRows:Vector<Float> = new Vector((3 : UInt), true);

	static var sTexCols:Vector<Float> = new Vector((3 : UInt), true);

	static var sTexRows:Vector<Float> = new Vector((3 : UInt), true);

	var _scale9Grid:Rectangle;

	var _tileGrid:Rectangle;

	public function new(texture:Texture) {
		super(100, 100);
		this.texture = texture;
		readjustSize();
	}

	public static function automateSetupForTexture(texture:Texture, onAssign:ASFunction, onRelease:ASFunction = null) {
		var _loc4_ = ASCompat.coerce(sAutomators[texture], SetupAutomator);
		if (_loc4_ != null) {
			_loc4_.add(onAssign, onRelease);
		} else {
			sAutomators[texture] = new SetupAutomator(onAssign, onRelease);
		}
	}

	public static function resetSetupForTexture(texture:Texture) {
		sAutomators.remove(texture);
	}

	public static function removeSetupForTexture(texture:Texture, onAssign:ASFunction, onRelease:ASFunction = null) {
		var _loc4_ = ASCompat.coerce(sAutomators[texture], SetupAutomator);
		if (_loc4_ != null) {
			_loc4_.remove(onAssign, onRelease);
		}
	}

	public static function bindScale9GridToTexture(texture:Texture, scale9Grid:Rectangle) {
		automateSetupForTexture(texture, function(param1:Image) {
			param1.scale9Grid = scale9Grid;
		}, function(param1:Image) {
			param1.scale9Grid = null;
		});
	}

	public static function bindPivotPointToTexture(texture:Texture, pivotX:Float, pivotY:Float) {
		automateSetupForTexture(texture, function(param1:Image) {
			param1.pivotX = pivotX;
			param1.pivotY = pivotY;
		}, function(param1:Image) {
			param1.pivotX = param1.pivotY = 0;
		});
	}

	@:isVar public var scale9Grid(get, set):Rectangle;

	public function get_scale9Grid():Rectangle {
		return _scale9Grid;
	}

	function set_scale9Grid(value:Rectangle):Rectangle {
		if (value != null) {
			if (_scale9Grid == null) {
				_scale9Grid = value.clone();
			} else {
				_scale9Grid.copyFrom(value);
			}
			readjustSize();
			_tileGrid = null;
		} else {
			_scale9Grid = null;
		}
		setupVertices();
		return value;
	}

	@:isVar public var tileGrid(get, set):Rectangle;

	public function get_tileGrid():Rectangle {
		return _tileGrid;
	}

	function set_tileGrid(value:Rectangle):Rectangle {
		if (value != null) {
			if (_tileGrid == null) {
				_tileGrid = value.clone();
			} else {
				_tileGrid.copyFrom(value);
			}
			_scale9Grid = null;
		} else {
			_tileGrid = null;
		}
		setupVertices();
		return value;
	}

	override function setupVertices() {
		if (texture != null && _scale9Grid != null) {
			setupScale9Grid();
		} else if (texture != null && _tileGrid != null) {
			setupTileGrid();
		} else {
			super.setupVertices();
		}
	}

	override public function set_scaleX(value:Float):Float {
		super.scaleX = value;
		if (texture != null && (_scale9Grid != null || _tileGrid != null)) {
			setupVertices();
		}
		return value;
	}

	override public function set_scaleY(value:Float):Float {
		super.scaleY = value;
		if (texture != null && (_scale9Grid != null || _tileGrid != null)) {
			setupVertices();
		}
		return value;
	}

	override public function set_texture(value:Texture):Texture {
		if (value != texture) {
			if (texture != null && ASCompat.toBool(sAutomators[texture])) {
				sAutomators[texture].onRelease(this);
			}
			super.texture = value;
			if (value != null && ASCompat.toBool(sAutomators[value])) {
				sAutomators[value].onAssign(this);
			} else if (_scale9Grid != null && value != null) {
				readjustSize();
			}
		}
		return value;
	}

	function setupScale9Grid() {
		var _loc1_ = 0;
		var _loc10_ = 0;
		var _loc18_ = Math.NaN;
		var _loc6_ = 0;
		var _loc3_ = (0 : UInt);
		var _loc17_ = Math.NaN;
		var _loc4_ = this.texture;
		var _loc19_ = _loc4_.frame;
		var _loc9_ = scaleX > 0 ? scaleX : -scaleX;
		var _loc11_ = scaleY > 0 ? scaleY : -scaleY;
		if (_loc9_ == 0 || _loc11_ == 0) {
			return;
		}
		if (MathUtil.isEquivalent(_scale9Grid.width, _loc4_.frameWidth)) {
			_loc11_ /= _loc9_;
		} else if (MathUtil.isEquivalent(_scale9Grid.height, _loc4_.frameHeight)) {
			_loc9_ /= _loc11_;
		}
		var _loc7_ = 1 / _loc9_;
		var _loc13_ = 1 / _loc11_;
		var _loc5_ = this.vertexData;
		var _loc8_ = this.indexData;
		var _loc2_ = _loc5_.numVertices;
		var _loc12_ = Pool.getRectangle();
		var _loc14_ = Pool.getRectangle();
		var _loc15_ = Pool.getRectangle();
		var _loc16_ = Pool.getRectangle();
		_loc12_.copyFrom(_scale9Grid);
		_loc14_.setTo(0, 0, _loc4_.frameWidth, _loc4_.frameHeight);
		if (_loc19_ != null) {
			_loc15_.setTo(-_loc19_.x, -_loc19_.y, _loc4_.width, _loc4_.height);
		} else {
			_loc15_.copyFrom(_loc14_);
		}
		RectangleUtil.intersect(_loc12_, _loc15_, _loc16_);
		sBasCols[0] = sBasCols[2] = 0;
		sBasRows[0] = sBasRows[2] = 0;
		sBasCols[1] = _loc16_.width;
		sBasRows[1] = _loc16_.height;
		if (_loc15_.x < _loc12_.x) {
			sBasCols[0] = _loc12_.x - _loc15_.x;
		}
		if (_loc15_.y < _loc12_.y) {
			sBasRows[0] = _loc12_.y - _loc15_.y;
		}
		if (_loc15_.right > _loc12_.right) {
			sBasCols[2] = _loc15_.right - _loc12_.right;
		}
		if (_loc15_.bottom > _loc12_.bottom) {
			sBasRows[2] = _loc15_.bottom - _loc12_.bottom;
		}
		if (_loc15_.x < _loc12_.x) {
			sPadding.left = _loc15_.x * _loc7_;
		} else {
			sPadding.left = _loc12_.x * _loc7_ + _loc15_.x - _loc12_.x;
		}
		if (_loc15_.right > _loc12_.right) {
			sPadding.right = (_loc14_.width - _loc15_.right) * _loc7_;
		} else {
			sPadding.right = (_loc14_.width - _loc12_.right) * _loc7_ + _loc12_.right - _loc15_.right;
		}
		if (_loc15_.y < _loc12_.y) {
			sPadding.top = _loc15_.y * _loc13_;
		} else {
			sPadding.top = _loc12_.y * _loc13_ + _loc15_.y - _loc12_.y;
		}
		if (_loc15_.bottom > _loc12_.bottom) {
			sPadding.bottom = (_loc14_.height - _loc15_.bottom) * _loc13_;
		} else {
			sPadding.bottom = (_loc14_.height - _loc12_.bottom) * _loc13_ + _loc12_.bottom - _loc15_.bottom;
		}
		sPosCols[0] = sBasCols[0] * _loc7_;
		sPosCols[2] = sBasCols[2] * _loc7_;
		sPosCols[1] = _loc14_.width - sPadding.left - sPadding.right - sPosCols[0] - sPosCols[2];
		sPosRows[0] = sBasRows[0] * _loc13_;
		sPosRows[2] = sBasRows[2] * _loc13_;
		sPosRows[1] = _loc14_.height - sPadding.top - sPadding.bottom - sPosRows[0] - sPosRows[2];
		if (sPosCols[1] <= 0) {
			_loc18_ = _loc14_.width / (_loc14_.width - _loc12_.width) * _loc9_;
			sPadding.left *= _loc18_;
			sPosCols[0] *= _loc18_;
			sPosCols[1] = 0;
			sPosCols[2] *= _loc18_;
		}
		if (sPosRows[1] <= 0) {
			_loc18_ = _loc14_.height / (_loc14_.height - _loc12_.height) * _loc11_;
			sPadding.top *= _loc18_;
			sPosRows[0] *= _loc18_;
			sPosRows[1] = 0;
			sPosRows[2] *= _loc18_;
		}
		sTexCols[0] = sBasCols[0] / _loc15_.width;
		sTexCols[2] = sBasCols[2] / _loc15_.width;
		sTexCols[1] = 1 - sTexCols[0] - sTexCols[2];
		sTexRows[0] = sBasRows[0] / _loc15_.height;
		sTexRows[2] = sBasRows[2] / _loc15_.height;
		sTexRows[1] = 1 - sTexRows[0] - sTexRows[2];
		_loc10_ = setupScale9GridAttributes(sPadding.left, sPadding.top, sPosCols, sPosRows, sTexCols, sTexRows);
		_loc1_ = ASCompat.floatToInt(_loc10_ / 4);
		_loc5_.numVertices = _loc10_;
		_loc8_.numIndices = 0;
		_loc6_ = 0;
		while (_loc6_ < _loc1_) {
			_loc8_.addQuad((_loc6_ * 4 : UInt), (_loc6_ * 4 + 1 : UInt), (_loc6_ * 4 + 2 : UInt), (_loc6_ * 4 + 3 : UInt));
			_loc6_++;
		}
		if (_loc10_ != _loc2_) {
			_loc3_ = (ASCompat.toInt(_loc2_ != 0 ? _loc5_.getColor(0) : 16777215) : UInt);
			_loc17_ = _loc2_ != 0 ? _loc5_.getAlpha(0) : 1;
			_loc5_.colorize("color", _loc3_, _loc17_);
		}
		Pool.putRectangle(_loc14_);
		Pool.putRectangle(_loc15_);
		Pool.putRectangle(_loc12_);
		Pool.putRectangle(_loc16_);
		setRequiresRedraw();
	}

	function setupScale9GridAttributes(startX:Float, startY:Float, posCols:Vector<Float>, posRows:Vector<Float>, texCols:Vector<Float>,
			texRows:Vector<Float>):Int {
		var _loc13_:String = null;
		_loc13_ = "position";
		var _loc21_:String = null;
		_loc21_ = "texCoords";
		var _loc7_ = 0;
		var _loc20_ = 0;
		var _loc12_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc10_ = this.vertexData;
		var _loc9_ = this.texture;
		var _loc14_ = startX;
		var _loc11_ = startY;
		var _loc17_:Float = 0;
		var _loc16_:Float = 0;
		var _loc8_ = 0;
		_loc20_ = 0;
		while (_loc20_ < 3) {
			_loc12_ = posRows[_loc20_];
			_loc18_ = texRows[_loc20_];
			if (_loc12_ > 0) {
				_loc7_ = 0;
				while (_loc7_ < 3) {
					_loc19_ = posCols[_loc7_];
					_loc15_ = texCols[_loc7_];
					if (_loc19_ > 0) {
						_loc10_.setPoint(_loc8_, "position", _loc14_, _loc11_);
						_loc9_.setTexCoords(_loc10_, _loc8_, "texCoords", _loc17_, _loc16_);
						_loc8_++;
						_loc10_.setPoint(_loc8_, "position", _loc14_ + _loc19_, _loc11_);
						_loc9_.setTexCoords(_loc10_, _loc8_, "texCoords", _loc17_ + _loc15_, _loc16_);
						_loc8_++;
						_loc10_.setPoint(_loc8_, "position", _loc14_, _loc11_ + _loc12_);
						_loc9_.setTexCoords(_loc10_, _loc8_, "texCoords", _loc17_, _loc16_ + _loc18_);
						_loc8_++;
						_loc10_.setPoint(_loc8_, "position", _loc14_ + _loc19_, _loc11_ + _loc12_);
						_loc9_.setTexCoords(_loc10_, _loc8_, "texCoords", _loc17_ + _loc15_, _loc16_ + _loc18_);
						_loc8_++;
						_loc14_ += _loc19_;
					}
					_loc17_ += _loc15_;
					_loc7_++;
				}
				_loc11_ += _loc12_;
			}
			_loc14_ = startX;
			_loc17_ = 0;
			_loc16_ += _loc18_;
			_loc20_++;
		}
		return _loc8_;
	}

	function setupTileGrid() {
		var _loc12_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc27_ = Math.NaN;
		var _loc21_ = 0;
		var _loc17_ = this.texture;
		var _loc32_ = _loc17_.frame;
		var _loc20_ = this.vertexData;
		var _loc4_ = this.indexData;
		var _loc28_ = getBounds(this, sBounds);
		var _loc13_ = _loc20_.numVertices;
		var _loc1_ = (ASCompat.toInt(_loc13_ != 0 ? _loc20_.getColor(0) : 16777215) : UInt);
		var _loc9_ = _loc13_ != 0 ? _loc20_.getAlpha(0) : 1;
		var _loc22_ = scaleX > 0 ? 1 / scaleX : -1 / scaleX;
		var _loc8_ = scaleY > 0 ? 1 / scaleY : -1 / scaleY;
		var _loc26_ = _tileGrid.width > 0 ? _tileGrid.width : _loc17_.frameWidth;
		var _loc11_ = _tileGrid.height > 0 ? _tileGrid.height : _loc17_.frameHeight;
		_loc26_ *= _loc22_;
		_loc11_ *= _loc8_;
		var _loc31_ = _loc32_ != null ? -_loc32_.x * (_loc26_ / _loc32_.width) : 0;
		var _loc33_ = _loc32_ != null ? -_loc32_.y * (_loc11_ / _loc32_.height) : 0;
		var _loc23_ = _loc17_.width * (_loc26_ / _loc17_.frameWidth);
		var _loc34_ = _loc17_.height * (_loc11_ / _loc17_.frameHeight);
		var _loc15_ = _tileGrid.x * _loc22_ % _loc26_;
		var _loc14_ = _tileGrid.y * _loc8_ % _loc11_;
		if (_loc15_ < 0) {
			_loc15_ += _loc26_;
		}
		if (_loc14_ < 0) {
			_loc14_ += _loc11_;
		}
		var _loc30_ = _loc15_ + _loc31_;
		var _loc29_ = _loc14_ + _loc33_;
		if (_loc30_ > _loc26_ - _loc23_) {
			_loc30_ -= _loc26_;
		}
		if (_loc29_ > _loc11_ - _loc34_) {
			_loc29_ -= _loc11_;
		}
		var _loc6_ = "position";
		var _loc19_ = "texCoords";
		var _loc5_ = _loc29_;
		var _loc3_ = 0;
		_loc4_.numIndices = 0;
		while (_loc5_ < _loc28_.height) {
			_loc27_ = _loc30_;
			while (_loc27_ < _loc28_.width) {
				_loc4_.addQuad((_loc3_ : UInt), (_loc3_ + 1 : UInt), (_loc3_ + 2 : UInt), (_loc3_ + 3 : UInt));
				_loc18_ = _loc27_ < 0 ? 0 : _loc27_;
				_loc7_ = _loc5_ < 0 ? 0 : _loc5_;
				_loc12_ = _loc27_ + _loc23_ > _loc28_.width ? _loc28_.width : _loc27_ + _loc23_;
				_loc24_ = _loc5_ + _loc34_ > _loc28_.height ? _loc28_.height : _loc5_ + _loc34_;
				_loc20_.setPoint(_loc3_, _loc6_, _loc18_, _loc7_);
				_loc20_.setPoint(_loc3_ + 1, _loc6_, _loc12_, _loc7_);
				_loc20_.setPoint(_loc3_ + 2, _loc6_, _loc18_, _loc24_);
				_loc20_.setPoint(_loc3_ + 3, _loc6_, _loc12_, _loc24_);
				_loc16_ = (_loc18_ - _loc27_) / _loc23_;
				_loc10_ = (_loc7_ - _loc5_) / _loc34_;
				_loc25_ = (_loc12_ - _loc27_) / _loc23_;
				_loc2_ = (_loc24_ - _loc5_) / _loc34_;
				_loc17_.setTexCoords(_loc20_, _loc3_, _loc19_, _loc16_, _loc10_);
				_loc17_.setTexCoords(_loc20_, _loc3_ + 1, _loc19_, _loc25_, _loc10_);
				_loc17_.setTexCoords(_loc20_, _loc3_ + 2, _loc19_, _loc16_, _loc2_);
				_loc17_.setTexCoords(_loc20_, _loc3_ + 3, _loc19_, _loc25_, _loc2_);
				_loc27_ += _loc26_;
				_loc3_ += 4;
			}
			_loc5_ += _loc11_;
		}
		_loc20_.numVertices = _loc3_;
		_loc21_ = _loc13_;
		while (_loc21_ < _loc3_) {
			_loc20_.setColor(_loc21_, "color", _loc1_);
			_loc20_.setAlpha(_loc21_, "color", _loc9_);
			_loc21_++;
		}
		setRequiresRedraw();
	}
}

private class SetupAutomator {
	var _onAssign:Array<ASAny>;

	var _onRelease:Array<ASAny>;

	public function new(onAssign:ASFunction, onRelease:ASFunction) {
		_onAssign = [];
		_onRelease = [];
		add(onAssign, onRelease);
	}

	public function add(onAssign:ASFunction, onRelease:ASFunction) {
		if (onAssign != null && _onAssign.indexOf(onAssign) == -1) {
			_onAssign[_onAssign.length] = onAssign;
		}
		if (onRelease != null && _onRelease.indexOf(onRelease) == -1) {
			_onRelease[_onRelease.length] = onRelease;
		}
	}

	public function remove(onAssign:ASFunction, onRelease:ASFunction) {
		var _loc3_ = 0;
		var _loc4_ = 0;
		if (onAssign != null) {
			_loc3_ = _onAssign.indexOf(onAssign);
			if (_loc3_ != -1) {
				_onAssign.splice(_loc3_, 1);
			}
		}
		if (onRelease != null) {
			_loc4_ = _onRelease.indexOf(onRelease);
			if (_loc4_ != -1) {
				_onRelease.splice(_loc4_, 1);
			}
		}
	}

	public function onAssign(image:Image) {
		var _loc3_ = 0;
		var _loc2_ = _onAssign.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			Execute.execute(ASCompat.coerceFunction(_onAssign[_loc3_]), image);
			_loc3_++;
		}
	}

	public function onRelease(image:Image) {
		var _loc3_ = 0;
		var _loc2_ = _onRelease.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			Execute.execute(ASCompat.coerceFunction(_onRelease[_loc3_]), image);
			_loc3_++;
		}
	}
}
