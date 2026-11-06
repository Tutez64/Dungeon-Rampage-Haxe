package collision;

interface IContactResolver {
	function enterContact(actorId:UInt):Void;

	function exitContact(actorId:UInt):Void;
}
