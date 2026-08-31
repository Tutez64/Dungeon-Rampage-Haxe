package org.as3commons.collections.framework;

interface ISortedMap extends IMap extends ISortOrder {
	function higherKey(item:ASAny):ASAny;

	function lesserKey(item:ASAny):ASAny;

	function equalKeys(item:ASAny):Array<ASAny>;
}
