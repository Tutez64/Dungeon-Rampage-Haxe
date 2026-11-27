package starling.extensions.animate.styles;

class MaskColorTransformStyle extends ColorTransformStyle {
	public function new(matrix:Vector<Float> = null) {
		super(matrix);
		maskDiscard = true;
	}
}
