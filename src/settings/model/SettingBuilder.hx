package settings.model;

import settings.model.bindings.ISettingBinding;

class SettingBuilder {
	var mDefinition:SettingDefinition;

	public function new(id:String, category:String) {
		mDefinition = new SettingDefinition(id, category, SettingDefinition.labelKeyFor(id), SettingDefinition.descriptionKeyFor(id), null, null);
	}

	public function defaultsTo(value:ASAny):SettingBuilder {
		mDefinition.defaultValue = value;
		return this;
	}

	public function literalText(label:String, description:String):SettingBuilder {
		mDefinition.labelText = label;
		mDefinition.descriptionText = description;
		return this;
	}

	public function boundTo(binding:ISettingBinding):SettingBuilder {
		mDefinition.binding = binding;
		return this;
	}

	public function requiresRestart():SettingBuilder {
		mDefinition.requiresRestart = true;
		return this;
	}

	public function range(minimum:Float, maximum:Float, step:Float):SettingBuilder {
		mDefinition.minimum = minimum;
		mDefinition.maximum = maximum;
		mDefinition.step = step;
		return this;
	}

	public function displayedAs(scale:Float, decimals:Int = 0):SettingBuilder {
		mDefinition.displayScale = scale;
		mDefinition.decimals = decimals;
		return this;
	}

	public function choice(value:ASAny, labelKey:String = null):SettingBuilder {
		return addChoice(new SettingChoice(value, choiceLabelKey(value, labelKey)));
	}

	public function choicesFrom(choices:Vector<SettingChoice>, coerce:ASFunction):SettingBuilder {
		mDefinition.choices = choices;
		mDefinition.coerceValue = coerce;
		return this;
	}

	public function descriptionFrom(provider:ASFunction):SettingBuilder {
		mDefinition.descriptionKeyProvider = provider;
		return this;
	}

	public function presetChoice(value:ASAny, memberValues:ASObject, labelKey:String = null):SettingBuilder {
		return addChoice(new SettingChoice(value, choiceLabelKey(value, labelKey), memberValues));
	}

	public function derivedChoice(value:ASAny, labelKey:String = null):SettingBuilder {
		return addChoice(new SettingChoice(value, choiceLabelKey(value, labelKey), null, true));
	}

	public function keyBinding(action:String):SettingBuilder {
		mDefinition.keyBindingAction = action;
		return this;
	}

	public function build():SettingDefinition {
		var _loc1_ = (mDefinition.choices != null ? 1 : 0) + (!Math.isNaN(mDefinition.minimum) ? 1 : 0) + (mDefinition.keyBindingAction != null ? 1 : 0);
		if (_loc1_ > 1) {
			throw new Error("Setting " + mDefinition.id + " was given the fields of more than one kind");
		}
		return mDefinition;
	}

	function choiceLabelKey(value:ASAny, labelKey:String):String {
		return labelKey ?? SettingDefinition.choiceLabelKeyFor(mDefinition.id, value);
	}

	function addChoice(choice:SettingChoice):SettingBuilder {
		if (mDefinition.choices == null) {
			mDefinition.choices = new Vector<SettingChoice>();
		}
		mDefinition.choices.push(choice);
		return this;
	}
}
