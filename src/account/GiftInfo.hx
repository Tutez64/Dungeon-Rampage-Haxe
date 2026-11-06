package account;

import facade.DBFacade;

class GiftInfo {
	var mFromAccountId:UInt = 0;

	var mOfferId:UInt = 0;

	var mRequestId:String;

	var mDBFacade:DBFacade;

	var mResponseCallback:ASFunction;

	public function new(dbFacade:DBFacade, giftJson:ASObject, responseCallback:ASFunction = null) {
		mDBFacade = dbFacade;
		mResponseCallback = responseCallback;
		parseJson(giftJson);
	}

	function parseJson(giftJson:ASObject) {
		if (giftJson == null) {
			return;
		}
		mFromAccountId = ASCompat.asUint(giftJson.from_account_id);
		mOfferId = ASCompat.asUint(giftJson.offer_id);
		mRequestId = ASCompat.asString(giftJson.request_id);
		if (mResponseCallback != null) {
			mResponseCallback();
		}
	}

	@:isVar public var fromAccountId(get, never):UInt;

	public function get_fromAccountId():UInt {
		return mFromAccountId;
	}

	@:isVar public var requestId(get, never):String;

	public function get_requestId():String {
		return mRequestId;
	}

	@:isVar public var offerId(get, never):UInt;

	public function get_offerId():UInt {
		return mOfferId;
	}
}
