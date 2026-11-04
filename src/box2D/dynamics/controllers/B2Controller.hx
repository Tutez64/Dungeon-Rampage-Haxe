package box2D.dynamics.controllers;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2TimeStep;
import box2D.dynamics.B2World;

class B2Controller {
	public var m_world:B2World;

	public var m_prev:B2Controller;

	public var m_next:B2Controller;

	public var m_bodyList:B2ControllerEdge;

	public var m_bodyCount:Int = 0;

	public function new() {
		m_bodyCount = 0;
	}

	public function step(step:B2TimeStep) {
		Step(step);
	}

	public function removeBody(body:B2Body) {
		RemoveBody(body);
	}

	public function getWorld():B2World {
		return GetWorld();
	}

	public function getNext():B2Controller {
		return GetNext();
	}

	public function getBodyList():B2ControllerEdge {
		return GetBodyList();
	}

	public function draw(debugDraw:B2DebugDraw) {
		Draw(debugDraw);
	}

	public function clear() {
		Clear();
	}

	public function addBody(body:B2Body) {
		AddBody(body);
	}

	public function Step(step:B2TimeStep) {}

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
		if (m_bodyList == _loc2_) {
			m_bodyList = _loc2_.nextBody;
		}
		if (body.m_controllerList == _loc2_) {
			body.m_controllerList = _loc2_.nextController;
		}
		--body.m_controllerCount;
		--m_bodyCount;
	}

	public function GetWorld():B2World {
		return m_world;
	}

	public function GetNext():B2Controller {
		return m_next;
	}

	public function GetBodyList():B2ControllerEdge {
		return m_bodyList;
	}

	public function Draw(debugDraw:B2DebugDraw) {}

	public function Clear() {
		while (m_bodyList != null) {
			removeBody(m_bodyList.body);
		}
	}

	public function AddBody(body:B2Body) {
		var _loc2_ = new B2ControllerEdge();
		_loc2_.controller = this;
		_loc2_.body = body;
		_loc2_.nextBody = m_bodyList;
		_loc2_.prevBody = null;
		m_bodyList = _loc2_;
		if (_loc2_.nextBody != null) {
			_loc2_.nextBody.prevBody = _loc2_;
		}
		++m_bodyCount;
		_loc2_.nextController = body.m_controllerList;
		_loc2_.prevController = null;
		body.m_controllerList = _loc2_;
		if (_loc2_.nextController != null) {
			_loc2_.nextController.prevController = _loc2_;
		}
		++body.m_controllerCount;
	}
}
