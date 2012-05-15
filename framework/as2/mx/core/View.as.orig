// Copyright © 2003-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.events.UIEventDispatcher;
import mx.core.UIObject;
import mx.skins.RectBorder;
import mx.core.UIComponent;
import mx.managers.DepthManager;

/**
* base class for views/containers
*
* @helpid 3294
* @tiptext
*/
class mx.core.View extends UIComponent
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "View";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.core.View;

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "View";

/**
* @private
* the border object
*/
	var border_mc:RectBorder;

	// internal object that gives initial size
	var boundingBox_mc:MovieClip;

	// value of tabIndex
	var __tabIndex:Number;

	// Base for all children names (_child0 - _childN)
	static var childNameBase:String = "_child";

/* loading external content takes place in two stages: emptying the existing content,
   and loading the new content.  We track all loading using an object that moves from
   one stage to the other. */

	// the last used depth for the children
	var depth:Number;

	// from DepthManager;
	var createClassChildAtDepth:Function;

	// from ExternalContent
	var loadExternal:Function;

	// whether we've been layed out
	private var hasBeenLayedOut:Boolean = false;

	// className used to construct placeholder clip for loadExternal()
	private var _loadExternalClass:String = "UIComponent";

	function View()
	{
	}

	// initialize variables
	function init():Void
	{
		super.init();

		// by default containers cannot receive focus but their children can
		tabChildren = true;
		tabEnabled = false;

		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;

	}

	// respond to size changes
	function size():Void
	{

		// border covers the whole thing
		border_mc.move(0, 0);
		border_mc.setSize(width, height);

		// layout the content
		doLayout();
	}

	// redraw by re-laying out
	function draw():Void
	{
		size();
	}

/**
* get the number of children in this view
* @tiptext Returns the number of children
* @helpid 3400
*/
	function get numChildren():Number
	{
		var childName:String = childNameBase;

		for (var i:Number = 0; true; i++)
		{
			if (this[childName + i] == undefined)
				return i;
		}

		// Should never get here...
		return -1;
	}

/**
* By default, views are not tabstops so tabIndex will
* be undefined.  However, some views can be tabstops and will therefore
* return a tabIndex
*/
	function get tabIndex():Number
	{
		return tabEnabled ? __tabIndex : undefined;
	}
	function set tabIndex(n:Number)
	{
		__tabIndex = n;
	}

/**
* @private
* override this to find out when a new object is added that needs to be layed out
* @param object the layout object
*/
	function addLayoutObject(object:Object):Void
	{
		//trace("View.addLayoutObject");
	}

/**
* add a new child object
* @param className the name of the symbol, a reference to a class, or file path or URL to the external content
* @param instanceName the instance name of the child
* @param initProps object containing initialization properties
* @return reference to the child object
*/
	function createChild(className, instanceName:String, initProps:Object):MovieClip
	{
		if (depth == undefined)
			depth = 1;

		// Attach our object
		var newObj: MovieClip;
		if (typeof(className) == "string")
			newObj = createObject(className, instanceName, depth++, initProps);
		else
			newObj = createClassObject(className, instanceName, depth++, initProps);

		// See if we need to load it
		if (newObj == undefined)
		{
			newObj = loadExternal(className, _loadExternalClass, instanceName, depth++, initProps);
		}
		else
		{
			// Make an alias for ordered access
			//trace("View.createChild: this[" + childNameBase + numChildren + "] = " + newObj);
			this[childNameBase + numChildren] = newObj;

			newObj._complete = true;
			childLoaded(newObj);
		}

		// Finally, tell the layout manager about this new object.
		addLayoutObject(newObj);

		return newObj;
	}

/**
* get the Nth child object
* @param childIndex a number from 0 to N-1
* @return a reference to the child
* @tiptext  Returns the child at the specified position
* @helpid 3403
*/
	function getChildAt(childIndex:Number):UIObject
	{
		//trace("View.getChildAt");

		return this[childNameBase + childIndex];
	}

/**
* destroy the Nth child object.  Remaining child objects get renumbered
* @param childIndex a number from 0 to N-1
* @return a reference to the child
*/
	function destroyChildAt(childIndex:Number):Void
	{

		if (!(childIndex >= 0 && childIndex < numChildren))
			return;

		var childName:String = childNameBase + childIndex;
		var nChildren:Number = numChildren;

		// Find the real child object
		var slot:String; // ???
		for (slot in this)
		{
			if (slot == childName)
			{
				// Disconnect our _childN alias from the original
				childName = "";

				// Delete the child
				destroyObject(slot);

				// Done.
				break;
			}
		}

		// Shuffle all higher numbered children down
		for (var i:Number = Number(childIndex); i < (nChildren - 1); i++)
		{
			this[childNameBase + i] = this[childNameBase + (i + 1)];
		}

		// Delete the leftover slot
		delete this[childNameBase + (nChildren - 1)];
		depth--;
	}

	// layout the first time
	function initLayout():Void
	{
		if (!hasBeenLayedOut)
		{
			// Default is to just call doLayout. Override if you need to
			// do additional processing upon initial layout.
			doLayout();
		}
	}

/**
* @private
* override this to layout the content
*/
	function doLayout():Void
	{
		hasBeenLayedOut = true;
	}

	// create the border behind everything and schedule first layout
	function createChildren():Void
	{
		if (border_mc == undefined)
			border_mc = createClassChildAtDepth(_global.styles.rectBorderClass, DepthManager.kBottom, {styleName : this});

		// The constructors for this object's children haven't executed yet.
		// Wait until later to register the children with the layout manager.
		doLater(this, "initLayout");
	}


	// anything that gets loadmovie'd is just a movieclip.  There's no way to make it a component except by doing this
	function convertToUIObject(obj:MovieClip):Void
	{
	}

/**
* @private
* this gets called when the child is finished loading
* @param obj the loaded child
*/
	function childLoaded(obj:MovieClip):Void
	{
		convertToUIObject(obj);
	}

	// this never gets called, it just makes sure the external content module gets loaded
	static function extension()
	{
		mx.core.ExternalContent.enableExternalContent();
	}

}


