package box2D.collision;

import box2D.common.math.*;

class B2DynamicTreeBroadPhase implements IBroadPhase {
	var m_tree:B2DynamicTree = new B2DynamicTree();

	var m_proxyCount:Int = 0;

	var m_moveBuffer:Vector<B2DynamicTreeNode> = new Vector();

	var m_pairBuffer:Vector<B2DynamicTreePair> = new Vector();

	var m_pairCount:Int = 0;

	public function new() {}

	public function CreateProxy(aabb:B2AABB, userData:ASAny):ASAny {
		var _loc3_ = this.m_tree.CreateProxy(aabb, userData);
		++this.m_proxyCount;
		this.BufferMove(_loc3_);
		return _loc3_;
	}

	public function DestroyProxy(proxy:ASAny) {
		this.UnBufferMove(ASCompat.dynamicAs(proxy, box2D.collision.B2DynamicTreeNode));
		--this.m_proxyCount;
		this.m_tree.DestroyProxy(ASCompat.dynamicAs(proxy, box2D.collision.B2DynamicTreeNode));
	}

	public function MoveProxy(proxy:ASAny, aabb:B2AABB, displacement:B2Vec2) {
		var _loc4_ = this.m_tree.MoveProxy(ASCompat.dynamicAs(proxy, box2D.collision.B2DynamicTreeNode), aabb, displacement);
		if (_loc4_) {
			this.BufferMove(ASCompat.dynamicAs(proxy, box2D.collision.B2DynamicTreeNode));
		}
	}

	public function TestOverlap(proxyA:ASAny, proxyB:ASAny):Bool {
		var _loc3_ = this.m_tree.GetFatAABB(ASCompat.dynamicAs(proxyA, box2D.collision.B2DynamicTreeNode));
		var _loc4_ = this.m_tree.GetFatAABB(ASCompat.dynamicAs(proxyB, box2D.collision.B2DynamicTreeNode));
		return _loc3_.TestOverlap(_loc4_);
	}

	public function GetUserData(proxy:ASAny):ASAny {
		return this.m_tree.GetUserData(ASCompat.dynamicAs(proxy, box2D.collision.B2DynamicTreeNode));
	}

	public function GetFatAABB(proxy:ASAny):B2AABB {
		return this.m_tree.GetFatAABB(ASCompat.dynamicAs(proxy, box2D.collision.B2DynamicTreeNode));
	}

	public function GetProxyCount():Int {
		return this.m_proxyCount;
	}

	public function UpdatePairs(callback:ASFunction) {
		var QueryCallback:ASFunction;
		var queryProxy:B2DynamicTreeNode = null;
		var i = 0;
		var fatAABB:B2AABB = null;
		var primaryPair:B2DynamicTreePair = null;
		var userDataA:ASAny = /*undefined*/ null;
		var userDataB:ASAny = /*undefined*/ null;
		var pair:B2DynamicTreePair = null;
		this.m_pairCount = 0;
		final __ax4_iter_88 = this.m_moveBuffer;
		if (checkNullIteratee(__ax4_iter_88))
			for (_tmp_ in __ax4_iter_88) {
				queryProxy = _tmp_;
				QueryCallback = function(proxy:B2DynamicTreeNode):Bool {
					if (proxy == queryProxy) {
						return true;
					}
					if (m_pairCount == m_pairBuffer.length) {
						m_pairBuffer[m_pairCount] = new B2DynamicTreePair();
					}
					var _loc2_ = m_pairBuffer[m_pairCount];
					_loc2_.proxyA = Reflect.compare(proxy, queryProxy) < 0 ? proxy : queryProxy;
					_loc2_.proxyB = Reflect.compare(proxy, queryProxy) >= 0 ? proxy : queryProxy;
					++m_pairCount;
					return true;
				};
				fatAABB = this.m_tree.GetFatAABB(queryProxy);
				this.m_tree.Query(QueryCallback, fatAABB);
			}
		this.m_moveBuffer.length = 0;
		i = 0;
		while (i < this.m_pairCount) {
			primaryPair = this.m_pairBuffer[i];
			userDataA = this.m_tree.GetUserData(primaryPair.proxyA);
			userDataB = this.m_tree.GetUserData(primaryPair.proxyB);
			callback(userDataA, userDataB);
			i++;
			while (i < this.m_pairCount) {
				pair = this.m_pairBuffer[i];
				if (pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB) {
					break;
				}
				i++;
			}
		}
	}

	public function Query(callback:ASFunction, aabb:B2AABB) {
		this.m_tree.Query(callback, aabb);
	}

	public function RayCast(callback:ASFunction, input:B2RayCastInput) {
		this.m_tree.RayCast(callback, input);
	}

	public function Validate() {}

	public function Rebalance(iterations:Int) {
		this.m_tree.Rebalance(iterations);
	}

	function BufferMove(proxy:B2DynamicTreeNode) {
		this.m_moveBuffer[this.m_moveBuffer.length] = proxy;
	}

	function UnBufferMove(proxy:B2DynamicTreeNode) {
		var _loc2_ = this.m_moveBuffer.indexOf(proxy);
		this.m_moveBuffer.splice(_loc2_, (1 : UInt));
	}

	function ComparePairs(pair1:B2DynamicTreePair, pair2:B2DynamicTreePair):Int {
		return 0;
	}
}
