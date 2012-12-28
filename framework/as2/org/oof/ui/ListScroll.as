/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.utils.Delegate;
import org.oof.ui.elements.ScrollUi;
/*
	this file is part of OOF
	OOF : Open Source Open Minded Flash Components

	OOF is (c) 2008 Alexandre Hoyau and Ariel Sommeria-Klein. It is released under the GPL License:

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License (GPL)
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
	
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this component is a scroll bar for lists. Not sure if this is still necessary,
 * as there such functionalities and more in ListUi.
 * @author Ariel Sommeria-klein
 * */
 
class org.oof.ui.ListScroll extends OofBase{
	// UI
	var scrollUi:ScrollUi;
	
	private var _list:Object = null;
	private var _listPath:String = null;
	private var _isHorizontal:Boolean;
	private var _scrollStep = 1;
	
	public function ListScroll():Void
	{
		typeArray.push("org.oof.ui.ListScrollBar");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		scrollUi.addEventListener("change", Delegate.create(this, onScrollUiMove));
		tryToLinkWith(_listPath, Delegate.create(this, doOnListFound));
		
	}
	
	function onScrollUiMove(){
		setListPos(scrollUi.position);
	}
	
	function getListItemsPerRow():Number{
		var itemsPerRow:Number = _list.itemsPerRow;
		if(itemsPerRow == undefined){
			//default for nearly all lists
			itemsPerRow = 1;
		}
		return itemsPerRow;
		
	}
	//scrollui position is between 0 and 1. list position is between 0 and the number of items.
	//for convenience use these functions to get and set the list position, with values between
	//0 and 1
	function getListPos():Number{
		if(!_isHorizontal){
			return _list.vPosition / _list.length;
		}else{
			return _list.hPosition / _list.length;
		}
	}
	
	function setListPos(val:Number){
		if(!_isHorizontal){
			_list.vPosition = val * _list.length;
		}else{
			_list.hPosition = val * _list.length;
		}
	}
	
	 /** function doOnListFound
	*@returns void
	*/
	function doOnListFound(target:Object){
		_list = target;
		
		_list.addEventListener("scroll", Delegate.create(this, redraw));
		_list.addEventListener("change", Delegate.create(this, redraw));
		_list.addEventListener("draw", Delegate.create(this, redraw));
		redraw();
	}
	

	
	function redraw(evtObj:Object ) {
		super.redraw();
		
		var itemsPerRow:Number = _list.itemsPerRow;
		scrollUi.position = getListPos();
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
	
	/** function set isHorizontal
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name = "list is horizontal", type = Boolean, defaultValue = false)]
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