package generatedCode;

interface IHeroGameObjectOwner {
	function setOwnerNetworkComponentHeroGameObject(iface:HeroGameObjectOwnerNetworkComponent):Void;

	function ReportBuffEffect(byWho:UInt, amount:Int, buffId:UInt, effectiveness:Int):Void;

	function ReceivedBuffEffect(amount:Int, buffId:UInt, effectiveness:Int):Void;

	function TooFullForDoober(isHealthDoober:UInt):Void;

	function ProposeSelfRevive_Resp(yesno:UInt, isParty:UInt):Void;
}
