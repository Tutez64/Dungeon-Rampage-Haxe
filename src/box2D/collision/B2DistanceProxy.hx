package box2D.collision;

import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2DistanceProxy {
	public var m_vertices:Vector<B2Vec2>;

	public var m_count:Int = 0;

	public var m_radius:Float = Math.NaN;

	public function new() {}

	public function Set(shape:B2Shape) {
		var _loc2_:B2CircleShape = null;
		var _loc3_:B2PolygonShape = null;
		switch (shape.GetType()) {
			case B2Shape.e_circleShape:
				_loc2_ = ASCompat.reinterpretAs(shape, B2CircleShape);
				this.m_vertices = new Vector<B2Vec2>((1 : UInt), true);
				this.m_vertices[0] = _loc2_.m_p;
				this.m_count = 1;
				this.m_radius = _loc2_.m_radius;

			case B2Shape.e_polygonShape:
				_loc3_ = ASCompat.reinterpretAs(shape, B2PolygonShape);
				this.m_vertices = _loc3_.m_vertices;
				this.m_count = _loc3_.m_vertexCount;
				this.m_radius = _loc3_.m_radius;

			default:
				B2Settings.b2Assert(false);
		}
	}

	public function GetSupport(d:B2Vec2):Float {
		var _loc5_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
		var _loc4_ = 1;
		while (_loc4_ < this.m_count) {
			_loc5_ = this.m_vertices[_loc4_].x * d.x + this.m_vertices[_loc4_].y * d.y;
			if (_loc5_ > _loc3_) {
				_loc2_ = _loc4_;
				_loc3_ = _loc5_;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return _loc2_;
	}

	public function GetSupportVertex(d:B2Vec2):B2Vec2 {
		var _loc5_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
		var _loc4_ = 1;
		while (_loc4_ < this.m_count) {
			_loc5_ = this.m_vertices[_loc4_].x * d.x + this.m_vertices[_loc4_].y * d.y;
			if (_loc5_ > _loc3_) {
				_loc2_ = _loc4_;
				_loc3_ = _loc5_;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return this.m_vertices[_loc2_];
	}

	public function GetVertexCount():Int {
		return this.m_count;
	}

	public function GetVertex(index:Int):B2Vec2 {
		B2Settings.b2Assert(0 <= index && index < this.m_count);
		return this.m_vertices[index];
	}
}
