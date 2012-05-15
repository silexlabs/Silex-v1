//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.events.EventDispatcher;
import mx.core.UIComponent;

/**
* @tiptext idle event
* @helpid 3317
*/
[Event("idle")]
/**
* @tiptext resize event
* @helpid 3318
*/
[Event("resize")]
/**
* Class for managing which top level window is activated.  Also provides an idle event and stage coordinates
*
* @helpid 3319
* @tiptext
*/
class mx.managers.SystemManager
{
	// if the system manager has been initialized
	private static var _initialized:Boolean = false;

	// number of frames since the last mouse or key activity
	static var idleFrames:Number = 0;
	// state of the mouse button
	static var isMouseDown = false;
	// list of top level windows
	static var forms:Array = new Array();
	// the current top level window
	static var form:MovieClip;
	// the interval used to check for idle
	static var interval:Number;

/**
* listen for idle events
* @see mx.events.EventDispatcher
*/
	static var addEventListener:Function;
/**
* listen for idle events
* @see mx.events.EventDispatcher
*/
	static var removeEventListener:Function;

	// internal override of addEventListener
	static var _xAddEventListener:Function;
	// internal override of removeEventListener
	static var _xRemoveEventListener:Function;
	// from mx.events.EventDispatcher
	static var dispatchEvent:Function;
	// the current coordinates of the stage
	static var __screen:Object;

	// mixins from OverlappedWindows
	static var activate:Function;
	static var deactivate:Function;
	static var checkIdle:Function;
	static var __addEventListener:Function;
	static var __removeEventListener:Function;
	static var onMouseMove:Function;
	static var onMouseUp:Function;

/**
* users of SystemManager must call init() before using SystemManager
*/
	static function init(Void):Void
	{
		if (_initialized == false)
		{
			_initialized = true;
			EventDispatcher.initialize(SystemManager);
			Mouse.addListener(SystemManager);
			Stage.addListener(SystemManager);
			SystemManager._xAddEventListener = SystemManager.addEventListener;
			SystemManager.addEventListener = SystemManager.__addEventListener;
			SystemManager._xRemoveEventListener = SystemManager.removeEventListener;
			SystemManager.removeEventListener = SystemManager.__removeEventListener;
		}
	}

	// register a window containing a focus manager.
	// this method is replaced when overlapped window support is added
	static function addFocusManager(f:UIComponent):Void
	{
		SystemManager.form = f;
		f.focusManager.activate();
	}
	// focus managers should never get removed unless overlapped window support is added
	static function removeFocusManager(f:UIComponent):Void
	{
	}
	// track mouse clicks to see if we change top-level forms
	static function onMouseDown(Void):Void
	{
		var z:MovieClip = SystemManager.form;
		z.focusManager._onMouseDown();
	}

	// keep track of the size and position of the stage
	static function onResize(Void):Void
	{
		var w:Number = Stage.width;
		var h:Number = Stage.height;
		var m:Number = _global.origWidth;
		var n:Number = _global.origHeight;
		var a:String = Stage.align;
		var x:Number = (m - w) / 2;
		var y:Number = (n - h) / 2;
		if (a == "T")
		{
			y = 0;
		}
		else if (a == "B")
		{
			y = n - h;
		}
		else if (a == "L")
		{
			x = 0;
		}
		else if (a == "R")
		{
			x = m - w;
		}
		else if (a == "LT") // even though doc says "TL"
		{
			y = 0;
			x = 0;
		}
		else if (a == "TR")
		{
			y = 0;
			x = m - w;
		}
		else if (a == "LB") // even though doc says "BL"
		{
			y = n - h;
			x = 0;
		}
		else if (a == "RB") // even though doc says "BR"
		{
			y = n - h;
			x = m - w;
		}
		if (__screen == undefined)
			__screen = new Object();
		__screen.x = x;
		__screen.y = y;
		__screen.width = w;
		__screen.height = h;
		// move the focusManager on _root if needed
		_root.focusManager.relocate();
		SystemManager.dispatchEvent({type:"resize"});
	}

/**
* get an object containing the size and position of the stage
* @return object with x, y, width and height
*
* @tiptext
* @helpid 3320
*/
	static function get screen():Object
	{
		init();
		if (__screen == undefined)
			onResize();
		return __screen;
	}

}
