package com.junkbyte.console;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.geom.Rectangle;

class Cc {
	public static var _console:Console;

	public static var _config:ConsoleConfig;

	public function new() {}

	@:isVar public static var config(get, never):ConsoleConfig;

	static public function get_config():ConsoleConfig {
		return Cc.get_config();
	}

	public static function get_config():ConsoleConfig {
		if (Cc._config == null) {
			Cc._config = new ConsoleConfig();
		}
		return Cc._config;
	}

	public static function start(container:DisplayObjectContainer, password:String = /*undefined*/ null) {
		if (password == null) {
			password = "";
		}
		if (Cc._console != null) {
			if (container != null && Cc._console.parent == null) {
				container.addChild(Cc._console);
			}
		} else {
			Cc._console = new Console(password, Cc.get_config());
			if (container != null) {
				container.addChild(Cc._console);
			}
		}
	}

	public static function startOnStage(display:DisplayObject = /*undefined*/ null, password:String = /*undefined*/ null) {
		if (password == null) {
			password = "";
		}
		if (Cc._console != null) {
			if (display != null && display.stage != null && Cc._console.parent != display.stage) {
				display.stage.addChild(Cc._console);
			}
		} else if (display != null && display.stage != null) {
			Cc.start(display.stage, password);
		} else {
			Cc._console = new Console(password, Cc.get_config());
			if (display != null) {
				display.addEventListener(Event.ADDED_TO_STAGE, Cc.addedToStageHandle);
			}
		}
	}

	public static function addedToStageHandle(e:Event) {
		var _loc2_ = cast(e.currentTarget, DisplayObject);
		_loc2_.removeEventListener(Event.ADDED_TO_STAGE, Cc.addedToStageHandle);
		if (Cc._console != null && Cc._console.parent == null) {
			_loc2_.stage.addChild(Cc._console);
		}
	}

	public static function add(string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		if (Cc._console != null) {
			Cc._console.add(string, priority, isRepeating);
		}
	}

	public static function ch(channel:ASAny, string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		if (Cc._console != null) {
			Cc._console.ch(channel, string, priority, isRepeating);
		}
	}

	public static function log(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.log();
			} else if (rest.length == 1) {
				Cc._console.log(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.log(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.log(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.log(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function info(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.info();
			} else if (rest.length == 1) {
				Cc._console.info(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.info(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.info(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.info(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function debug(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.debug();
			} else if (rest.length == 1) {
				Cc._console.debug(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.debug(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.debug(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.debug(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function warn(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.warn();
			} else if (rest.length == 1) {
				Cc._console.warn(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.warn(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.warn(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.warn(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function error(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.error();
			} else if (rest.length == 1) {
				Cc._console.error(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.error(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.error(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.error(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function fatal(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.fatal();
			} else if (rest.length == 1) {
				Cc._console.fatal(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.fatal(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.fatal(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.fatal(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function logch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			Cc._console.addCh(channel, ASCompat.coerce(rest.copy(), Array), 1);
		}
	}

	public static function infoch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			Cc._console.addCh(channel, ASCompat.coerce(rest.copy(), Array), 3);
		}
	}

	public static function debugch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			Cc._console.addCh(channel, ASCompat.coerce(rest.copy(), Array), 6);
		}
	}

	public static function warnch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			Cc._console.addCh(channel, ASCompat.coerce(rest.copy(), Array), 8);
		}
	}

	public static function errorch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			Cc._console.addCh(channel, ASCompat.coerce(rest.copy(), Array), 9);
		}
	}

	public static function fatalch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			Cc._console.addCh(channel, ASCompat.coerce(rest.copy(), Array), 10);
		}
	}

	public static function stack(string:ASAny, depth:Int = -1, priority:Int = 5) {
		if (Cc._console != null) {
			Cc._console.stack(string, depth, priority);
		}
	}

	public static function stackch(channel:ASAny, string:ASAny, depth:Int = -1, priority:Int = 5) {
		if (Cc._console != null) {
			Cc._console.stackch(channel, string, depth, priority);
		}
	}

	public static function inspect(obj:ASAny, showInherit:Bool = true) {
		if (Cc._console != null) {
			Cc._console.inspect(obj, showInherit);
		}
	}

	public static function inspectch(channel:ASAny, obj:ASAny, showInherit:Bool = true) {
		if (Cc._console != null) {
			Cc._console.inspectch(channel, obj, showInherit);
		}
	}

	public static function explode(obj:ASAny, depth:Int = 3) {
		if (Cc._console != null) {
			Cc._console.explode(obj, depth);
		}
	}

	public static function explodech(channel:ASAny, obj:ASAny, depth:Int = 3) {
		if (Cc._console != null) {
			Cc._console.explodech(channel, obj, depth);
		}
	}

	public static function addHTML(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.addHTML();
			} else if (rest.length == 1) {
				Cc._console.addHTML(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.addHTML(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.addHTML(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
			} else if (rest.length == 14) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
			} else if (rest.length == 15) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.addHTML(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function addHTMLch(channel:ASAny, priority:Int, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc5_:Console = null;
		var _loc6_:(ASAny, Int) -> Void = null;
		var _loc7_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		if (Cc._console != null) {
			_loc5_ = Cc._console;
			_loc6_ = Cc._console.addHTMLch;
			_loc7_ = ([channel, priority] : Array<ASAny>).concat(ASCompat.coerce(rest.copy(), Array));
			Reflect.callMethod(_loc5_, _loc6_, _loc7_);
		}
	}

	public static function map(container:DisplayObjectContainer, maxDepth:UInt = (0 : UInt)) {
		if (Cc._console != null) {
			Cc._console.map(container, maxDepth);
		}
	}

	public static function mapch(channel:ASAny, container:DisplayObjectContainer, maxDepth:UInt = (0 : UInt)) {
		if (Cc._console != null) {
			Cc._console.mapch(channel, container, maxDepth);
		}
	}

	public static function clear(channel:String = /*undefined*/ null) {
		if (Cc._console != null) {
			Cc._console.clear(channel);
		}
	}

	public static function bindKey(key:KeyBind, callback:ASAny = /*undefined*/ null, args:Array<ASAny> = /*undefined*/ null) {
		if (Cc._console != null) {
			Cc._console.bindKey(key, callback, args);
		}
	}

	public static function addMenu(key:String, callback:ASAny, args:Array<ASAny> = /*undefined*/ null, rollover:String = /*undefined*/ null) {
		if (Cc._console != null) {
			Cc._console.addMenu(key, callback, args, rollover);
		}
	}

	public static function listenUncaughtErrors(loaderinfo:LoaderInfo) {
		if (Cc._console != null) {
			Cc._console.listenUncaughtErrors(loaderinfo);
		}
	}

	public static function store(name:String, obj:ASAny, useStrong:Bool = false) {
		if (Cc._console != null) {
			Cc._console.store(name, obj, useStrong);
		}
	}

	public static function addSlashCommand(name:String, callback:ASAny, description:String = /*undefined*/ null, alwaysAvailable:Bool = true,
			endOfArgsMarker:String = /*undefined*/ null) {
		if (description == null) {
			description = "";
		}
		if (endOfArgsMarker == null) {
			endOfArgsMarker = ";";
		}
		if (Cc._console != null) {
			Cc._console.addSlashCommand(name, callback, description, alwaysAvailable, endOfArgsMarker);
		}
	}

	public static function watch(obj:ASAny, name:String = /*undefined*/ null):String {
		if (Cc._console != null) {
			return Cc._console.watch(obj, name);
		}
		return null;
	}

	public static function unwatch(name:String) {
		if (Cc._console != null) {
			Cc._console.unwatch(name);
		}
	}

	public static function addGraph(panelName:String, obj:ASAny, property:String, color:Int = -1, idKey:String = /*undefined*/ null,
			rectArea:Rectangle = /*undefined*/ null, inverse:Bool = false) {
		if (Cc._console != null) {
			Cc._console.addGraph(panelName, obj, property, color, idKey, rectArea, inverse);
		}
	}

	public static function fixGraphRange(panelName:String, min:ASObject = /*undefined*/ null, max:ASObject = /*undefined*/ null) {
		if (min == null) {
			min = Math.NaN;
		}
		if (max == null) {
			max = Math.NaN;
		}
		if (Cc._console != null) {
			Cc._console.fixGraphRange(panelName, min, max);
		}
	}

	public static function removeGraph(panelName:String, obj:ASAny = /*undefined*/ null, property:String = /*undefined*/ null) {
		if (Cc._console != null) {
			Cc._console.removeGraph(panelName, obj, property);
		}
	}

	public static function setViewingChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.setViewingChannels();
			} else if (rest.length == 1) {
				Cc._console.setViewingChannels(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.setViewingChannels(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12]);
			} else if (rest.length == 14) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13]);
			} else if (rest.length == 15) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	public static function setIgnoredChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (Cc._console != null) {
			if (rest.length == 0) {
				Cc._console.setIgnoredChannels();
			} else if (rest.length == 1) {
				Cc._console.setIgnoredChannels(rest[0]);
			} else if (rest.length == 2) {
				Cc._console.setIgnoredChannels(rest[0], rest[1]);
			} else if (rest.length == 3) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2]);
			} else if (rest.length == 4) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3]);
			} else if (rest.length == 5) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4]);
			} else if (rest.length == 6) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			} else if (rest.length == 7) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			} else if (rest.length == 8) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			} else if (rest.length == 9) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			} else if (rest.length == 10) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
			} else if (rest.length == 11) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
			} else if (rest.length == 12) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
			} else if (rest.length == 13) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12]);
			} else if (rest.length == 14) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13]);
			} else if (rest.length == 15) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14]);
			} else if (rest.length == 16) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15]);
			} else if (rest.length == 17) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16]);
			} else if (rest.length == 18) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16], rest[17]);
			} else if (rest.length == 19) {
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
			} else {
				if (rest.length != 20) {
					throw "Too many rest arguments";
				}
				Cc._console.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11],
					rest[12], rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
			}
		}
	}

	@:isVar public static var minimumPriority(never, set):UInt;

	static public function set_minimumPriority(value:UInt):UInt {
		Cc.set_minimumPriority(value);
		return value;
	}

	public static function set_minimumPriority(level:UInt):UInt {
		if (Cc._console != null) {
			Cc._console.set_minimumPriority(level);
		}
		return level;
	}

	@:isVar public static var width(get, set):Float;

	static public function get_width():Float {
		return Cc.get_width();
	}

	public static function get_width():Float {
		if (Cc._console != null) {
			return Cc._console.get_width();
		}
		return 0;
	}

	static function set_width(value:Float):Float {
		Cc.set_width(value);
		return value;
	}

	public static function set_width(v:Float):Float {
		if (Cc._console != null) {
			Cc._console.set_width(v);
		}
		return v;
	}

	@:isVar public static var height(get, set):Float;

	static public function get_height():Float {
		return Cc.get_height();
	}

	public static function get_height():Float {
		if (Cc._console != null) {
			return Cc._console.get_height();
		}
		return 0;
	}

	static function set_height(value:Float):Float {
		Cc.set_height(value);
		return value;
	}

	public static function set_height(v:Float):Float {
		if (Cc._console != null) {
			Cc._console.set_height(v);
		}
		return v;
	}

	@:isVar public static var x(get, set):Float;

	static public function get_x():Float {
		return Cc.get_x();
	}

	public static function get_x():Float {
		if (Cc._console != null) {
			return Cc._console.get_x();
		}
		return 0;
	}

	static function set_x(value:Float):Float {
		Cc.set_x(value);
		return value;
	}

	public static function set_x(v:Float):Float {
		if (Cc._console != null) {
			Cc._console.set_x(v);
		}
		return v;
	}

	@:isVar public static var y(get, set):Float;

	static public function get_y():Float {
		return Cc.get_y();
	}

	public static function get_y():Float {
		if (Cc._console != null) {
			return Cc._console.get_y();
		}
		return 0;
	}

	static function set_y(value:Float):Float {
		Cc.set_y(value);
		return value;
	}

	public static function set_y(v:Float):Float {
		if (Cc._console != null) {
			Cc._console.set_y(v);
		}
		return v;
	}

	@:isVar public static var visible(get, set):Bool;

	static public function get_visible():Bool {
		return Cc.get_visible();
	}

	public static function get_visible():Bool {
		if (Cc._console != null) {
			return Cc._console.visible;
		}
		return false;
	}

	static function set_visible(value:Bool):Bool {
		Cc.set_visible(value);
		return value;
	}

	public static function set_visible(v:Bool):Bool {
		if (Cc._console != null) {
			Cc._console.set_visible(v);
		}
		return v;
	}

	@:isVar public static var fpsMonitor(get, set):Bool;

	static public function get_fpsMonitor():Bool {
		return Cc.get_fpsMonitor();
	}

	public static function get_fpsMonitor():Bool {
		if (Cc._console != null) {
			return Cc._console.get_fpsMonitor();
		}
		return false;
	}

	static function set_fpsMonitor(value:Bool):Bool {
		Cc.set_fpsMonitor(value);
		return value;
	}

	public static function set_fpsMonitor(v:Bool):Bool {
		if (Cc._console != null) {
			Cc._console.set_fpsMonitor(v);
		}
		return v;
	}

	@:isVar public static var memoryMonitor(get, set):Bool;

	static public function get_memoryMonitor():Bool {
		return Cc.get_memoryMonitor();
	}

	public static function get_memoryMonitor():Bool {
		if (Cc._console != null) {
			return Cc._console.get_memoryMonitor();
		}
		return false;
	}

	static function set_memoryMonitor(value:Bool):Bool {
		Cc.set_memoryMonitor(value);
		return value;
	}

	public static function set_memoryMonitor(v:Bool):Bool {
		if (Cc._console != null) {
			Cc._console.set_memoryMonitor(v);
		}
		return v;
	}

	@:isVar public static var commandLine(get, set):Bool;

	static public function get_commandLine():Bool {
		return Cc.get_commandLine();
	}

	public static function get_commandLine():Bool {
		if (Cc._console != null) {
			return Cc._console.get_commandLine();
		}
		return false;
	}

	static function set_commandLine(value:Bool):Bool {
		Cc.set_commandLine(value);
		return value;
	}

	public static function set_commandLine(v:Bool):Bool {
		if (Cc._console != null) {
			Cc._console.set_commandLine(v);
		}
		return v;
	}

	@:isVar public static var displayRoller(get, set):Bool;

	static public function get_displayRoller():Bool {
		return Cc.get_displayRoller();
	}

	public static function get_displayRoller():Bool {
		if (Cc._console != null) {
			return Cc._console.get_displayRoller();
		}
		return false;
	}

	static function set_displayRoller(value:Bool):Bool {
		Cc.set_displayRoller(value);
		return value;
	}

	public static function set_displayRoller(v:Bool):Bool {
		if (Cc._console != null) {
			Cc._console.set_displayRoller(v);
		}
		return v;
	}

	public static function setRollerCaptureKey(character:String, ctrl:Bool = false, alt:Bool = false, shift:Bool = false) {
		if (Cc._console != null) {
			Cc._console.setRollerCaptureKey(character, shift, ctrl, alt);
		}
	}

	@:isVar public static var remoting(get, set):Bool;

	static public function get_remoting():Bool {
		return Cc.get_remoting();
	}

	public static function get_remoting():Bool {
		if (Cc._console != null) {
			return Cc._console.get_remoting();
		}
		return false;
	}

	static function set_remoting(value:Bool):Bool {
		Cc.set_remoting(value);
		return value;
	}

	public static function set_remoting(v:Bool):Bool {
		if (Cc._console != null) {
			Cc._console.set_remoting(v);
		}
		return v;
	}

	public static function remotingSocket(host:String, port:Int) {
		if (Cc._console != null) {
			Cc._console.remotingSocket(host, port);
		}
	}

	public static function remove() {
		if (Cc._console != null) {
			if (Cc._console.parent != null) {
				Cc._console.parent.removeChild(Cc._console);
			}
			Cc._console = null;
		}
	}

	public static function getAllLog(splitter:String = /*undefined*/ null):String {
		if (splitter == null) {
			splitter = "\r\n";
		}
		if (Cc._console != null) {
			return Cc._console.getAllLog(splitter);
		}
		return "";
	}

	@:isVar public static var instance(get, never):Console;

	static public function get_instance():Console {
		return Cc.get_instance();
	}

	public static function get_instance():Console {
		return Cc._console;
	}
}
