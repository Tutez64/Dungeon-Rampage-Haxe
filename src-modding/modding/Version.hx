package modding;

/**
 * Facade contract and the release tag written into `mods/last-run.json`.
 *
 * `API` changes only when an existing wrapper or event changes. Adding one does not.
 * `TAG` is the GitHub release number without the `V`. Package builds pass `-D drh_tag`
 * from that tag; a build without the define reports `0`.
 */
class Version {
	public static inline final API:Int = 1;

	public static inline final TAG:String =
		#if drh_tag
		haxe.macro.Compiler.getDefine("drh_tag");
		#else
		"0";
		#end
}
