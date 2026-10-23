package modding;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * The compile-time half of the core, installed on the game's types by `project.xml`. Other types are
 * left as they are.
 *
 * - Every `destroy()` of a game object (`brain.gameObject.GameObject` and its subclasses) starts by
 *   telling the host, so mods see the object still whole whichever class destroys it and from wherever:
 *   the most derived `destroy()` runs first, and the host only reports an object once.
 * - Every generated network component (`generatedCode.*NetworkComponent`) gets a table of the fields
 *   its `recvById` dispatches, by id, as its `recv_` methods name them, so mods see a field's name and
 *   not only its number.
 */
class Hooks {
	/** Adds `build` to the types of `classpath`, by its top-level packages: the game's own, not the libraries'. */
	public static function install(classpath:String):Void {
		if (!sys.FileSystem.isDirectory(classpath))
			Context.fatalError("modding.Hooks: no " + classpath + " directory", Context.currentPos());
		for (name in sys.FileSystem.readDirectory(classpath))
			if (sys.FileSystem.isDirectory(classpath + "/" + name))
				haxe.macro.Compiler.addGlobalMetadata(name, "@:build(modding.Hooks.build())");
	}

	static function build():Null<Array<Field>> {
		var local = Context.getLocalClass();
		if (local == null)
			return null;
		var type = local.get();
		if (isGameObject(type))
			return gone(type);
		if (type.pack.join(".") == "generatedCode" && StringTools.endsWith(type.name, "NetworkComponent"))
			return fieldNames(type);
		return null;
	}

	static function gone(type:ClassType):Null<Array<Field>> {
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
					type.meta.add(":access", [macro modding.Host], field.pos);
					return fields;
				default:
			}
		}
		return null;
	}

	/**
	 * `__fieldNames`, from `recvById`'s `switch (fieldid - first) { case n: recv_name(packet); }`: the
	 * id `first + n` is `<Class>.name`, `<Class>` the component's name without `NetworkComponent`.
	 */
	static function fieldNames(type:ClassType):Null<Array<Field>> {
		var fields = Context.getBuildFields();
		var owner = type.name.substr(0, type.name.length - "NetworkComponent".length);
		var entries:Array<Expr> = [];
		for (field in fields) {
			if (field.name != "recvById")
				continue;
			switch (field.kind) {
				case FFun(f) if (f.expr != null):
					collect(f.expr, owner, entries);
				default:
			}
		}
		if (entries.length == 0)
			return null;
		var pos = Context.currentPos();
		fields.push({
			name: "__fieldNames",
			access: [APublic, AStatic],
			kind: FVar(macro :Map<Int, String>, {expr: EArrayDecl(entries), pos: pos}),
			meta: [{name: ":keep", pos: pos}],
			pos: pos
		});
		return fields;
	}

	static function collect(e:Expr, owner:String, entries:Array<Expr>):Void {
		switch (e.expr) {
			case EBlock(exprs):
				for (inner in exprs)
					collect(inner, owner, entries);
			case EParenthesis(inner):
				collect(inner, owner, entries);
			case ESwitch(subject, cases, _):
				var first = offset(subject);
				if (first == null)
					return;
				for (c in cases) {
					var name = received(c.expr);
					if (name == null)
						continue;
					for (value in c.values)
						switch (value.expr) {
							case EConst(CInt(n)):
								var id = first + Std.parseInt(n);
								entries.push(macro $v{id} => $v{owner + "." + name});
							default:
						}
				}
			default:
		}
	}

	/** `first` in `fieldid - first`, 0 for a bare `fieldid`. */
	static function offset(e:Expr):Null<Int> {
		return switch (e.expr) {
			case EParenthesis(inner): offset(inner);
			case EConst(CIdent("fieldid")): 0;
			case EBinop(OpSub, {expr: EConst(CIdent("fieldid"))}, {expr: EConst(CInt(n))}): Std.parseInt(n);
			default: null;
		}
	}

	/** The name of the `recv_` method a case calls. */
	static function received(e:Null<Expr>):Null<String> {
		if (e == null)
			return null;
		return switch (e.expr) {
			case EBlock(exprs):
				var found:Null<String> = null;
				for (inner in exprs)
					if (found == null)
						found = received(inner);
				found;
			case ECall({expr: EConst(CIdent(name))}, _) if (StringTools.startsWith(name, "recv_")):
				name.substr("recv_".length);
			default: null;
		}
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
