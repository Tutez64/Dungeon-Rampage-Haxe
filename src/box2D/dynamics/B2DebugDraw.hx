package box2D.dynamics;

import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Color;
import box2dcompat.As3Array;
import flash.display.Sprite;

class B2DebugDraw {
	public static var e_shapeBit:Int = 1;

	public static var e_jointBit:Int = 2;

	public static var e_aabbBit:Int = 4;

	public static var e_pairBit:Int = 8;

	public static var e_centerOfMassBit:Int = 16;

	public static var e_controllerBit:Int = 32;

	public var m_xformScale:Float = Math.NaN;

	public var m_sprite:Sprite;

	public var m_lineThickness:Float = Math.NaN;

	public var m_fillAlpha:Float = Math.NaN;

	public var m_drawScale:Float = Math.NaN;

	public var m_drawFlags:Int = 0;

	public var m_alpha:Float = Math.NaN;

	public function new() {
		m_drawScale = 1;
		m_lineThickness = 1;
		m_alpha = 1;
		m_fillAlpha = 1;
		m_xformScale = 1;
		m_drawFlags = 0;
	}

	public function setXFormScale(xformScale:Float) {
		SetXFormScale(xformScale);
	}

	public function setSprite(sprite:Sprite) {
		SetSprite(sprite);
	}

	public function setLineThickness(lineThickness:Float) {
		SetLineThickness(lineThickness);
	}

	public function setFlags(flags:Int) {
		SetFlags(flags);
	}

	public function setFillAlpha(alpha:Float) {
		SetFillAlpha(alpha);
	}

	public function setDrawScale(drawScale:Float) {
		SetDrawScale(drawScale);
	}

	public function setAlpha(alpha:Float) {
		SetAlpha(alpha);
	}

	public function getXFormScale():Float {
		return GetXFormScale();
	}

	public function getSprite():Sprite {
		return GetSprite();
	}

	public function getLineThickness():Float {
		return GetLineThickness();
	}

	public function getFlags():Int {
		return GetFlags();
	}

	public function getFillAlpha():Float {
		return GetFillAlpha();
	}

	public function getDrawScale():Float {
		return GetDrawScale();
	}

	public function getAlpha():Float {
		return GetAlpha();
	}

	public function drawTransform(xf:B2Transform) {
		DrawTransform(xf);
	}

	public function drawSolidPolygon(vertices:Array<ASAny>, vertexCount:Int, color:B2Color) {
		var _loc6_ = 0;
		m_sprite.graphics.lineStyle(m_lineThickness, (color.get_color() : UInt), m_alpha);
		m_sprite.graphics.moveTo(ASCompat.toNumberField(vertices[0], "x") * m_drawScale, ASCompat.toNumberField(vertices[0], "y") * m_drawScale);
		m_sprite.graphics.beginFill((color.get_color() : UInt), m_fillAlpha);
		var _loc4_ = 1;
		var _loc5_ = vertexCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			m_sprite.graphics.lineTo(ASCompat.toNumberField(vertices[_loc6_], "x") * m_drawScale, ASCompat.toNumberField(vertices[_loc6_], "y") * m_drawScale);
		}
		m_sprite.graphics.lineTo(ASCompat.toNumberField(vertices[0], "x") * m_drawScale, ASCompat.toNumberField(vertices[0], "y") * m_drawScale);
		m_sprite.graphics.endFill();
	}

	public function drawSolidCircle(center:B2Vec2, radius:Float, axis:B2Vec2, color:B2Color) {
		DrawSolidCircle(center, radius, axis, color);
	}

	public function drawSegment(p1:B2Vec2, p2:B2Vec2, color:B2Color) {
		DrawSegment(p1, p2, color);
	}

	public function drawPolygon(vertices:Array<ASAny>, vertexCount:Int, color:B2Color) {
		var _loc6_ = 0;
		m_sprite.graphics.lineStyle(m_lineThickness, (color.get_color() : UInt), m_alpha);
		m_sprite.graphics.moveTo(ASCompat.toNumberField(vertices[0], "x") * m_drawScale, ASCompat.toNumberField(vertices[0], "y") * m_drawScale);
		var _loc4_ = 1;
		var _loc5_ = vertexCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			m_sprite.graphics.lineTo(ASCompat.toNumberField(vertices[_loc6_], "x") * m_drawScale, ASCompat.toNumberField(vertices[_loc6_], "y") * m_drawScale);
		}
		m_sprite.graphics.lineTo(ASCompat.toNumberField(vertices[0], "x") * m_drawScale, ASCompat.toNumberField(vertices[0], "y") * m_drawScale);
	}

	public function drawCircle(center:B2Vec2, radius:Float, color:B2Color) {
		DrawCircle(center, radius, color);
	}

	public function clearFlags(flags:Int) {
		ClearFlags(flags);
	}

	public function clear() {
		Clear();
	}

	public function appendFlags(flags:Int) {
		AppendFlags(flags);
	}

	public function SetXFormScale(xformScale:Float) {
		m_xformScale = xformScale;
	}

	public function SetSprite(sprite:Sprite) {
		m_sprite = sprite;
	}

	public function SetLineThickness(lineThickness:Float) {
		m_lineThickness = lineThickness;
	}

	public function SetFlags(flags:Int) {
		m_drawFlags = flags;
	}

	public function SetFillAlpha(alpha:Float) {
		m_fillAlpha = alpha;
	}

	public function SetDrawScale(drawScale:Float) {
		m_drawScale = drawScale;
	}

	public function SetAlpha(alpha:Float) {
		m_alpha = alpha;
	}

	public function GetXFormScale():Float {
		return m_xformScale;
	}

	public function GetSprite():Sprite {
		return m_sprite;
	}

	public function GetLineThickness():Float {
		return m_lineThickness;
	}

	public function GetFlags():Int {
		return m_drawFlags;
	}

	public function GetFillAlpha():Float {
		return m_fillAlpha;
	}

	public function GetDrawScale():Float {
		return m_drawScale;
	}

	public function GetAlpha():Float {
		return m_alpha;
	}

	public function DrawTransform(xf:B2Transform) {
		m_sprite.graphics.lineStyle(m_lineThickness, (16711680 : UInt), m_alpha);
		m_sprite.graphics.moveTo(xf.position.x * m_drawScale, xf.position.y * m_drawScale);
		m_sprite.graphics.lineTo((xf.position.x + m_xformScale * xf.R.col1.x) * m_drawScale, (xf.position.y + m_xformScale * xf.R.col1.y) * m_drawScale);
		m_sprite.graphics.lineStyle(m_lineThickness, (65280 : UInt), m_alpha);
		m_sprite.graphics.moveTo(xf.position.x * m_drawScale, xf.position.y * m_drawScale);
		m_sprite.graphics.lineTo((xf.position.x + m_xformScale * xf.R.col2.x) * m_drawScale, (xf.position.y + m_xformScale * xf.R.col2.y) * m_drawScale);
	}

	public function DrawSolidPolygon(vertices:ASAny, vertexCount:Int, color:B2Color) {
		drawSolidPolygon(As3Array.of(vertices), vertexCount, color);
	}

	public function DrawSolidCircle(center:B2Vec2, radius:Float, axis:B2Vec2, color:B2Color) {
		m_sprite.graphics.lineStyle(m_lineThickness, (color.get_color() : UInt), m_alpha);
		m_sprite.graphics.moveTo(0, 0);
		m_sprite.graphics.beginFill((color.get_color() : UInt), m_fillAlpha);
		m_sprite.graphics.drawCircle(center.x * m_drawScale, center.y * m_drawScale, radius * m_drawScale);
		m_sprite.graphics.endFill();
		m_sprite.graphics.moveTo(center.x * m_drawScale, center.y * m_drawScale);
		m_sprite.graphics.lineTo((center.x + axis.x * radius) * m_drawScale, (center.y + axis.y * radius) * m_drawScale);
	}

	public function DrawSegment(p1:B2Vec2, p2:B2Vec2, color:B2Color) {
		m_sprite.graphics.lineStyle(m_lineThickness, (color.get_color() : UInt), m_alpha);
		m_sprite.graphics.moveTo(p1.x * m_drawScale, p1.y * m_drawScale);
		m_sprite.graphics.lineTo(p2.x * m_drawScale, p2.y * m_drawScale);
	}

	public function DrawPolygon(vertices:ASAny, vertexCount:Int, color:B2Color) {
		drawPolygon(As3Array.of(vertices), vertexCount, color);
	}

	public function DrawCircle(center:B2Vec2, radius:Float, color:B2Color) {
		m_sprite.graphics.lineStyle(m_lineThickness, (color.get_color() : UInt), m_alpha);
		m_sprite.graphics.drawCircle(center.x * m_drawScale, center.y * m_drawScale, radius * m_drawScale);
	}

	public function ClearFlags(flags:Int) {
		m_drawFlags = m_drawFlags & ~flags;
	}

	public function Clear() {
		m_sprite.graphics.clear();
	}

	public function AppendFlags(flags:Int) {
		m_drawFlags = m_drawFlags | flags;
	}
}
