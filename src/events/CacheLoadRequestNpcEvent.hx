package events;

import flash.events.Event;

class CacheLoadRequestNpcEvent extends Event {
	public static inline final CACHE_LOAD_REQUEST = "Busterncpccahche_event";

	public var cacheNpc:Vector<UInt>;

	public var cacheSwf:Vector<String>;

	public var tilelibraryname:Vector<String>;

	public function new(cachenpc:Vector<UInt>, cacheswf:Vector<String>, tilelibrary:Vector<String>, bubbles:Bool = false, cancelable:Bool = false) {
		cacheSwf = cacheswf;
		cacheNpc = cachenpc;
		tilelibraryname = tilelibrary;
		super("Busterncpccahche_event", bubbles, cancelable);
	}
}
