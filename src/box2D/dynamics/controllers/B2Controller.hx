package box2D.dynamics.controllers;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2TimeStep;
import box2D.dynamics.B2World;

/*use*/ /*namespace*/ /*b2internal*/ class B2Controller {
	/*b2internal*/
	public var m_next:B2Controller;

	/*b2internal*/
	public var m_prev:B2Controller;

	var m_bodyList:B2ControllerEdge;

	var m_bodyCount:Int = 0;

	/*b2internal*/
	public var m_world:B2World;

	public function new() {}

	public function Step(step:B2TimeStep) {}

	public function Draw(debugDraw:B2DebugDraw) {}

	public function AddBody(body:B2Body) {
		var _loc2_ = new B2ControllerEdge();
		_loc2_.controller = this;
		_loc2_.body = body;
		_loc2_.nextBody = this.m_bodyList;
		_loc2_.prevBody = null;
		this.m_bodyList = _loc2_;
		if (_loc2_.nextBody != null) {
			_loc2_.nextBody.prevBody = _loc2_;
		}
		++this.m_bodyCount;
		_loc2_.nextController = body.m_controllerList;
		_loc2_.prevController = null;
		body.m_controllerList = _loc2_;
		if (_loc2_.nextController != null) {
			_loc2_.nextController.prevController = _loc2_;
		}
		++body.m_controllerCount;
	}

	public function RemoveBody(body:B2Body) {
		var _loc2_ = body.m_controllerList;
		while (_loc2_ != null && _loc2_.controller != this) {
			_loc2_ = _loc2_.nextController;
		}
		if (_loc2_.prevBody != null) {
			_loc2_.prevBody.nextBody = _loc2_.nextBody;
		}
		if (_loc2_.nextBody != null) {
			_loc2_.nextBody.prevBody = _loc2_.prevBody;
		}
		if (_loc2_.nextController != null) {
			_loc2_.nextController.prevController = _loc2_.prevController;
		}
		if (_loc2_.prevController != null) {
			_loc2_.prevController.nextController = _loc2_.nextController;
		}
		if (this.m_bodyList == _loc2_) {
			this.m_bodyList = _loc2_.nextBody;
		}
		if (body.m_controllerList == _loc2_) {
			body.m_controllerList = _loc2_.nextController;
		}
		--body.m_controllerCount;
		--this.m_bodyCount;
	}

	public function Clear() {
		while (this.m_bodyList != null) {
			this.RemoveBody(this.m_bodyList.body);
		}
	}

	public function GetNext():B2Controller {
		return this.m_next;
	}

	public function GetWorld():B2World {
		return this.m_world;
	}

	public function GetBodyList():B2ControllerEdge {
		return this.m_bodyList;
	}
}
