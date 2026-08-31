package town;

interface ITownAdProvider {
	function CheckForAds(callback:ASFunction):Void;

	function ShowingAdButton():Void;

	function ShowAdPlayer():Void;

	function SetResetCallback(callback:ASFunction):Void;
}
