package modding;

/**
 * Base class of the `api` mod's entry, and of `mods.api.Mod`, which every other mod's entry extends.
 *
 * All three methods are optional. `onInit` runs before any of the game exists,
 * `onReady` once the account and clocks exist and before the loop, `onDispose`
 * on a graceful exit.
 */
class Mod {
	public function new() {}

	public function onInit(ctx:ModContext):Void {}

	public function onReady(ctx:ModContext):Void {}

	public function onDispose():Void {}
}
