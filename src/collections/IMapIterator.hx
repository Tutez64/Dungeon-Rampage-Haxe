package collections;

interface IMapIterator extends IIterator {
	function get_key():ASAny;

	@:isVar var key(get, never):ASAny;

	function get_current():ASAny;

	@:isVar var current(get, never):ASAny;
}
