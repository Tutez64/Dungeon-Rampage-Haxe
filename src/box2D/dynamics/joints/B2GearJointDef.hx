package box2D.dynamics.joints;

class B2GearJointDef extends B2JointDef {
	public var ratio:Float = Math.NaN;

	public var joint2:B2Joint;

	public var joint1:B2Joint;

	public function new() {
		super();
		type = 6;
		joint1 = null;
		joint2 = null;
		ratio = 1;
	}
}
