import brain.GameEntry;
import brain.logger.Logger;
import brain.mouseScrollPlugin.*;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import com.amanitadesign.steam.SteamEvent;
import flash.desktop.NativeApplication;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;

@:meta(SWF(width = "1920", height = "1080", backgroundColor = "#1e0808", frameRate = "60"))
class DungeonBustersProject extends GameEntry {
	#if cpp
	static inline final FRAME_RATE_ARGUMENT:String = "--fps";

	static inline final MIN_FRAME_RATE:Float = 1;

	// Lime clamps its application frame rate to this value.
	static inline final MAX_FRAME_RATE:Float = 10000;

	static inline final AUTO_FRAME_RATE_FALLBACK:Float = 120;
	static inline final AUTO_FRAME_RATE_STEP:Float = 24;
	static inline final AUTO_FRAME_RATE_MAXIMUM:Float = 240;

	var mAutoFrameRateMessage:String;
	var mAutoFrameRateDetectionFailed:Bool = false;
	#end

	var mDBFacade:DBFacade;

	public function new() {
		super();
		var _loc1_:String = null;
		#if cpp
		_loc1_ = applyFrameRateFromArguments(Sys.args());
		#end
		stage.scaleMode = "showAll";
		stage.quality = "high";
		mDBFacade = new DBFacade();
		mDBFacade.init(this.stage);
		if (_loc1_ != null) {
			Logger.warn(_loc1_);
		}
		#if cpp
		if (mAutoFrameRateMessage != null) {
			if (mAutoFrameRateDetectionFailed) {
				Logger.warn(mAutoFrameRateMessage);
			} else {
				Logger.info(mAutoFrameRateMessage);
			}
		}
		#end
		Logger.info("Frame rate: " + stage.frameRate);
		NativeApplication.nativeApplication.addEventListener("invoke", onInvoke);
		MouseWheelEnabler.init(this.stage);
		this.loaderInfo.uncaughtErrorEvents.addEventListener("uncaughtError", function(param1:flash.events.UncaughtErrorEvent) {
			var _loc2_:String = null;
			var _loc5_:Error = null;
			param1.preventDefault();
			var _loc4_ = false;
			if (Std.isOfType(param1.error, Error)) {
				_loc5_ = ASCompat.dynamicAs(param1.error, Error);
				_loc2_ = (_loc5_ : ASAny).hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : Std.string(_loc5_);
				if (_loc5_ != null && ASCompat.toBool(_loc5_.name) && ASCompat.toNumber(_loc5_.name.indexOf("LOGGED")) == 0) {
					_loc4_ = true;
				}
			} else if (Std.isOfType(param1.error, ErrorEvent)) {
				_loc2_ = cast(param1.error, ErrorEvent).text;
			} else {
				_loc2_ = "Unknown error";
			}
			var _loc3_ = 0;
			if (mDBFacade != null && mDBFacade.gameClock != null) {
				_loc3_ = mDBFacade.gameClock.gameTime;
			}
			if (!_loc4_) {
				Logger.error("UncaughtError: " + _loc2_);
			}
			mDBFacade.loggerErrorCall("UncaughtError: " + _loc2_ + " GameTime: " + _loc3_);
		});
	}

	#if cpp
	function applyFrameRateFromArguments(args:Array<String>):String {
		var _loc1_:String = null;
		var _loc2_:String = null;
		var _loc3_ = 0;
		while (_loc3_ < args.length) {
			_loc1_ = args[_loc3_];
			if (_loc1_ == FRAME_RATE_ARGUMENT) {
				if (_loc3_ + 1 < args.length) {
					_loc2_ = args[_loc3_ + 1];
				}
				break;
			}
			if (StringTools.startsWith(_loc1_, FRAME_RATE_ARGUMENT + "=")) {
				_loc2_ = _loc1_.substr(FRAME_RATE_ARGUMENT.length + 1);
				break;
			}
			_loc3_++;
		}
		if (_loc2_ == null) {
			return _loc1_ == FRAME_RATE_ARGUMENT ? "Ignoring " + FRAME_RATE_ARGUMENT + " without a value." : null;
		}
		if (_loc2_.toLowerCase() == "auto") {
			stage.frameRate = resolveAutoFrameRate();
			return null;
		}
		if (!~/^[0-9]+(?:\.[0-9]+)?$/.match(_loc2_)) {
			return "Ignoring invalid " + FRAME_RATE_ARGUMENT + " value: " + _loc2_;
		}
		var _loc4_ = Std.parseFloat(_loc2_);
		if (_loc4_ < MIN_FRAME_RATE || _loc4_ > MAX_FRAME_RATE) {
			return "Ignoring "
				+ FRAME_RATE_ARGUMENT
				+ " outside the supported range of "
				+ MIN_FRAME_RATE
				+ " to "
				+ MAX_FRAME_RATE
				+ ": "
				+ _loc2_;
		}
		stage.frameRate = _loc4_;
		return null;
	}

	function resolveAutoFrameRate():Float {
		// The window manager may not have placed the window yet during initialization.
		var _loc1_ = lime.system.System.getDisplay(0);
		if (_loc1_ != null && _loc1_.currentMode != null) {
			var _loc2_ = _loc1_.currentMode.refreshRate;
			if (_loc2_ > 0) {
				var _loc3_ = Math.min(Math.ceil(_loc2_ / AUTO_FRAME_RATE_STEP) * AUTO_FRAME_RATE_STEP, AUTO_FRAME_RATE_MAXIMUM);
				mAutoFrameRateMessage = "Auto frame rate detection succeeded: primary display reports " + _loc2_ + " Hz; selected " + _loc3_ + " FPS.";
				return _loc3_;
			}
		}
		mAutoFrameRateDetectionFailed = true;
		mAutoFrameRateMessage = "Auto frame rate detection failed; using the " + AUTO_FRAME_RATE_FALLBACK + " FPS fallback.";
		return AUTO_FRAME_RATE_FALLBACK;
	}
	#end

	public function onInvoke(e:InvokeEvent = null) {
		NativeApplication.nativeApplication.addEventListener("exiting", onExit);
		try {
			if (!mDBFacade.mSteamworks.init()) {
				Logger.warn("STEAMWORKS API is NOT available");
			} else {
				Logger.info("STEAMWORKS API is available\n");
				mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE, onSteamResponse);
				mDBFacade.mSteamUserId = mDBFacade.mSteamworks.getUserID();
				Logger.info("STEAMWORKS User ID: " + mDBFacade.mSteamUserId);
				mDBFacade.mSteamAppId = mDBFacade.mSteamworks.getAppID();
				Logger.info("STEAMWORKS App ID: " + mDBFacade.mSteamAppId);
				mDBFacade.mSteamPersonaName = mDBFacade.mSteamworks.getPersonaName();
				Logger.info("STEAMWORKS Persona name: " + mDBFacade.mSteamPersonaName);
				mDBFacade.mSteamworks.getAuthTicketForWebApi();
			}
		} catch (e:Dynamic) {
			Logger.warn("*** STEAMWORKS ERROR ***");
			Logger.error(e.message, e);
		}
		processArguments(e.arguments);
	}

	function onSteamResponse(e:SteamEvent) {
		switch (e.req_type - 27) {
			case 0:
				Logger.info("[Steam] RESPONSE_OnGetAuthTicketForWebApiResponse: " + e.response);
				mDBFacade.mSteamWebApiAuthTicket = mDBFacade.mSteamworks.getAuthTicketForWebApiResultHexString();
				mDBFacade.mSteamAuthTicketHandle = mDBFacade.mSteamworks.getAuthTicketForWebApiResultHandle();
		}
	}

	function onExit(e:Event) {
		Logger.info("Exiting application, cleaning up Steam");
		mDBFacade.mSteamworks.dispose();
	}

	function processArguments(arguments:Array<ASAny>) {
		var _loc3_ = 0;
		var _loc2_:String = null;
		mDBFacade.featureFlags.loadFeatureFlagValuesFromCli(arguments);
		var _loc4_ = 0;
		_loc3_ = 0;
		while (_loc3_ < arguments.length) {
			_loc2_ = arguments[_loc3_];
			if (DBGlobal.endsWith(_loc2_, ".json")) {
				if (++_loc4_ > 2) {
					Logger.warn("GBS: Too many JSON files passed in! Only supports two json files, ignoring: " + _loc2_);
				} else {
					mDBFacade.mAdditionalConfigFilesToLoad.push("DBConfiguration/" + _loc2_);
				}
			}
			_loc3_++;
		}
	}
}
