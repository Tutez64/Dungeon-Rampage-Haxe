package box2D.dynamics.contacts;

import flash.Boot;

class B2ContactRegister {
	public var primary:Bool = false;

	public var poolCount:Int = 0;

	public var pool:B2Contact;

	public var destroyFcn:ASAny;

	public var createFcn:ASAny;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		poolCount = 0;
	}
}
