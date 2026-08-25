package gameMasterDictionary;

class GMFeedPosts {
	public var Id:UInt = 0;

	public var Constant:String;

	public var FeedName:String;

	public var IdTrigger:UInt = 0;

	public var LevelTrigger:UInt = 0;

	public var Category:String;

	public var FeedCaption:String;

	public var FeedDescriptions:String;

	public var FeedActionsName:String;

	public var FeedActionsLink:String;

	public var FeedActionsReward:String;

	public var FeedImageLink:String;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Constant = jsonAsset.Constant;
		FeedName = jsonAsset.FeedName;
		IdTrigger = (ASCompat.toInt(jsonAsset.IdTrigger) : UInt);
		Category = jsonAsset.Category;
		FeedCaption = jsonAsset.FeedCaption;
		FeedDescriptions = jsonAsset.FeedDescriptions;
		FeedActionsName = jsonAsset.FeedActionsName;
		FeedActionsLink = jsonAsset.FeedActionsLink;
		FeedActionsReward = jsonAsset.FeedActionsReward;
		FeedImageLink = jsonAsset.FeedImageLink;
		LevelTrigger = (ASCompat.toInt(jsonAsset.LevelTrigger) : UInt);
	}
}
