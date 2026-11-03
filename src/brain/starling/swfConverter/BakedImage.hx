package brain.starling.swfConverter;

import starling.display.Image;
import starling.rendering.Painter;

class BakedImage extends Image {
	var mCell:BakedCell;

	public function new(cell:BakedCell = null) {
		super(ASCompat.coerce(cell != null ? cell.texture : null, starling.textures.Texture));
		touchable = false;
		this.cell = cell;
	}

	@:isVar public var cell(get, set):BakedCell;

	public function get_cell():BakedCell {
		return mCell;
	}

	function set_cell(value:BakedCell):BakedCell {
		mCell = value;
		if (value == null || !value.alive) {
			return value;
		}
		texture = value.texture;
		readjustSize();
		pivotX = value.pivotX;
		pivotY = value.pivotY;
		return value;
	}

	override public function render(painter:Painter) {
		if (mCell == null || !mCell.alive) {
			return;
		}
		super.render(painter);
	}
}
