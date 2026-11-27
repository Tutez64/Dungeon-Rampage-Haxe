package starling.rendering;

import flash.errors.ArgumentError;

/*internal*/
class VertexDataAttribute {
	static var FORMAT_SIZES:ASObject;

	public var name:String;

	public var format:String;

	public var isColor:Bool = false;

	public var offset:Int = 0;

	public var size:Int = 0;

	public function new(name:String, format:String, offset:Int) {
		if (!FORMAT_SIZES.hasOwnProperty(format)) {
			throw new ArgumentError("Invalid attribute format: " + format + ". " + "Use one of the following: \'float1\'-\'float4\', \'bytes4\'");
		}
		this.name = name;
		this.format = format;
		this.offset = offset;
		this.size = ASCompat.toInt(FORMAT_SIZES[format]);
		this.isColor = name.indexOf("color") != -1 || name.indexOf("Color") != -1;
	}

	static function __init__() {
		FORMAT_SIZES = {
			"bytes4": 4,
			"float1": 4,
			"float2": 8,
			"float3": 12,
			"float4": 16
		};
	}
}
