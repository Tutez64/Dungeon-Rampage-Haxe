package com.greensock.core;

final class PropTween {
	public var priority:Int = 0;

	public var start:Float = Math.NaN;

	public var prevNode:PropTween;

	public var change:Float = Math.NaN;

	public var target:ASObject;

	public var name:String;

	public var property:String;

	public var nextNode:PropTween;

	public var isPlugin:Bool = false;

	public function new(target:ASObject, property:String, start:Float, change:Float, name:String, isPlugin:Bool, nextNode:PropTween = null, priority:Int = 0) {
		this.target = target;
		this.property = property;
		this.start = start;
		this.change = change;
		this.name = name;
		this.isPlugin = isPlugin;
		if (nextNode != null) {
			nextNode.prevNode = this;
			this.nextNode = nextNode;
		}
		this.priority = priority;
	}
}
