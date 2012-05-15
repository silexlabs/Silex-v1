//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.managers.DepthManager;
import mx.managers.SystemManager;
import mx.core.UIObject;
import mx.core.UIComponent;

/**
* @tiptext mouseDownOutside event
* @helpid 3314
*/
[Event("mouseDownOutside")]
/**
* Class for creating new top level windows.  Also provides modality and event if clicked outside window
*
* @helpid 3315
* @tiptext
*/
class mx.managers.PopUpManager
{
	// Version string
#include "../core/ComponentVersion.as"

/**
* modality is accomplished by creating a full screen transparent window underneath the popup that eats all mouse clicks
*/
	var modalWindow:MovieClip;

	// properties and methods that actually live on UIObject
	var _parent:UIObject;
	var popUp:MovieClip;
	var owner:MovieClip;
	var setSize:Function;
	var move:Function;
	var _visible:Boolean;
	var _name:String;

	// need an instance of yourself so you can add methods to another instance
	static var mixins:PopUpManager = undefined;

	// create the modal window
	static function createModalWindow(parent:MovieClip, o:MovieClip, broadcastOutsideEvents:Boolean):Void
	{
		// create a modalWindow the size of the stage that eats all mouse clicks
		var modalWindow:MovieClip = parent.createChildAtDepth("Modal", DepthManager.kTopmost);
		modalWindow.setDepthBelow(o);
		o.modalID = modalWindow._name;
		modalWindow._alpha = _global.style.modalTransparency;
		modalWindow.tabEnabled = false;
		if (broadcastOutsideEvents)
		{
			modalWindow.onPress = mixins.onPress;
		}
		else
		{
			modalWindow.onPress = mixins.nullFunction;
		}
		modalWindow.onRelease = mixins.nullFunction;
		modalWindow.resize = mixins.resize;
		SystemManager.init();
		SystemManager.addEventListener("resize", modalWindow);
		modalWindow.resize();
		modalWindow.useHandCursor = false;
		modalWindow.popUp = o;
		o.modalWindow = modalWindow;
		o.deletePopUp = mixins.deletePopUp;
		o.setVisible = mixins.setVisible;
		o.getVisible = mixins.getVisible;
		o.addProperty("visible",  o.getVisible, o.setVisible );
	}

/**
* create a top level window.  Modal windows must be destroyed by calling deletePopUp() which will be added to the top level window
*
* @param parent the object to use to center the new top level window.  The top level window will probably actually be parented by _root
* @param className the class of object to convert into the top level window.
* @param modal if true, window is modal
* @param initObj object containing initialization properties
* @param broadcastOutsideEvents if true, will dispatch mouseDownOutside events if mouse clicked outside the window
* @return reference to new top level window
*
* @tiptext
* @helpid 3316
*/
	static function createPopUp(parent:MovieClip, className:Object, modal:Boolean, initobj:Object, broadcastOutsideEvents:Boolean):MovieClip
	{
		if (mixins == undefined)
			mixins = new PopUpManager;

		if (broadcastOutsideEvents == undefined)
			broadcastOutsideEvents = false;
		// find the top level parent
 		var localRoot = parent._root;
		if (localRoot == undefined) localRoot = _root;
 		while (parent != localRoot)
 		{
   			parent = parent._parent;
 		}

		initobj.popUp = true;
		var o:MovieClip = parent.createClassChildAtDepth(className, (broadcastOutsideEvents || modal) ? DepthManager.kTopmost : DepthManager.kTop, initobj);
		// don't use createClassObject because that requires the Package
		// this mechanism makes the FocusManager optional
		var r = _root;
		var useFocusManager = (r.focusManager != undefined);
		while (r._parent != undefined)
		{
			r = r._parent._root;
			if (r.focusManager != undefined)
			{
				useFocusManager = true;
				break;
			}
		}
		if (useFocusManager)
		{
			o.createObject("FocusManager", "focusManager", -1);
			if (o._visible == false)
					SystemManager.deactivate(o);
		}

		if (modal)
		{
			PopUpManager.createModalWindow(parent, o, broadcastOutsideEvents);
		}
		else
		{
			if (broadcastOutsideEvents) {
				o.mouseListener = new Object();
				o.mouseListener.owner = o;
				o.mouseListener.onMouseDown = mixins.onMouseDown;
				Mouse.addListener(o.mouseListener);
			}
			o.deletePopUp = mixins.deletePopUp;
		}

		return o;
	}

	// added to modal window to get mouseDownOutside events
	function onPress(Void):Void
	{
		var root = popUp._root;
		if (root == undefined) root = _root;
		
		if (popUp.hitTest(root._xmouse, root._ymouse, false))
			return;

		popUp.dispatchEvent({type:"mouseDownOutside"});
	}

	// stub function used to capture mouse
	function nullFunction(Void):Void
	{
	}

	// the modal window must react to screen size changes
	function resize(Void):Void
	{
		var s:Object = SystemManager.screen;
		setSize(s.width, s.height);
		move(s.x, s.y);
	}

/**
* modal windows must be destroyed via deletePopUp
*/
	function deletePopUp(Void):Void
	{
		if (modalWindow != undefined)
		{
			_parent.destroyObject(modalWindow._name);
		}
		_parent.destroyObject(_name);
	}

	// override visible in order to take care of the modal window
	function setVisible(v:Boolean, noEvent:Boolean):Void
	{
		super.setVisible(v, noEvent);
		modalWindow._visible = v;
	}

	// override visible in order to take care of the modal window
	function getVisible(Void):Boolean
	{
		return _visible;
	}

	// check to see if we've been clicked outside the modal window
	function onMouseDown(Void):Void
	{
		var root = owner._root;
		if (root == undefined) root = _root;
 		var pt = new Object();
 		pt.x = root._xmouse;
 		pt.y = root._ymouse;
 		root.localToGlobal(pt);
		
		// shapeFlag is false here for performance
 		if( owner.hitTest(pt.x, pt.y, false) ) {
			// do nothing
		}
		else {
			owner.mouseDownOutsideHandler(owner);
		}
	}


}

