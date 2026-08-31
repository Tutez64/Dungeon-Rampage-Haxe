package box2D.dynamics;

class B2TimeStep {
	public var dt:Float = Math.NaN;

	public var inv_dt:Float = Math.NaN;

	public var dtRatio:Float = Math.NaN;

	public var velocityIterations:Int = 0;

	public var positionIterations:Int = 0;

	public var warmStarting:Bool = false;

	public function new() {}

	public function Set(step:B2TimeStep) {
		this.dt = step.dt;
		this.inv_dt = step.inv_dt;
		this.positionIterations = step.positionIterations;
		this.velocityIterations = step.velocityIterations;
		this.warmStarting = step.warmStarting;
	}
}
