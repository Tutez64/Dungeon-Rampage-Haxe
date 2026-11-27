package box2D.collision;

import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2dcompat.Scratch;

class B2DynamicTree {
	public var m_root:B2DynamicTreeNode;

	public var m_queryStack:Array<ASAny>;

	public var m_queryDepth:Int = 0;

	public var m_path:Int = 0;

	public var m_insertionCount:Int = 0;

	public var m_freeList:B2DynamicTreeNode;

	public function new() {
		m_queryDepth = 0;
		m_queryStack = [];
		m_root = null;
		m_freeList = null;
		m_path = 0;
		m_insertionCount = 0;
	}

	public function removeLeaf(leaf:B2DynamicTreeNode) {
		var _loc4_ = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		var _loc5_ = ASCompat.dynamicAs(null, B2AABB);
		var _loc6_ = ASCompat.dynamicAs(null, B2AABB);
		if (leaf == m_root) {
			m_root = null;
			return;
		}
		var _loc2_ = leaf.parent;
		var _loc3_ = _loc2_.parent;
		if (_loc2_.child1 == leaf) {
			_loc4_ = _loc2_.child2;
		} else {
			_loc4_ = _loc2_.child1;
		}
		if (_loc3_ != null) {
			if (_loc3_.child1 == _loc2_) {
				_loc3_.child1 = _loc4_;
			} else {
				_loc3_.child2 = _loc4_;
			}
			ASCompat.setProperty(_loc4_, "parent", _loc3_);
			freeNode(_loc2_);
			while (_loc3_ != null) {
				_loc5_ = _loc3_.aabb;
				_loc6_ = Scratch.spare;
				Scratch.spare = _loc5_;
				_loc3_.aabb = _loc6_;
				_loc3_.aabb.combine(_loc3_.child1.aabb, _loc3_.child2.aabb);
				if (ASCompat.toBool(_loc5_.contains(_loc3_.aabb))) {
					break;
				}
				_loc3_ = _loc3_.parent;
			}
		} else {
			m_root = _loc4_;
			ASCompat.setProperty(_loc4_, "parent", null);
			freeNode(_loc2_);
		}
	}

	public function rebalance(iterations:Int) {
		Rebalance(iterations);
	}

	public function rayCast(callbackMethod:ASFunction, input:B2RayCastInput) {
		RayCast(callbackMethod, input);
	}

	public function query(callbackMethod:ASFunction, aabb:B2AABB) {
		Query(callbackMethod, aabb);
	}

	public function moveProxy(proxy:B2DynamicTreeNode, aabb:B2AABB, displacement:B2Vec2):Bool {
		return MoveProxy(proxy, aabb, displacement);
	}

	public function insertLeaf(leaf:B2DynamicTreeNode) {
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		var _loc6_ = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		++m_insertionCount;
		if (m_root == null) {
			m_root = leaf;
			m_root.parent = null;
			return;
		}
		var _loc2_ = leaf.aabb;
		Scratch.centre.x = (_loc2_.lowerBound.x + _loc2_.upperBound.x) / 2;
		Scratch.centre.y = (_loc2_.lowerBound.y + _loc2_.upperBound.y) / 2;
		var _loc3_ = Scratch.centre;
		var _loc4_ = m_root;
		if (_loc4_.isLeaf() == false) {
			do {
				_loc5_ = _loc4_.child1;
				_loc6_ = _loc4_.child2;
				_loc7_ = Math.abs(ASCompat.toNumber(_loc5_.aabb.lowerBound.x + _loc5_.aabb.upperBound.x) / 2 - _loc3_.x)
					+ Math.abs(ASCompat.toNumber(_loc5_.aabb.lowerBound.y + _loc5_.aabb.upperBound.y) / 2 - _loc3_.y);
				_loc8_ = Math.abs(ASCompat.toNumber(_loc6_.aabb.lowerBound.x + _loc6_.aabb.upperBound.x) / 2 - _loc3_.x)
					+ Math.abs(ASCompat.toNumber(_loc6_.aabb.lowerBound.y + _loc6_.aabb.upperBound.y) / 2 - _loc3_.y);
				if (_loc7_ < _loc8_) {
					_loc4_ = ASCompat.coerce(_loc5_, box2D.collision.B2DynamicTreeNode);
				} else {
					_loc4_ = _loc6_;
				}
			} while (_loc4_.isLeaf() == false);
		}
		_loc5_ = _loc4_.parent;
		_loc6_ = allocateNode();
		ASCompat.setProperty(_loc6_, "parent", _loc5_);
		ASCompat.setProperty(_loc6_, "userData", null);
		_loc6_.aabb.combine(leaf.aabb, _loc4_.aabb);
		if (_loc5_ != null) {
			if (_loc4_.parent.child1 == _loc4_) {
				ASCompat.setProperty(_loc5_, "child1", _loc6_);
			} else {
				ASCompat.setProperty(_loc5_, "child2", _loc6_);
			}
			ASCompat.setProperty(_loc6_, "child1", _loc4_);
			ASCompat.setProperty(_loc6_, "child2", leaf);
			_loc4_.parent = _loc6_;
			leaf.parent = _loc6_;
			while (!ASCompat.toBool(_loc5_.aabb.contains(_loc6_.aabb))) {
				_loc5_.aabb.combine(_loc5_.child1.aabb, _loc5_.child2.aabb);
				_loc6_ = _loc5_;
				_loc5_ = _loc5_.parent;
				if (_loc5_ == null) {
					break;
				}
			}
		} else {
			ASCompat.setProperty(_loc6_, "child1", _loc4_);
			ASCompat.setProperty(_loc6_, "child2", leaf);
			_loc4_.parent = _loc6_;
			leaf.parent = _loc6_;
			m_root = _loc6_;
		}
	}

	public function getUserData(proxy:B2DynamicTreeNode):ASAny {
		return GetUserData(proxy);
	}

	public function getFatAABB(proxy:B2DynamicTreeNode):B2AABB {
		return GetFatAABB(proxy);
	}

	public function freeNode(node:B2DynamicTreeNode) {
		node.parent = m_freeList;
		m_freeList = node;
	}

	public function endAbandonedQueries() {
		EndAbandonedQueries();
	}

	public function destroyProxy(proxy:B2DynamicTreeNode) {
		DestroyProxy(proxy);
	}

	public function createProxy(aabb:B2AABB, userData:ASAny):B2DynamicTreeNode {
		return CreateProxy(aabb, userData);
	}

	public function allocateNode():B2DynamicTreeNode {
		var _loc1_ = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		if (m_freeList != null) {
			_loc1_ = m_freeList;
			m_freeList = ASCompat.coerce(_loc1_.parent, box2D.collision.B2DynamicTreeNode);
			ASCompat.setProperty(_loc1_, "parent", null);
			ASCompat.setProperty(_loc1_, "child1", null);
			ASCompat.setProperty(_loc1_, "child2", null);
			return _loc1_;
		}
		return new B2DynamicTreeNode();
	}

	public function Rebalance(iterations:Int) {
		var _loc4_ = 0;
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		var _loc6_ = 0;
		if (m_root == null) {
			return;
		}
		var _loc2_ = 0;
		var _loc3_ = iterations;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			_loc5_ = m_root;
			_loc6_ = 0;
			while (_loc5_.isLeaf() == false) {
				_loc5_ = (m_path >> _loc6_ & 1) != 0 ? _loc5_.child2 : _loc5_.child1;
				_loc6_ = _loc6_ + 1 & 0x1F;
			}
			++m_path;
			removeLeaf(ASCompat.coerce(_loc5_, box2D.collision.B2DynamicTreeNode));
			insertLeaf(ASCompat.coerce(_loc5_, box2D.collision.B2DynamicTreeNode));
		}
	}

	public function RayCast(callbackMethod:ASFunction, input:B2RayCastInput) {
		var _loc14_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		var _loc15_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc16_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc17_ = Math.NaN;
		var _loc18_ = ASCompat.dynamicAs(null, B2RayCastInput);
		if (m_root == null) {
			return;
		}
		var _loc3_ = input.p1;
		var _loc4_ = input.p2;
		var _loc5_ = B2Math.subtractVV(_loc3_, _loc4_);
		_loc5_.normalize();
		var _loc6_ = B2Math.crossFV(1, _loc5_);
		var _loc7_ = B2Math.absV(_loc6_);
		var _loc8_ = input.maxFraction;
		var _loc9_ = new B2AABB();
		var _loc10_ = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
		var _loc11_ = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
		_loc9_.lowerBound.x = Math.min(_loc3_.x, _loc10_);
		_loc9_.lowerBound.y = Math.min(_loc3_.y, _loc11_);
		_loc9_.upperBound.x = Math.max(_loc3_.x, _loc10_);
		_loc9_.upperBound.y = Math.max(_loc3_.y, _loc11_);
		var _loc12_:Array<ASAny> = [];
		var _loc13_ = 0;
		_loc12_[_loc13_++] = m_root;
		while (_loc13_ > 0) {
			_loc14_ = _loc12_[--_loc13_];
			if (_loc14_.aabb.testOverlap(_loc9_) != false) {
				_loc15_ = _loc14_.aabb.getCenter();
				_loc16_ = _loc14_.aabb.getExtents();
				_loc17_ = Math.abs(_loc6_.x * (_loc3_.x - ASCompat.toNumberField(_loc15_, "x")) + _loc6_.y * (_loc3_.y - ASCompat.toNumberField(_loc15_, "y")))
					- _loc7_.x * ASCompat.toNumberField(_loc16_, "x")
					- _loc7_.y * ASCompat.toNumberField(_loc16_, "y");
				if (_loc17_ <= 0) {
					if (ASCompat.toBool(_loc14_.isLeaf())) {
						_loc18_ = new B2RayCastInput();
						ASCompat.setProperty(_loc18_, "p1", input.p1);
						ASCompat.setProperty(_loc18_, "p2", input.p2);
						ASCompat.setProperty(_loc18_, "maxFraction", input.maxFraction);
						_loc8_ = ASCompat.toNumber(callbackMethod(_loc18_, _loc14_));
						if (_loc8_ == 0) {
							return;
						}
						_loc10_ = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
						_loc11_ = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
						_loc9_.lowerBound.x = Math.min(_loc3_.x, _loc10_);
						_loc9_.lowerBound.y = Math.min(_loc3_.y, _loc11_);
						_loc9_.upperBound.x = Math.max(_loc3_.x, _loc10_);
						_loc9_.upperBound.y = Math.max(_loc3_.y, _loc11_);
					} else {
						_loc12_[_loc13_++] = _loc14_.child1;
						_loc12_[_loc13_++] = _loc14_.child2;
					}
				}
			}
		}
	}

	public function Query(callbackMethod:ASFunction, aabb:B2AABB) {
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		if (m_root == null) {
			return;
		}
		var _loc3_ = m_queryDepth;
		var _loc4_ = _loc3_ == 0 ? m_queryStack : [];
		m_queryDepth = _loc3_ + 1;
		var _loc5_ = 0;
		_loc4_[_loc5_++] = m_root;
		while (_loc5_ > 0) {
			_loc6_ = _loc4_[--_loc5_];
			if (ASCompat.toBool(_loc6_.aabb.testOverlap(aabb))) {
				if (ASCompat.toBool(_loc6_.isLeaf())) {
					if (!ASCompat.toBool(callbackMethod(_loc6_))) {
						break;
					}
				} else {
					_loc4_[_loc5_++] = _loc6_.child1;
					_loc4_[_loc5_++] = _loc6_.child2;
				}
			}
		}
		_loc4_.resize(0);
		m_queryDepth = _loc3_;
	}

	public function MoveProxy(proxy:B2DynamicTreeNode, aabb:B2AABB, displacement:B2Vec2):Bool {
		B2Settings.b2Assert(proxy.isLeaf());
		if (proxy.aabb.contains(aabb)) {
			return false;
		}
		removeLeaf(proxy);
		var _loc4_ = B2Settings.b2_aabbExtension + B2Settings.b2_aabbMultiplier * (displacement.x > 0 ? displacement.x : -displacement.x);
		var _loc5_ = B2Settings.b2_aabbExtension + B2Settings.b2_aabbMultiplier * (displacement.y > 0 ? displacement.y : -displacement.y);
		proxy.aabb.lowerBound.x = aabb.lowerBound.x - _loc4_;
		proxy.aabb.lowerBound.y = aabb.lowerBound.y - _loc5_;
		proxy.aabb.upperBound.x = aabb.upperBound.x + _loc4_;
		proxy.aabb.upperBound.y = aabb.upperBound.y + _loc5_;
		insertLeaf(proxy);
		return true;
	}

	public function GetUserData(proxy:B2DynamicTreeNode):ASAny {
		return proxy.userData;
	}

	public function GetFatAABB(proxy:B2DynamicTreeNode):B2AABB {
		return proxy.aabb;
	}

	public function EndAbandonedQueries() {
		if (m_queryDepth == 0 && m_queryStack.length == 0) {
			return;
		}
		m_queryDepth = 0;
		m_queryStack = [];
	}

	public function DestroyProxy(proxy:B2DynamicTreeNode) {
		removeLeaf(proxy);
		freeNode(proxy);
	}

	public function CreateProxy(aabb:B2AABB, userData:ASAny):B2DynamicTreeNode {
		var _loc3_ = allocateNode();
		var _loc4_ = B2Settings.b2_aabbExtension;
		var _loc5_ = B2Settings.b2_aabbExtension;
		_loc3_.aabb.lowerBound.x = aabb.lowerBound.x - _loc4_;
		_loc3_.aabb.lowerBound.y = aabb.lowerBound.y - _loc5_;
		_loc3_.aabb.upperBound.x = aabb.upperBound.x + _loc4_;
		_loc3_.aabb.upperBound.y = aabb.upperBound.y + _loc5_;
		_loc3_.userData = userData;
		insertLeaf(_loc3_);
		return _loc3_;
	}
}
