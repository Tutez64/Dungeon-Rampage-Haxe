package starling.rendering;

import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.events.Event;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.errors.MissingContextError;

class Program {
	static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();

	var _vertexShader:ByteArray;

	var _fragmentShader:ByteArray;

	var _program3D:Program3D;

	public function new(vertexShader:ByteArray, fragmentShader:ByteArray) {
		_vertexShader = vertexShader;
		_fragmentShader = fragmentShader;
		Starling.current.stage3D.addEventListener("context3DCreate", onContextCreated, false, 30, true);
	}

	public static function fromSource(vertexShader:String, fragmentShader:String, agalVersion:UInt = (1 : UInt)):Program {
		return new Program(sAssembler.assemble("vertex", vertexShader, agalVersion), sAssembler.assemble("fragment", fragmentShader, agalVersion));
	}

	public function dispose() {
		Starling.current.stage3D.removeEventListener("context3DCreate", onContextCreated);
		disposeProgram();
	}

	public function activate(context:Context3D = null) {
		if (context == null) {
			context = Starling.context;
			if (context == null) {
				throw new MissingContextError();
			}
		}
		if (_program3D == null) {
			_program3D = context.createProgram();
			_program3D.upload(_vertexShader, _fragmentShader);
		}
		context.setProgram(_program3D);
	}

	function onContextCreated(event:Event) {
		disposeProgram();
	}

	function disposeProgram() {
		if (_program3D != null) {
			_program3D.dispose();
			_program3D = null;
		}
	}
}
