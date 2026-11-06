package starling.styles;

import flash.display3D.Context3D;
import flash.geom.Matrix;
import starling.core.Starling;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.RenderState;
import starling.rendering.VertexDataFormat;
import starling.textures.Texture;
import starling.utils.RenderUtil;

/**
	Lets one batch draw meshes from several atlases, each vertex holding the index of its atlas: the game
	changes atlas so often that most of its batches held a single mesh, and each batch is a draw call.
	The same idea as MultiTextureStyle in openfl/starling, which DR's Starling doesn't have.
**/
class MultiAtlasStyle extends MeshStyle {
	/** The most atlases in a batch, 0 for what the GPU allows. **/
	public static var maxAtlases = 0;

	public static final FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("texture:float1");

	public var extraRoots:Array<Texture> = [];

	public function new() {
		super();
	}

	override public function copyFrom(meshStyle:MeshStyle) {
		super.copyFrom(meshStyle);
		extraRoots = Std.isOfType(meshStyle, MultiAtlasStyle) ? (cast meshStyle : MultiAtlasStyle).extraRoots.copy() : [];
	}

	override public function createEffect():MeshEffect {
		return new MultiAtlasEffect();
	}

	override public function updateEffect(effect:MeshEffect, state:RenderState) {
		(cast effect : MultiAtlasEffect).extraRoots = extraRoots;
		super.updateEffect(effect, state);
	}

	// The shader needs AGAL 2, and a sampler for each atlas.
	static function detectMaxAtlases():Int {
		var profile = Starling.current.profile;
		if (profile == null || StringTools.startsWith(profile, "baseline")) {
			return 1;
		}
		#if flash
		return 1;
		#else
		var gl = @:privateAccess Starling.context.gl;
		return Std.int(Math.min(16, gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS)));
		#end
	}

	// The index of an atlas in this batch: 0 for its first atlas, -1 for one it doesn't hold.
	function indexOfRoot(root:Texture):Int {
		if (root == _textureRoot) {
			return 0;
		}
		var roots = extraRoots;
		for (i in 0...roots.length) {
			if (roots[i] == root) {
				return i + 1;
			}
		}
		return -1;
	}

	override public function canBatchWith(meshStyle:MeshStyle):Bool {
		if (meshStyle._type != _type || (_texture == null) != (meshStyle._texture == null)) {
			return false;
		}
		if (_texture == null) {
			return true;
		}
		if (_textureSmoothing != meshStyle._textureSmoothing || _textureRepeat != meshStyle._textureRepeat) {
			return false;
		}
		var other:MultiAtlasStyle = cast meshStyle;
		if (other.extraRoots.length > 0) {
			return false;
		}
		var root = meshStyle._textureRoot;
		if (indexOfRoot(root) >= 0) {
			return true;
		}
		// one program per format: atlases of another format don't share a batch
		if (maxAtlases == 0) {
			maxAtlases = detectMaxAtlases();
		}
		return extraRoots.length + 1 < maxAtlases && RenderUtil.getTextureVariantBits(root) == RenderUtil.getTextureVariantBits(_textureRoot);
	}

	override public function batchVertexData(targetStyle:MeshStyle, targetVertexID:Int = 0, matrix:Matrix = null, vertexID:Int = 0, numVertices:Int = -1) {
		super.batchVertexData(targetStyle, targetVertexID, matrix, vertexID, numVertices);
		if (targetStyle._type != _type || _textureRoot == null) {
			return;
		}
		var target:MultiAtlasStyle = cast targetStyle;
		var index = target.indexOfRoot(_textureRoot);
		if (index == 0) {
			// a mesh's own vertices hold 0, which was just copied
			return;
		}
		if (index < 0) {
			target.extraRoots.push(_textureRoot);
			index = target.extraRoots.length;
		}
		var count = numVertices < 0 ? _vertexData.numVertices - vertexID : numVertices;
		var data = target._vertexData;
		for (i in 0...count) {
			data.setFloat(targetVertexID + i, "texture", index);
		}
	}

	override public function get_vertexFormat():VertexDataFormat {
		return FORMAT;
	}
}

class MultiAtlasEffect extends MeshEffect {
	public var extraRoots:Array<Texture> = [];

	static final thresholds:flash.Vector<Float> = {
		var values = new flash.Vector<Float>();
		for (i in 0...16) values.push(i + 0.5);
		values;
	};

	public function new() {
		super();
	}

	override function get_programVariantName():UInt {
		return ((super.get_programVariantName() : Int) | extraRoots.length << 8 : UInt);
	}

	override function createProgram():Program {
		if (extraRoots.length == 0) {
			return super.createProgram();
		}
		var vertex = "m44 op, va0, vc0\nmov v0, va1\nmul v1, va2, vc4\nmov v2, va3";
		var lines:Array<String> = [];
		choose(lines, 0, extraRoots.length + 1);
		lines.push("mul oc, ft0, v1");
		return Program.fromSource(vertex, lines.join("\n"), (2 : UInt));
	}

	// A binary tree of tests on the vertex's atlas index, from `first`, over `count` atlases.
	function choose(lines:Array<String>, first:Int, count:Int) {
		if (count == 1) {
			lines.push(RenderUtil.createAGALTexOperation("ft0", "v0", first, texture));
			return;
		}
		var half = (count + 1) >> 1;
		var last = first + half - 1;
		lines.push("ifl v2.x, fc" + (last >> 2) + "." + "xyzw".charAt(last & 3));
		choose(lines, first, half);
		lines.push("els");
		choose(lines, first + half, count - half);
		lines.push("eif");
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		var count = extraRoots.length;
		if (count > 0) {
			for (i in 0...count) {
				RenderUtil.setSamplerStateAt(i + 1, extraRoots[i].mipMapping, textureSmoothing, textureRepeat);
				context.setTextureAt(i + 1, extraRoots[i].base);
			}
			vertexFormat.setVertexBufferAt(3, vertexBuffer, "texture");
			context.setProgramConstantsFromVector("fragment", 0, thresholds, (count + 4) >> 2);
		}
	}

	override function afterDraw(context:Context3D) {
		for (i in 0...extraRoots.length) {
			context.setTextureAt(i + 1, null);
		}
		if (extraRoots.length > 0) {
			context.setVertexBufferAt(3, null);
		}
		super.afterDraw(context);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return MultiAtlasStyle.FORMAT;
	}
}
