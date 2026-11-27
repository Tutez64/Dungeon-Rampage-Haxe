package box2D.dynamics;

class B2TimeStep {
	public var warmStarting:Bool = false;

	public var velocityIterations:Int = 0;

	public var positionIterations:Int = 0;

	public var inv_dt:Float = Math.NaN;

	public var dtRatio:Float = Math.NaN;

	public var dt:Float = Math.NaN;

	public function new() {
		positionIterations = 0;
		velocityIterations = 0;
		dtRatio = 0;
		inv_dt = 0;
		dt = 0;
	}

	public function set(step:B2TimeStep) {
		Set(step);
	}

	public function Set(step:B2TimeStep) {
		dt = step.dt;
		inv_dt = step.inv_dt;
		positionIterations = step.positionIterations;
		velocityIterations = step.velocityIterations;
		warmStarting = step.warmStarting;
	}
}
