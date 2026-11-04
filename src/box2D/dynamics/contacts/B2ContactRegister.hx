package box2D.dynamics.contacts;

class B2ContactRegister {
	public var primary:Bool = false;

	public var poolCount:Int = 0;

	public var pool:B2Contact;

	public var destroyFcn:ASAny;

	public var createFcn:ASAny;

	public function new() {
		poolCount = 0;
	}
}
