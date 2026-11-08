package starling.assets;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.system.System;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.events.EventDispatcher;
import starling.text.BitmapFont;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.textures.TextureOptions;
import starling.utils.MathUtil;
import starling.utils.Execute;
import starling.assets.AssetManager;
import flash.errors.ArgumentError;

class AssetManager extends EventDispatcher {
	static inline final NO_NAME = "unnamed";

	static var sNoNameCount:Int = 0;

	static final NAME_REGEX:compat.RegExp = new compat.RegExp("(([^?\\/\\\\]+?)(?:\\.([\\w\\-]+))?)(?:\\?.*)?$");

	static var sNames:Vector<String> = new Vector((0 : UInt));

	var _starling:Starling;

	var _assets:ASDictionary<ASAny, ASAny>;

	var _verbose:Bool = false;

	var _numConnections:Int = 0;

	var _dataLoader:DataLoader;

	var _textureOptions:TextureOptions;

	var _queue:Vector<AssetReference>;

	var _registerBitmapFontsWithFontFace:Bool = false;

	var _assetFactories:Vector<AssetFactory>;

	var _numRestoredTextures:Int = 0;

	var _numLostTextures:Int = 0;

	public function new(scaleFactor:Float = 1) {
		super();
		_assets = new ASDictionary<ASAny, ASAny>();
		_verbose = true;
		_textureOptions = new TextureOptions(scaleFactor);
		_queue = new Vector<AssetReference>((0 : UInt));
		_numConnections = 3;
		_dataLoader = new DataLoader();
		_assetFactories = new Vector<AssetFactory>((0 : UInt));
		registerFactory(new BitmapTextureFactory());
		registerFactory(new AtfTextureFactory());
		registerFactory(new SoundFactory());
		registerFactory(new JsonFactory());
		registerFactory(new XmlFactory());
		registerFactory(new ByteArrayFactory(), -100);
	}

	static function comparePriorities(a:ASObject, b:ASObject):Int {
		if (a.priority == b.priority) {
			return 0;
		}
		return a.priority > b.priority ? -1 : 1;
	}

	static function getDictionaryKeys(dictionary:ASDictionary<ASAny, ASAny>, prefix:String = "", out:Vector<String> = null):Vector<String> {
		var _loc4_:String;
		if (out == null) {
			out = new Vector<String>((0 : UInt));
		}
		if (dictionary != null) {
			if (checkNullIteratee(dictionary))
				for (_tmp_ in dictionary.keys()) {
					_loc4_ = _tmp_;
					if (_loc4_.indexOf(prefix) == 0) {
						out[out.length] = _loc4_;
					}
				}
			ASCompat.ASVector.sortWithOptions(out, 1);
		}
		return out;
	}

	static function getUniqueName():String {
		return "unnamed-" + sNoNameCount++;
	}

	public function dispose() {
		var _loc2_:ASObject;
		purgeQueue();
		var _loc1_:ASDictionary<ASAny, ASAny>;
		final __ax4_iter_375 = _assets;
		if (checkNullIteratee(__ax4_iter_375))
			for (_tmp_ in __ax4_iter_375) {
				_loc1_ = (_tmp_ : ASDictionary<ASAny, ASAny>);
				if (checkNullIteratee(_loc1_))
					for (_tmp_ in _loc1_) {
						_loc2_ = _tmp_;
						disposeAsset(_loc2_);
					}
			}
	}

	public function purge() {
		log("Purging all assets, emptying queue");
		purgeQueue();
		dispose();
		_assets = new ASDictionary<ASAny, ASAny>();
	}

	public function enqueue(..._rest:ASAny) {
		var __ax4_iter_376:compat.XMLList;
		var __ax4_iter_377:compat.XMLList;
		var rest = ASCompat.restToArray(_rest);
		var asset:ASObject;
		var typeXml:compat.XML;
		var childNode:compat.XML;
		var url:String;
		var mimeType:String;
		var processNode:compat.XML->Void;
		var assets = rest;
		if (checkNullIteratee(assets))
			for (_tmp_ in assets) {
				asset = _tmp_;
				if (Std.isOfType(asset, Array)) {
					enqueue(...(asset ?? []));
				} else if (Std.isOfType(asset, Class)) {
					processNode = function(param1:compat.XML) {
						url = findUrlInVariableMetadata(param1);
						mimeType = findMimeTypeInVariableMetadata(param1);
						if (_verbose && (ASCompat.stringAsBool(url) || ASCompat.stringAsBool(mimeType))) {
							log("Found class with embed information. URL: \'" + url + "\', mimeType: \'" + mimeType + "\'");
						}
						enqueueSingle(asset[param1.attribute("name")], param1.attribute("name"), null, getExtensionFromUrl(url), mimeType);
					};
					typeXml = ASCompat.describeType(asset);
					if (_verbose) {
						log("Looking for static embedded assets in \'" + typeXml.attribute("name").toString().split("::").pop() + "\'");
					}
					__ax4_iter_376 = ASCompat.filterXmlList(typeXml.child("constant"), function(__xml:compat.XML):Bool {
						return __xml.attribute("type") == "Class";
					});
					if (checkNullIteratee(__ax4_iter_376))
						for (_tmp_ in __ax4_iter_376) {
							childNode = _tmp_;
							processNode(childNode);
						}
					__ax4_iter_377 = ASCompat.filterXmlList(typeXml.child("variable"), function(__xml:compat.XML):Bool {
						return __xml.attribute("type") == "Class";
					});
					if (checkNullIteratee(__ax4_iter_377))
						for (_tmp_ in __ax4_iter_377) {
							childNode = _tmp_;
							processNode(childNode);
						}
				} else if (ASCompat.getQualifiedClassName(asset) == "flash.filesystem::File") {
					if (!ASCompat.toBool(asset["exists"])) {
						log("File or directory not found: \'" + Std.string(asset["url"]) + "\'");
					} else if (!ASCompat.toBool(asset["isHidden"])) {
						if (ASCompat.toBool(asset["isDirectory"])) {
							enqueue(...(asset["getDirectoryListing"]() ?? []));
						} else {
							enqueueSingle(asset);
						}
					}
				} else if (Std.isOfType(asset, String) || Std.isOfType(asset, URLRequest) || Std.isOfType(asset, AssetManager)) {
					enqueueSingle(asset);
				} else {
					log("Ignoring unsupported asset type: " + ASCompat.getQualifiedClassName(asset));
				}
			}
	}

	function findUrlInVariableMetadata(variableDeclarationNode:compat.XML):String {
		var _loc11_:Int;
		var _loc10_:compat.XMLList;
		var _loc2_:compat.XML = null;
		var _loc3_:compat.XML = null;
		final __ax4_iter_378 = ASCompat.filterXmlList(variableDeclarationNode.child("metadata"), function(__xml:compat.XML):Bool {
			return __xml.attribute("name") == "Embed";
		});
		if (checkNullIteratee(__ax4_iter_378))
			for (_tmp_ in __ax4_iter_378) {
				_loc2_ = _tmp_;
				_loc11_ = 0;
				_loc10_ = ASCompat.filterXmlList(_loc2_.child("arg"), function(__xml:compat.XML):Bool {
					return __xml.attribute("key") == "source";
				});
				if (checkNullIteratee(_loc10_))
					for (_tmp_ in _loc10_) {
						_loc3_ = _tmp_;
						return _loc3_.attribute("value");
					}
			}
		return null;
	}

	function findMimeTypeInVariableMetadata(variableDeclarationNode:compat.XML):String {
		var _loc11_:Int;
		var _loc10_:compat.XMLList;
		var _loc2_:compat.XML = null;
		var _loc3_:compat.XML = null;
		final __ax4_iter_379 = ASCompat.filterXmlList(variableDeclarationNode.child("metadata"), function(__xml:compat.XML):Bool {
			return __xml.attribute("name") == "Embed";
		});
		if (checkNullIteratee(__ax4_iter_379))
			for (_tmp_ in __ax4_iter_379) {
				_loc2_ = _tmp_;
				_loc11_ = 0;
				_loc10_ = ASCompat.filterXmlList(_loc2_.child("arg"), function(__xml:compat.XML):Bool {
					return __xml.attribute("key") == "mimeType";
				});
				if (checkNullIteratee(_loc10_))
					for (_tmp_ in _loc10_) {
						_loc3_ = _tmp_;
						return _loc3_.attribute("value");
					}
			}
		return null;
	}

	public function enqueueSingle(asset:ASObject, name:String = null, options:TextureOptions = null, customExtension:String = null,
			customMimeType:String = null):String {
		if (Std.isOfType(asset, Class)) {
			asset = ASCompat.createInstance(asset, []);
		}
		var _loc7_ = new AssetReference(asset);
		_loc7_.name = ASCompat.orValue(if (ASCompat.stringAsBool(name)) name else getNameFromUrl(_loc7_.url), getUniqueName());
		_loc7_.extension = if (ASCompat.stringAsBool(customExtension)) customExtension else getExtensionFromUrl(_loc7_.url);
		_loc7_.mimeType = customMimeType;
		_loc7_.textureOptions = if (options != null) options else _textureOptions;
		var _loc6_ = ASCompat.orValue(getFilenameFromUrl(_loc7_.url), _loc7_.name);
		_queue.push(_loc7_);
		log("Enqueuing \'" + _loc6_ + "\'");
		return _loc7_.name;
	}

	public function dequeue(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var assetNames = rest;
		_queue = ASCompat.ASVectorTools.filter(_queue, function(param1:AssetReference, param2:Int, param3:ASAny):Bool {
			return assetNames.indexOf(param1.name) == -1;
		});
	}

	public function purgeQueue() {
		_queue.length = 0;
		_dataLoader.close();
		dispatchEventWith("cancel");
	}

	public function loadQueue(onComplete:ASFunction, onError:ASFunction = null, onProgress:ASFunction = null) {
		var onAssetLoaded:ASFunction = null;
		var onAssetLoadError:(String, AssetReference) -> Void = null;
		var onAssetProgress:Float->Void = null;
		var runPostProcessors:() -> Void = null;
		var onCanceled:() -> Void = null;
		var finish:() -> Void = null;
		var factoryHelper:AssetFactoryHelper = null;
		var i:Int;
		var self:AssetManager = null;
		var canceled = false;
		var queue:Vector<AssetReference> = null;
		var numAssets = 0;
		var numComplete = 0;
		var numConnections:Int;
		var assetProgress:Vector<Float> = null;
		var postProcessors:Vector<AssetPostProcessor> = null;
		var loadNextAsset = function() {
			var _loc1_ = 0;
			if (canceled) {
				return;
			}
			_loc1_ = 0;
			while (_loc1_ < numAssets) {
				if (assetProgress[_loc1_] < 0) {
					loadFromQueue(queue, assetProgress, _loc1_, factoryHelper, onAssetLoaded, onAssetProgress, onAssetLoadError, onError);
					break;
				}
				_loc1_++;
			}
		};
		onAssetLoaded = function(param1:String = null, param2:ASObject = null, param3:String = null) {
			if (canceled && ASCompat.toBool(param2)) {
				disposeAsset(param2);
			} else {
				if (ASCompat.stringAsBool(param1) && ASCompat.toBool(param2)) {
					addAsset(param1, param2, param3);
				}
				numComplete = numComplete + 1;
				if (numComplete == numAssets) {
					ASCompat.ASVector.sort(postProcessors, comparePriorities);
					ASCompat.setTimeout(runPostProcessors, 1);
				} else {
					ASCompat.setTimeout(loadNextAsset, 1);
				}
			}
		};
		onAssetLoadError = function(param1:String, param2:AssetReference) {
			if (!canceled) {
				starling.utils.Execute.execute(onError, param1, param2);
				onAssetLoaded();
			}
		};
		onAssetProgress = function(param1:Float) {
			if (!canceled) {
				starling.utils.Execute.execute(onProgress, param1 * 0.95);
			}
		};
		var addPostProcessor = function(param1:ASFunction, param2:Int) {
			postProcessors.push(new AssetPostProcessor(param1, param2));
		};
		runPostProcessors = function() {
			if (!canceled) {
				if (postProcessors.length != 0) {
					try {
						postProcessors.shift().execute(self);
					} catch (e:Dynamic) {
						starling.utils.Execute.execute(onError, ASCompat.asError(e).message);
					}
					ASCompat.setTimeout(runPostProcessors, 1);
				} else {
					finish();
				}
			}
		};
		onCanceled = function() {
			canceled = true;
			removeEventListener("cancel", (cast onCanceled));
		};
		finish = function() {
			onCanceled();
			starling.utils.Execute.execute(onProgress, 1);
			starling.utils.Execute.execute(onComplete, self);
		};
		if (_queue.length == 0) {
			finish();
			return;
		}
		addEventListener("cancel", (cast onCanceled));
		factoryHelper = new AssetFactoryHelper();
		factoryHelper.getNameFromUrlFunc = getNameFromUrl;
		factoryHelper.getExtensionFromUrlFunc = getExtensionFromUrl;
		factoryHelper.addPostProcessorFunc = addPostProcessor;
		factoryHelper.addAssetFunc = addAsset;
		factoryHelper.onRestoreFunc = onAssetRestored;
		factoryHelper.dataLoader = _dataLoader;
		factoryHelper.logFunc = log;
		self = this;
		canceled = false;
		queue = _queue.concat();
		numAssets = queue.length;
		numComplete = 0;
		numConnections = ASCompat.floatToInt(MathUtil.min(_numConnections, numAssets));
		assetProgress = new Vector<Float>((numAssets : UInt), true);
		postProcessors = new Vector<AssetPostProcessor>((0 : UInt));
		_starling = Starling.current;
		_queue.length = 0;
		i = 0;
		while (i < numAssets) {
			assetProgress[i] = -1;
			i = i + 1;
		}
		i = 0;
		while (i < numConnections) {
			loadNextAsset();
			i = i + 1;
		}
	}

	function loadFromQueue(queue:Vector<AssetReference>, progressRatios:Vector<Float>, index:Int, helper:AssetFactoryHelper, onComplete:ASFunction,
			onProgress:ASFunction, onError:ASFunction, onIntermediateError:ASFunction) {
		var onLoadProgress:Float->Void = null;
		var onAnyError:String->Void = null;
		var onFactoryError:String->Void = null;
		var referenceCount = 0;
		var reference:AssetReference = null;
		var onLoadComplete:ASFunction = function(param1:ASObject, param2:String = null, param3:String = null, param4:String = null) {
			if (_starling != null) {
				_starling.makeCurrent();
			}
			onLoadProgress(1);
			if (ASCompat.toBool(param1)) {
				reference.data = param1;
			}
			if (ASCompat.stringAsBool(param3)) {
				reference.name = param3;
			}
			if (ASCompat.stringAsBool(param4)) {
				reference.extension = param4;
			}
			if (ASCompat.stringAsBool(param2)) {
				reference.mimeType = param2;
			}
			var _loc5_ = getFactoryFor(reference);
			if (_loc5_ == null) {
				starling.utils.Execute.execute(onAnyError, "Warning: no suitable factory found for \'" + reference.name + "\'");
			} else {
				var diagStart = diag.LoadDiag.begin("asset create " + (reference.url != null ? reference.url : reference.name));
				_loc5_.create(reference, helper, onComplete, onFactoryError);
				diag.LoadDiag.work("create " + reference.extension, reference.url != null ? reference.url : reference.name, diagStart);
			}
		};
		onLoadProgress = function(param1:Float) {
			var _loc5_ = 0;
			var _loc2_ = Math.NaN;
			progressRatios[index] = param1;
			var _loc3_:Float = 0;
			var _loc4_ = 1 / referenceCount;
			_loc5_ = 0;
			while (_loc5_ < referenceCount) {
				_loc2_ = progressRatios[_loc5_];
				if (_loc2_ > 0) {
					_loc3_ += _loc4_ * _loc2_;
				}
				_loc5_++;
			}
			starling.utils.Execute.execute(onProgress, MathUtil.min(_loc3_, 1));
		};
		var onLoadError = function(param1:String) {
			onLoadProgress(1);
			starling.utils.Execute.execute(onAnyError, "Error loading " + reference.name + ": " + param1);
		};
		onAnyError = function(param1:String) {
			log(param1);
			starling.utils.Execute.execute(onError, param1, reference);
		};
		onFactoryError = function(param1:String) {
			starling.utils.Execute.execute(onAnyError, "Error creating " + reference.name + ": " + param1);
		};
		var onManagerComplete = function() {
			onComplete(reference.name, reference.data);
		};
		referenceCount = queue.length;
		reference = queue[index];
		progressRatios[index] = 0;
		if (ASCompat.stringAsBool(reference.url)) {
			_dataLoader.load(reference.url, onLoadComplete, onLoadError, onLoadProgress);
		} else if (Std.isOfType(reference.data, AssetManager)) {
			ASCompat.dynamicAs(reference.data, AssetManager).loadQueue(onManagerComplete, onIntermediateError, onLoadProgress);
		} else {
			ASCompat.setTimeout(onLoadComplete, 1, reference.data);
		}
	}

	function getFactoryFor(asset:AssetReference):AssetFactory {
		var _loc4_ = 0;
		var _loc2_:AssetFactory = null;
		var _loc3_ = _assetFactories.length;
		_loc4_ = 0;
		while (_loc4_ < _loc3_) {
			_loc2_ = _assetFactories[_loc4_];
			if (_loc2_.canHandle(asset)) {
				return _loc2_;
			}
			_loc4_++;
		}
		return null;
	}

	function onAssetRestored(finished:Bool) {
		if (finished) {
			_numRestoredTextures = _numRestoredTextures + 1;
			if (_starling != null) {
				_starling.stage.setRequiresRedraw();
			}
			if (_numRestoredTextures == _numLostTextures) {
				dispatchEventWith("texturesRestored");
			}
		} else {
			_numLostTextures = _numLostTextures + 1;
		}
	}

	public function addAsset(name:String, asset:ASObject, type:String = null) {
		if (!ASCompat.stringAsBool(type)) {
			type = AssetType.fromAsset(asset);
		}
		var _loc4_ = (ASDictionary.getString(_assets, type) : ASDictionary<ASAny, ASAny>);
		if (_loc4_ == null) {
			_loc4_ = new ASDictionary<ASAny, ASAny>();
			_assets[type] = _loc4_;
		}
		log("Adding " + type + " \'" + name + "\'");
		var _loc5_:ASObject = ASDictionary.getString(_loc4_, name);
		if (ASCompat.toBool(_loc5_) && _loc5_ != asset) {
			log("Warning: name was already in use; disposing the previous " + type);
			disposeAsset(_loc5_);
		}
		_loc4_[name] = asset;
	}

	public function getAsset(type:String, name:String, recursive:Bool = true):ASObject {
		var _loc6_:AssetManager;
		var _loc7_:TextureAtlas;
		var _loc5_:ASDictionary<ASAny, ASAny> = null;
		var _loc10_:ASObject = null;
		var _loc4_:ASDictionary<ASAny, ASAny> = null;
		var _loc8_:Texture = null;
		if (recursive) {
			_loc5_ = (ASDictionary.getString(_assets, "assetManager") : ASDictionary<ASAny, ASAny>);
			if (_loc5_ != null) {
				if (checkNullIteratee(_loc5_))
					for (_tmp_ in _loc5_) {
						_loc6_ = ASCompat.coerce(_tmp_, AssetManager);
						_loc10_ = _loc6_.getAsset(type, name, true);
						if (ASCompat.toBool(_loc10_)) {
							return _loc10_;
						}
					}
			}
			if (type == "texture") {
				_loc4_ = (ASDictionary.getString(_assets, "textureAtlas") : ASDictionary<ASAny, ASAny>);
				if (_loc4_ != null) {
					if (checkNullIteratee(_loc4_))
						for (_tmp_ in _loc4_) {
							_loc7_ = ASCompat.coerce(_tmp_, starling.textures.TextureAtlas);
							_loc8_ = _loc7_.getTexture(name);
							if (_loc8_ != null) {
								return _loc8_;
							}
						}
				}
			}
		}
		var _loc9_ = (ASDictionary.getString(_assets, type) : ASDictionary<ASAny, ASAny>);
		if (_loc9_ != null) {
			return ASDictionary.getString(_loc9_, name);
		}
		return null;
	}

	public function getAssetNames(assetType:String, prefix:String = "", recursive:Bool = true, out:Vector<String> = null):Vector<String> {
		var _loc7_:AssetManager;
		var _loc8_:TextureAtlas;
		var _loc6_:ASDictionary<ASAny, ASAny> = null;
		var _loc5_:ASDictionary<ASAny, ASAny> = null;
		if (out == null) {
			out = new Vector<String>();
		}
		if (recursive) {
			_loc6_ = (ASDictionary.getString(_assets, "assetManager") : ASDictionary<ASAny, ASAny>);
			if (_loc6_ != null) {
				if (checkNullIteratee(_loc6_))
					for (_tmp_ in _loc6_) {
						_loc7_ = ASCompat.coerce(_tmp_, AssetManager);
						_loc7_.getAssetNames(assetType, prefix, true, out);
					}
			}
			if (assetType == "texture") {
				_loc5_ = (ASDictionary.getString(_assets, "textureAtlas") : ASDictionary<ASAny, ASAny>);
				if (_loc5_ != null) {
					if (checkNullIteratee(_loc5_))
						for (_tmp_ in _loc5_) {
							_loc8_ = ASCompat.coerce(_tmp_, starling.textures.TextureAtlas);
							_loc8_.getNames(prefix, out);
						}
				}
			}
		}
		getDictionaryKeys((ASDictionary.getString(_assets, assetType) : ASDictionary<ASAny, ASAny>), prefix, out);
		ASCompat.ASVector.sortWithOptions(out, 1);
		return out;
	}

	public function removeAsset(assetType:String, name:String, dispose:Bool = true) {
		var _loc5_:ASObject = null;
		var _loc4_ = (ASDictionary.getString(_assets, assetType) : ASDictionary<ASAny, ASAny>);
		if (_loc4_ != null) {
			_loc5_ = ASDictionary.getString(_loc4_, name);
			if (ASCompat.toBool(_loc5_)) {
				log("Removing " + assetType + " \'" + name + "\'");
				if (dispose) {
					disposeAsset(_loc5_);
				}
				_loc4_.remove(name);
			}
		}
	}

	public function getTexture(name:String):Texture {
		return ASCompat.dynamicAs(getAsset("texture", name), Texture);
	}

	public function getTextures(prefix:String = "", out:Vector<Texture> = null):Vector<Texture> {
		if (out == null) {
			out = new Vector<Texture>((0 : UInt));
		}
		var _loc3_:String;
		final __ax4_iter_380 = getTextureNames(prefix, sNames);
		if (checkNullIteratee(__ax4_iter_380))
			for (_tmp_ in __ax4_iter_380) {
				_loc3_ = _tmp_;
				out[out.length] = getTexture(_loc3_);
			}
		sNames.length = 0;
		return out;
	}

	public function getTextureNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("texture", prefix, true, out);
	}

	public function getTextureAtlas(name:String):TextureAtlas {
		return ASCompat.dynamicAs(getAsset("textureAtlas", name), TextureAtlas);
	}

	public function getTextureAtlasNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("textureAtlas", prefix, true, out);
	}

	public function getSound(name:String):Sound {
		return ASCompat.dynamicAs(getAsset("sound", name), Sound);
	}

	public function getSoundNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("sound", prefix, true, out);
	}

	public function playSound(name:String, startTime:Float = 0, loops:Int = 0, transform:SoundTransform = null):SoundChannel {
		var _loc5_ = getSound(name);
		if (_loc5_ != null) {
			return _loc5_.play(startTime, loops, transform);
		}
		return null;
	}

	public function getXml(name:String):compat.XML {
		return ASCompat.asXML(getAsset("xml", name));
	}

	public function getXmlNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("xml", prefix, true, out);
	}

	public function getObject(name:String):ASObject {
		return getAsset("object", name);
	}

	public function getObjectNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("object", prefix, true, out);
	}

	public function getByteArray(name:String):ByteArray {
		return (getAsset("byteArray", name) : ByteArray);
	}

	public function getByteArrayNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("byteArray", prefix, true, out);
	}

	public function getBitmapFont(name:String):BitmapFont {
		return ASCompat.dynamicAs(getAsset("bitmapFont", name), BitmapFont);
	}

	public function getBitmapFontNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("bitmapFont", prefix, true, out);
	}

	public function getAssetManager(name:String):AssetManager {
		return ASCompat.dynamicAs(getAsset("assetManager", name), AssetManager);
	}

	public function getAssetManagerNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		return getAssetNames("assetManager", prefix, true, out);
	}

	public function removeTexture(name:String, dispose:Bool = true) {
		removeAsset("texture", name, dispose);
	}

	public function removeTextureAtlas(name:String, dispose:Bool = true) {
		removeAsset("textureAtlas", name, dispose);
	}

	public function removeSound(name:String) {
		removeAsset("sound", name);
	}

	public function removeXml(name:String, dispose:Bool = true) {
		removeAsset("xml", name, dispose);
	}

	public function removeObject(name:String) {
		removeAsset("object", name);
	}

	public function removeByteArray(name:String, dispose:Bool = true) {
		removeAsset("byteArray", name, dispose);
	}

	public function removeBitmapFont(name:String, dispose:Bool = true) {
		removeAsset("bitmapFont", name, dispose);
	}

	public function removeAssetManager(name:String, dispose:Bool = true) {
		removeAsset("assetManager", name, dispose);
	}

	public function registerFactory(factory:AssetFactory, priority:Int = 0) {
		factory.priority = priority;
		_assetFactories.push(factory);
		ASCompat.ASVector.sort(_assetFactories, comparePriorities);
	}

	public function unregisterFactory(factory:AssetFactory) {
		var _loc2_ = _assetFactories.indexOf(factory);
		if (_loc2_ != -1) {
			_assetFactories.removeAt(_loc2_);
		}
	}

	function getFilenameFromUrl(url:String):String {
		var _loc2_:Array<ASAny> = null;
		if (ASCompat.stringAsBool(url)) {
			_loc2_ = matchRegEx(url);
			if (_loc2_ != null && _loc2_.length > 1) {
				return _loc2_[1];
			}
		}
		return null;
	}

	function getNameFromUrl(url:String):String {
		var _loc2_:Array<ASAny> = null;
		if (ASCompat.stringAsBool(url)) {
			_loc2_ = matchRegEx(url);
			if (_loc2_ != null && _loc2_.length > 2) {
				return _loc2_[2];
			}
		}
		return null;
	}

	function getExtensionFromUrl(url:String):String {
		var _loc2_:Array<ASAny> = null;
		if (ASCompat.stringAsBool(url)) {
			_loc2_ = matchRegEx(url);
			if (_loc2_ != null && _loc2_.length > 3) {
				return _loc2_[3];
			}
		}
		return "";
	}

	function matchRegEx(url:String):Array<ASAny> {
		return ASCompat.coerce(NAME_REGEX.exec(ASCompat.decodeURIComponent(url)), Array);
	}

	function disposeAsset(asset:ASObject) {
		if (ASCompat.isByteArray(asset)) {
			((asset : ByteArray)).clear();
		}
		if (Std.isOfType(asset, compat.XML.typeReference())) {
			System.disposeXML(ASCompat.asXML(asset));
		}
		if (asset.hasOwnProperty("dispose")) {
			asset["dispose"]();
		}
	}

	function log(message:String) {
		if (_verbose) {}
	}

	@:isVar public var verbose(get, set):Bool;

	public function get_verbose():Bool {
		return _verbose;
	}

	function set_verbose(value:Bool):Bool {
		return _verbose = value;
	}

	@:isVar public var numQueuedAssets(get, never):Int;

	public function get_numQueuedAssets():Int {
		return _queue.length;
	}

	@:isVar public var numConnections(get, set):Int;

	public function get_numConnections():Int {
		return _numConnections;
	}

	function set_numConnections(value:Int):Int {
		_numConnections = ASCompat.floatToInt(MathUtil.max(1, value));
		return value;
	}

	@:isVar public var textureOptions(get, set):TextureOptions;

	public function get_textureOptions():TextureOptions {
		return _textureOptions;
	}

	function set_textureOptions(value:TextureOptions):TextureOptions {
		_textureOptions.copyFrom(value);
		return value;
	}

	@:isVar public var dataLoader(get, set):DataLoader;

	public function get_dataLoader():DataLoader {
		return _dataLoader;
	}

	function set_dataLoader(value:DataLoader):DataLoader {
		return _dataLoader = value;
	}

	@:isVar public var registerBitmapFontsWithFontFace(get, set):Bool;

	public function get_registerBitmapFontsWithFontFace():Bool {
		return _registerBitmapFontsWithFontFace;
	}

	function set_registerBitmapFontsWithFontFace(value:Bool):Bool {
		return _registerBitmapFontsWithFontFace = value;
	}
}

private class AssetPostProcessor {
	var _priority:Int = 0;

	var _callback:ASFunction;

	public function new(callback:ASFunction, priority:Int) {
		if (callback == null || callback.length != 1) {
			throw new ArgumentError("callback must be a function accepting one \'AssetStore\' parameter");
		}
		_callback = callback;
		_priority = priority;
	}

	@:allow(starling.assets) function execute(store:AssetManager) {
		_callback(store);
	}

	@:isVar public var priority(get, never):Int;

	public function get_priority():Int {
		return _priority;
	}
}
