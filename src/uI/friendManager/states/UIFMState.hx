package uI.friendManager.states;

import brain.uI.UIButton;
import facade.DBFacade;
import town.TownStateMachine;
import uI.friendManager.UIFriendManager;
import flash.display.MovieClip;

class UIFMState {
	var mDBFacade:DBFacade;

	var mUIFriendManager:UIFriendManager;

	var mTownStateMachine:TownStateMachine;

	public function new(dbFacade:DBFacade, friendMgr:UIFriendManager, townStateMachine:TownStateMachine) {
		mDBFacade = dbFacade;
		mUIFriendManager = friendMgr;
		mTownStateMachine = townStateMachine;
	}

	public function enter() {}

	public function exit() {}

	public function createButton(btnStr:String, text:String, xPos:Int, yPos:Int, callbackFunc:ASFunction):UIButton {
		var _loc7_ = mTownStateMachine.getTownAsset(btnStr);
		var _loc8_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
		var _loc6_ = new UIButton(mDBFacade, _loc8_);
		_loc6_.releaseCallback = callbackFunc;
		_loc8_.x = xPos;
		_loc8_.y = yPos;
		_loc6_.root.scaleY = _loc6_.root.scaleX = 1.8;
		_loc6_.label.text = text;
		mUIFriendManager.addToUI(_loc6_.root);
		return _loc6_;
	}
}
