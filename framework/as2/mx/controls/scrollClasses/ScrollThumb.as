//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.skins.CustomBorder;

/**
* The thumb of the scrollbar is a custom button
*
* @helpid 3268
* @tiptext
*/
class mx.controls.scrollClasses.ScrollThumb extends CustomBorder
{

/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner = CustomBorder.symbolOwner;
/**
* name of this class
*/
	var className:String = "ScrollThumb";

	var gripSkin:String;
	var grip_mc:MovieClip;

	//keeps the thumb grip from moving on press
	var btnOffset:Number = 0;

	// stored values for the thumb parameters
	var ymin:Number;
	var ymax:Number;
	var datamin:Number;
	var datamax:Number;
	// last position of the thumb
	var lastY:Number;
	// how much the thumb has moved when being dragged
	var scrollMove:Number;

	var horizontal = false;

	var idNames = new Array("l_mc", "m_mc", "r_mc", "grip_mc");

	function ScrollThumb()
	{
	}

/**
* @private
* create child objects.
*/
	function createChildren(Void):Void
	{
		super.createChildren();
		useHandCursor=false;
	}

/**
* @private
* set the range of motion for the thumb.  How far it can move and what data values that covers
*/
	function setRange(_ymin:Number, _ymax:Number, _datamin:Number, _datamax:Number):Void
	{
		ymin = _ymin;
		ymax = _ymax;
		datamin = _datamin;
		datamax = _datamax;
	}

/**
* @private
* drag the thumb around and update the scrollbar accordingly
*/
	function dragThumb(Void):Void
	{
		scrollMove = _ymouse - lastY;
		scrollMove += _y;
		if (scrollMove < ymin) {
			scrollMove = ymin;
		}
		else if (scrollMove > ymax) {
			scrollMove = ymax;
		}
		_parent.isScrolling = true;
		_y = scrollMove;

		// in an ideal world, this would probably broadcast an event, however
		// this object is rather hardwired into a scroll bar so we'll just
		// have it tell the scroll bar to change its position
		var pos:Number = Math.round( (datamax - datamin)
												 * (_y - ymin) / (ymax - ymin)) + datamin;
		_parent.scrollPosition = pos;
		_parent.dispatchScrollEvent("ThumbTrack");

		updateAfterEvent();
	}

/**
* @private
* stop dragging the thumb around
*/
	function stopDragThumb(Void):Void
	{
		_parent.isScrolling = false;
		_parent.dispatchScrollEvent("ThumbPosition");
		_parent.dispatchScrollChangedEvent();
		delete onMouseMove;
	}

/**
* @private
* user pressed on the thumb, start tracking in case they drag it
*/
	function onPress(Void):Void
	{
		_parent.pressFocus();
		lastY = _ymouse;
		onMouseMove = dragThumb;
		super.onPress();
	}

/**
* @private
* user released the thumb so end dragging
*/
	function onRelease(Void):Void
	{
		_parent.releaseFocus();
		stopDragThumb();
		super.onRelease();
	}

/**
* @private
* user released the thumb outside so end dragging and change states
*/
	function onReleaseOutside(Void):Void
	{
		_parent.releaseFocus();
		stopDragThumb();
		super.onReleaseOutside();
	}

	function draw()
	{
		super.draw();
		if (grip_mc == undefined)
			setSkin(3, gripSkin);
	}

	function size()
	{
		super.size();
		grip_mc.move((width - grip_mc.width) / 2, (height - grip_mc.height) / 2);
	}
}
