package box2D.collision;

import box2D.common.math.B2Transform;

class B2DistanceInput {
	public var useRadii:Bool = false;

	public var transformB:B2Transform;

	public var transformA:B2Transform;

	public var proxyB:B2DistanceProxy;

	public var proxyA:B2DistanceProxy;

	public function new() {}
}
