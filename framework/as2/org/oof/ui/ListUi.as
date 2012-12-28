/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.utils.Delegate;
import mx.transitions.Tween;
import mx.transitions.easing.*;

/** this component is a user interface for lists. It allows you to move up and down in the list,
 * either with a scroll bar and/or buttons.
 * If the list is not derived from oofbase, 
 * use a finder(org.oof.util.Finder)with it, otherwise it won't be possible for listUi 
 * to link with it.
 * it has 4 buttons for scrolling, one next and one previous button. 
 * it also looks for an included bg_mc to hide when then list doesn't need a scroll. 
 * so if you want your background to disappear when the list doesn't need any scroll buttons, call it bg_mc
 *
 * @author Ariel Sommeria-klein
 * */
 /*
*/
class org.oof.ui.ListUi extends OofBase{
	// UI
	var next_btn:Button;
	var previous_btn:Button;
	var scrollUp_btn:Button;
	var scrollDown_btn:Button;
	var scrollLeft_btn:Button;
	var scrollRight_btn:Button;
	var bg_mc:MovieClip;

	private var _list:Object = null;
	private var _listPath:String = null;
	private var _loopList:Boolean = false;
	private var _isHorizontal:Boolean;
	private var _scrollStep = 1;
	
	
	public function ListUi(){
		super();
		_className = "org.oof.ui.ListUi";
		typeArray.push("org.oof.ui.ListUi");
	}
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		next_btn.onRelease = Delegate.create(this, nextItem);
		previous_btn.onRelease = Delegate.create(this, previousItem);
		scrollUp_btn.onRelease = Delegate.create(this, scrollUp);
		scrollDown_btn.onRelease = Delegate.create(this, scrollDown);
		scrollLeft_btn.onRelease = Delegate.create(this, scrollLeft);
		scrollRight_btn.onRelease = Delegate.create(this, scrollRight);

		//start invisible
		next_btn._visible = false;
		previous_btn._visible = false;
		scrollLeft_btn._visible = false;
		scrollRight_btn._visible = false;
		scrollUp_btn._visible = false;
		scrollDown_btn._visible = false;
		bg_mc._visible = false;
		tryToLinkWith(_listPath, Delegate.create(this, doOnListFound));
		
	}
	 /** function doOnListFound
	*@returns void
	*/
	function doOnListFound(target:Object){
		_list = target;

		next_btn._visible = true;
		previous_btn._visible = true;
		_list.addEventListener("scroll", Delegate.create(this, redraw));
		_list.addEventListener("change", Delegate.create(this, redraw));
		_list.addEventListener("draw", Delegate.create(this, redraw));
		_list.addEventListener("modelChanged", Delegate.create(this, redraw));
		invalidate();
	}
	
	private function updateButtonsVisibility():Void{
		var itemsPerRow:Number = _list.itemsPerRow;
		if(itemsPerRow == undefined){
			//default for nearly all lists
			itemsPerRow = 1;
		}
		
		if(_list.length == undefined){
			//list not properly there yet, do quick update
			scrollLeft_btn._visible = false;
			scrollRight_btn._visible = false;
			scrollUp_btn._visible = false;
			scrollDown_btn._visible = false;
			bg_mc._visible = false;
			return;
		}
		
		var showLeft:Boolean = false;
		var showRight:Boolean = false;
		var showUp:Boolean = false;
		var showDown:Boolean = false;
		//vPosition is a whole number, and goes from 0 to list.length - the number of visible items
		//same for hPosition
		var maxPos:Number = getMaxPos();
		if (!maxPos) {
			//list not ready. come back later
			invalidate();
		}
		
		
		if(_isHorizontal){
			if(_list.hPosition > 0){
				showLeft = true;
			}
			if(_list.hPosition < maxPos){
				showRight = true;
			}
		}else{
			if(_list.vPosition > 0){
				showUp = true;
			}
			if(_list.vPosition < maxPos){
				showDown = true;
			}
				
		}

		scrollLeft_btn._visible = showLeft;
		scrollRight_btn._visible = showRight;
		scrollUp_btn._visible = showUp;
		scrollDown_btn._visible = showDown;			
		bg_mc._visible = showLeft ||showRight || showUp || showDown;
		
	}
	
	function redraw(evtObj:Object ) {
		super.redraw();
		updateButtonsVisibility();
	}
	////////////////////////////////////////
	//item selection
	////////////////////////////////////////
	/** function nextItem
	* called by next_btn
	*/
	function nextItem(){
		var index = _list.selectedIndex;
		if( index == undefined){
			_list.selectedIndex = 0;
		}else if(index == _list.length - 1){
			if(_loopList){
				_list.selectedIndex = 0;
			}else{
				return;
			}
		}else{
			_list.selectedIndex = index + 1;
		}
	}
	
	/** function previousItem
	* called by previous_btn
	*/
	function previousItem(){
		var index = _list.selectedIndex;
		if( index == undefined){
			_list.selectedIndex = _list.length - 1;
		}else if (index == 0){
			if(_loopList){
				_list.selectedIndex = _list.length - 1;
			}else{
				return;
			}
		}else{
			_list.selectedIndex = index - 1;
		}
	
	}
	
	
	function getItemsPerRow():Number{
		var itemsPerRow:Number = _list.itemsPerRow;
		if(itemsPerRow == undefined){
			//default for nearly all lists
			itemsPerRow = 1;
		}
		return itemsPerRow;
	}
	
	function getNumVisibleItems():Number{
		var limitingDimLength:Number;
		if(!_isHorizontal){
			limitingDimLength = _list.height;
		}else{
			limitingDimLength = _list.width;
		}
		var ret:Number = Math.floor(getItemsPerRow() * limitingDimLength / _list.rowHeight);
		//tyu("getNumVisibleItems", ret);
		return ret;
	}
	
	function getMaxPos():Number{
		var itemsPerRow:Number = getItemsPerRow();
		//round up to full rows
		var maxPos:Number = Math.ceil((_list.length - getNumVisibleItems()) / itemsPerRow) * itemsPerRow; 
		
		return maxPos;
	}
	
	////////////////////////////////////////
	//scrolling
	////////////////////////////////////////
	/** function scrollUp
	* called by scrollUp_btn
	*/
	function scrollUp(){
		_list.vPosition = Math.max(0, _list.vPosition - _scrollStep);
		redraw();
	}

	/** function scrollDown
	* called by scrollDown_btn
	*/
	function scrollDown(){
		_list.vPosition = Math.min(getMaxPos(), _list.vPosition + _scrollStep);
		redraw();
	}
	
	/** function scrollLeft
	* called by scrollLeft_btn
	*/
	function scrollLeft() {
		_list.hPosition = Math.max(0, _list.hPosition - _scrollStep);
		redraw();
	}
	
	/** function scrollRight
	* called by scrollRight_btn
	*/
	function scrollRight(){
		_list.hPosition = Math.min(getMaxPos(), _list.hPosition + _scrollStep);
		redraw();
	}
	

	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** function set listPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="list (full path)",type=String, defaultValue="")]
	public function set listPath(val:String){
		_listPath = val;
	}
	
	/** function get listPath
	* @returns String
	*/
	
	public function get listPath():String{
		return _listPath;
	}		
	
	/** function set loopList
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type=Boolean, name="list loop", defaultValue=false)]
	public function set loopList(val:Boolean){
		_loopList = val;
	}
	
	/** function get loopList
	* @returns Boolean
	*/
	
	public function get loopList():Boolean{
		return _loopList;
	}		

	/** function set isHorizontal
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name = "horizontal", type = Boolean, defaultValue = false)]
	public function set isHorizontal(val:Boolean){
		_isHorizontal = val;
	}
	
	/** function get isHorizontal
	* @returns Boolean
	*/
	
	public function get isHorizontal():Boolean{
		return _isHorizontal;
	}		
		
	/**
	 * Get the value of scrollStep
	 * @return The value of scrollStep
	 */ 
	[Inspectable(type = Number,defaultValue = 1)]
	public function get scrollStep() : Number {
		return _scrollStep;
	}
	
	/**
	 * Set the value of scrollStep
	 * @param val The value to set scrollStep to
	 */ 
	public function set scrollStep(val : Number) : Void {
		_scrollStep = val;
		
	}
	
	
}