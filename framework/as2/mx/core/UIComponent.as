//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.SkinElement;
import mx.core.UIObject;

/**
* @tiptext focusIn event
* @helpid 3950
*/
[Event("focusIn")]
/**
* @tiptext focusOut event
* @helpid 3951
*/
[Event("focusOut")]
/**
* @tiptext keyDown event
* @helpid 3954
*/
[Event("keyDown")]
/**
* @tiptext keyUp event
* @helpid 3955
*/
[Event("keyUp")]

/**
* UIComponent class
* - extends UIObject
* - Adds focus, enabling
* - Resizes by sizing and positioning internal components
*
* @tiptext Base class for all components.  Extends UIObject
* @helpid 3279
*/
class mx.core.UIComponent extends UIObject
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "UIComponent";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.core.UIComponent;

	// Version string
#include "../core/ComponentVersion.as"

/**
* number used to imply stretchability in preferredWidth/Height
*/
	static var kStretch:Number = 5000;

	// UIComponents can receive focus from mouse clicks as well as tabbing
	var focusEnabled:Boolean = true;
	var tabEnabled:Boolean = true;

	// top-level windows have a focusManager instance.  Other windows and components should
	// use getFocusManager() to find the focusManager that is responsible for that component.
	var focusManager:MovieClip;	// actually an instance of FocusManager
	// Components that contain a TextField must set a pointer to that TextField.
	var focusTextField:Object; // relaxed typing so textInputs can be included.

	// draw focus on the object.  Actually implemented in the theme.
	var drawFocus:Function;

	// RadioButtons and other grouped controls use this property
	var groupName:String;

	// the original border colors for a component showing an error state
	var origBorderStyles:Object = { themeColor: 0xFF0000 };
	var origBorderValues:Object;

/**
* @private
* list of clip parameters to check at init
*/
	var clipParameters:Object = {};
/**
* @private
* all components must use this mechanism to merge their clip parameters with their base class clip parameters
*/
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(UIComponent.prototype.clipParameters, UIObject.prototype.clipParameters);

/**
* @tiptext Specifies whether component accepts user-interaction
* @helpid 3952
*/
	// this is just here so we can put metadata on it
	[Inspectable(defaultValue=true, verbose=1, category="Other")]
	var enabled:Boolean;

/**
* @tiptext Specifies the tabIndex of the component
* @helpid 3957
*/
	var tabIndex:Number;

	// set by FPopUp to indicate that component is a popup window
	var popUp:Boolean;

	function UIComponent()
	{
	}

/**
* width of object
*/
	function get width():Number
	{
		return __width;
	}

/**
* height of object
*/
	function get height():Number
	{
		return __height;
	}

/**
* @private
* override this instead of adding your own setter for visible
*/
	function setVisible(x:Boolean, noEvent:Boolean):Void
	{
		super.setVisible(x, noEvent);
	}

/**
* @private
* enabled is a special case.  It cannot be getter/setter because the property name is the same as the getter/setter name
* so we do this to watch it.  This is slighly heavier than getter/setter so don't do this unless you have to. To override
* this, override setEnabled();
*/
	function enabledChanged(id:String, oldValue:Boolean, newValue:Boolean):Boolean
	{
		setEnabled(newValue);
		invalidate();
		delete stylecache.tf;	// need to flush textformat so it recalcs it with disabled color
		return newValue;
	}

/**
* @private
* this is called whenever the enabled state changes.
*/
	function setEnabled(enabled:Boolean):Void
	{
		invalidate();
	}

/**
*  Gets the object that has the focus.  It may not be this object.
*  This is just here as a convenience
*
* @return	Object	The object that has the focus
*
* @tiptext Returns the component that currently has focus
* @helpid 3953
*/
	function getFocus():Object
	{
		var selFocus:String = Selection.getFocus();
		return (selFocus === null ? null : eval(selFocus));
	}

/**
*  Sets the focus to this object.
*
* @tiptext Sets focus to this component
* @helpid 3956
*/
	function setFocus():Void
	{
		Selection.setFocus(this);
	}

/**
*  Get the current focusManager.
*/
	function getFocusManager():Object
	{
		var o:MovieClip = this;
		while (o != undefined)
		{
			if (o.focusManager != undefined)
				return o.focusManager;
			o = o._parent;
		}
		return undefined;
	}

/**
* @private
* called when you lose focus.  If you override, be sure to call the base class.
*/
	function onKillFocus(newFocus:Object):Void
	{
		removeEventListener("keyDown", this);
		removeEventListener("keyUp", this);
		dispatchEvent({ type:"focusOut"});
		drawFocus(false);
	}

/**
* @private
* called when you get focus.  If you override, be sure to call the base class.
*/
	function onSetFocus(oldFocus:Object):Void
	{
		addEventListener("keyDown", this);
		addEventListener("keyUp", this);
		dispatchEvent({ type:"focusIn"});
		if (getFocusManager().bDrawFocus != false)
			drawFocus(true);
	}

	// find the child object that should get the Selection focus
	function findFocusInChildren(o:Object):Object
	{
		if (o.focusTextField != undefined)
		{
			return o.focusTextField;
		}
		if (o.tabEnabled == true)
			return o;

		return undefined;
	}

	// either this object should get focus
	// or if it is in a container, a textfield in that
	// container could get focus
	// or look at the parent
	function findFocusFromObject(o:Object):Object
	{
		if (o.tabEnabled != true)
		{
			if (o._parent == undefined)
				return undefined;
			if (o._parent.tabEnabled == true)
				o = o._parent;
			else if (o._parent.tabChildren)
				o = findFocusInChildren(o._parent);
			else
				o = findFocusFromObject(o._parent);
		}
		return o;
	}

/**
* @private
* all onPress handlers should call this.  It doesn't actually
* set focus, it makes it appear that it got focus.  Focus is
* actually set in releaseFocus;
*/
	function pressFocus():Void
	{

		// trace("pressFocus");
		var o = findFocusFromObject(this);
		var p = getFocus();
		if (o != p)
		{
			p.drawFocus(false);
			if (getFocusManager().bDrawFocus != false) // undefined if no focus manager
				o.drawFocus(true);
		}
	}

/**
* @private
* all onRelease handlers should call this.  It sets focus to the component.
*/
	function releaseFocus():Void
	{
		// trace("releaseFocus");
		var o = findFocusFromObject(this);
		if (o != getFocus())
		{
			// trace("releaseFocus set focus to " + o);
			o.setFocus();
		}
	}

/**
* @private
* tells you whether the object is a parented by this component
* @params o the potential parent to this compoenent
*/
	function isParent(o:Object):Boolean
	{
		while (o != undefined)
		{
			if (o == this)
				return true;
			o = o._parent;
		}
		return false;
	}

/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/
	function size():Void
	{
		// don't call super, it will cause us to scale.
		// just do nothing instead
	}

/**
* @private
* each component must override init, even if just to call
* the base class.
*/
	function init():Void
	{
		super.init();
		// all ccmponents have 100% scaling
		_xscale = 100;
		_yscale = 100;
		// turn off focus rect so we can use our own
		_focusrect = _global.useFocusRect == false;

		// see documentation for enabledChanged
		watch("enabled", enabledChanged);

		// special case for enable since it isn't getter/setter
		// all components assume enabled unless set to disabled
		if (enabled == false)
		{
			setEnabled(false);
		}

	}

/**
* @private
* dispatch the ValueChanged event.  All components that support databinding
* must call this method when the value of the component changes
*/
    function dispatchValueChangedEvent(value):Void
    {
		// Dispatch a "valueChanged" event.  This event is currently
		// used by the Data Model to do data binding.
		dispatchEvent({type:"valueChanged", value:value});
    }

}
