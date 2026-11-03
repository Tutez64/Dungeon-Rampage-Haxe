package box2D.collision;

import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import flash.Boot;

class B2Simplex {
	public var m_vertices:Array<ASAny>;

	public var m_v3:B2SimplexVertex;

	public var m_v2:B2SimplexVertex;

	public var m_v1:B2SimplexVertex;

	public var m_count:Int = 0;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_count = 0;
		m_v1 = new B2SimplexVertex();
		m_v2 = new B2SimplexVertex();
		m_v3 = new B2SimplexVertex();
		m_vertices = [];
		m_vertices[0] = m_v1;
		m_vertices[1] = m_v2;
		m_vertices[2] = m_v3;
	}

	public function writeCache(cache:B2SimplexCache) {
		WriteCache(cache);
	}

	public function solve3() {
		Solve3();
	}

	public function solve2() {
		Solve2();
	}

	public function readCache(cache:B2SimplexCache, proxyA:B2DistanceProxy, transformA:B2Transform, proxyB:B2DistanceProxy, transformB:B2Transform) {
		ReadCache(cache, proxyA, transformA, proxyB, transformB);
	}

	public function getWitnessPoints(pA:B2Vec2, pB:B2Vec2) {
		GetWitnessPoints(pA, pB);
	}

	public function getSearchDirection():B2Vec2 {
		return GetSearchDirection();
	}

	public function getMetric():Float {
		return GetMetric();
	}

	public function getClosestPoint():B2Vec2 {
		return GetClosestPoint();
	}

	public function WriteCache(cache:B2SimplexCache) {
		var _loc5_ = 0;
		cache.metric = getMetric();
		cache.count = m_count;
		var _loc2_ = m_vertices;
		var _loc3_ = 0;
		var _loc4_ = m_count;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			cache.indexA[_loc5_] = ASCompat.toInt(_loc2_[_loc5_].indexA);
			cache.indexB[_loc5_] = ASCompat.toInt(_loc2_[_loc5_].indexB);
		}
	}

	public function Solve3() {
		var _loc23_ = Math.NaN;
		var _loc1_ = m_v1.w;
		var _loc2_ = m_v2.w;
		var _loc3_ = m_v3.w;
		var _loc4_ = B2Math.subtractVV(_loc2_, _loc1_);
		var _loc5_ = B2Math.dot(_loc1_, _loc4_);
		var _loc6_:Float;
		var _loc7_ = _loc6_ = B2Math.dot(_loc2_, _loc4_);
		var _loc8_ = -_loc5_;
		var _loc9_ = B2Math.subtractVV(_loc3_, _loc1_);
		var _loc10_ = B2Math.dot(_loc1_, _loc9_);
		var _loc11_:Float;
		var _loc12_ = _loc11_ = B2Math.dot(_loc3_, _loc9_);
		var _loc13_ = -_loc10_;
		var _loc14_ = B2Math.subtractVV(_loc3_, _loc2_);
		var _loc15_ = B2Math.dot(_loc2_, _loc14_);
		var _loc16_:Float;
		var _loc17_ = _loc16_ = B2Math.dot(_loc3_, _loc14_);
		var _loc18_ = -_loc15_;
		var _loc19_ = B2Math.crossVV(_loc4_, _loc9_);
		var _loc20_ = _loc19_ * B2Math.crossVV(_loc2_, _loc3_);
		var _loc21_ = _loc19_ * B2Math.crossVV(_loc3_, _loc1_);
		var _loc22_ = _loc19_ * B2Math.crossVV(_loc1_, _loc2_);
		if (_loc8_ <= 0 && _loc13_ <= 0) {
			m_v1.a = 1;
			m_count = 1;
			return;
		}
		if (_loc7_ > 0 && _loc8_ > 0 && _loc22_ <= 0) {
			_loc23_ = 1 / (_loc7_ + _loc8_);
			m_v1.a = _loc7_ * _loc23_;
			m_v2.a = _loc8_ * _loc23_;
			m_count = 2;
			return;
		}
		if (_loc12_ > 0 && _loc13_ > 0 && _loc21_ <= 0) {
			_loc23_ = 1 / (_loc12_ + _loc13_);
			m_v1.a = _loc12_ * _loc23_;
			m_v3.a = _loc13_ * _loc23_;
			m_count = 2;
			m_v2.set(m_v3);
			return;
		}
		if (_loc7_ <= 0 && _loc18_ <= 0) {
			m_v2.a = 1;
			m_count = 1;
			m_v1.set(m_v2);
			return;
		}
		if (_loc12_ <= 0 && _loc17_ <= 0) {
			m_v3.a = 1;
			m_count = 1;
			m_v1.set(m_v3);
			return;
		}
		if (_loc17_ > 0 && _loc18_ > 0 && _loc20_ <= 0) {
			_loc23_ = 1 / (_loc17_ + _loc18_);
			m_v2.a = _loc17_ * _loc23_;
			m_v3.a = _loc18_ * _loc23_;
			m_count = 2;
			m_v1.set(m_v3);
			return;
		}
		_loc23_ = 1 / (_loc20_ + _loc21_ + _loc22_);
		m_v1.a = _loc20_ * _loc23_;
		m_v2.a = _loc21_ * _loc23_;
		m_v3.a = _loc22_ * _loc23_;
		m_count = 3;
	}

	public function Solve2() {
		var _loc1_ = m_v1.w;
		var _loc2_ = m_v2.w;
		var _loc3_ = B2Math.subtractVV(_loc2_, _loc1_);
		var _loc4_ = -(_loc1_.x * _loc3_.x + _loc1_.y * _loc3_.y);
		if (_loc4_ <= 0) {
			m_v1.a = 1;
			m_count = 1;
			return;
		}
		var _loc5_ = _loc2_.x * _loc3_.x + _loc2_.y * _loc3_.y;
		if (_loc5_ <= 0) {
			m_v2.a = 1;
			m_count = 1;
			m_v1.set(m_v2);
			return;
		}
		var _loc6_ = 1 / (_loc5_ + _loc4_);
		m_v1.a = _loc5_ * _loc6_;
		m_v2.a = _loc4_ * _loc6_;
		m_count = 2;
	}

	public function ReadCache(cache:B2SimplexCache, proxyA:B2DistanceProxy, transformA:B2Transform, proxyB:B2DistanceProxy, transformB:B2Transform) {
		var _loc6_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc7_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, B2SimplexVertex);
		var _loc12_ = 0;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		B2Settings.b2Assert(0 <= cache.count && cache.count <= 3);
		m_count = cache.count;
		var _loc8_ = m_vertices;
		var _loc10_ = 0;
		var _loc11_ = m_count;
		while (_loc10_ < _loc11_) {
			_loc12_ = _loc10_++;
			_loc9_ = _loc8_[_loc12_];
			ASCompat.setProperty(_loc9_, "indexA", ASCompat.toInt(cache.indexA[_loc12_]));
			ASCompat.setProperty(_loc9_, "indexB", ASCompat.toInt(cache.indexB[_loc12_]));
			_loc6_ = proxyA.getVertex(ASCompat.toInt(_loc9_.indexA));
			_loc7_ = proxyB.getVertex(ASCompat.toInt(_loc9_.indexB));
			ASCompat.setProperty(_loc9_, "wA", B2Math.mulX(transformA, _loc6_));
			ASCompat.setProperty(_loc9_, "wB", B2Math.mulX(transformB, _loc7_));
			ASCompat.setProperty(_loc9_, "w",
				B2Math.subtractVV(ASCompat.coerce(_loc9_.wB, box2D.common.math.B2Vec2), ASCompat.coerce(_loc9_.wA, box2D.common.math.B2Vec2)));
			ASCompat.setProperty(_loc9_, "a", 0);
		}
		if (m_count > 1) {
			_loc13_ = cache.metric;
			_loc14_ = getMetric();
			if (_loc14_ < 0.5 * _loc13_ || 2 * _loc13_ < _loc14_ || _loc14_ < ASCompat.MIN_FLOAT) {
				m_count = 0;
			}
		}
		if (m_count == 0) {
			_loc9_ = _loc8_[0];
			ASCompat.setProperty(_loc9_, "indexA", 0);
			ASCompat.setProperty(_loc9_, "indexB", 0);
			_loc6_ = proxyA.getVertex(0);
			_loc7_ = proxyB.getVertex(0);
			ASCompat.setProperty(_loc9_, "wA", B2Math.mulX(transformA, _loc6_));
			ASCompat.setProperty(_loc9_, "wB", B2Math.mulX(transformB, _loc7_));
			ASCompat.setProperty(_loc9_, "w",
				B2Math.subtractVV(ASCompat.coerce(_loc9_.wB, box2D.common.math.B2Vec2), ASCompat.coerce(_loc9_.wA, box2D.common.math.B2Vec2)));
			m_count = 1;
		}
	}

	public function GetWitnessPoints(pA:B2Vec2, pB:B2Vec2) {
		var _loc3_ = Math.NaN;
		switch (m_count) {
			case 0:
				B2Settings.b2Assert(false);

			case 1:
				pA.setV(m_v1.wA);
				pB.setV(m_v1.wB);

			case 2:
				pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x;
				pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y;
				pB.x = m_v1.a * m_v1.wB.x + m_v2.a * m_v2.wB.x;
				pB.y = m_v1.a * m_v1.wB.y + m_v2.a * m_v2.wB.y;

			case 3:
				pB.x = pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x + m_v3.a * m_v3.wA.x;
				pB.y = pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y + m_v3.a * m_v3.wA.y;

			default:
				B2Settings.b2Assert(false);
		}
	}

	public function GetSearchDirection():B2Vec2 {
		var _loc1_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc2_ = Math.NaN;
		switch (m_count) {
			case 1:
				return m_v1.w.getNegative();
			case 2:
				_loc1_ = B2Math.subtractVV(m_v2.w, m_v1.w);
				_loc2_ = B2Math.crossVV(_loc1_, m_v1.w.getNegative());
				if (_loc2_ > 0) {
					return B2Math.crossFV(1, _loc1_);
				}
				return B2Math.crossVF(_loc1_, 1);

			default:
				B2Settings.b2Assert(false);
				return new B2Vec2();
		}
		return null;
	}

	public function GetMetric():Float {
		switch (m_count) {
			case 0:
				B2Settings.b2Assert(false);
				return 0;
			case 1:
				return 0;
			case 2:
				return B2Math.subtractVV(m_v1.w, m_v2.w).length();
			case 3:
				return B2Math.crossVV(B2Math.subtractVV(m_v2.w, m_v1.w), B2Math.subtractVV(m_v3.w, m_v1.w));
			default:
				B2Settings.b2Assert(false);
				return 0;
		}
		return Math.NaN;
	}

	public function GetClosestPoint():B2Vec2 {
		switch (m_count) {
			case 0:
				B2Settings.b2Assert(false);
				return new B2Vec2();
			case 1:
				return m_v1.w;
			case 2:
				return new B2Vec2(m_v1.a * m_v1.w.x + m_v2.a * m_v2.w.x, m_v1.a * m_v1.w.y + m_v2.a * m_v2.w.y);
			default:
				B2Settings.b2Assert(false);
				return new B2Vec2();
		}
		return null;
	}
}
