package account;

import gameMasterDictionary.GMKey;
import gameMasterDictionary.GMOffer;

class KeyInfo {
	var mGMKey:GMKey;

	var mGMKeyOffer:GMOffer;

	var mCount:UInt = 0;

	public function new(gmKey:GMKey, gmKeyOffer:GMOffer, num:UInt) {
		mGMKey = gmKey;
		mGMKeyOffer = gmKeyOffer;
		mCount = num;
	}

	@:isVar public var gmKey(get, never):GMKey;

	public function get_gmKey():GMKey {
		return mGMKey;
	}

	@:isVar public var gmKeyOffer(get, never):GMOffer;

	public function get_gmKeyOffer():GMOffer {
		return mGMKeyOffer;
	}

	@:isVar public var count(get, set):UInt;

	public function get_count():UInt {
		return mCount;
	}

	function set_count(val:UInt):UInt {
		return mCount = val;
	}
}
