package com.junkbyte.console;

import com.junkbyte.console.text.StyleSheet;
import flash.Boot;

class ConsoleStyle {
	public var traceFontSize:Int = 0;

	public var traceFont:String;

	public var topMenu:Bool = false;

	public var showCommandLineScope:Bool = false;

	public var roundBorder:Int = 0;

	public var priorityC2:UInt = 0;

	public var priorityC1:UInt = 0;

	public var priority9:UInt = 0;

	public var priority8:UInt = 0;

	public var priority7:UInt = 0;

	public var priority6:UInt = 0;

	public var priority5:UInt = 0;

	public var priority4:UInt = 0;

	public var priority3:UInt = 0;

	public var priority2:UInt = 0;

	public var priority10:UInt = 0;

	public var priority1:UInt = 0;

	public var priority0:UInt = 0;

	public var panelSnapping:Int = 0;

	public var menuHighlightColor:UInt = 0;

	public var menuFontSize:Int = 0;

	public var menuFont:String;

	public var menuColor:UInt = 0;

	public var maxChannelsInMenu:Int = 0;

	public var lowColor:UInt = 0;

	public var logHeaderColor:UInt = 0;

	public var highColor:UInt = 0;

	public var controlSize:UInt = 0;

	public var controlColor:UInt = 0;

	public var commandLineColor:UInt = 0;

	public var channelsColor:UInt = 0;

	public var channelColor:UInt = 0;

	public var backgroundColor:UInt = 0;

	public var backgroundAlpha:Float = Math.NaN;

	public var _css:StyleSheet;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		roundBorder = 10;
		panelSnapping = 3;
		maxChannelsInMenu = 7;
		showCommandLineScope = true;
		topMenu = true;
		priorityC2 = (16746496 : UInt);
		priorityC1 = (39372 : UInt);
		priority10 = (16720418 : UInt);
		priority9 = (16720418 : UInt);
		priority8 = (16742263 : UInt);
		priority7 = (16755370 : UInt);
		priority6 = (16768477 : UInt);
		priority5 = (15329769 : UInt);
		priority4 = (14085846 : UInt);
		priority3 = (10539168 : UInt);
		priority2 = (7846775 : UInt);
		priority1 = (4495684 : UInt);
		priority0 = (3831610 : UInt);
		channelColor = (39372 : UInt);
		channelsColor = (16777215 : UInt);
		menuHighlightColor = (14505216 : UInt);
		menuColor = (16746496 : UInt);
		logHeaderColor = (12632256 : UInt);
		lowColor = (12632256 : UInt);
		highColor = (16777215 : UInt);
		commandLineColor = (1092096 : UInt);
		controlSize = (5 : UInt);
		controlColor = (10027008 : UInt);
		backgroundAlpha = 0.9;
		backgroundColor = (0 : UInt);
		traceFontSize = 11;
		traceFont = "Verdana";
		menuFontSize = 12;
		menuFont = "Arial";
		_css = new StyleSheet();
	}

	public function whiteBase() {
		backgroundColor = (16777215 : UInt);
		controlColor = (16724787 : UInt);
		commandLineColor = (6736896 : UInt);
		highColor = (0 : UInt);
		lowColor = (3355443 : UInt);
		logHeaderColor = (4473924 : UInt);
		menuColor = (13373696 : UInt);
		menuHighlightColor = (8917248 : UInt);
		channelsColor = (0 : UInt);
		channelColor = (26282 : UInt);
		priority0 = (4497476 : UInt);
		priority1 = (3379251 : UInt);
		priority2 = (2258722 : UInt);
		priority3 = (1135889 : UInt);
		priority4 = (13056 : UInt);
		priority5 = (0 : UInt);
		priority6 = (6684672 : UInt);
		priority7 = (10027008 : UInt);
		priority8 = (12255232 : UInt);
		priority9 = (14483456 : UInt);
		priority10 = (14483456 : UInt);
		priorityC1 = (39372 : UInt);
		priorityC2 = (16737792 : UInt);
	}

	public function updateStyleSheet() {
		_css.setStyle("high", {
			"color": hesh(highColor),
			"fontFamily": menuFont,
			"fontSize": menuFontSize,
			"display": "inline"
		});
		_css.setStyle("low", {
			"color": hesh(lowColor),
			"fontFamily": menuFont,
			"fontSize": menuFontSize - 2,
			"display": "inline"
		});
		_css.setStyle("menu", {
			"color": hesh(menuColor),
			"display": "inline"
		});
		_css.setStyle("menuHi", {
			"color": hesh(menuHighlightColor),
			"display": "inline"
		});
		_css.setStyle("chs", {
			"color": hesh(channelsColor),
			"fontSize": menuFontSize,
			"leading": "2",
			"display": "inline"
		});
		_css.setStyle("ch", {
			"color": hesh(channelColor),
			"display": "inline"
		});
		_css.setStyle("tt", {
			"color": hesh(menuColor),
			"fontFamily": menuFont,
			"fontSize": menuFontSize,
			"textAlign": "center"
		});
		_css.setStyle("r", {
			"textAlign": "right",
			"display": "inline"
		});
		_css.setStyle("p", {
			"fontFamily": traceFont,
			"fontSize": traceFontSize
		});
		_css.setStyle("p0", {
			"color": hesh(priority0),
			"display": "inline"
		});
		_css.setStyle("p1", {
			"color": hesh(priority1),
			"display": "inline"
		});
		_css.setStyle("p2", {
			"color": hesh(priority2),
			"display": "inline"
		});
		_css.setStyle("p3", {
			"color": hesh(priority3),
			"display": "inline"
		});
		_css.setStyle("p4", {
			"color": hesh(priority4),
			"display": "inline"
		});
		_css.setStyle("p5", {
			"color": hesh(priority5),
			"display": "inline"
		});
		_css.setStyle("p6", {
			"color": hesh(priority6),
			"display": "inline"
		});
		_css.setStyle("p7", {
			"color": hesh(priority7),
			"display": "inline"
		});
		_css.setStyle("p8", {
			"color": hesh(priority8),
			"display": "inline"
		});
		_css.setStyle("p9", {
			"color": hesh(priority9),
			"display": "inline"
		});
		_css.setStyle("p10", {
			"color": hesh(priority10),
			"fontWeight": "bold",
			"display": "inline"
		});
		_css.setStyle("p-1", {
			"color": hesh(priorityC1),
			"display": "inline"
		});
		_css.setStyle("p-2", {
			"color": hesh(priorityC2),
			"display": "inline"
		});
		_css.setStyle("logs", {
			"color": hesh(logHeaderColor),
			"display": "inline"
		});
	}

	public function hesh(n:UInt):String {
		return "#" + StringTools.hex((n : Int));
	}

	public function get_styleSheet():StyleSheet {
		return _css;
	}

	@:isVar public var styleSheet(get, never):StyleSheet;

	public function get_styleSheet():StyleSheet {
		return get_styleSheet();
	}

	public function big() {
		traceFontSize = 13;
		menuFontSize = 14;
	}
}
