package modding;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * The compile-time half of the core, installed on the game's types by `project.xml`. Every `destroy()` of
 * a game object (`brain.gameObject.GameObject` and its subclasses) starts by telling the host, so mods
 * see the object still whole whichever class destroys it and from wherever: the most derived
 * `destroy()` runs first, and the host only reports an object once. Other types are left as they are.
 */
class Hooks {
	/** Adds `gone` to the types of `classpath`, by its top-level packages: the game's own, not the libraries'. */
	public static function install(classpath:String):Void {
		if (!sys.FileSystem.isDirectory(classpath))
			Context.fatalError("modding.Hooks: no " + classpath + " directory", Context.currentPos());
		for (name in sys.FileSystem.readDirectory(classpath))
			if (sys.FileSystem.isDirectory(classpath + "/" + name))
				haxe.macro.Compiler.addGlobalMetadata(name, "@:build(modding.Hooks.gone())");
	}

	static function gone():Null<Array<Field>> {
		var local = Context.getLocalClass();
		if (local == null || !isGameObject(local.get()))
			return null;
		var fields = Context.getBuildFields();
		for (field in fields) {
			if (field.name != "destroy")
				continue;
			switch (field.kind) {
				case FFun(f) if (f.expr != null):
					f.expr = macro {
						modding.Host.gone(this);
						${f.expr};
					};
					local.get().meta.add(":access", [macro modding.Host], field.pos);
					return fields;
				default:
			}
		}
		return null;
	}

	static function isGameObject(type:ClassType):Bool {
		var current:Null<ClassType> = type;
		while (current != null) {
			if (current.name == "GameObject" && current.pack.join(".") == "brain.gameObject")
				return true;
			current = current.superClass == null ? null : current.superClass.t.get();
		}
		return false;
	}
}
#end
