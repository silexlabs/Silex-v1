/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import com.gskinner.events.GDispatcher;
import org.silex.core.Utils;
/**
* UIComponent class
* - Resizes by sizing and positioning internal components
* - events
* - doLater and onLoad
*
* @tiptext Base class for all components
*/
class org.silex.ui.UIComponent extends MovieClip
{

	////////////////////////////
	// Group: EventDispatcher mixin
	////////////////////////////
	var addEventListener:Function;
 	var removeEventListener:Function;
    var dispatchEvent:Function
	
	// whether the component needs to be drawn
	private var invalidateFlag:Boolean = false;
	/**
	 * reference to silex api used in Silex components
	 */
	//var silexInstance:org.silex.core.Api;
	/**
	 * reference to silex api used in Oof components
	 */
	//static private var silexPtr:org.silex.core.Api;
	
	/**
	 *
	 */
	private var doLaterCallbackDelegate:Function;
	 	
	/**
	 * UNUSED FOR NOW - list of clip parameters to check at init
	 */
	var clipParameters:Object = {};
	
	/**
	* width of object
	* Read-Only:  use setSize() to change.
	*/
	function get width():Number
	{
		return __width;
	}

	/**
	* height of object
	* Read-Only:  use setSize() to change.
	*/
	function get height():Number
	{
		return __height;
	}
	var __width:Number;
	var __height:Number;


/**
* move the object
*
* @param	x	left position of the object
* @param	y	top position of the object
* @param	noEvent	if true, doesn't broadcast "move" event
*
* @tiptext Moves the object to the specified location
* @helpid 3970
*/
	function move(x:Number, y:Number, noEvent:Boolean):Void
	{
		var oldX:Number = _x;
	  	var oldY:Number = _y;

		_x = x;
		_y = y;

		if (noEvent != true)
		{
			dispatchEvent({type:"move", oldX:oldX, oldY:oldY});
		}
	}

/**
* size the object
*
* @param	w	width of the object
* @param	h	height of the object
* @param	noEvent	if true, doesn't broadcast "resize" event
*
* @tiptext Resizes the object to the specified size
* @helpid 3976
*/
	function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		var oldWidth:Number = __width;
	  	var oldHeight:Number = __height;

		__width = w;
		__height = h;

		size();

		if (noEvent != true)
		{
			dispatchEvent({type:"resize", oldWidth:oldWidth, oldHeight:oldHeight});
		}
	}

/**
* @private
* size the object.  called by setSize().  Components should implement this method
* to layout their contents.  The width and height properties are set to the
* new desired size by the time size() is called.
*/
	// default is to scale object.  override to do something more intelligent
	function size(Void):Void
	{
		_width = __width;
		_height = __height;
	}

    /**
	 * function constructor
	 * @return void
	 */
     public function UIComponent()
     {
		__width = _width;
		__height = _height;

		//eventDispatcher
		GDispatcher.initialize(this);
		
		doLaterCallbackDelegate = Utils.createDelegate(this,doLaterCallback);
		
		//this bit about silex should be in a static constructor :-(
/*		var globalSilex = _global.getSilex(this);
		if(globalSilex != null){
			silexPtr = globalSilex;
		}else{
			silexPtr = new org.silex.core.Api;
		}
		silexInstance = silexPtr;
*/		
		// call the onLoad function later
		doLater(onLoad);
     }
     /**
      * call a function in the next frame
      */
     public function doLater(delegatedCallback,numberOfFrames)
     {
     	// default
     	if (numberOfFrames == undefined) numberOfFrames = 1;
		_global.getSilex(this).doInNFrames(numberOfFrames,doLaterCallbackDelegate,delegatedCallback);
    }
    public function doLaterCallback(delegatedCallback)
    {
    	var delegatedCallbackDelegate = Utils.createDelegate(this,delegatedCallback);
    	delegatedCallbackDelegate();
    	Utils.removeDelegate(this,delegatedCallback);
    }
    /**
     * onLoad is executed after all sub components are created (1 frame after constructor)
     */
	public function onLoad(){
		_onLoad();
	}
    /**
     * onLoad is executed after all sub components are created (1 frame after constructor)
     */
	public function _onLoad(){
//		invalidate();
		redraw();
	}
/**
* @private
* draw the object.  Called by redraw() which is called explicitly or
* by the system if the object is invalidated.
* Each component should implement this method and make subobjects visible and lay them out.
* Most components do the layout by calling their size() method.
*/
	function draw(Void):Void
	{
	}



/**
* mark component so it will get drawn later
* @tiptext Marks an object to be redrawn on the next frame interval
* @helpid 3966
*/
	function invalidate(Void):Void
	{
		invalidateFlag = true;
		doLater(redraw);
	}

/**
* redraws object if you couldn't wait for invalidation to do it
*
* @param bAlways	if False, doesn't redraw if not invalidated
* @tiptext Redraws an object immediately
* @helpid 3971
*/
	function redraw(bAlways:Boolean):Void
	{
		if (invalidateFlag || bAlways)
		{
			invalidateFlag = false;
			draw();
		}
	}
}
