package brain.camera;

import brain.workLoop.WorkComponent;

class CameraStrategy {
	var mCamera:Camera;

	public function new(camera:Camera) {
		mCamera = camera;
	}

	public function destroy() {
		mCamera = null;
		stop();
	}

	public function start(workComponent:WorkComponent) {
		throw new Error("Override this start function in the camera strategy sub-class.");
	}

	public function stop() {
		throw new Error("Override this stop function in the camera strategy sub-class.");
	}
}
