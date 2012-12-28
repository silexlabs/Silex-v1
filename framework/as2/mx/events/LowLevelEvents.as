//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.events.UIEventDispatcher;

/**
* support for low-level DOM mouse events
*/
class mx.events.LowLevelEvents
{

/**
* list of supported mouse events
*/
	static var mouseEvents:Object = { mouseMove: 1, mouseDown: 1, mouseUp: 1, mouseOver: 1, mouseOut: 1 };
/**
* Flash specific mouse events that track the mouse over any object
*/
	static var somewhereEvents:Object = { mouseDownSomewhere: 1, mouseUpSomewhere: 1};

	// copies of the original functions, if any
	var _onMouseMove:Function;
	var _onMouseDown:Function;
	var _onMouseUp:Function;
	var _onRollOver:Function;
	var _onRollOut:Function;
	var _onDragOver:Function;
	var _onDragOut:Function;
	var _onPress:Function;
	var _onRelease:Function;
	var _onReleaseOutside:Function;
	var createEvent:Function;
	var dispatchEvent:Function;
	static var _fEventDispatcher:UIEventDispatcher;

	// the mouseMove queue is specially handled
	var __q_mouseMove:Array;

	// internal function that adds mouse listeners to a UIObject so the
	// listener can get events
	static function addMouseEvents(obj:Object):Void
	{
		if (obj.refcntMouseEvents > 0)
		{
			obj.refcntMouseEvents++;
			return;	// already did it
		}

		var d = UIEventDispatcher._fEventDispatcher;
		obj.refcntMouseEvents = 1;
		obj._onPress = obj.onPress;
		obj.onPress = d.onPress;
		obj._onRelease = obj.onRelease;
		obj.onRelease = d.onRelease;
		obj._onReleaseOutside = obj.onReleaseOutside;
		obj.onReleaseOutside = d.onReleaseOutside;
		obj._onRollOver = obj.onRollOver;
		obj.onRollOver = d.onRollOver;
		obj._onRollOut = obj.onRollOut;
		obj.onRollOut = d.onRollOut;
		obj._onDragOver = obj.onDragOver;
		obj.onDragOver = d.onDragOver;
		obj._onDragOut = obj.onDragOut;
		obj.onDragOut = d.onDragOut;

	}

	// internal function that removes mouse listeners from a UIObject
	static function removeMouseEvents(obj:Object):Void
	{
		if (obj.refcntMouseEvents > 1)
		{
			obj.refcntMouseEvents--;
			return;	// already did it
		}

		obj.refcntMouseEvents = 0;
		if (obj._onPress != undefined)
			obj.onPress = obj._onPress;
		else
			delete obj.onPress;

		if (obj._onRelease != undefined)
			obj.onRelease = obj._onRelease;
		else
			delete obj.onRelease;

		if (obj._onReleaseOutside != undefined)
			obj.onReleaseOutside = obj._onReleaseOutside;
		else
			delete obj.onReleaseOutside;

		if (obj._onRollOver != undefined)
			obj.onRollOver = obj._onRollOver;
		else
			delete obj.onRollOver;

		if (obj._onRollOut != undefined)
			obj.onRollOut = obj._onRollOut;
		else
			delete obj.onRollOut;

		if (obj._onDragOver != undefined)
			obj.onDragOver = obj._onDragOver;
		else
			delete obj.onDragOver;

		if (obj._onDragOut != undefined)
			obj.onDragOut = obj._onDragOut;
		else
			delete obj.onDragOut;

		if (obj._onMouseMove != undefined)
			obj.onMouseMove = obj._onMouseMove;
		else
			delete obj.onMouseMove;
	}

	// internal function that adds mouse listeners to a UIObject so the
	// listener can get events
	static function addSomewhereEvents(obj:Object):Void
	{
		if (obj.refcntSomewhereEvents > 0)
		{
			obj.refcntSomewhereEvents++;
			return;	// already did it
		}

		var d = UIEventDispatcher._fEventDispatcher;

		obj.refcntSomewhereEvents = 1;
		obj._onMouseDown = obj.onMouseDown;
		obj.onMouseDown = d.onMouseDown;
		obj._onMouseUp = obj.onMouseUp;
		obj.onMouseUp = d.onMouseUp;

	}

	// internal function that removes mouse listeners from a UIObject
	static function removeSomewhereEvents(obj:Object):Void
	{
		if (obj.refcntSomewhereEvents > 1)
		{
			obj.refcntSomewhereEvents--;
			return;	// already did it
		}

		obj.refcntSomewhereEvents = 0;
		if (obj._onMouseDown != undefined)
			obj.onMouseDown = obj._onMouseDown;
		else
			delete obj.onMouseDown;

		if (obj._onMouseUp != undefined)
			obj.onMouseUp = obj._onMouseUp;
		else
			delete obj.onMouseUp;
	}

/*
	XML mouse events are different from Flash mouse events.  Here's how you should respond to XML mouse events in order
	to mimic a button

	mouseUp:  if (mousewasdown && mouseisover)
					dispatchEvent("click")
			  else {
			  		mousewasdown = false;
			  }
			  showUpState();
	mouseDown:  mousewasdown = true;
	mouseOver:  mouseisover = true;
				if (mousewasdown)
					showDownState()
				else
					showOverState();
	mouseOut: mouseisover = false;
			  showUpState();

*/
	// internal hook for mouse events
	function onMouseMove(Void):Void
	{
		dispatchEvent({type: "mouseMove"});

		_onMouseMove();
	}

	// internal hook for mouse events
	function onRollOver(Void):Void
	{
		dispatchEvent({type: "mouseOver"});
		if (__q_mouseMove.length > 0)
		{
			_onMouseMove = onMouseMove;
			var z = UIEventDispatcher._fEventDispatcher;
			onMouseMove = z.onMouseMove;
		}

		_onRollOver();
	}

	// internal hook for mouse events
	function onRollOut(Void):Void
	{
		dispatchEvent({type: "mouseOut"});
		if (__q_mouseMove.length > 0)
		{
			if (_onMouseMove != undefined)
				onMouseMove == _onMouseMove;
			else
				delete onMouseMove;
		}

		_onRollOut();
	}

	// internal hook for mouse events
	function onPress(Void):Void
	{
		dispatchEvent({type: "mouseDown"});

		_onPress();
	}

	// internal hook for mouse events
	function onRelease(Void):Void
	{
		dispatchEvent({type: "mouseUp"});

		_onRelease();
	}

	// internal hook for mouse events
	function onReleaseOutside(Void):Void
	{
		dispatchEvent({type: "mouseUp"});

		_onReleaseOutside();
	}

	// internal hook for mouse events
	function onDragOver(Void):Void
	{
		dispatchEvent({type: "mouseOver"});

		_onDragOver();
	}

	// internal hook for mouse events
	function onDragOut(Void):Void
	{
		dispatchEvent({type: "mouseOut"});

		_onDragOut();
	}

	// internal hook for somewhere events
	function onMouseDown(Void):Void
	{
		dispatchEvent({type: "mouseDownSomewhere"});

		_onMouseDown();
	}

	// internal hook for somewhere events
	function onMouseUp(Void):Void
	{
		dispatchEvent({type: "mouseUpSomewhere"});

		_onMouseUp();
	}

	static function enableLowLevelEvents()
	{
	}

	static function classConstruct():Boolean
	{
		var ui = UIEventDispatcher;
		var ll = LowLevelEvents;
		ui.lowLevelEvents.mouseEvents = ["addMouseEvents", "removeMouseEvents"];
		ui.lowLevelEvents.somewhereEvents = ["addSomewhereEvents", "removeSomewhereEvents"];
		ui.mouseEvents = ll.mouseEvents;
		ui.addMouseEvents = ll.addMouseEvents;
		ui.removeMouseEvents = ll.removeMouseEvents;
		ui.somewhereEvents = ll.somewhereEvents;
		ui.addSomewhereEvents = ll.addSomewhereEvents;
		ui.removeSomewhereEvents = ll.removeSomewhereEvents;

		if (ui._fEventDispatcher == undefined)
		{
			ui._fEventDispatcher = new UIEventDispatcher;
		}
		var z = ui._fEventDispatcher;
		var p = ll.prototype;
		z.onPress = p.onPress;
		z.onRelease = p.onRelease;
		z.onReleaseOutside = p.onReleaseOutside;
		z.onRollOut = p.onRollOut;
		z.onRollOver = p.onRollOver;
		z.onDragOut = p.onDragOut;
		z.onDragOver = p.onDragOver;
		z.onMouseDown = p.onMouseDown;
		z.onMouseMove = p.onMouseMove;
		z.onMouseUp = p.onMouseUp;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var UIEventDispatcherDependency = UIEventDispatcher;

}
