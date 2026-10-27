package town;

class MessageOfTheDay {
	public static inline final IMAGE_PORTRAIT = (0 : UInt);

	public static inline final IMAGE_LANDSCAPE = (1 : UInt);

	public static inline final MOVIE = (2 : UInt);

	public var type:UInt = 0;

	public var title:String;

	public var message:String;

	public var imageURL:String;

	public var mainText:String;

	public var mainCallback:ASFunction;

	public var webText:String;

	public var webURL:String;

	public function new(LayoutType:String, TitleText:String, MessageText:String, ImageURL:String, MainText:String, MainCallback:ASFunction, WebText:String,
			WebURL:String) {
		if (LayoutType == "IMAGE_PORTRAIT") {
			type = (0 : UInt);
		} else if (LayoutType == "IMAGE_LANDSCAPE") {
			type = (1 : UInt);
		} else if (LayoutType == "MOVIE") {
			type = (2 : UInt);
		}
		title = TitleText;
		message = MessageText;
		imageURL = ImageURL;
		mainText = MainText;
		mainCallback = MainCallback;
		webText = WebText;
		webURL = WebURL;
	}
}
