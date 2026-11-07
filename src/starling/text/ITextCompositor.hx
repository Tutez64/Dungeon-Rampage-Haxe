package starling.text;

import starling.display.MeshBatch;
import starling.styles.MeshStyle;

interface ITextCompositor {
	function fillMeshBatch(meshBatch:MeshBatch, width:Float, height:Float, text:String, format:TextFormat, options:TextOptions = null):Void;

	function clearMeshBatch(meshBatch:MeshBatch):Void;

	function getDefaultMeshStyle(previousStyle:MeshStyle, format:TextFormat, options:TextOptions):MeshStyle;

	function dispose():Void;
}
