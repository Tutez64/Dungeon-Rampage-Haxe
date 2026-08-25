package box2D.collision;

import box2D.common.*;
import box2D.common.math.*;

class B2DynamicTree {
	var m_root:B2DynamicTreeNode;

	var m_freeList:B2DynamicTreeNode;

	var m_path:UInt = 0;

	var m_insertionCount:Int = 0;

	public function new() {
		this.m_root = null;
		this.m_freeList = null;
		this.m_path = (0 : UInt);
		this.m_insertionCount = 0;
	}

	public function CreateProxy(aabb:B2AABB, userData:ASAny):B2DynamicTreeNode {
		var _loc3_:B2DynamicTreeNode = null;
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		_loc3_ = this.AllocateNode();
		_loc4_ = B2Settings.b2_aabbExtension;
		_loc5_ = B2Settings.b2_aabbExtension;
		_loc3_.aabb.lowerBound.x = aabb.lowerBound.x - _loc4_;
		_loc3_.aabb.lowerBound.y = aabb.lowerBound.y - _loc5_;
		_loc3_.aabb.upperBound.x = aabb.upperBound.x + _loc4_;
		_loc3_.aabb.upperBound.y = aabb.upperBound.y + _loc5_;
		_loc3_.userData = userData;
		this.InsertLeaf(_loc3_);
		return _loc3_;
	}

	public function DestroyProxy(proxy:B2DynamicTreeNode) {
		this.RemoveLeaf(proxy);
		this.FreeNode(proxy);
	}

	public function MoveProxy(proxy:B2DynamicTreeNode, aabb:B2AABB, displacement:B2Vec2):Bool {
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		B2Settings.b2Assert(proxy.IsLeaf());
		if (proxy.aabb.Contains(aabb)) {
			return false;
		}
		this.RemoveLeaf(proxy);
		_loc4_ = B2Settings.b2_aabbExtension + B2Settings.b2_aabbMultiplier * (displacement.x > 0 ? displacement.x : -displacement.x);
		_loc5_ = B2Settings.b2_aabbExtension + B2Settings.b2_aabbMultiplier * (displacement.y > 0 ? displacement.y : -displacement.y);
		proxy.aabb.lowerBound.x = aabb.lowerBound.x - _loc4_;
		proxy.aabb.lowerBound.y = aabb.lowerBound.y - _loc5_;
		proxy.aabb.upperBound.x = aabb.upperBound.x + _loc4_;
		proxy.aabb.upperBound.y = aabb.upperBound.y + _loc5_;
		this.InsertLeaf(proxy);
		return true;
	}

	public function Rebalance(iterations:Int) {
		var _loc3_:B2DynamicTreeNode = null;
		var _loc4_ = (0 : UInt);
		if (this.m_root == null) {
			return;
		}
		var _loc2_ = 0;
		while (_loc2_ < iterations) {
			_loc3_ = this.m_root;
			_loc4_ = (0 : UInt);
			while (_loc3_.IsLeaf() == false) {
				_loc3_ = ((this.m_path : Int) >> (_loc4_ : Int) & 1) != 0 ? _loc3_.child2 : _loc3_.child1;
				_loc4_ = ((_loc4_ + 1 : Int) & 0x1F : UInt);
			}
			++this.m_path;
			this.RemoveLeaf(_loc3_);
			this.InsertLeaf(_loc3_);
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
	}

	public function GetFatAABB(proxy:B2DynamicTreeNode):B2AABB {
		return proxy.aabb;
	}

	public function GetUserData(proxy:B2DynamicTreeNode):ASAny {
		return proxy.userData;
	}

	public function Query(callback:ASFunction, aabb:B2AABB) {
		var _loc8_:Float;
		var _loc9_:Float;
		var _loc5_:B2DynamicTreeNode = null;
		var _loc6_ = false;
		if (this.m_root == null) {
			return;
		}
		var _loc3_ = new Vector<B2DynamicTreeNode>();
		var _loc4_ = 0;
		var _loc7_:Float;
		_loc3_[Std.int(_loc7_ = ASCompat.toNumber(_loc4_++))] = this.m_root;
		while (_loc4_ > 0) {
			_loc5_ = _loc3_[Std.int(--_loc4_)];
			if (_loc5_.aabb.TestOverlap(aabb)) {
				if (_loc5_.IsLeaf()) {
					_loc6_ = ASCompat.toBool(callback(_loc5_));
					if (!_loc6_) {
						return;
					}
				} else {
					_loc3_[Std.int(_loc8_ = ASCompat.toNumber(_loc4_++))] = _loc5_.child1;
					_loc3_[Std.int(_loc9_ = ASCompat.toNumber(_loc4_++))] = _loc5_.child2;
				}
			}
		}
	}

	public function RayCast(callback:ASFunction, input:B2RayCastInput) {
		var _loc20_:Float;
		var _loc21_:Float;
		var _loc3_:B2Vec2 = null;
		var _loc9_:B2AABB = null;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc14_:B2DynamicTreeNode = null;
		var _loc15_:B2Vec2 = null;
		var _loc16_:B2Vec2 = null;
		var _loc17_ = Math.NaN;
		var _loc18_:B2RayCastInput = null;
		if (this.m_root == null) {
			return;
		}
		_loc3_ = input.p1;
		var _loc4_ = input.p2;
		var _loc5_ = B2Math.SubtractVV(_loc3_, _loc4_);
		_loc5_.Normalize();
		var _loc6_ = B2Math.CrossFV(1, _loc5_);
		var _loc7_ = B2Math.AbsV(_loc6_);
		var _loc8_ = input.maxFraction;
		_loc9_ = new B2AABB();
		_loc10_ = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
		_loc11_ = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
		_loc9_.lowerBound.x = Math.min(_loc3_.x, _loc10_);
		_loc9_.lowerBound.y = Math.min(_loc3_.y, _loc11_);
		_loc9_.upperBound.x = Math.max(_loc3_.x, _loc10_);
		_loc9_.upperBound.y = Math.max(_loc3_.y, _loc11_);
		var _loc12_ = new Vector<B2DynamicTreeNode>();
		var _loc13_ = 0;
		var _loc19_:Float;
		_loc12_[Std.int(_loc19_ = ASCompat.toNumber(_loc13_++))] = this.m_root;
		while (_loc13_ > 0) {
			_loc14_ = _loc12_[Std.int(--_loc13_)];
			if (_loc14_.aabb.TestOverlap(_loc9_) != false) {
				_loc15_ = _loc14_.aabb.GetCenter();
				_loc16_ = _loc14_.aabb.GetExtents();
				_loc17_ = Math.abs(_loc6_.x * (_loc3_.x - _loc15_.x) + _loc6_.y * (_loc3_.y - _loc15_.y)) - _loc7_.x * _loc16_.x - _loc7_.y * _loc16_.y;
				if (_loc17_ <= 0) {
					if (_loc14_.IsLeaf()) {
						_loc18_ = new B2RayCastInput();
						_loc18_.p1 = input.p1;
						_loc18_.p2 = input.p2;
						_loc18_.maxFraction = input.maxFraction;
						_loc8_ = ASCompat.toNumber(callback(_loc18_, _loc14_));
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
						_loc12_[Std.int(_loc20_ = ASCompat.toNumber(_loc13_++))] = _loc14_.child1;
						_loc12_[Std.int(_loc21_ = ASCompat.toNumber(_loc13_++))] = _loc14_.child2;
					}
				}
			}
		}
	}

	function AllocateNode():B2DynamicTreeNode {
		var _loc1_:B2DynamicTreeNode = null;
		if (this.m_freeList != null) {
			_loc1_ = this.m_freeList;
			this.m_freeList = _loc1_.parent;
			_loc1_.parent = null;
			_loc1_.child1 = null;
			_loc1_.child2 = null;
			return _loc1_;
		}
		return new B2DynamicTreeNode();
	}

	function FreeNode(node:B2DynamicTreeNode) {
		node.parent = this.m_freeList;
		this.m_freeList = node;
	}

	function InsertLeaf(leaf:B2DynamicTreeNode) {
		var _loc6_:B2DynamicTreeNode = null;
		var _loc7_:B2DynamicTreeNode = null;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		++this.m_insertionCount;
		if (this.m_root == null) {
			this.m_root = leaf;
			this.m_root.parent = null;
			return;
		}
		var _loc2_ = leaf.aabb.GetCenter();
		var _loc3_ = this.m_root;
		if (_loc3_.IsLeaf() == false) {
			do {
				_loc6_ = _loc3_.child1;
				_loc7_ = _loc3_.child2;
				_loc8_ = Math.abs((_loc6_.aabb.lowerBound.x + _loc6_.aabb.upperBound.x) / 2 - _loc2_.x)
					+ Math.abs((_loc6_.aabb.lowerBound.y + _loc6_.aabb.upperBound.y) / 2 - _loc2_.y);
				_loc9_ = Math.abs((_loc7_.aabb.lowerBound.x + _loc7_.aabb.upperBound.x) / 2 - _loc2_.x)
					+ Math.abs((_loc7_.aabb.lowerBound.y + _loc7_.aabb.upperBound.y) / 2 - _loc2_.y);
				if (_loc8_ < _loc9_) {
					_loc3_ = _loc6_;
				} else {
					_loc3_ = _loc7_;
				}
			} while (_loc3_.IsLeaf() == false);
		}
		var _loc4_ = _loc3_.parent;
		var _loc5_ = this.AllocateNode();
		_loc5_.parent = _loc4_;
		_loc5_.userData = null;
		_loc5_.aabb._Combine(leaf.aabb, _loc3_.aabb);
		if (_loc4_ != null) {
			if (_loc3_.parent.child1 == _loc3_) {
				_loc4_.child1 = _loc5_;
			} else {
				_loc4_.child2 = _loc5_;
			}
			_loc5_.child1 = _loc3_;
			_loc5_.child2 = leaf;
			_loc3_.parent = _loc5_;
			leaf.parent = _loc5_;
			while (!_loc4_.aabb.Contains(_loc5_.aabb)) {
				_loc4_.aabb._Combine(_loc4_.child1.aabb, _loc4_.child2.aabb);
				_loc5_ = _loc4_;
				_loc4_ = _loc4_.parent;
				if (_loc4_ == null) {
					break;
				}
			}
		} else {
			_loc5_.child1 = _loc3_;
			_loc5_.child2 = leaf;
			_loc3_.parent = _loc5_;
			leaf.parent = _loc5_;
			this.m_root = _loc5_;
		}
	}

	function RemoveLeaf(leaf:B2DynamicTreeNode) {
		var _loc4_:B2DynamicTreeNode = null;
		var _loc5_:B2AABB = null;
		if (leaf == this.m_root) {
			this.m_root = null;
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
			_loc4_.parent = _loc3_;
			this.FreeNode(_loc2_);
			while (_loc3_ != null) {
				_loc5_ = _loc3_.aabb;
				_loc3_.aabb = B2AABB.Combine(_loc3_.child1.aabb, _loc3_.child2.aabb);
				if (_loc5_.Contains(_loc3_.aabb)) {
					break;
				}
				_loc3_ = _loc3_.parent;
			}
		} else {
			this.m_root = _loc4_;
			_loc4_.parent = null;
			this.FreeNode(_loc2_);
		}
	}
}
