package box2D.dynamics;

import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.contacts.*;
import flash.display.Sprite;

/*use*/ /*namespace*/ /*b2internal*/ class B2DebugDraw {
	public static var e_shapeBit:UInt = (1 : UInt);

	public static var e_jointBit:UInt = (2 : UInt);

	public static var e_aabbBit:UInt = (4 : UInt);

	public static var e_pairBit:UInt = (8 : UInt);

	public static var e_centerOfMassBit:UInt = (16 : UInt);

	public static var e_controllerBit:UInt = (32 : UInt);

	var m_drawFlags:UInt = 0;

	/*b2internal*/
	public var m_sprite:Sprite;

	var m_drawScale:Float = 1;

	var m_lineThickness:Float = 1;

	var m_alpha:Float = 1;

	var m_fillAlpha:Float = 1;

	var m_xformScale:Float = 1;

	public function new() {
		this.m_drawFlags = (0 : UInt);
	}

	public function SetFlags(flags:UInt) {
		this.m_drawFlags = flags;
	}

	public function GetFlags():UInt {
		return this.m_drawFlags;
	}

	public function AppendFlags(flags:UInt) {
		this.m_drawFlags = ((this.m_drawFlags | flags:UInt) : UInt);
	}

	public function ClearFlags(flags:UInt) {
		this.m_drawFlags = ((this.m_drawFlags & (~(flags : Int) : UInt):UInt) : UInt);
	}

	public function SetSprite(sprite:Sprite) {
		this.m_sprite = sprite;
	}

	public function GetSprite():Sprite {
		return this.m_sprite;
	}

	public function SetDrawScale(drawScale:Float) {
		this.m_drawScale = drawScale;
	}

	public function GetDrawScale():Float {
		return this.m_drawScale;
	}

	public function SetLineThickness(lineThickness:Float) {
		this.m_lineThickness = lineThickness;
	}

	public function GetLineThickness():Float {
		return this.m_lineThickness;
	}

	public function SetAlpha(alpha:Float) {
		this.m_alpha = alpha;
	}

	public function GetAlpha():Float {
		return this.m_alpha;
	}

	public function SetFillAlpha(alpha:Float) {
		this.m_fillAlpha = alpha;
	}

	public function GetFillAlpha():Float {
		return this.m_fillAlpha;
	}

	public function SetXFormScale(xformScale:Float) {
		this.m_xformScale = xformScale;
	}

	public function GetXFormScale():Float {
		return this.m_xformScale;
	}

	public function DrawPolygon(vertices:Array<ASAny>, vertexCount:Int, color:B2Color) {
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, color.color, this.m_alpha);
		this.m_sprite.graphics.moveTo(ASCompat.toNumber(ASCompat.toNumberField(vertices[0], "x") * this.m_drawScale),
			ASCompat.toNumber(ASCompat.toNumberField(vertices[0], "y") * this.m_drawScale));
		var _loc4_ = 1;
		while (_loc4_ < vertexCount) {
			this.m_sprite.graphics.lineTo(ASCompat.toNumber(ASCompat.toNumberField(vertices[_loc4_], "x") * this.m_drawScale),
				ASCompat.toNumber(ASCompat.toNumberField(vertices[_loc4_], "y") * this.m_drawScale));
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		this.m_sprite.graphics.lineTo(ASCompat.toNumber(ASCompat.toNumberField(vertices[0], "x") * this.m_drawScale),
			ASCompat.toNumber(ASCompat.toNumberField(vertices[0], "y") * this.m_drawScale));
	}

	public function DrawSolidPolygon(vertices:Vector<B2Vec2>, vertexCount:Int, color:B2Color) {
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, color.color, this.m_alpha);
		this.m_sprite.graphics.moveTo(vertices[0].x * this.m_drawScale, vertices[0].y * this.m_drawScale);
		this.m_sprite.graphics.beginFill(color.color, this.m_fillAlpha);
		var _loc4_ = 1;
		while (_loc4_ < vertexCount) {
			this.m_sprite.graphics.lineTo(vertices[_loc4_].x * this.m_drawScale, vertices[_loc4_].y * this.m_drawScale);
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		this.m_sprite.graphics.lineTo(vertices[0].x * this.m_drawScale, vertices[0].y * this.m_drawScale);
		this.m_sprite.graphics.endFill();
	}

	public function DrawCircle(center:B2Vec2, radius:Float, color:B2Color) {
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, color.color, this.m_alpha);
		this.m_sprite.graphics.drawCircle(center.x * this.m_drawScale, center.y * this.m_drawScale, radius * this.m_drawScale);
	}

	public function DrawSolidCircle(center:B2Vec2, radius:Float, axis:B2Vec2, color:B2Color) {
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, color.color, this.m_alpha);
		this.m_sprite.graphics.moveTo(0, 0);
		this.m_sprite.graphics.beginFill(color.color, this.m_fillAlpha);
		this.m_sprite.graphics.drawCircle(center.x * this.m_drawScale, center.y * this.m_drawScale, radius * this.m_drawScale);
		this.m_sprite.graphics.endFill();
		this.m_sprite.graphics.moveTo(center.x * this.m_drawScale, center.y * this.m_drawScale);
		this.m_sprite.graphics.lineTo((center.x + axis.x * radius) * this.m_drawScale, (center.y + axis.y * radius) * this.m_drawScale);
	}

	public function DrawSegment(p1:B2Vec2, p2:B2Vec2, color:B2Color) {
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, color.color, this.m_alpha);
		this.m_sprite.graphics.moveTo(p1.x * this.m_drawScale, p1.y * this.m_drawScale);
		this.m_sprite.graphics.lineTo(p2.x * this.m_drawScale, p2.y * this.m_drawScale);
	}

	public function DrawTransform(xf:B2Transform) {
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, (16711680 : UInt), this.m_alpha);
		this.m_sprite.graphics.moveTo(xf.position.x * this.m_drawScale, xf.position.y * this.m_drawScale);
		this.m_sprite.graphics.lineTo((xf.position.x + this.m_xformScale * xf.R.col1.x) * this.m_drawScale,
			(xf.position.y + this.m_xformScale * xf.R.col1.y) * this.m_drawScale);
		this.m_sprite.graphics.lineStyle(this.m_lineThickness, (65280 : UInt), this.m_alpha);
		this.m_sprite.graphics.moveTo(xf.position.x * this.m_drawScale, xf.position.y * this.m_drawScale);
		this.m_sprite.graphics.lineTo((xf.position.x + this.m_xformScale * xf.R.col2.x) * this.m_drawScale,
			(xf.position.y + this.m_xformScale * xf.R.col2.y) * this.m_drawScale);
	}
}
