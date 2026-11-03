package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import flash.Boot;
import flash.events.TextEvent;
import flash.text.TextFieldAutoSize;

class ChannelsPanel extends ConsolePanel {
	public static var NAME:String = "channelsPanel";

	public function new(m:Console = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(m);
			name = "channelsPanel";
			init(10, 10, false);
			txtField = makeTF("channelsField");
			txtField.wordWrap = true;
			txtField.width = 160;
			txtField.multiline = true;
			txtField.autoSize = TextFieldAutoSize.LEFT;
			registerTFRoller(txtField, onMenuRollOver, linkHandler);
			registerDragger(txtField);
			addChild(txtField);
		}
	}

	public function update() {
		txtField.wordWrap = false;
		txtField.width = 80;
		var _loc1_ = "<high><menu> <b><a href=\"event:close\">X</a></b></menu> " + console.get_panels().get_mainPanel().getChannelsLink();
		txtField.htmlText = _loc1_ + "</high>";
		if (txtField.width > 160) {
			txtField.wordWrap = true;
			txtField.width = 160;
		}
		set_width(txtField.width + 4);
		set_height(txtField.height);
	}

	public function onMenuRollOver(e:TextEvent) {
		console.get_panels().get_mainPanel().onMenuRollOver(e, this);
	}

	public function linkHandler(e:TextEvent) {
		txtField.setSelection(0, 0);
		if (e.text == "close") {
			console.get_panels().set_channelsPanel(false);
		} else if (e.text.substring(0, 8) == "channel_") {
			console.get_panels().get_mainPanel().onChannelPressed(e.text.substring(8));
		}
		txtField.setSelection(0, 0);
		e.stopPropagation();
	}
}
