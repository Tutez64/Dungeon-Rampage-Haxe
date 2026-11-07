package settings.model;

import facade.DBFacade;
import settings.model.bindings.FeatureFlagBinding;

class SettingsSection {
	var mDBFacade:DBFacade;

	var mCategory:String;

	var mBuilders:Vector<SettingBuilder> = new Vector();

	public function new(dbFacade:DBFacade, category:String) {
		mDBFacade = dbFacade;
		mCategory = category;
	}

	public function setting(id:String):SettingBuilder {
		var _loc2_ = new SettingBuilder(id, mCategory);
		mBuilders.push(_loc2_);
		return _loc2_;
	}

	public function flag(id:String, flagName:String):SettingBuilder {
		return setting(id).defaultsTo(mDBFacade.featureFlags.getFlagDefaultValue(flagName)).boundTo(new FeatureFlagBinding(mDBFacade, flagName));
	}

	public function build():Vector<SettingDefinition> {
		var _loc2_ = new Vector<SettingDefinition>();
		var _loc1_:SettingBuilder;
		final __ax4_iter_469 = mBuilders;
		if (checkNullIteratee(__ax4_iter_469))
			for (_tmp_ in __ax4_iter_469) {
				_loc1_ = _tmp_;
				_loc2_.push(_loc1_.build());
			}
		mBuilders = null;
		mDBFacade = null;
		return _loc2_;
	}
}
