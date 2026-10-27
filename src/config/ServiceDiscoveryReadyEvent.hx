package config;

import flash.events.Event;

class ServiceDiscoveryReadyEvent extends Event {
	public static inline final EVENT_NAME = "ServiceDiscoveryReadyEvent";

	public var serviceDiscoveryResult:ASObject;

	public var serviceDiscoveryErrorCode:Int = 0;

	public var serviceDiscoveryErrorText:String;

	public function new(result:ASObject, errorCode:Int, errorText:String = "") {
		super("ServiceDiscoveryReadyEvent", true);
		serviceDiscoveryResult = result;
		serviceDiscoveryErrorCode = errorCode;
		serviceDiscoveryErrorText = errorText;
	}
}
