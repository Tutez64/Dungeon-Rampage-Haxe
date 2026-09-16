import account.SteamAccountInfo;
import brain.assetRepository.TestResourceLocator;
import brain.event.EventListeners;
import brain.GameEntry;
import brain.logger.Logger;
import brain.render.tweens.TweeningProxy;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import util.GameLogOutput;
import util.LaunchWindowOptions;
import flash.desktop.NativeApplication;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;

@:meta(SWF(width = "1920", height = "1080", backgroundColor = "#1e0808", frameRate = "60"))
class DungeonBustersProject extends GameEntry {
	var mDBFacade:DBFacade;

	var mSteamStarted:Bool = false;

	var mSteamDisposed:Bool = false;

	public function new() {
		super();
		stage.scaleMode = "noScale";
		stage.align = "TL";
		stage.quality = "high";
		mDBFacade = new DBFacade();
		mDBFacade.init(this.stage);
		EventListeners.add(NativeApplication.nativeApplication, "invoke", onInvoke);
		EventListeners.add(this.loaderInfo.uncaughtErrorEvents, "uncaughtError", function(param1:flash.events.UncaughtErrorEvent) {
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
				#if cpp
				// A Haxe exception (hxcpp's Null Object Reference, Invalid field access, a thrown
				// String...) is not an Error: say what it is, with its stack when the build keeps one.
				_loc2_ = Std.string(param1.error) + haxe.CallStack.toString(haxe.CallStack.exceptionStack());
				#else
				_loc2_ = "Unknown error";
				#end
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

	public function onInvoke(e:InvokeEvent) {
		EventListeners.add(NativeApplication.nativeApplication, "exiting", onExit);
		if (!mSteamStarted) {
			mSteamStarted = true;
			SteamAccountInfo.startSteam(mDBFacade);
		}
		GameLogOutput.configure(e.arguments);
		processArguments(e.arguments);
	}

	function onExit(e:Event) {
		if (mSteamDisposed) {
			return;
		}
		mSteamDisposed = true;
		Logger.info("Exiting application, cleaning up Steam");
		mDBFacade.mSteamworks.dispose();
		TweeningProxy.shutdown();
		GameLogOutput.close();
	}

	function processArguments(arguments:Array<ASAny>) {
		var _loc3_ = 0;
		var _loc2_:String = null;
		TestResourceLocator.apply(arguments);
		mDBFacade.featureFlags.loadFeatureFlagValuesFromCli(arguments);
		LaunchWindowOptions.apply(stage, mDBFacade.featureFlags, arguments);
		var _loc4_ = 0;
		_loc3_ = 0;
		while (_loc3_ < arguments.length) {
			_loc2_ = arguments[_loc3_];
			if (!(_loc2_ == "--log" || _loc2_.indexOf("--log=") == 0)) {
				if (!(_loc2_ == "--windowed" || _loc2_.indexOf("--windowed=") == 0)) {
					if (DBGlobal.endsWith(_loc2_, ".json")) {
						if (++_loc4_ > 3) {
							Logger.warn("GBS: Too many JSON files passed in! Only supports three json files, ignoring: " + _loc2_);
						} else {
							mDBFacade.mAdditionalConfigFilesToLoad.push("DBConfiguration/" + _loc2_);
						}
					}
				}
			}
			_loc3_++;
		}
	}
}
