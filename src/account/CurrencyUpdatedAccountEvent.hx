package account;

import flash.events.Event;

class CurrencyUpdatedAccountEvent extends Event {
	public static inline final EVENT_NAME = "CurrencyUpdatedAccountEvent";

	var mBasicCurrency:UInt = 0;

	var mPremiumCurrency:UInt = 0;

	public function new(basicCurrency:UInt, premiumCurrency:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super("CurrencyUpdatedAccountEvent", bubbles, cancelable);
		mPremiumCurrency = premiumCurrency;
		mBasicCurrency = basicCurrency;
	}

	@:isVar public var basicCurrency(get, never):UInt;

	public function get_basicCurrency():UInt {
		return mBasicCurrency;
	}

	@:isVar public var premiumCurrency(get, never):UInt;

	public function get_premiumCurrency():UInt {
		return mPremiumCurrency;
	}
}
