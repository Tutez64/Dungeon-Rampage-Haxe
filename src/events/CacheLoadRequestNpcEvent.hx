package events;

import flash.events.Event;

class CacheLoadRequestNpcEvent extends Event {
	public static inline final CACHE_LOAD_REQUEST = "Busterncpccahche_event";

	public var cacheNpc:Vector<UInt>;

	public var cacheSwf:Vector<String>;

	public var tileLibraryName:Vector<String>;

	public function new(inCacheNpc:Vector<UInt>, inCacheSwf:Vector<String>, inTileLibraryName:Vector<String>, bubbles:Bool = false, cancelable:Bool = false) {
		cacheSwf = inCacheSwf;
		cacheNpc = inCacheNpc;
		tileLibraryName = inTileLibraryName;
		super("Busterncpccahche_event", bubbles, cancelable);
	}
}
