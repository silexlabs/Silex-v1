//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.events.EventDispatcher;
import mx.core.UIObject;

/**
* event listening and dispatching for UIObjects.
*
* @helpid 3296
* @tiptext
*/
class mx.events.UIEventDispatcher extends EventDispatcher
{
/**
* list of supported keyboard events
*/
	static var keyEvents:Object = { keyDown: 1, keyUp: 1 };
/**
* load and unload events
*/
	static var loadEvents:Object = { load: 1, unload: 1};
	// we can't use 'super' in a mix-in because we'd then have
	// to mix into the object's prototype which is too dangerous
	// instead we rename functions from the parent class and add
	// them to the object as well.
	var __origAddEventListener:Function;

	// a pointer to the target object used when we get called
	// in a different scope
	var owner:Object;

	// we don't know if the load event has already been sent when the
	// user adds a listener for "load".  So, we send them a load event
	// and don't send one when the real load event happens
	var __sentLoadEvent;

	static var lowLevelEvents:Object = { keyEvents: ["addKeyEvents", "removeKeyEvents"],
										 loadEvents: ["addLoadEvents", "removeLoadEvents"] };

	// a copy of ourselves so we can add methods to other instances
	static var _fEventDispatcher:UIEventDispatcher = undefined;

	// internal function that adds keyboard listeners to a UIObject so the
	// listener can get events
	static function addKeyEvents(obj:Object):Void
	{
		if (obj.keyHandler == undefined)
		{
			var o = obj.keyHandler = new Object();
			o.owner = obj;
			o.onKeyDown = _fEventDispatcher.onKeyDown;
			o.onKeyUp = _fEventDispatcher.onKeyUp;
		}
		Key.addListener(obj.keyHandler);

	}

	// internal function that removes keyboard listeners from a UIObject
	static function removeKeyEvents(obj:Object):Void
	{
		Key.removeListener(obj.keyHandler);
	}

	// internal function that adds load/unload listeners to a UIObject so the
	// listener can get events
	static function addLoadEvents(obj:Object):Void
	{
		if (obj.onLoad == undefined)
		{
			obj.onLoad = _fEventDispatcher.onLoad;
			obj.onUnload = _fEventDispatcher.onUnload;

			// sometimes when you create an obj, the player has already figured out the list of
			// methods it needs to run so when you add an onLoad here it is too late and never
			// gets called.
			if (obj.getBytesTotal() == obj.getBytesLoaded())
			{
				obj.doLater(obj, "onLoad");
			}
		}
	}

	// internal function that removes load/unload listeners from a UIObject
	static function removeLoadEvents(obj:Object):Void
	{
		delete obj.onLoad;
		delete obj.onUnload;
	}

/**
* add listening and dispatching methods to an object
* @param object the object to receive the methods
*/
	static function initialize(obj:Object):Void
	{
		if (_fEventDispatcher == undefined)
		{
			_fEventDispatcher = new UIEventDispatcher;
		}
		obj.addEventListener = _fEventDispatcher.__addEventListener;
		obj.__origAddEventListener = _fEventDispatcher.addEventListener;
		obj.removeEventListener = _fEventDispatcher.removeEventListener;
		obj.dispatchEvent = _fEventDispatcher.dispatchEvent;
		obj.dispatchQueue = _fEventDispatcher.dispatchQueue;
	}

/**
* dispatch the event to all listeners
* @param eventObj an Event or one of its subclasses describing the event
*/
	function dispatchEvent(eventObj:Object):Void
	{
		if (eventObj.target == undefined)
			eventObj.target = this;

		this[eventObj.type + "Handler"](eventObj);

		// Dispatch to objects that are registered as listeners for
		// all objects.
		this.dispatchQueue(EventDispatcher, eventObj);

		// Dispatch to objects that are registered as listeners for
		// this object.
		this.dispatchQueue(this, eventObj);
	}

	// internal hook for keyboard events
	function onKeyDown(Void):Void
	{
		owner.dispatchEvent({type:"keyDown", code:Key.getCode(), ascii:Key.getAscii(),
														shiftKey:Key.isDown(Key.SHIFT), ctrlKey:Key.isDown(Key.CONTROL)});
	}

	// internal hook for keyboard events
	function onKeyUp(Void):Void
	{
		owner.dispatchEvent({type:"keyUp", code:Key.getCode(), ascii:Key.getAscii(),
														shiftKey:Key.isDown(Key.SHIFT), ctrlKey:Key.isDown(Key.CONTROL)});
	}

	// internal hook for load events
	function onLoad(Void):Void
	{
		if (__sentLoadEvent != true)
			dispatchEvent({type:"load"});
		__sentLoadEvent = true;
	}

	// internal hook for load events
	function onUnload(Void):Void
	{
		dispatchEvent({type:"unload"});
	}

	// internal hook of FEventDispatcher.addEventListener
	function __addEventListener(event:String, handler):Void
	{
		__origAddEventListener(event, handler);

		var ll = UIEventDispatcher.lowLevelEvents;
		for (var i in ll)
		{
			if (UIEventDispatcher[i][event] != undefined)
			{
				var s = ll[i][0];
				UIEventDispatcher[s](this);
			}
		}
	}

	// override of FEventDispatcher.removeEventListener
	function removeEventListener(event:String, handler):Void
	{
		var queueName:String = "__q_" + event;
		EventDispatcher._removeEventListener(this[queueName], event, handler);
		if (this[queueName].length == 0)	// no more listeners
		{
			var ll = UIEventDispatcher.lowLevelEvents;
			for (var i in ll)
			{
				if (UIEventDispatcher[i][event] != undefined)
				{
					var s = ll[i][1];
					UIEventDispatcher[ll[i][1]](this);
				}
			}
		}
	}
}

