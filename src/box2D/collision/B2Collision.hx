package box2D.collision;

import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2Collision {
	public static inline final b2_nullFeature = (255 : UInt);

	static var s_incidentEdge:Vector<ClipVertex> = MakeClipPointVector();

	static var s_clipPoints1:Vector<ClipVertex> = MakeClipPointVector();

	static var s_clipPoints2:Vector<ClipVertex> = MakeClipPointVector();

	static var s_edgeAO:Vector<Int> = new Vector((1 : UInt));

	static var s_edgeBO:Vector<Int> = new Vector((1 : UInt));

	static var s_localTangent:B2Vec2 = new B2Vec2();

	static var s_localNormal:B2Vec2 = new B2Vec2();

	static var s_planePoint:B2Vec2 = new B2Vec2();

	static var s_normal:B2Vec2 = new B2Vec2();

	static var s_tangent:B2Vec2 = new B2Vec2();

	static var s_tangent2:B2Vec2 = new B2Vec2();

	static var s_v11:B2Vec2 = new B2Vec2();

	static var s_v12:B2Vec2 = new B2Vec2();

	static var b2CollidePolyTempVec:B2Vec2 = new B2Vec2();

	public function new() {}

	public static function ClipSegmentToLine(vOut:Vector<ClipVertex>, vIn:Vector<ClipVertex>, normal:B2Vec2, offset:Float):Int {
		var _loc5_:ClipVertex = null;
		var _loc6_ = 0;
		var _loc7_:B2Vec2 = null;
		var _loc9_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_:B2Vec2 = null;
		var _loc13_:ClipVertex = null;
		_loc6_ = 0;
		_loc5_ = vIn[0];
		_loc7_ = _loc5_.v;
		_loc5_ = vIn[1];
		var _loc8_ = _loc5_.v;
		_loc9_ = normal.x * _loc7_.x + normal.y * _loc7_.y - offset;
		var _loc10_ = normal.x * _loc8_.x + normal.y * _loc8_.y - offset;
		if (_loc9_ <= 0) {
			vOut[ASCompat.toInt(_loc6_++)].Set(vIn[0]);
		}
		if (_loc10_ <= 0) {
			vOut[ASCompat.toInt(_loc6_++)].Set(vIn[1]);
		}
		if (_loc9_ * _loc10_ < 0) {
			_loc11_ = _loc9_ / (_loc9_ - _loc10_);
			_loc5_ = vOut[_loc6_];
			_loc12_ = _loc5_.v;
			_loc12_.x = _loc7_.x + _loc11_ * (_loc8_.x - _loc7_.x);
			_loc12_.y = _loc7_.y + _loc11_ * (_loc8_.y - _loc7_.y);
			_loc5_ = vOut[_loc6_];
			if (_loc9_ > 0) {
				_loc13_ = vIn[0];
				_loc5_.id = _loc13_.id;
			} else {
				_loc13_ = vIn[1];
				_loc5_.id = _loc13_.id;
			}
			_loc6_ = ASCompat.toInt(_loc6_) + 1;
		}
		return _loc6_;
	}

	public static function EdgeSeparation(poly1:B2PolygonShape, xf1:B2Transform, edge1:Int, poly2:B2PolygonShape, xf2:B2Transform):Float {
		var _loc11_:B2Mat22 = null;
		var _loc12_:B2Vec2 = null;
		var _loc25_ = Math.NaN;
		var _loc6_ = poly1.m_vertexCount;
		var _loc7_ = poly1.m_vertices;
		var _loc8_ = poly1.m_normals;
		var _loc9_ = poly2.m_vertexCount;
		var _loc10_ = poly2.m_vertices;
		_loc11_ = xf1.R;
		_loc12_ = _loc8_[edge1];
		var _loc13_ = _loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y;
		var _loc14_ = _loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y;
		_loc11_ = xf2.R;
		var _loc15_ = _loc11_.col1.x * _loc13_ + _loc11_.col1.y * _loc14_;
		var _loc16_ = _loc11_.col2.x * _loc13_ + _loc11_.col2.y * _loc14_;
		var _loc17_ = 0;
		var _loc18_:Float = ASCompat.MAX_FLOAT;
		var _loc19_ = 0;
		while (_loc19_ < _loc9_) {
			_loc12_ = _loc10_[_loc19_];
			_loc25_ = _loc12_.x * _loc15_ + _loc12_.y * _loc16_;
			if (_loc25_ < _loc18_) {
				_loc18_ = _loc25_;
				_loc17_ = _loc19_;
			}
			_loc19_ = ASCompat.toInt(_loc19_) + 1;
		}
		_loc12_ = _loc7_[edge1];
		_loc11_ = xf1.R;
		var _loc20_ = xf1.position.x + (_loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y);
		var _loc21_ = xf1.position.y + (_loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y);
		_loc12_ = _loc10_[_loc17_];
		_loc11_ = xf2.R;
		var _loc22_ = xf2.position.x + (_loc11_.col1.x * _loc12_.x + _loc11_.col2.x * _loc12_.y);
		var _loc23_ = xf2.position.y + (_loc11_.col1.y * _loc12_.x + _loc11_.col2.y * _loc12_.y);
		_loc22_ -= _loc20_;
		_loc23_ -= _loc21_;
		return _loc22_ * _loc13_ + _loc23_ * _loc14_;
	}

	public static function FindMaxSeparation(edgeIndex:Vector<Int>, poly1:B2PolygonShape, xf1:B2Transform, poly2:B2PolygonShape, xf2:B2Transform):Float {
		var _loc8_:B2Vec2 = null;
		var _loc9_:B2Mat22 = null;
		var _loc22_ = 0;
		var _loc23_ = Math.NaN;
		var _loc24_ = 0;
		var _loc25_ = Math.NaN;
		var _loc6_ = poly1.m_vertexCount;
		var _loc7_ = poly1.m_normals;
		_loc9_ = xf2.R;
		_loc8_ = poly2.m_centroid;
		var _loc10_ = xf2.position.x + (_loc9_.col1.x * _loc8_.x + _loc9_.col2.x * _loc8_.y);
		var _loc11_ = xf2.position.y + (_loc9_.col1.y * _loc8_.x + _loc9_.col2.y * _loc8_.y);
		_loc9_ = xf1.R;
		_loc8_ = poly1.m_centroid;
		_loc10_ -= xf1.position.x + (_loc9_.col1.x * _loc8_.x + _loc9_.col2.x * _loc8_.y);
		_loc11_ -= xf1.position.y + (_loc9_.col1.y * _loc8_.x + _loc9_.col2.y * _loc8_.y);
		var _loc12_ = _loc10_ * xf1.R.col1.x + _loc11_ * xf1.R.col1.y;
		var _loc13_ = _loc10_ * xf1.R.col2.x + _loc11_ * xf1.R.col2.y;
		var _loc14_ = 0;
		var _loc15_ = -ASCompat.MAX_FLOAT;
		var _loc16_ = 0;
		while (_loc16_ < _loc6_) {
			_loc8_ = _loc7_[_loc16_];
			_loc25_ = _loc8_.x * _loc12_ + _loc8_.y * _loc13_;
			if (_loc25_ > _loc15_) {
				_loc15_ = _loc25_;
				_loc14_ = _loc16_;
			}
			_loc16_ = ASCompat.toInt(_loc16_) + 1;
		}
		var _loc17_ = EdgeSeparation(poly1, xf1, _loc14_, poly2, xf2);
		var _loc18_ = _loc14_ - 1 >= 0 ? _loc14_ - 1 : _loc6_ - 1;
		var _loc19_ = EdgeSeparation(poly1, xf1, _loc18_, poly2, xf2);
		var _loc20_ = _loc14_ + 1 < _loc6_ ? _loc14_ + 1 : 0;
		var _loc21_ = EdgeSeparation(poly1, xf1, _loc20_, poly2, xf2);
		if (_loc19_ > _loc17_ && _loc19_ > _loc21_) {
			_loc24_ = -1;
			_loc22_ = _loc18_;
			_loc23_ = _loc19_;
		} else {
			if (_loc21_ <= _loc17_) {
				edgeIndex[0] = _loc14_;
				return _loc17_;
			}
			_loc24_ = 1;
			_loc22_ = _loc20_;
			_loc23_ = _loc21_;
		}
		while (true) {
			if (_loc24_ == -1) {
				_loc14_ = _loc22_ - 1 >= 0 ? _loc22_ - 1 : _loc6_ - 1;
			} else {
				_loc14_ = _loc22_ + 1 < _loc6_ ? _loc22_ + 1 : 0;
			}
			_loc17_ = EdgeSeparation(poly1, xf1, _loc14_, poly2, xf2);
			if (_loc17_ <= _loc23_) {
				break;
			}
			_loc22_ = _loc14_;
			_loc23_ = _loc17_;
		}
		edgeIndex[0] = _loc22_;
		return _loc23_;
	}

	public static function FindIncidentEdge(c:Vector<ClipVertex>, poly1:B2PolygonShape, xf1:B2Transform, edge1:Int, poly2:B2PolygonShape, xf2:B2Transform) {
		var _loc12_:B2Mat22 = null;
		var _loc13_:B2Vec2 = null;
		var _loc20_:ClipVertex = null;
		var _loc23_ = Math.NaN;
		var _loc7_ = poly1.m_vertexCount;
		var _loc8_ = poly1.m_normals;
		var _loc9_ = poly2.m_vertexCount;
		var _loc10_ = poly2.m_vertices;
		var _loc11_ = poly2.m_normals;
		_loc12_ = xf1.R;
		_loc13_ = _loc8_[edge1];
		var _loc14_ = _loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y;
		var _loc15_ = _loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y;
		_loc12_ = xf2.R;
		var _loc16_ = _loc12_.col1.x * _loc14_ + _loc12_.col1.y * _loc15_;
		_loc15_ = _loc12_.col2.x * _loc14_ + _loc12_.col2.y * _loc15_;
		_loc14_ = _loc16_;
		var _loc17_ = 0;
		var _loc18_:Float = ASCompat.MAX_FLOAT;
		var _loc19_ = 0;
		while (_loc19_ < _loc9_) {
			_loc13_ = _loc11_[_loc19_];
			_loc23_ = _loc14_ * _loc13_.x + _loc15_ * _loc13_.y;
			if (_loc23_ < _loc18_) {
				_loc18_ = _loc23_;
				_loc17_ = _loc19_;
			}
			_loc19_ = ASCompat.toInt(_loc19_) + 1;
		}
		var _loc21_ = _loc17_;
		var _loc22_ = _loc21_ + 1 < _loc9_ ? _loc21_ + 1 : 0;
		_loc20_ = c[0];
		_loc13_ = _loc10_[_loc21_];
		_loc12_ = xf2.R;
		_loc20_.v.x = xf2.position.x + (_loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y);
		_loc20_.v.y = xf2.position.y + (_loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y);
		_loc20_.id.features.referenceEdge = edge1;
		_loc20_.id.features.incidentEdge = _loc21_;
		_loc20_.id.features.incidentVertex = 0;
		_loc20_ = c[1];
		_loc13_ = _loc10_[_loc22_];
		_loc12_ = xf2.R;
		_loc20_.v.x = xf2.position.x + (_loc12_.col1.x * _loc13_.x + _loc12_.col2.x * _loc13_.y);
		_loc20_.v.y = xf2.position.y + (_loc12_.col1.y * _loc13_.x + _loc12_.col2.y * _loc13_.y);
		_loc20_.id.features.referenceEdge = edge1;
		_loc20_.id.features.incidentEdge = _loc22_;
		_loc20_.id.features.incidentVertex = 1;
	}

	static function MakeClipPointVector():Vector<ClipVertex> {
		var _loc1_ = new Vector<ClipVertex>((2 : UInt));
		_loc1_[0] = new ClipVertex();
		_loc1_[1] = new ClipVertex();
		return _loc1_;
	}

	public static function CollidePolygons(manifold:B2Manifold, polyA:B2PolygonShape, xfA:B2Transform, polyB:B2PolygonShape, xfB:B2Transform) {
		var _loc6_:ClipVertex = null;
		var _loc12_:B2PolygonShape = null;
		var _loc13_:B2PolygonShape = null;
		var _loc14_:B2Transform = null;
		var _loc15_:B2Transform = null;
		var _loc16_ = 0;
		var _loc17_ = (0 : UInt);
		var _loc20_:B2Mat22 = null;
		var _loc25_:B2Vec2 = null;
		var _loc39_ = 0;
		var _loc42_ = Math.NaN;
		var _loc43_:B2ManifoldPoint = null;
		var _loc44_ = Math.NaN;
		var _loc45_ = Math.NaN;
		manifold.m_pointCount = 0;
		var _loc7_ = polyA.m_radius + polyB.m_radius;
		var _loc8_ = 0;
		s_edgeAO[0] = _loc8_;
		var _loc9_ = FindMaxSeparation(s_edgeAO, polyA, xfA, polyB, xfB);
		_loc8_ = s_edgeAO[0];
		if (_loc9_ > _loc7_) {
			return;
		}
		var _loc10_ = 0;
		s_edgeBO[0] = _loc10_;
		var _loc11_ = FindMaxSeparation(s_edgeBO, polyB, xfB, polyA, xfA);
		_loc10_ = s_edgeBO[0];
		if (_loc11_ > _loc7_) {
			return;
		}
		var _loc18_:Float = 0.98;
		var _loc19_:Float = 0.001;
		if (_loc11_ > _loc18_ * _loc9_ + _loc19_) {
			_loc12_ = polyB;
			_loc13_ = polyA;
			_loc14_ = xfB;
			_loc15_ = xfA;
			_loc16_ = _loc10_;
			manifold.m_type = B2Manifold.e_faceB;
			_loc17_ = (1 : UInt);
		} else {
			_loc12_ = polyA;
			_loc13_ = polyB;
			_loc14_ = xfA;
			_loc15_ = xfB;
			_loc16_ = _loc8_;
			manifold.m_type = B2Manifold.e_faceA;
			_loc17_ = (0 : UInt);
		}
		var _loc21_ = s_incidentEdge;
		FindIncidentEdge(_loc21_, _loc12_, _loc14_, _loc16_, _loc13_, _loc15_);
		var _loc22_ = _loc12_.m_vertexCount;
		var _loc23_ = _loc12_.m_vertices;
		var _loc24_ = _loc23_[_loc16_];
		if (_loc16_ + 1 < _loc22_) {
			_loc25_ = _loc23_[_loc16_ + 1];
		} else {
			_loc25_ = _loc23_[0];
		}
		var _loc26_ = s_localTangent;
		_loc26_.Set(_loc25_.x - _loc24_.x, _loc25_.y - _loc24_.y);
		_loc26_.Normalize();
		var _loc27_ = s_localNormal;
		_loc27_.x = _loc26_.y;
		_loc27_.y = -_loc26_.x;
		var _loc28_ = s_planePoint;
		_loc28_.Set(0.5 * (_loc24_.x + _loc25_.x), 0.5 * (_loc24_.y + _loc25_.y));
		var _loc29_ = s_tangent;
		_loc20_ = _loc14_.R;
		_loc29_.x = _loc20_.col1.x * _loc26_.x + _loc20_.col2.x * _loc26_.y;
		_loc29_.y = _loc20_.col1.y * _loc26_.x + _loc20_.col2.y * _loc26_.y;
		var _loc30_ = s_tangent2;
		_loc30_.x = -_loc29_.x;
		_loc30_.y = -_loc29_.y;
		var _loc31_ = s_normal;
		_loc31_.x = _loc29_.y;
		_loc31_.y = -_loc29_.x;
		var _loc32_ = s_v11;
		var _loc33_ = s_v12;
		_loc32_.x = _loc14_.position.x + (_loc20_.col1.x * _loc24_.x + _loc20_.col2.x * _loc24_.y);
		_loc32_.y = _loc14_.position.y + (_loc20_.col1.y * _loc24_.x + _loc20_.col2.y * _loc24_.y);
		_loc33_.x = _loc14_.position.x + (_loc20_.col1.x * _loc25_.x + _loc20_.col2.x * _loc25_.y);
		_loc33_.y = _loc14_.position.y + (_loc20_.col1.y * _loc25_.x + _loc20_.col2.y * _loc25_.y);
		var _loc34_ = _loc31_.x * _loc32_.x + _loc31_.y * _loc32_.y;
		var _loc35_ = -_loc29_.x * _loc32_.x - _loc29_.y * _loc32_.y + _loc7_;
		var _loc36_ = _loc29_.x * _loc33_.x + _loc29_.y * _loc33_.y + _loc7_;
		var _loc37_ = s_clipPoints1;
		var _loc38_ = s_clipPoints2;
		_loc39_ = ClipSegmentToLine(_loc37_, _loc21_, _loc30_, _loc35_);
		if (_loc39_ < 2) {
			return;
		}
		_loc39_ = ClipSegmentToLine(_loc38_, _loc37_, _loc29_, _loc36_);
		if (_loc39_ < 2) {
			return;
		}
		manifold.m_localPlaneNormal.SetV(_loc27_);
		manifold.m_localPoint.SetV(_loc28_);
		var _loc40_ = 0;
		var _loc41_ = 0;
		while (_loc41_ < B2Settings.b2_maxManifoldPoints) {
			_loc6_ = _loc38_[_loc41_];
			_loc42_ = _loc31_.x * _loc6_.v.x + _loc31_.y * _loc6_.v.y - _loc34_;
			if (_loc42_ <= _loc7_) {
				_loc43_ = manifold.m_points[_loc40_];
				_loc20_ = _loc15_.R;
				_loc44_ = _loc6_.v.x - _loc15_.position.x;
				_loc45_ = _loc6_.v.y - _loc15_.position.y;
				_loc43_.m_localPoint.x = _loc44_ * _loc20_.col1.x + _loc45_ * _loc20_.col1.y;
				_loc43_.m_localPoint.y = _loc44_ * _loc20_.col2.x + _loc45_ * _loc20_.col2.y;
				_loc43_.m_id.Set(_loc6_.id);
				_loc43_.m_id.features.flip = (_loc17_ : Int);
				_loc40_ = ASCompat.toInt(_loc40_) + 1;
			}
			_loc41_ = ASCompat.toInt(_loc41_) + 1;
		}
		manifold.m_pointCount = _loc40_;
	}

	public static function CollideCircles(manifold:B2Manifold, circle1:B2CircleShape, xf1:B2Transform, circle2:B2CircleShape, xf2:B2Transform) {
		var _loc6_:B2Mat22 = null;
		var _loc7_:B2Vec2 = null;
		manifold.m_pointCount = 0;
		_loc6_ = xf1.R;
		_loc7_ = circle1.m_p;
		var _loc8_ = xf1.position.x + (_loc6_.col1.x * _loc7_.x + _loc6_.col2.x * _loc7_.y);
		var _loc9_ = xf1.position.y + (_loc6_.col1.y * _loc7_.x + _loc6_.col2.y * _loc7_.y);
		_loc6_ = xf2.R;
		_loc7_ = circle2.m_p;
		var _loc10_ = xf2.position.x + (_loc6_.col1.x * _loc7_.x + _loc6_.col2.x * _loc7_.y);
		var _loc11_ = xf2.position.y + (_loc6_.col1.y * _loc7_.x + _loc6_.col2.y * _loc7_.y);
		var _loc12_ = _loc10_ - _loc8_;
		var _loc13_ = _loc11_ - _loc9_;
		var _loc14_ = _loc12_ * _loc12_ + _loc13_ * _loc13_;
		var _loc15_ = circle1.m_radius + circle2.m_radius;
		if (_loc14_ > _loc15_ * _loc15_) {
			return;
		}
		manifold.m_type = B2Manifold.e_circles;
		manifold.m_localPoint.SetV(circle1.m_p);
		manifold.m_localPlaneNormal.SetZero();
		manifold.m_pointCount = 1;
		manifold.m_points[0].m_localPoint.SetV(circle2.m_p);
		manifold.m_points[0].m_id.key = (0 : UInt);
	}

	public static function CollidePolygonAndCircle(manifold:B2Manifold, polygon:B2PolygonShape, xf1:B2Transform, circle:B2CircleShape, xf2:B2Transform) {
		var _loc6_:B2ManifoldPoint = null;
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_:B2Vec2 = null;
		var _loc12_:B2Mat22 = null;
		var _loc17_ = Math.NaN;
		var _loc31_ = Math.NaN;
		var _loc32_ = Math.NaN;
		var _loc33_ = Math.NaN;
		manifold.m_pointCount = 0;
		_loc12_ = xf2.R;
		_loc11_ = circle.m_p;
		var _loc13_ = xf2.position.x + (_loc12_.col1.x * _loc11_.x + _loc12_.col2.x * _loc11_.y);
		var _loc14_ = xf2.position.y + (_loc12_.col1.y * _loc11_.x + _loc12_.col2.y * _loc11_.y);
		_loc7_ = _loc13_ - xf1.position.x;
		_loc8_ = _loc14_ - xf1.position.y;
		_loc12_ = xf1.R;
		var _loc15_ = _loc7_ * _loc12_.col1.x + _loc8_ * _loc12_.col1.y;
		var _loc16_ = _loc7_ * _loc12_.col2.x + _loc8_ * _loc12_.col2.y;
		var _loc18_ = 0;
		var _loc19_ = -ASCompat.MAX_FLOAT;
		var _loc20_ = polygon.m_radius + circle.m_radius;
		var _loc21_ = polygon.m_vertexCount;
		var _loc22_ = polygon.m_vertices;
		var _loc23_ = polygon.m_normals;
		var _loc24_ = 0;
		while (_loc24_ < _loc21_) {
			_loc11_ = _loc22_[_loc24_];
			_loc7_ = _loc15_ - _loc11_.x;
			_loc8_ = _loc16_ - _loc11_.y;
			_loc11_ = _loc23_[_loc24_];
			_loc31_ = _loc11_.x * _loc7_ + _loc11_.y * _loc8_;
			if (_loc31_ > _loc20_) {
				return;
			}
			if (_loc31_ > _loc19_) {
				_loc19_ = _loc31_;
				_loc18_ = _loc24_;
			}
			_loc24_ = ASCompat.toInt(_loc24_) + 1;
		}
		var _loc25_ = _loc18_;
		var _loc26_ = _loc25_ + 1 < _loc21_ ? _loc25_ + 1 : 0;
		var _loc27_ = _loc22_[_loc25_];
		var _loc28_ = _loc22_[_loc26_];
		if (_loc19_ < ASCompat.MIN_FLOAT) {
			manifold.m_pointCount = 1;
			manifold.m_type = B2Manifold.e_faceA;
			manifold.m_localPlaneNormal.SetV(_loc23_[_loc18_]);
			manifold.m_localPoint.x = 0.5 * (_loc27_.x + _loc28_.x);
			manifold.m_localPoint.y = 0.5 * (_loc27_.y + _loc28_.y);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = (0 : UInt);
			return;
		}
		var _loc29_ = (_loc15_ - _loc27_.x) * (_loc28_.x - _loc27_.x) + (_loc16_ - _loc27_.y) * (_loc28_.y - _loc27_.y);
		var _loc30_ = (_loc15_ - _loc28_.x) * (_loc27_.x - _loc28_.x) + (_loc16_ - _loc28_.y) * (_loc27_.y - _loc28_.y);
		if (_loc29_ <= 0) {
			if ((_loc15_ - _loc27_.x) * (_loc15_ - _loc27_.x) + (_loc16_ - _loc27_.y) * (_loc16_ - _loc27_.y) > _loc20_ * _loc20_) {
				return;
			}
			manifold.m_pointCount = 1;
			manifold.m_type = B2Manifold.e_faceA;
			manifold.m_localPlaneNormal.x = _loc15_ - _loc27_.x;
			manifold.m_localPlaneNormal.y = _loc16_ - _loc27_.y;
			manifold.m_localPlaneNormal.Normalize();
			manifold.m_localPoint.SetV(_loc27_);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = (0 : UInt);
		} else if (_loc30_ <= 0) {
			if ((_loc15_ - _loc28_.x) * (_loc15_ - _loc28_.x) + (_loc16_ - _loc28_.y) * (_loc16_ - _loc28_.y) > _loc20_ * _loc20_) {
				return;
			}
			manifold.m_pointCount = 1;
			manifold.m_type = B2Manifold.e_faceA;
			manifold.m_localPlaneNormal.x = _loc15_ - _loc28_.x;
			manifold.m_localPlaneNormal.y = _loc16_ - _loc28_.y;
			manifold.m_localPlaneNormal.Normalize();
			manifold.m_localPoint.SetV(_loc28_);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = (0 : UInt);
		} else {
			_loc32_ = 0.5 * (_loc27_.x + _loc28_.x);
			_loc33_ = 0.5 * (_loc27_.y + _loc28_.y);
			_loc19_ = (_loc15_ - _loc32_) * _loc23_[_loc25_].x + (_loc16_ - _loc33_) * _loc23_[_loc25_].y;
			if (_loc19_ > _loc20_) {
				return;
			}
			manifold.m_pointCount = 1;
			manifold.m_type = B2Manifold.e_faceA;
			manifold.m_localPlaneNormal.x = _loc23_[_loc25_].x;
			manifold.m_localPlaneNormal.y = _loc23_[_loc25_].y;
			manifold.m_localPlaneNormal.Normalize();
			manifold.m_localPoint.Set(_loc32_, _loc33_);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = (0 : UInt);
		}
	}

	public static function TestOverlap(a:B2AABB, b:B2AABB):Bool {
		var _loc3_ = b.lowerBound;
		var _loc4_ = a.upperBound;
		var _loc5_ = _loc3_.x - _loc4_.x;
		var _loc6_ = _loc3_.y - _loc4_.y;
		_loc3_ = a.lowerBound;
		_loc4_ = b.upperBound;
		var _loc7_ = _loc3_.x - _loc4_.x;
		var _loc8_ = _loc3_.y - _loc4_.y;
		if (_loc5_ > 0 || _loc6_ > 0) {
			return false;
		}
		if (_loc7_ > 0 || _loc8_ > 0) {
			return false;
		}
		return true;
	}
}
