package box2D.collision;

import box2D.common.math.B2Sweep;

class B2TOIInput {
	public var tolerance:Float = Math.NaN;

	public var sweepB:B2Sweep;

	public var sweepA:B2Sweep;

	public var proxyB:B2DistanceProxy;

	public var proxyA:B2DistanceProxy;

	public function new() {
		proxyA = new B2DistanceProxy();
		proxyB = new B2DistanceProxy();
		sweepA = new B2Sweep();
		sweepB = new B2Sweep();
	}
}
