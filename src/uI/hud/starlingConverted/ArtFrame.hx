package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;

class ArtFrame {
	public var children:Vector<ArtChildState> = new Vector((0 : UInt));

	public var cell:BakedCell;

	@:allow(UI.Hud.StarlingConverted) var filterState:Int = 0;

	public function new() {}
}
