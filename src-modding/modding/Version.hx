package modding;

/**
 * The release tag written into `mods/last-run.json` and checked against a mod's `drh`.
 *
 * `TAG` is the GitHub release number without the `V`. Package builds pass `-D drh_tag` from that tag;
 * a build without the define reports `0`.
 */
class Version {
	public static inline final TAG:String =
		#if drh_tag
		haxe.macro.Compiler.getDefine("drh_tag");
		#else
		"0";
		#end
}
