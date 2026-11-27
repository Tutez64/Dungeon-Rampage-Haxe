package box2D.collision;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;

class B2DistanceProxy {
	public var m_vertices:Array<ASAny>;

	public var m_radius:Float = Math.NaN;

	public var m_count:Int = 0;

	public function new() {
		m_radius = 0;
		m_count = 0;
		m_vertices = [];
	}

	public function set(shape:B2Shape) {
		Set(shape);
	}

	public function getVertexCount():Int {
		return GetVertexCount();
	}

	public function getVertex(index:Int):B2Vec2 {
		return GetVertex(index);
	}

	public function getSupportVertex(d:B2Vec2):B2Vec2 {
		return GetSupportVertex(d);
	}

	public function getSupport(d:B2Vec2):Float {
		return GetSupport(d);
	}

	public function Set(shape:B2Shape) {
		var _loc2_ = ASCompat.dynamicAs(null, B2CircleShape);
		var _loc3_ = ASCompat.dynamicAs(null, B2PolygonShape);
		switch (shape.getType()) {
			case 1:
				_loc2_ = cast(shape, B2CircleShape);
				m_vertices = [];
				m_vertices[0] = _loc2_.m_p;
				m_count = 1;
				m_radius = ASCompat.toNumberField(_loc2_, "m_radius");

			case 2:
				_loc3_ = cast(shape, B2PolygonShape);
				m_vertices = ASCompat.coerce(_loc3_.m_vertices, Array);
				m_count = ASCompat.toInt(_loc3_.m_vertexCount);
				m_radius = ASCompat.toNumberField(_loc3_, "m_radius");

			default:
				B2Settings.b2Assert(false);
		}
	}

	public function GetVertexCount():Int {
		return m_count;
	}

	public function GetVertex(index:Int):B2Vec2 {
		B2Settings.b2Assert(0 <= index && index < m_count);
		return ASCompat.coerce(m_vertices[index], box2D.common.math.B2Vec2);
	}

	public function GetSupportVertex(d:B2Vec2):B2Vec2 {
		var _loc6_ = 0;
		var _loc7_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = ASCompat.toNumberField(m_vertices[0], "x") * d.x + ASCompat.toNumberField(m_vertices[0], "y") * d.y;
		var _loc4_ = 1;
		var _loc5_ = m_count;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = ASCompat.toNumberField(m_vertices[_loc6_], "x") * d.x + ASCompat.toNumberField(m_vertices[_loc6_], "y") * d.y;
			if (_loc7_ > _loc3_) {
				_loc2_ = _loc6_;
				_loc3_ = _loc7_;
			}
		}
		return ASCompat.coerce(m_vertices[_loc2_], box2D.common.math.B2Vec2);
	}

	public function GetSupport(d:B2Vec2):Float {
		var _loc6_ = 0;
		var _loc7_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = ASCompat.toNumberField(m_vertices[0], "x") * d.x + ASCompat.toNumberField(m_vertices[0], "y") * d.y;
		var _loc4_ = 1;
		var _loc5_ = m_count;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = ASCompat.toNumberField(m_vertices[_loc6_], "x") * d.x + ASCompat.toNumberField(m_vertices[_loc6_], "y") * d.y;
			if (_loc7_ > _loc3_) {
				_loc2_ = _loc6_;
				_loc3_ = _loc7_;
			}
		}
		return _loc2_;
	}
}
