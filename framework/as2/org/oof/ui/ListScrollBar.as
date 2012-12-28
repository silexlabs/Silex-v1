/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.utils.Delegate;
import org.oof.ui.ListUi;
import mx.transitions.Tween;
import mx.transitions.easing.*;
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
 
class org.oof.ui.ListScrollBar extends ListUi{
	// UI
	var handleBg_mc:MovieClip;
	var handle_mc:MovieClip;
	
	private var _suspendRedraw;
	
	public function ListScrollBar(){
		super();
		_className = "org.oof.ui.ListScrollBar";
		typeArray.push("org.oof.ui.ListScrollBar");
		_suspendRedraw = false;
	}	
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		handle_mc.onPress = Delegate.create(this,handleStartDrag);
		handle_mc.onRelease = Delegate.create(this,handleStopDrag);
		handle_mc.onReleaseOutside = Delegate.create(this,handleStopDrag);
		handleBg_mc.onPress = Delegate.create(this, bgPress);
		scrollUp_btn._visible = true;
		scrollDown_btn._visible = true;
		
		//override!
		if(_isHorizontal){
			scrollUp_btn.onRelease = Delegate.create(this, scrollLeft);
			scrollDown_btn.onRelease = Delegate.create(this, scrollRight);
		}else{
			scrollUp_btn.onRelease = Delegate.create(this, scrollUp);
			scrollDown_btn.onRelease = Delegate.create(this, scrollDown);
		}
	 }
	 
	 private function updateButtonsVisibility():Void{
		 //we don't want the list ui hide/show logic!
		 return;
		
	 }
	 
	function redraw(evtObj:Object ) {
		if(_suspendRedraw){
			return;
		}
		super.redraw();
		var heightProportion:Number = getNumVisibleItems() / _list.length;
		var maxPos:Number = getMaxPos();
		if(heightProportion > 1){
			heightProportion = 1;
		}
		
		//setting _visible directly doesn't work in silex! so do it for sub elements
		handle_mc._visible = handleBg_mc._visible = scrollUp_btn._visible = scrollDown_btn._visible = (heightProportion < 1);
		handle_mc._height = handleBg_mc._height * heightProportion;
		handle_mc._width = handleBg_mc._width;

		var yProportion:Number;
		if(!_isHorizontal){
			yProportion = _list.vPosition / maxPos;
		}else{
			yProportion = _list.hPosition / maxPos;
		}		
		handle_mc._y = handleBg_mc._y + (handleBg_mc._height - handle_mc._height) * yProportion;
		handle_mc._x = handleBg_mc._x;

	}
	
	private function handleStartDrag():Void {
		handle_mc.startDrag(false, handleBg_mc._x, handleBg_mc._y, handleBg_mc._x, handleBg_mc._height + handleBg_mc._y - handle_mc._height);
		onMouseMove = Delegate.create(this,handleMove);
		_suspendRedraw = true;
	}
	
	private function handleMove():Void {
		var position:Number = (handle_mc._y  - handleBg_mc._y) / (handleBg_mc._height - handle_mc._height);
		var pos:Number = Math.ceil(position * getMaxPos());
		if(!_isHorizontal){
			_list.vPosition = pos;
		}else{
			_list.hPosition = pos;
		}
		
	}
	
	private function handleStopDrag():Void{
		handle_mc.stopDrag();
		onMouseMove = null;
		_suspendRedraw = false;
	}
	
	
	private function bgPress():Void{
		if(_ymouse > handle_mc._y){
			if(_isHorizontal){
				scrollRight();
			}else{
				scrollDown();
			}
		}else{
			if(_isHorizontal){
				scrollLeft();
			}else{
				scrollUp();
			}
		}
		
	}	
	
}