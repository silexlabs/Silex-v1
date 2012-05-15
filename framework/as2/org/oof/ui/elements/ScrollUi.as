/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.OofBase;
import mx.events.EventDispatcher;
import mx.transitions.Tween;
import mx.transitions.easing.*;
/** this is the base class for scroll bars. Derived bars must just specifiy 
 * if they are horizontal or vertical. 
 * CAUTION: bg_mc coordinates and position must be whole numbers, because startDrag takes onLy whole numbers, it seems
 * @author Ariel Sommeria-klein
 * */
class org.oof.ui.elements.ScrollUi extends mx.core.UIComponent{
	
	//UI
	var bg_mc:MovieClip;
	var knob_mc:MovieClip;
	var more_btn:Button;
	var less_btn:Button;
	
	private var _scrollTween:Tween;
	private var _pixelsToJumpOnClick:Number = 0;
	private var _easingDuration:Number = 0;
	private var _updateDuringDrag:Boolean = false;
	private var _initialValue:Number = 0;
	private var _hideButtonsWhenUnusable:Boolean = false;
	private var _hideBarAndKnob:Boolean = false;
	private var _scrollDim:String = null;
	private var _scrollDimSize:String = null; //width or height
	
	//this  is set when a user action takes precedence over whatever process might be updating the position
	private var _isOngoingUserAction:Boolean = false;

	//things get messy when the user clicks again before the first easing is over. So store destination 
	// of easing here, and take next easing from there
	private var _plannedKnobRestPos:Number = 0;
	
	//event functions
	var onChange:Function = null;
	var onKnobRelease:Function = null;
	var onKnobPress:Function = null;
	var onMoreClick:Function = null;
	var onLessClick:Function = null;
	
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function onLoad(){
 		super.onLoad();
		less_btn.onRelease = Delegate.create(this,less);
		more_btn.onRelease = Delegate.create(this,more);
		knob_mc.onPress = Delegate.create(this,knobStartDrag);
		knob_mc.onRelease = Delegate.create(this,knobStopDrag);
		knob_mc.onReleaseOutside = Delegate.create(this,knobStopDrag);
		bg_mc.onPress = Delegate.create(this, bgPress);
		position = _initialValue;
		updateButtonsVisibility();
		if(_hideBarAndKnob){
			knob_mc._visible = false;
			bg_mc._visible = false;
		}
		_plannedKnobRestPos = bg_mc[_scrollDim];
		
	}
	
	function updateButtonsVisibility(){
		if(_hideButtonsWhenUnusable){
			if(knob_mc[_scrollDim] - bg_mc[_scrollDim] == 0){
				less_btn._visible = false;
			}else{
				less_btn._visible = true;
			}
			if(knob_mc[_scrollDim] - bg_mc[_scrollDimSize] - bg_mc[_scrollDim]== 0){
				more_btn._visible = false;
			}else{
				more_btn._visible = true;
			}
		}
		
	}
	
	function knobStartDrag() {
		_isOngoingUserAction = true;
		if(_scrollDim == "_y"){
			knob_mc.startDrag(true, knob_mc._x, bg_mc._y, knob_mc._x, bg_mc._height + bg_mc._y);
		}else{
			knob_mc.startDrag(true, bg_mc._x, knob_mc._y, bg_mc._width + bg_mc._x, knob_mc._y);
		}
		_scrollTween.stop();
		onMouseMove = Delegate.create(this,knobMove);
		if(onKnobPress)
			onKnobPress();
		dispatchEvent({target:this, type:"knobPress"});			
	}
	
	function knobMove() {
		if(_updateDuringDrag){
			if(onChange)
				onChange();
			dispatchEvent({target:this, type:"change"});			
		}
	}
	
	function endKnobMove(){
		_isOngoingUserAction = false;
		if(onChange)
			onChange();
		dispatchEvent({target:this, type:"change"});			
		updateButtonsVisibility();
		
	}
	function knobStopDrag(){
		knob_mc.stopDrag();
		onMouseMove = null;
		endKnobMove();
		if(onKnobRelease)
			onKnobRelease();
		dispatchEvent({target:this, type:"knobRelease"});			
	}

	function less() {
		var startPoint:Number = knob_mc[_scrollDim];
		if(_isOngoingUserAction){
			startPoint = _plannedKnobRestPos;
		}
		_isOngoingUserAction = true;
		var fullJumpPos = startPoint - _pixelsToJumpOnClick;
		var scrollBarLimit = bg_mc[_scrollDim];
		updatePositionFromUi(Math.max(fullJumpPos, scrollBarLimit));
		if(onLessClick)
			onLessClick();
		dispatchEvent({target:this, type:"lessClick"});			
	}
	
	function more() {
		var startPoint:Number = knob_mc[_scrollDim];
		if(_isOngoingUserAction){
			startPoint = _plannedKnobRestPos;
		}
		_isOngoingUserAction = true;
		var fullJumpPos = startPoint + _pixelsToJumpOnClick;
		var scrollBarLimit = bg_mc[_scrollDim] + bg_mc[_scrollDimSize];
		updatePositionFromUi(Math.min(fullJumpPos, scrollBarLimit));
		dispatchEvent({target:this, type:"moreClick"});			
		if(onMoreClick)
			onMoreClick();
	}
	
	function bgPress(){
		
		//look at _ymouse or _xmouse
		if(this[_scrollDim + "mouse"] > knob_mc[_scrollDim]){
			more();
		}else{
			less();
		}
		
	}
	function get position():Number{
		var val = (knob_mc[_scrollDim]  - bg_mc[_scrollDim]) / bg_mc[_scrollDimSize];
		
		return val;
	}
	
	
	//used by ui functions to set position. internal onLy
	private function updatePositionFromUi(val:Number){
		if(_scrollTween != null){
			_scrollTween.stop();
		}
		_scrollTween = new Tween(knob_mc, _scrollDim, Strong.easeOut, knob_mc[_scrollDim], val, _easingDuration, true);
		_plannedKnobRestPos = val;
		_scrollTween.onMotionChanged = Delegate.create(this, knobMove);
		_scrollTween.onMotionFinished = Delegate.create(this, endKnobMove);
		
	}
	/** function set position
	/* used by outside process to set position
	/* @param val between 0 and 1
	*/
	function set position(val:Number){ 
		//update onLy if no user action
		if(!_isOngoingUserAction){
			knob_mc[_scrollDim] = bg_mc[_scrollDimSize] * val + bg_mc[_scrollDim];
			updateButtonsVisibility();
		}
		
	}
/*
//this doesn't work properly because sample buttons aren't properly positionned. need _x and _y to be 0 for everything

	function size(){
		less_btn[_scrollDim] = 0;
		bg_mc[_scrollDim] = less_btn[_scrollDimSize];
		//shrink or stretch bg_mc
		bg_mc[_scrollDimSize] = this[_scrollDimSize] - less_btn[_scrollDimSize] - more_btn[_scrollDimSize];
		
		knob_mc[_scrollDim] = bg_mc[_scrollDim];
		more_btn[_scrollDim] = bg_mc[_scrollDim] + bg_mc[_scrollDimSize];
	}
*/	
	/**
	 * Get the value of pixelsToJumpOnClick
	 * @return The value of pixelsToJumpOnClick
	 */ 
	[Inspectable(name="step size in pixels", type = Number,defaultValue = 100,name="pixels to jump on click")]
	public function get pixelsToJumpOnClick() : Number {
		return _pixelsToJumpOnClick;
	}
	
	/**
	 * Set the value of pixelsToJumpOnClick
	 * @param ppixelsToJumpOnClick The value to set pixelsToJumpOnClick to
	 */ 
	public function set pixelsToJumpOnClick(ppixelsToJumpOnClick : Number) : Void {
		_pixelsToJumpOnClick = ppixelsToJumpOnClick;
		
	}
	
	/**
	 * Get the value of easingDuration
	 * @return The value of easingDuration
	 */ 
	[Inspectable(name="easing duration", type = Number,defaultValue = 0.5)]
	public function get easingDuration() : Number {
		return _easingDuration;
	}
	
	/**
	 * Set the value of easingDuration
	 * @param peasingDuration The value to set easingDuration to
	 */ 
	public function set easingDuration(peasingDuration : Number) : Void {
		_easingDuration = peasingDuration;
		
	}
	
	/** function set updateDuringDrag
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="smooth drag", type=Boolean,defaultValue=false)]
	public function set updateDuringDrag(val:Boolean){
		_updateDuringDrag = val;
	}
	
	/** function get updateDuringDrag
	* @returns Boolean
	*/
	
	public function get updateDuringDrag():Boolean{
		return _updateDuringDrag;
	}		

	/**
	 * Get the value of initialValue
	 * @return The value of initialValue
	 */ 
	[Inspectable(name="initial scroll position", type = Number,defaultValue = 0,name="initial value(0 to 1)")]
	public function get initialValue() : Number {
		return _initialValue;
	}
	
	/**
	 * Set the value of initialValue
	 * @param val The value to set initialValue to
	 */ 
	public function set initialValue(val : Number) : Void {
		_initialValue = val;
		
	}
	
	/** function set hideButtonsWhenUnusable
	* @param val(Boolean)
	* @returns void
	*/
	//not sure if this is a good idea. keep it for now but don't show it in component inspector
	[Inspectable(name = "hide buttons when unusable", type = Boolean, defaultValue = false)]
	public function set hideButtonsWhenUnusable(val:Boolean){
		_hideButtonsWhenUnusable = val;
	}
	
	/** function get hideButtonsWhenUnusable
	* @returns Boolean
	*/
	
	public function get hideButtonsWhenUnusable():Boolean{
		return _hideButtonsWhenUnusable;
	}		
		
	/** function set hideBarAndKnob
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name = "hide bar and knob", type = Boolean, defaultValue = false)]
	public function set hideBarAndKnob(val:Boolean){
		_hideBarAndKnob = val;
	}
	
	/** function get hideBarAndKnob
	* @returns Boolean
	*/
	
	public function get hideBarAndKnob():Boolean{
		return _hideBarAndKnob;
	}		
		
	
}
