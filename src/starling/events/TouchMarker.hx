package starling.events;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Point;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

/*internal*/
class TouchMarker extends Sprite {
	var _center:Point;

	var _texture:Texture;

	public function new() {
		var _loc2_ = 0;
		var _loc1_:Image = null;
		super();
		_center = new Point();
		_texture = createTexture();
		_loc2_ = 0;
		while (_loc2_ < 2) {
			_loc1_ = new Image(_texture);
			_loc1_.pivotX = _texture.width / 2;
			_loc1_.pivotY = _texture.height / 2;
			_loc1_.touchable = false;
			addChild(_loc1_);
			_loc2_++;
		}
	}

	override public function dispose() {
		_texture.dispose();
		super.dispose();
	}

	public function moveMarker(x:Float, y:Float, withCenter:Bool = false) {
		if (withCenter) {
			_center.x += x - realMarker.x;
			_center.y += y - realMarker.y;
		}
		realMarker.x = x;
		realMarker.y = y;
		mockMarker.x = 2 * _center.x - x;
		mockMarker.y = 2 * _center.y - y;
	}

	public function moveCenter(x:Float, y:Float) {
		_center.x = x;
		_center.y = y;
		moveMarker(realX, realY);
	}

	function createTexture():Texture {
		var _loc5_ = Starling.contentScaleFactor;
		var _loc6_ = 12 * _loc5_;
		var _loc4_ = ASCompat.floatToInt(32 * _loc5_);
		var _loc7_ = ASCompat.floatToInt(32 * _loc5_);
		var _loc3_ = 1.5 * _loc5_;
		var _loc2_ = new Shape();
		_loc2_.graphics.lineStyle(_loc3_, (0 : UInt), 0.3);
		_loc2_.graphics.drawCircle(_loc4_ / 2, _loc7_ / 2, _loc6_ + _loc3_);
		_loc2_.graphics.beginFill((16777215 : UInt), 0.4);
		_loc2_.graphics.lineStyle(_loc3_, (16777215 : UInt));
		_loc2_.graphics.drawCircle(_loc4_ / 2, _loc7_ / 2, _loc6_);
		_loc2_.graphics.endFill();
		var _loc1_ = new BitmapData(_loc4_, _loc7_, true, (0 : UInt));
		_loc1_.draw(_loc2_);
		return Texture.fromBitmapData(_loc1_, false, false, _loc5_);
	}

	@:isVar var realMarker(get, never):Image;

	function get_realMarker():Image {
		return ASCompat.reinterpretAs(getChildAt(0), Image);
	}

	@:isVar var mockMarker(get, never):Image;

	function get_mockMarker():Image {
		return ASCompat.reinterpretAs(getChildAt(1), Image);
	}

	@:isVar public var realX(get, never):Float;

	public function get_realX():Float {
		return realMarker.x;
	}

	@:isVar public var realY(get, never):Float;

	public function get_realY():Float {
		return realMarker.y;
	}

	@:isVar public var mockX(get, never):Float;

	public function get_mockX():Float {
		return mockMarker.x;
	}

	@:isVar public var mockY(get, never):Float;

	public function get_mockY():Float {
		return mockMarker.y;
	}
}
