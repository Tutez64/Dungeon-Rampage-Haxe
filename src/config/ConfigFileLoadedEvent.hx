package config;

import flash.events.Event;

class ConfigFileLoadedEvent extends Event {
	public static inline final EVENT_NAME = "ConfigFileLoadedEvent";

	var mDBConfigManager:DBConfigManager;

	public function new(configManager:DBConfigManager, bubbles:Bool = false, cancelable:Bool = false) {
		super("ConfigFileLoadedEvent", bubbles, cancelable);
		mDBConfigManager = configManager;
	}

	@:isVar public var dbConfigManager(get, never):DBConfigManager;

	public function get_dbConfigManager():DBConfigManager {
		return mDBConfigManager;
	}
}
