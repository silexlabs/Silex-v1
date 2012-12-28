/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.utils.Delegate;
/** this is a button that calls a method on a component when clicked. Mostly useful in Flash,
 * as in Silex there are commands. if the list is not derived from oofbase, so use a finder(org.oof.util.Finder)
 * with it, otherwise it won't be possible for listUi to link with it.
 * @author Alexandre Hoyau
 * */

class org.oof.ui.AutoListUi extends OofBase{
	static private var className:String = "org.oof.ui.AutoListUi";

	private var _list:Object = null;
	private var _listPath:String = null;
	private var _isHorizontal:Boolean;
	private var mouseListener:Object;
	private var desiredPosition:Number
	
	public function AutoListUi():Void
	{
		typeArray("org.oof.ui.AutoListUi");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tryToLinkWith(_listPath, Delegate.create(this, doOnListFound));
		mouseListener=new Object();
		mouseListener.onMouseMove=Delegate.create(this,checkMousePosition);
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
	
	function checkMousePosition (){
		
		if (_list._xmouse>0 && _list._ymouse>0 && _list._xmouse<_list.width && _list._ymouse<_list.height){
			setDesiredPosition()
			if(this.onEnterFrame==undefined){
				this.onEnterFrame= Delegate.create(this, refreshPosition);
			}
		}
	}
	function setDesiredPosition(){
		if(!_isHorizontal){
			var positionPercent=(_list._ymouse-_list._fixedRowHeight)/(_list.height-_list._fixedRowHeight*2)
			positionPercent=(positionPercent<0) ? 0 : positionPercent
			positionPercent=(positionPercent>1) ? 1 : positionPercent
			desiredPosition==-positionPercent*(_list.listContent._height-_list.mask_mc._height)
			
		}else{
			var positionPercent=(_list._xmouse-_list._fixedRowHeight)/(_list.width-_list._fixedRowHeight*2)
			positionPercent=(positionPercent<0) ? 0 : positionPercent
			positionPercent=(positionPercent>1) ? 1 : positionPercent
			desiredPosition=-positionPercent*(_list.listContent._width-_list.mask_mc._width)
		}
	}
	function refreshPosition(){
		var propToRefresh=(_isHorizontal) ? "_x":"_y"
		var distance=desiredPosition-_list.listContent[propToRefresh]
		_list.listContent[propToRefresh]+=distance*0.2
		if (Math.abs(distance)<0.3){
			delete this.onEnterFrame
		}
	}
	
	function redraw(evtObj:Object ) {
		super.redraw();
		if(!_isHorizontal){
			if (_list.listContent._height>_list.mask_mc._height){
				Mouse.addListener(mouseListener)
			}else{
				Mouse.removeListener(mouseListener)
				_list.listContent._y=0
			}
		}else{
			
			if (_list.listContent._width>_list.mask_mc._width){
				Mouse.addListener(mouseListener)
			}else{
				Mouse.removeListener(mouseListener)
				delete this.onEnterFrame
				_list.listContent._x=0
			}
		}
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
}