package box2D.collision;

import box2D.common.math.B2Vec2;
import flash.Boot;

class B2DynamicTreeBroadPhase implements IBroadPhase {
	public var m_tree:B2DynamicTree;

	public var m_queryProxy:B2DynamicTreeNode;

	public var m_proxyCount:Int = 0;

	public var m_pairCount:Int = 0;

	public var m_pairBuffer:Array<ASAny>;

	public var m_moveBuffer:Array<ASAny>;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_tree = new B2DynamicTree();
		m_moveBuffer = [];
		m_pairBuffer = [];
		m_pairCount = 0;
		m_proxyCount = 0;
	}

	public function validate() {
		Validate();
	}

	public function updatePairsQueryCallback(proxy:B2DynamicTreeNode):Bool {
		if (proxy == m_queryProxy) {
			return true;
		}
		if (m_pairCount == m_pairBuffer.length) {
			m_pairBuffer[m_pairCount] = new B2DynamicTreePair();
		}
		var _loc2_ = ASCompat.coerce(m_pairBuffer[m_pairCount], box2D.collision.B2DynamicTreePair);
		if (proxy.id < m_queryProxy.id) {
			_loc2_.proxyA = proxy;
			_loc2_.proxyB = m_queryProxy;
		} else {
			_loc2_.proxyA = m_queryProxy;
			_loc2_.proxyB = proxy;
		}
		++m_pairCount;
		return true;
	}

	public function updatePairs(callbackMethod:ASAny) {
		UpdatePairs(callbackMethod);
	}

	public function unBufferMove(proxy:B2DynamicTreeNode) {
		m_moveBuffer.remove(proxy);
	}

	public function testOverlap(proxyA:ASAny, proxyB:ASAny):Bool {
		return TestOverlap(proxyA, proxyB);
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

	public function moveProxy(proxy:ASAny, aabb:B2AABB, displacement:B2Vec2) {
		MoveProxy(proxy, aabb, displacement);
	}

	public function getUserData(proxy:ASAny):ASAny {
		return GetUserData(proxy);
	}

	public function getProxyCount():Int {
		return GetProxyCount();
	}

	public function getFatAABB(proxy:ASAny):B2AABB {
		return GetFatAABB(proxy);
	}

	public function endAbandonedQueries() {
		EndAbandonedQueries();
	}

	public function destroyProxy(proxy:ASAny) {
		DestroyProxy(proxy);
	}

	public function createProxy(aabb:B2AABB, userData:ASAny):ASAny {
		return CreateProxy(aabb, userData);
	}

	public function comparePairs(pair1:B2DynamicTreePair, pair2:B2DynamicTreePair):Int {
		return 0;
	}

	public function bufferMove(proxy:B2DynamicTreeNode) {
		m_moveBuffer[m_moveBuffer.length] = proxy;
	}

	public function Validate() {}

	public function UpdatePairs(callbackMethod:ASAny) {
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreeNode);
		var _loc5_ = ASCompat.dynamicAs(null, B2AABB);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreePair);
		var _loc8_:ASAny = null;
		var _loc9_:ASAny = null;
		var _loc10_:ASAny = ASCompat.dynamicAs(null, B2DynamicTreePair);
		m_pairCount = 0;
		var _loc2_ = 0;
		var _loc3_ = m_moveBuffer;
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			m_queryProxy = ASCompat.coerce(_loc4_, box2D.collision.B2DynamicTreeNode);
			_loc5_ = m_tree.getFatAABB(ASCompat.coerce(_loc4_, box2D.collision.B2DynamicTreeNode));
			m_tree.query(updatePairsQueryCallback, _loc5_);
		}
		m_moveBuffer.resize(0);
		var _loc6_ = true;
		_loc2_ = 0;
		while (_loc6_) {
			if (_loc2_ >= m_pairCount) {
				_loc6_ = false;
			} else {
				_loc7_ = m_pairBuffer[_loc2_];
				_loc8_ = m_tree.getUserData(ASCompat.coerce(_loc7_.proxyA, box2D.collision.B2DynamicTreeNode));
				_loc9_ = m_tree.getUserData(ASCompat.coerce(_loc7_.proxyB, box2D.collision.B2DynamicTreeNode));
				callbackMethod(_loc8_, _loc9_);
				_loc2_++;
				while (_loc2_ < m_pairCount) {
					_loc10_ = m_pairBuffer[_loc2_];
					if (_loc10_.proxyA != _loc7_.proxyA || _loc10_.proxyB != _loc7_.proxyB) {
						break;
					}
					_loc2_++;
				}
			}
		}
	}

	public function TestOverlap(proxyA:ASAny, proxyB:ASAny):Bool {
		var _loc3_ = m_tree.getFatAABB(ASCompat.coerce(proxyA, box2D.collision.B2DynamicTreeNode));
		var _loc4_ = m_tree.getFatAABB(ASCompat.coerce(proxyB, box2D.collision.B2DynamicTreeNode));
		return _loc3_.testOverlap(_loc4_);
	}

	public function Rebalance(iterations:Int) {
		m_tree.rebalance(iterations);
	}

	public function RayCast(callbackMethod:ASFunction, input:B2RayCastInput) {
		m_tree.rayCast(callbackMethod, input);
	}

	public function Query(callbackMethod:ASFunction, aabb:B2AABB) {
		m_tree.query(callbackMethod, aabb);
	}

	public function MoveProxy(proxy:ASAny, aabb:B2AABB, displacement:B2Vec2) {
		var _loc4_ = m_tree.moveProxy(ASCompat.coerce(proxy, box2D.collision.B2DynamicTreeNode), aabb, displacement);
		if (_loc4_) {
			bufferMove(ASCompat.coerce(proxy, box2D.collision.B2DynamicTreeNode));
		}
	}

	public function GetUserData(proxy:ASAny):ASAny {
		return m_tree.getUserData(ASCompat.coerce(proxy, box2D.collision.B2DynamicTreeNode));
	}

	public function GetProxyCount():Int {
		return m_proxyCount;
	}

	public function GetFatAABB(proxy:ASAny):B2AABB {
		return m_tree.getFatAABB(ASCompat.coerce(proxy, box2D.collision.B2DynamicTreeNode));
	}

	public function EndAbandonedQueries() {
		m_tree.endAbandonedQueries();
	}

	public function DestroyProxy(proxy:ASAny) {
		unBufferMove(ASCompat.coerce(proxy, box2D.collision.B2DynamicTreeNode));
		--m_proxyCount;
		m_tree.destroyProxy(ASCompat.coerce(proxy, box2D.collision.B2DynamicTreeNode));
	}

	public function CreateProxy(aabb:B2AABB, userData:ASAny):ASAny {
		var _loc3_ = m_tree.createProxy(aabb, userData);
		++m_proxyCount;
		bufferMove(_loc3_);
		return _loc3_;
	}
}
