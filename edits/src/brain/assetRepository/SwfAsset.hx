package brain.assetRepository
;
import brain.logger.Logger;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.media.Sound;
import haxe.ds.StringMap;
#if cpp
import haxe.io.Path;
import lime.utils.AssetBundle;
import openfl.utils.AssetLibrary;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import swf.exporters.animate.AnimateLibrary;
import sys.FileSystem;
import brain.logger.Logger;
#end

class SwfAsset extends Asset
{
    #if cpp
    static var sLoadedPreprocessedLibraries:StringMap<AssetLibrary> = new StringMap<AssetLibrary>();
    static var sFailedPreprocessedLibraries:StringMap<Bool> = new StringMap<Bool>();
    #end

    var mRootObject:Dynamic;

    var mSwfPath:String;

    var mHdRootObject:Dynamic = null;

    var mHdSwfPath:String = null;

    #if cpp
    var mPreprocessedLibraryName:String = null;
    var mPreprocessedLibrary:AssetLibrary = null;
    var mHdPreprocessedLibraryName:String = null;
    var mHdPreprocessedLibrary:AssetLibrary = null;
    var mPreprocessedRootObject:MovieClip = null;
    var mRootInstancePropertiesApplied:Bool = false;
    #end

    public function new(param1:Dynamic, param2:String)
    {
        mRootObject = param1;
        mSwfPath = param2;
        #if cpp
        mPreprocessedLibraryName = getPreprocessedLibraryId(param2);
        #end
        super();
    }

    override public function destroy()
    {
        unloadSwfRoot(mRootObject);
        mRootObject = null;
        mSwfPath = null;
        #if cpp
        mPreprocessedLibrary = null;
        mHdPreprocessedLibrary = null;
        if(mPreprocessedRootObject != null)
        {
            unloadSwfRoot(mPreprocessedRootObject);
            mPreprocessedRootObject = null;
        }
        #end
        if(mHdRootObject != null)
        {
            unloadSwfRoot(mHdRootObject);
            mHdRootObject = null;
        }
        mHdSwfPath = null;
    }

    @:isVar public var swfPath(get,never):String;
    public function  get_swfPath() : String
    {
        return mSwfPath;
    }

    public function setHdAsset(param1:Dynamic, param2:String)
    {
        mHdRootObject = param1;
        mHdSwfPath = param2;
        #if cpp
        mHdPreprocessedLibraryName = getPreprocessedLibraryId(param2);
        #end
    }

    #if cpp
    public static function getPreprocessedLibraryId(param1:String) : String
    {
        var _loc1_ = normalizeSwfAssetPath(param1).toLowerCase();
        var _loc2_ = new StringBuf();
        var _loc3_:Int = 0;
        var _loc4_:String = null;
        _loc2_.add("ax4_swf_");
        _loc3_ = 0;
        while(_loc3_ < _loc1_.length)
        {
            _loc4_ = _loc1_.charAt(_loc3_);
            if((_loc4_ >= "a" && _loc4_ <= "z") || (_loc4_ >= "0" && _loc4_ <= "9"))
            {
                _loc2_.add(_loc4_);
            }
            else
            {
                _loc2_.add("_");
            }
            _loc3_++;
        }
        return ~/[_]+/g.replace(_loc2_.toString(), "_");
    }

    public static function hasPreprocessedBundleForPath(param1:String) : Bool
    {
        return FileSystem.exists(getPreprocessedBundlePath(getPreprocessedLibraryId(param1)));
    }

    static function normalizeSwfAssetPath(param1:String) : String
    {
        var _loc1_ = param1;
        if(_loc1_ == null)
        {
            return "";
        }
        _loc1_ = StringTools.replace(_loc1_, "\\", "/");
        while(StringTools.startsWith(_loc1_, "./"))
        {
            _loc1_ = _loc1_.substr(2);
        }
        return _loc1_;
    }

    #end

    @:isVar public var hasHdAsset(get,never):Bool;
    public function  get_hasHdAsset() : Bool
    {
        return mHdRootObject != null;
    }

    @:isVar public var hdSwfPath(get,never):String;
    public function  get_hdSwfPath() : String
    {
        return mHdSwfPath;
    }

    @:isVar public var root(get,never):MovieClip;
    public function  get_root() : MovieClip
    {
        var _loc1_ = ASCompat.dynamicAs(mRootObject , MovieClip);
        if(_loc1_ != null)
        {
            #if cpp
            ensurePreprocessedLibrariesLoaded();
            if(!mRootInstancePropertiesApplied)
            {
                applyRootInstanceProperties(_loc1_,mPreprocessedLibrary,mSwfPath);
                mRootInstancePropertiesApplied = true;
            }
            #end
            return _loc1_;
        }
        #if cpp
        ensurePreprocessedLibrariesLoaded();
        if(mPreprocessedRootObject == null)
        {
            mPreprocessedRootObject = instantiatePreprocessedRootObject(mPreprocessedLibrary,mSwfPath);
            if(mPreprocessedRootObject != null)
            {
                applyRootInstanceProperties(mPreprocessedRootObject,mPreprocessedLibrary,mSwfPath);
            }
        }
        return mPreprocessedRootObject;
        #else
        return null;
        #end
    }

    public function getClass(param1:String, param2:Bool = false) : Dynamic
    {
        var _loc3_= getApplicationDomain(mHdRootObject);
        var _loc4_= getApplicationDomain(mRootObject);
        var _loc5_:Dynamic = null;
        if(_loc3_ != null && _loc3_.hasDefinition(param1))
        {
            return (_loc3_.getDefinition(param1) : Dynamic) ;
        }
        if(_loc4_ != null && _loc4_.hasDefinition(param1))
        {
            return (_loc4_.getDefinition(param1) : Dynamic) ;
        }
        #if cpp
        if(hasPreprocessedAsset(param1))
        {
            return cast ((new SwfClassProxy(this,param1) : Dynamic));
        }
        #end
        if(!param2)
        {
            if(_loc4_ == null)
            {
                Logger.warn("Could not resolve applicationDomain for SwfAsset " + mSwfPath + " while looking for class: " + param1 + ". rootType=" + objectTypeName(mRootObject) + (mHdRootObject != null ? " hdRootType=" + objectTypeName(mHdRootObject) : ""));
            }
            else
            {
                Logger.warn("Could not find class name: " + param1 + " in SwfAsset " + mSwfPath + (mHdSwfPath != null ? " or HD asset " + mHdSwfPath : ""));
            }
        }
        _loc5_ = Type.resolveClass(param1);
        return _loc5_;
    }

    public function instantiateRuntimeSymbol(param1:String, param2:Array<Dynamic>) : Dynamic
    {
        #if cpp
        var _loc3_ = instantiatePreprocessedSymbol(param1);
        if(_loc3_ != null)
        {
            return _loc3_;
        }
        _loc3_ = instantiateFromLoadedRoot(param1);
        if(_loc3_ != null)
        {
            bindTimelineFields(_loc3_);
            return _loc3_;
        }
        Logger.warn("SwfAsset.instantiateRuntimeSymbol: failed to instantiate symbol " + param1 + " in " + mSwfPath);
        #end
        return null;
    }

    function hasPreprocessedAsset(param1:String) : Bool
    {
        #if cpp
        ensurePreprocessedLibrariesLoaded();
        if(param1 == null)
        {
            return false;
        }
        return libraryHasPreprocessedSymbol(mHdPreprocessedLibrary,param1) || libraryHasPreprocessedSymbol(mPreprocessedLibrary,param1);
        #else
        return false;
        #end
    }

    #if cpp
    function libraryHasPreprocessedSymbol(param1:AssetLibrary, param2:String) : Bool
    {
        if(param1 == null || param2 == null)
        {
            return false;
        }
        return param1.exists(param2,null);
    }

    function instantiatePreprocessedSymbol(param1:String) : Dynamic
    {
        ensurePreprocessedLibrariesLoaded();
        var _loc1_ = instantiatePreprocessedFromSource(mHdPreprocessedLibrary,mHdPreprocessedLibraryName,param1);
        if(_loc1_ != null)
        {
            return _loc1_;
        }
        return instantiatePreprocessedFromSource(mPreprocessedLibrary,mPreprocessedLibraryName,param1);
    }

    function instantiatePreprocessedFromSource(param1:AssetLibrary, param2:String, param3:String) : Dynamic
    {
        return instantiatePreprocessedSymbolFromLibrary(param1,param2,param3);
    }

    function instantiatePreprocessedSymbolFromLibrary(param1:AssetLibrary, param2:String, param3:String) : Dynamic
    {
        var _loc4_:MovieClip = null;
        var _loc5_ = null;
        if(param1 == null || param3 == null)
        {
            return null;
        }
        if(param1.exists(param3,cast AssetType.MOVIE_CLIP))
        {
            _loc4_ = param1.getMovieClip(param3);
            if(_loc4_ != null)
            {
                bindTimelineFields(_loc4_);
                return _loc4_;
            }
        }
        if(param1.exists(param3,cast AssetType.SOUND) || param1.exists(param3,cast AssetType.MUSIC))
        {
            _loc5_ = param1.getAudioBuffer(param3);
            if(_loc5_ != null)
            {
                return Sound.fromAudioBuffer(_loc5_);
            }
        }
        if(param2 != null && Assets.exists(param2 + ":" + param3,cast AssetType.IMAGE))
        {
            return Assets.getBitmapData(param2 + ":" + param3);
        }
        return null;
    }

    function ensurePreprocessedLibrariesLoaded() : Void
    {
        if(mHdPreprocessedLibrary == null && mHdPreprocessedLibraryName != null)
        {
            mHdPreprocessedLibrary = loadPreprocessedLibrarySync(mHdPreprocessedLibraryName,mHdSwfPath);
        }
        if(mPreprocessedLibrary == null && mPreprocessedLibraryName != null)
        {
            mPreprocessedLibrary = loadPreprocessedLibrarySync(mPreprocessedLibraryName,mSwfPath);
        }
    }

    public function preloadPreprocessedLibraries() : Void
    {
        ensurePreprocessedLibrariesLoaded();
    }

    #if cpp
    function applyRootInstanceProperties(param1:MovieClip, param2:AssetLibrary, param3:String) : Void
    {
        var _loc4_:AnimateLibrary = null;
        var _loc5_:Dynamic = null;
        var _loc6_:String = null;
        if(param1 == null || param2 == null)
        {
            return;
        }
        _loc4_ = Std.isOfType(param2, AnimateLibrary) ? cast param2 : null;
        if(_loc4_ == null)
        {
            return;
        }
        _loc5_ = _loc4_.getRootInstanceProperties();
        if(_loc5_ == null)
        {
            return;
        }
        for(_loc6_ in Reflect.fields(_loc5_))
        {
            try
            {
                ASCompat.setProperty(param1,_loc6_,cloneInstanceProperty(Reflect.field(_loc5_,_loc6_)));
            }
            catch(e:Dynamic)
            {
                Logger.warn("SwfAsset.applyRootInstanceProperties: failed to set field " + _loc6_ + " on " + param3 + ": " + Std.string(e));
            }
        }
    }

    function cloneInstanceProperty(param1:Dynamic) : Dynamic
    {
        var _loc2_:Array<Dynamic> = null;
        var _loc3_:Dynamic = null;
        var _loc4_:String = null;
        if(param1 == null || Std.isOfType(param1,String) || Std.isOfType(param1,Bool) || Std.isOfType(param1,Int) || Std.isOfType(param1,Float))
        {
            return param1;
        }
        if(Std.isOfType(param1,Array))
        {
            _loc2_ = [];
            for(_loc3_ in cast(param1,Array<Dynamic>))
            {
                _loc2_.push(cloneInstanceProperty(_loc3_));
            }
            return _loc2_;
        }
        _loc3_ = {};
        for(_loc4_ in Reflect.fields(param1))
        {
            Reflect.setField(_loc3_,_loc4_,cloneInstanceProperty(Reflect.field(param1,_loc4_)));
        }
        return _loc3_;
    }

    function instantiatePreprocessedRootObject(param1:AssetLibrary, param2:String) : MovieClip
    {
        var _loc3_:AnimateLibrary = null;
        if(param1 == null)
        {
            return null;
        }
        _loc3_ = Std.isOfType(param1, AnimateLibrary) ? cast param1 : null;
        if(_loc3_ == null)
        {
            return null;
        }
        try
        {
            return _loc3_.getMovieClip("");
        }
        catch(e:Dynamic)
        {
            Logger.warn("SwfAsset.instantiatePreprocessedRootObject: failed for " + param2 + ": " + Std.string(e));
        }
        return null;
    }
    #end

    static function loadPreprocessedLibrarySync(param1:String, param2:String) : AssetLibrary
    {
        var _loc1_:AssetLibrary = null;
        var _loc2_:String = null;
        if(param1 == null || param1.length == 0)
        {
            return null;
        }
        if(sLoadedPreprocessedLibraries.exists(param1))
        {
            return sLoadedPreprocessedLibraries.get(param1);
        }
        if(sFailedPreprocessedLibraries.exists(param1))
        {
            return null;
        }
        _loc2_ = getPreprocessedBundlePath(param1);
        if(_loc2_ == null || !FileSystem.exists(_loc2_))
        {
            sFailedPreprocessedLibraries.set(param1,true);
            return null;
        }
        _loc1_ = cast Assets.getLibrary(param1);
        if(_loc1_ != null)
        {
            sLoadedPreprocessedLibraries.set(param1,_loc1_);
            return _loc1_;
        }
        try
        {
            _loc1_ = AssetLibrary.fromBundle(AssetBundle.fromFile(_loc2_));
            if(_loc1_ == null)
            {
                throw "AssetLibrary.fromBundle returned null";
            }
            if(Std.isOfType(_loc1_, AnimateLibrary))
            {
                cast(_loc1_, AnimateLibrary).load();
            }
            Assets.registerLibrary(param1,_loc1_);
            sLoadedPreprocessedLibraries.set(param1,_loc1_);
            return _loc1_;
        }
        catch(e:Dynamic)
        {
            Logger.warn("SwfAsset.loadPreprocessedLibrarySync: failed for " + param2 + " id=" + param1 + " bundle=" + _loc2_ + ": " + Std.string(e));
        }
        sFailedPreprocessedLibraries.set(param1,true);
        return null;
    }

    static function getPreprocessedBundlePath(param1:String) : String
    {
        var _loc1_= Path.directory(Sys.programPath());
        var _loc2_:Array<String> = null;
        var _loc3_:String = null;
        var _loc4_:String = null;
        if(_loc1_ == null || _loc1_.length == 0)
        {
            return null;
        }
        _loc2_ = [
            Path.normalize(Path.join([_loc1_,"lib",param1 + ".zip"])),
            Path.normalize(Path.join([_loc1_,"..","Resources","lib",param1 + ".zip"]))
        ];
        for(_loc3_ in _loc2_)
        {
            if(_loc4_ != _loc3_ && FileSystem.exists(_loc3_))
            {
                return _loc3_;
            }
            _loc4_ = _loc3_;
        }
        return _loc2_[0];
    }

    #end

    static function extractSimpleSymbolName(param1:String) : String
    {
        var _loc1_= param1;
        var _loc2_= _loc1_.lastIndexOf("::");
        if(_loc2_ != -1)
        {
            _loc1_ = _loc1_.substring(_loc2_ + 2);
        }
        _loc2_ = _loc1_.lastIndexOf(".");
        if(_loc2_ != -1)
        {
            _loc1_ = _loc1_.substring(_loc2_ + 1);
        }
        return _loc1_;
    }

    function instantiateFromLoadedRoot(param1:String) : Dynamic
    {
        var _loc1_:DisplayObjectContainer = null;
        var _loc2_:DisplayObject = null;
        var _loc3_:String = null;
        _loc1_ = ASCompat.dynamicAs(mRootObject , DisplayObjectContainer);
        if(_loc1_ == null)
        {
            _loc1_ = ASCompat.dynamicAs(mHdRootObject , DisplayObjectContainer);
        }
        if(_loc1_ == null)
        {
            return null;
        }
        _loc3_ = SwfAsset.extractSimpleSymbolName(param1);
        _loc2_ = findDisplayObjectByNameRecursive(_loc1_,_loc3_);
        if(_loc2_ == null && _loc3_ != param1)
        {
            _loc2_ = findDisplayObjectByNameRecursive(_loc1_,param1);
        }
        if(_loc2_ != null)
        {
            try
            {
                if(_loc2_.parent != null)
                {
                    _loc2_.parent.removeChild(_loc2_);
                }
            }
            catch(e:Dynamic)
            {
            }
        }
        return _loc2_;
    }

    function findDisplayObjectByNameRecursive(param1:DisplayObjectContainer, param2:String) : DisplayObject
    {
        var _loc3_:DisplayObject = null;
        var _loc4_:DisplayObjectContainer = null;
        var _loc1_= 0;
        if(param1 == null || param2 == null || param2.length == 0)
        {
            return null;
        }
        if(param1.name == param2)
        {
            return param1;
        }
        while(_loc1_ < param1.numChildren)
        {
            _loc3_ = param1.getChildAt(_loc1_);
            if(_loc3_ != null)
            {
                if(_loc3_.name == param2)
                {
                    return _loc3_;
                }
                _loc4_ = ASCompat.dynamicAs(_loc3_ , DisplayObjectContainer);
                if(_loc4_ != null)
                {
                    _loc3_ = findDisplayObjectByNameRecursive(_loc4_,param2);
                    if(_loc3_ != null)
                    {
                        return _loc3_;
                    }
                }
            }
            _loc1_++;
        }
        return null;
    }

    function bindTimelineFields(param1:Dynamic)
    {
        var _loc2_:DisplayObjectContainer = null;
        #if cpp
        _loc2_ = ASCompat.dynamicAs(param1 , DisplayObjectContainer);
        if(_loc2_ == null)
        {
            return;
        }
        bindTimelineFieldsRecursive(_loc2_);
        #end
    }

    function bindTimelineFieldsRecursive(param1:DisplayObjectContainer)
    {
        var _loc3_:DisplayObject = null;
        var _loc4_:DisplayObjectContainer = null;
        var _loc5_:String = null;
        var _loc6_:DisplayObject = null;
        var _loc7_:DisplayObjectContainer = null;
        var _loc2_= 0;
        if(param1 == null)
        {
            return;
        }
        while(_loc2_ < param1.numChildren)
        {
            _loc3_ = param1.getChildAt(_loc2_);
            if(_loc3_ != null)
            {
                _loc5_ = _loc3_.name;
                if(_loc5_ != null && _loc5_.length > 0)
                {
                    try
                    {
                        if(!Reflect.hasField(param1,_loc5_) || Reflect.field(param1,_loc5_) == null)
                        {
                            Reflect.setField(param1,_loc5_,_loc3_);
                            if(Reflect.field(param1,_loc5_) == null)
                            {
                                Reflect.setProperty(param1,_loc5_,_loc3_);
                            }
                        }
                    }
                    catch(e:Dynamic)
                    {
                    }
                }
                _loc4_ = ASCompat.dynamicAs(_loc3_ , DisplayObjectContainer);
                if(_loc4_ != null)
                {
                    bindTimelineFieldsRecursive(_loc4_);
                }
            }
            _loc2_++;
        }
        if(!Reflect.hasField(param1, "label") || Reflect.field(param1, "label") == null)
        {
            _loc6_ = param1.getChildByName("label");
            if(_loc6_ == null)
            {
                _loc7_ = ASCompat.dynamicAs(param1.getChildByName("up") , DisplayObjectContainer);
                if(_loc7_ != null)
                {
                    _loc6_ = _loc7_.getChildByName("label");
                }
            }
            if(_loc6_ == null)
            {
                _loc7_ = ASCompat.dynamicAs(param1.getChildByName("over") , DisplayObjectContainer);
                if(_loc7_ != null)
                {
                    _loc6_ = _loc7_.getChildByName("label");
                }
            }
            if(_loc6_ != null)
            {
                try
                {
                    Reflect.setField(param1, "label", _loc6_);
                }
                catch(e:Dynamic)
                {
                }
            }
        }
    }

    function unloadSwfRoot(param1:Dynamic)
    {
        var _loc2_:Dynamic = null;
        var _loc3_:Dynamic = null;
        if(param1 == null)
        {
            return;
        }
        try
        {
            _loc2_ = Reflect.field(param1, "loaderInfo");
            if(_loc2_ == null)
            {
                return;
            }
            _loc3_ = Reflect.field(_loc2_, "loader");
            if(_loc3_ != null && Reflect.hasField(_loc3_, "unloadAndStop"))
            {
                Reflect.callMethod(_loc3_,Reflect.field(_loc3_, "unloadAndStop"), []);
            }
        }
        catch(e:Dynamic)
        {
        }
    }

    function getApplicationDomain(param1:Dynamic) : Dynamic
    {
        var _loc2_:Dynamic = null;
        if(param1 == null)
        {
            return null;
        }
        try
        {
            _loc2_ = Reflect.field(param1, "loaderInfo");
            if(_loc2_ == null)
            {
                return null;
            }
            return Reflect.field(_loc2_, "applicationDomain");
        }
        catch(e:Dynamic)
        {
        }
        return null;
    }

    function objectTypeName(param1:Dynamic) : String
    {
        var _loc2_:Dynamic = null;
        if(param1 == null)
        {
            return "null";
        }
        _loc2_ = Type.getClass(param1);
        if(_loc2_ == null)
        {
            return "unknown";
        }
        return Type.getClassName(_loc2_);
    }
}

class SwfClassProxy
{
    var mSwfAsset:SwfAsset;
    var mClassName:String;

    public function new(param1:SwfAsset, param2:String)
    {
        mSwfAsset = param1;
        mClassName = param2;
    }

    public function create(param1:Array<Dynamic>) : Dynamic
    {
        if(mSwfAsset == null)
        {
            return null;
        }
        return mSwfAsset.instantiateRuntimeSymbol(mClassName,param1);
    }
}
