import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class ASCompatMacro {
	public static macro function applyClosure(closureExpr:Expr, argsExpr:Expr):ExprOf<Dynamic> {
		var closureRef = macro __ax4ApplyClosure;
		var argsRef = macro __ax4ApplyArgs;
		var cases:Array<Case> = [];
		var maxDirectArgs = 24;
		var minArgs = 0;
		var maxArgs = maxDirectArgs;
		var returnsVoid = false;

		var isRestArg = function(t:Type):Bool {
			return switch t {
				case TAbstract(a, _):
					var at = a.get();
					at.pack.length == 1 && at.pack[0] == "haxe" && at.name == "Rest";
				case _:
					false;
			}
		};

		var isVoidType = function(t:Type):Bool {
			return switch t {
				case TAbstract(a, _):
					var at = a.get();
					at.pack.length == 0 && at.name == "Void";
				case _:
					false;
			}
		};

		switch Context.typeof(closureExpr) {
			case TFun(arguments, ret):
				var required = 0;
				for (arg in arguments) {
					if (!arg.opt) {
						required++;
					}
				}
				var hasRest = arguments.length > 0 && isRestArg(arguments[arguments.length - 1].t);
				minArgs = if (hasRest) arguments.length - 1 else required;
				maxArgs = if (hasRest) maxDirectArgs else arguments.length;
				returnsVoid = isVoidType(ret);
			case _:
		}

		for (argCount in minArgs...maxArgs + 1) {
			var callArgs = [for (i in 0...argCount) macro $argsRef[$v{i}]];
			var callExpr:Expr = {
				expr: ECall(closureRef, callArgs),
				pos: closureExpr.pos
			};
			cases.push({
				values: [macro $v{argCount}],
				guard: null,
				expr: returnsVoid ? macro {
					$callExpr;
					null;
				} : callExpr
			});
		}

		cases.push({
			values: [macro _],
			guard: null,
			expr: returnsVoid ? macro {
				Reflect.callMethod(null, $closureRef, $argsRef);
				null;
			} : macro Reflect.callMethod(null, $closureRef, $argsRef)
		});

		var setupClosure = macro var __ax4ApplyClosure:Dynamic = $closureExpr;
		var setupArgs = macro var __ax4ApplyArgs = $argsExpr;
		var ensureArgs = macro if (__ax4ApplyArgs == null) __ax4ApplyArgs = [];
		var switchExpr:Expr = {
			expr: ESwitch(macro __ax4ApplyArgs.length, cases, null),
			pos: closureExpr.pos
		};
		return {
			expr: EBlock([setupClosure, setupArgs, ensureArgs, switchExpr]),
			pos: closureExpr.pos
		};
	}

	public static macro function applyBoundMethod(obj:Expr, methodNameExpr:ExprOf<String>, argsExpr:Expr):ExprOf<Dynamic> {
		var methodName = switch methodNameExpr.expr {
			case EConst(CString(value, _)):
				value;
			case _:
				Context.error("applyBoundMethod expects a string literal method name", methodNameExpr.pos);
		}

		var argsRef = macro __ax4ApplyArgs;
		var cases:Array<Case> = [];
		var maxDirectArgs = 24;
		var minArgs = 0;
		var maxArgs = maxDirectArgs;
		var returnsVoid = false;
		var methodFieldForTyping:Expr = {
			expr: EField(obj, methodName),
			pos: methodNameExpr.pos
		};

		var isRestArg = function(t:Type):Bool {
			return switch t {
				case TAbstract(a, _):
					var at = a.get();
					at.pack.length == 1 && at.pack[0] == "haxe" && at.name == "Rest";
				case _:
					false;
			}
		};

		var isVoidType = function(t:Type):Bool {
			return switch t {
				case TAbstract(a, _):
					var at = a.get();
					at.pack.length == 0 && at.name == "Void";
				case _:
					false;
			}
		};

		switch Context.typeof(methodFieldForTyping) {
			case TFun(arguments, ret):
				var required = 0;
				for (arg in arguments) {
					if (!arg.opt) {
						required++;
					}
				}
				var hasRest = arguments.length > 0 && isRestArg(arguments[arguments.length - 1].t);
				minArgs = if (hasRest) arguments.length - 1 else required;
				maxArgs = if (hasRest) maxDirectArgs else arguments.length;
				returnsVoid = isVoidType(ret);
			case _:
		}

		for (argCount in minArgs...maxArgs + 1) {
			var callArgs = [for (i in 0...argCount) macro $argsRef[$v{i}]];
			var callExpr = {
				expr: ECall({
					expr: EField(obj, methodName),
					pos: methodNameExpr.pos
				}, callArgs),
				pos: methodNameExpr.pos
			};
			cases.push({
				values: [macro $v{argCount}],
				guard: null,
				expr: returnsVoid ? macro {
					$callExpr;
					null;
				} : callExpr
			});
		}

		cases.push({
			values: [macro _],
			guard: null,
			expr: returnsVoid ? macro {
				Reflect.callMethod($obj, Reflect.field($obj, $v{methodName}), $argsRef);
				null;
			} : macro Reflect.callMethod($obj, Reflect.field($obj, $v{methodName}), $argsRef)
		});

		var setupArgs = macro var __ax4ApplyArgs = $argsExpr;
		var ensureArgs = macro if (__ax4ApplyArgs == null) __ax4ApplyArgs = [];
		var switchExpr:Expr = {
			expr: ESwitch(macro __ax4ApplyArgs.length, cases, null),
			pos: methodNameExpr.pos
		};
		return {
			expr: EBlock([setupArgs, ensureArgs, switchExpr]),
			pos: methodNameExpr.pos
		};
	}
}
