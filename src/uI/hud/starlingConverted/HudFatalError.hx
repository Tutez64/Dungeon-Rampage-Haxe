package uI.hud.starlingConverted;

/*internal*/
class HudFatalError extends Error {
	public function new(message:String) {
		super(message);
		name = "HudFatalError";
	}
}
