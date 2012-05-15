//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
* base class for event listening and dispatching
*
* @helpid 3295
* @tiptext
*/
class mx.events.EventDispatcher
{
	// make a instance of ourself so we can add methods to other objects
	static var _fEventDispatcher:EventDispatcher = undefined;

 	// these events do not get called via backdoor because of name collisions with other methods
 	static var exceptions:Object = {move: 1, draw: 1, load:1};

	// internal function for removing listeners
	static function _removeEventListener(queue:Object, event:String, handler):Void
	{
		if (queue != undefined)
		{
			var l:Number = queue.length;
			var i:Number;
			for (i = 0; i < l; i++)
			{
				var o = queue[i];
				if (o == handler) {
					queue.splice(i, 1);
					return;
				}
			}
		}
	}

/**
* add listening and dispatching methods to an object
* @param object the object to receive the methods
*/
	static function initialize(object:Object):Void
	{
		if (_fEventDispatcher == undefined)
		{
			_fEventDispatcher = new EventDispatcher;
		}
		object.addEventListener = _fEventDispatcher.addEventListener;
		object.removeEventListener = _fEventDispatcher.removeEventListener;
		object.dispatchEvent = _fEventDispatcher.dispatchEvent;
		object.dispatchQueue = _fEventDispatcher.dispatchQueue;
	}

	// internal function for dispatching events
	function dispatchQueue(queueObj:Object, eventObj:Object):Void
	{
		var queueName:String = "__q_" + eventObj.type;
		var queue:Array = queueObj[queueName];
		if (queue != undefined)
		{
			var i:String;
			// loop it as an object so it resists people removing listeners during dispatching
			for (i in queue)
			{
				var o = queue[i];
				var oType:String = typeof(o);

				// a handler can be a function, object, or movieclip
				if (oType == "object" || oType == "movieclip")
				{
					// this is a backdoor implementation that
					// is not compliant with the standard
   					if (o.handleEvent != undefined)
   					{
   						// this is the DOM3 way
   						o.handleEvent(eventObj);
   					}
 					if (o[eventObj.type] != undefined)
   					{
 						if (EventDispatcher.exceptions[eventObj.type] == undefined)
 						{	
 							// this is a backdoor implementation that
 							// is not compliant with the standard
 							o[eventObj.type](eventObj);
 						}
   					}
				}
				else // it is a function
				{
					o.apply(queueObj, [eventObj]);
				}
			}
		}
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
		// this object.
		this.dispatchQueue(this, eventObj);
	}

/**
* add a listener for a particular event
* @param event the name of the event ("click", "change", etc)
* @param the function or object that should be called
*/
	function addEventListener(event:String, handler):Void
	{
		var queueName:String = "__q_" + event;
		if (this[queueName] == undefined)
		{
			this[queueName] = new Array();
		}
		_global.ASSetPropFlags(this, queueName,1);

		EventDispatcher._removeEventListener(this[queueName], event, handler);
		this[queueName].push(handler);
	}

/**
* remove a listener for a particular event
* @param event the name of the event ("click", "change", etc)
* @param the function or object that should be called
*/
	function removeEventListener(event:String, handler):Void
	{
		var queueName:String = "__q_" + event;
		EventDispatcher._removeEventListener(this[queueName], event, handler);
	}


}

